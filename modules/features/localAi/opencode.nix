{ inputs, ... }: {
    flake.nixosModules.localAiOpencode = { lib, config, pkgs, ... }: let
        cfg = config.bytes.localAi;
        model = cfg.model;

        provider = "llama-cpp";
        main = "${provider}/${model.id}";

        md = ./md;
        prompt = files: lib.concatMapStringsSep "\n\n" (f: builtins.readFile "${md}/${f}") files;

        allow = patterns: lib.genAttrs patterns (_: "allow");

        # Read-only commands every agent may run without asking.
        readOnly = allow [
            "ls*" "cat *" "head *" "tail *" "wc *" "grep *" "rg *" "fd *" "jq *"
            "git status*" "git diff*" "git log*" "git show*" "git blame*"
        ];

        # Document tools of @builder and @reader.
        documentTools = allow [
            "typst *" "typstyle *" "typlite *" "pandoc *" "soffice *"
            "pdftotext *" "pdftoppm *" "pdfinfo *" "pdfimages *" "ocrmypdf *"
            "tesseract *" "markitdown *" "qpdf *" "magick *"
            "d2 *" "mmdc *" "dot *" "plantuml *" "python3 *" "mkdir *"
        ];

        spelling = allow [ "hunspell *" "languagetool *" "harper-cli *" ];

        # The last matching rule wins, but Nix sorts the keys: `*` always
        # ends up first, so the other patterns must not overlap each other.
        bash = rules: { "*" = "ask"; } // readOnly // rules // {
            "git push*" = "deny";
            "git commit*" = "ask";
            "rm -rf *" = "deny";
            "sudo *" = "deny";
        };

        readOnlyAgent = extra: {
            edit = "deny";
            bash = { "*" = "deny"; } // readOnly // extra;
        };

        editAgent = rules: { edit = "allow"; bash = bash rules; };

        local = command: { type = "local"; inherit command; };
        mcp = {
            nixos = local [ (lib.getExe pkgs.mcp-nixos) ];
            context7 = local [ (lib.getExe pkgs.context7-mcp) ];
            searxng = local [ (lib.getExe pkgs.mcp-searxng) ] // {
                environment.SEARXNG_URL = "http://${cfg.host}:${toString cfg.searxPort}";
            };
            markitdown = local [ (lib.getExe pkgs.markitdown-mcp) ];
            # Not in nixpkgs. The notes are plain markdown in ~/basic-memory.
            basic-memory = local [ "${pkgs.uv}/bin/uvx" "basic-memory" "mcp" ];
            playwright = local [ (lib.getExe pkgs.playwright-mcp) ];
        };

        # MCP tools cost ~15k tokens of every request. The primary agents get
        # none, each subagent only the servers it works with.
        mcpTools = servers: allow (map (server: "${server}_*") servers);
        noMcp = lib.mapAttrs (_: _: "deny") (mcpTools (lib.attrNames mcp));

        # Without a model a subagent runs on the one of the agent that called it.
        subagent = name: description: permission: {
            mode = "subagent";
            inherit description permission;
            prompt = prompt [ "agents/${name}.md" ];
        };

        opencodeConfig = (pkgs.formats.json { }).generate "opencode.json" {
            "$schema" = "https://opencode.ai/config.json";

            provider.${provider} = {
                npm = "@ai-sdk/openai-compatible";
                name = "llama.cpp";
                options.baseURL = "http://${cfg.host}:${toString cfg.port}/v1";
                models.${model.id} = {
                    inherit (model) name;
                    attachment = true;
                    reasoning = true;
                    tool_call = true;
                    modalities = {
                        input = [ "text" "image" ];
                        output = [ "text" ];
                    };
                    limit = {
                        inherit (model) context output;
                    };
                };
            };

            model = main;
            small_model = main;

            instructions = [ "${md}/instructions.md" ];

            # Only the name and description of a skill sit in the prompt, the
            # model loads the rest with the skill tool when it needs it.
            skills.paths = [ "${md}/skills" ];

            # From the pinned checkout instead of npm: opencode would fetch the
            # package at startup. OpenCode 1 takes the file, not the directory.
            plugin = [ "${inputs.ponytail}/.opencode/plugins/ponytail.mjs" ];

            # Built-in servers, off unless enabled. They use the binaries the
            # lsp feature puts in PATH.
            lsp = true;

            inherit mcp;

            permission = {
                edit = "allow";
                webfetch = "allow";
                external_directory = "ask";
                doom_loop = "ask";
                bash = bash { };
            } // noMcp;

            agent = {
                # Writes the text only, everything that needs a shell goes to
                # @builder and @reader.
                writer = {
                    mode = "primary";
                    description = "Reports and documents in Typst: structure, text, formatting by GOST and guide 4334.";
                    prompt = prompt [ "agents/writer.md" "documents.md" ];
                    permission = {
                        edit = "allow";
                        bash = "deny";
                        task = {
                            "*" = "deny";
                            builder = "allow";
                            reader = "allow";
                            researcher = "allow";
                            proofreader = "allow";
                            memory = "allow";
                        };
                    };
                };

                builder = subagent "builder"
                    "Builds documents: compiles Typst, converts to docx and PDF, renders diagrams and charts. Reports errors with file and line."
                    (editAgent documentTools);

                reader = subagent "reader"
                    "Extracts text, tables and figures from PDF, scans, images and office files into markdown."
                    (editAgent documentTools // mcpTools [ "markitdown" ]);

                proofreader = subagent "proofreader"
                    "Checks a document against GOST and guide 4334: formatting, numbering, references, spelling. Reports, does not edit."
                    (readOnlyAgent (spelling // { "typst *" = "allow"; }));

                planner = subagent "planner"
                    "Splits a task into ordered steps with the files to touch and how to verify each step. Does not edit."
                    (readOnlyAgent { });

                reviewer = subagent "reviewer"
                    "Reviews the current diff for bugs, security problems and missed edge cases. Does not edit."
                    (readOnlyAgent { });

                researcher = subagent "researcher"
                    "Searches the web and documentation, answers with sources formatted by GOST 7.1."
                    (readOnlyAgent { } // mcpTools [ "searxng" "context7" ]);

                memory = subagent "memory"
                    "Long-term notes in ~/basic-memory: saves facts about the user and projects, finds what was saved before."
                    (readOnlyAgent { } // mcpTools [ "basic-memory" ]);

                debugger = subagent "debugger"
                    "Reproduces a bug, finds the root cause and applies the smallest fix."
                    (editAgent { });

                tester = subagent "tester"
                    "Writes and runs tests for the given code and reports failures."
                    (editAgent { });

                web = subagent "web"
                    "Opens the web app in a browser with Playwright, checks layout on screenshots and console errors."
                    (editAgent { } // mcpTools [ "playwright" ]);

                nix = subagent "nix"
                    "NixOS and flake work: options, packages, modules of this configuration."
                    (editAgent (allow [ "nix eval *" "nix search *" "nix flake show*" "nix flake check*" ])
                        // mcpTools [ "nixos" ]);
            };
        };
        # Set in the wrapper, not in environment.variables: those only reach
        # shells started after a re-login, and opencode then falls back to
        # its own cloud model.
        opencode = pkgs.symlinkJoin {
            name = "opencode-local";
            paths = [ pkgs.opencode ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            # NixOS cannot run the language servers opencode downloads, it
            # gets ours instead. ~/.claude holds Claude Code's own CLAUDE.md
            # and skills, ~3.5k tokens that only confuse the local model.
            postBuild = ''
                wrapProgram $out/bin/opencode \
                    --set OPENCODE_CONFIG ${opencodeConfig} \
                    --set OPENCODE_DISABLE_LSP_DOWNLOAD true \
                    --set OPENCODE_DISABLE_CLAUDE_CODE_PROMPT true \
                    --set OPENCODE_DISABLE_CLAUDE_CODE_SKILLS true
            '';
            inherit (pkgs.opencode) meta;
        };
    in {
        environment.systemPackages = [ opencode ];
    };
}
