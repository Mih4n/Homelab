{ self, ... }: {
    flake.nixosModules.aiOpencode = { lib, config, pkgs, ... }: let
        s = self.settings;
        cfg = config.bytes.ai;

        md = ./md;
        prompt = files: lib.concatMapStringsSep "\n\n" (f: builtins.readFile "${md}/${f}") files;

        local = command: { type = "local"; inherit command; };

        mcp = {
            nixos = local [ (lib.getExe pkgs.mcp-nixos) ];
            context7 = local [ (lib.getExe pkgs.context7-mcp) ];
            searxng = local [ (lib.getExe pkgs.mcp-searxng) ] // {
                environment.SEARXNG_URL = cfg.searxUrl;
            };
            # markitdown = local [ (lib.getExe pkgs.markitdown-mcp) ];  # broken: failing tests in speechrecognition/pdfplumber deps
            playwright = local [ (lib.getExe pkgs.playwright-mcp) ];
            basic-memory = local [ "${pkgs.uv}/bin/uvx" "basic-memory" "mcp" ];
            # rag = local [ "${pkgs.uv}/bin/uvx" "mcp-server-qdrant" ] // {
            #     environment = {
            #         QDRANT_URL = cfg.rag.qdrantUrl;
            #         COLLECTION_NAME = cfg.rag.collection;
            #         EMBEDDING_MODEL = cfg.rag.embeddingModel;
            #     };
            # };
        };

        bash = {
            "*" = "allow";
            "git push*" = "deny";
            "sudo *" = "deny";
            "rm -rf*" = "deny";
            "rm -fr*" = "deny";
            "mkfs*" = "deny";
            "dd *" = "deny";
            "parted*" = "deny";
            "fdisk*" = "deny";
            "wipefs*" = "deny";
            "nixos-rebuild*" = "deny";
            "deploy*" = "deny";
            "shutdown*" = "deny";
            "reboot*" = "deny";
            "poweroff*" = "deny";
            "halt*" = "deny";
        };

        readOnly = { edit = "deny"; inherit bash; };
        editAgent = { edit = "allow"; inherit bash; };

        noMcp = lib.genAttrs (map (name: "${name}_*") (lib.attrNames mcp)) (_: "deny");
        withMcp = names: lib.genAttrs (map (name: "${name}_*") names) (_: "allow");

        subagent = name: model: description: permission: {
            mode = "subagent";
            inherit description permission model;
            prompt = prompt [ "agents/${name}.md" ];
        };

        models = lib.mapAttrs (id: name: {
            inherit name;
            attachment = true;
            reasoning = true;
            tool_call = true;
            modalities = {
                input = [ "text" ];
                output = [ "text" ];
            };
            limit = {
                context = 128000;
                output = 16384;
            };
        }) {
            "deepseek-v4-pro" = "DeepSeek V4 Pro";
            "deepseek-v4.1-flash" = "DeepSeek V4.1 Flash";
        };

        opencodeConfig = (pkgs.formats.json { }).generate "opencode.json" {
            "$schema" = "https://opencode.ai/config.json";

            provider.opencode-go = {
                npm = "@ai-sdk/openai-compatible";
                name = "OpenCode Go";
                options = {
                    baseURL = "https://opencode.ai/inference/go/openai/v1";
                    apiKey = "{env:OPENCODE_GO_API_KEY}";
                };
                inherit models;
            };

            model = cfg.models.thinking;
            small_model = cfg.models.execution;

            instructions = [ "${md}/instructions.md" ];

            skills.paths = [ "${md}/skills" ];

            lsp = true;

            inherit mcp;

            permission = {
                edit = "allow";
                webfetch = "allow";
                inherit bash;
            } // noMcp;

            agent = {
                writer = {
                    mode = "primary";
                    model = cfg.models.thinking;
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

                builder = subagent "builder" cfg.models.execution
                    "Builds documents: compiles Typst, converts to docx and PDF, renders diagrams and charts. Reports errors with file and line."
                    editAgent;

                reader = subagent "reader" cfg.models.execution
                    "Extracts text, tables and figures from PDF, scans, images and office files into markdown."
                    editAgent;

                proofreader = subagent "proofreader" cfg.models.execution
                    "Checks a document against GOST and guide 4334: formatting, numbering, references, spelling. Reports, does not edit."
                    readOnly;

                planner = subagent "planner" cfg.models.thinking
                    "Splits a task into ordered steps with the files to touch and how to verify each step. Does not edit."
                    readOnly;

                reviewer = subagent "reviewer" cfg.models.thinking
                    "Reviews the current diff for bugs, security problems and missed edge cases. Does not edit."
                    readOnly;

                researcher = subagent "researcher" cfg.models.thinking
                    "Searches the web, documentation and the document archive, answers with sources formatted by GOST 7.1."
                    (readOnly // withMcp [ "searxng" "context7" ]);

                memory = subagent "memory" cfg.models.execution
                    "Long-term notes in ~/basic-memory: saves facts about the user and projects, finds what was saved before."
                    (readOnly // withMcp [ "basic-memory" ]);

                debugger = subagent "debugger" cfg.models.execution
                    "Reproduces a bug, finds the root cause and applies the smallest fix."
                    editAgent;

                tester = subagent "tester" cfg.models.execution
                    "Writes and runs tests for the given code and reports failures."
                    editAgent;

                web = subagent "web" cfg.models.execution
                    "Opens the web app in a browser with Playwright, checks layout on screenshots and console errors."
                    (editAgent // withMcp [ "playwright" ]);

                nix = subagent "nix" cfg.models.execution
                    "NixOS and flake work: options, packages, modules of this configuration."
                    (editAgent // withMcp [ "nixos" ]);
            };
        };

        opencode = pkgs.symlinkJoin {
            name = "opencode-local";
            paths = [ pkgs.opencode ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
                wrapProgram $out/bin/opencode \
                    --set OPENCODE_CONFIG ${opencodeConfig} \
                    --run 'if [ -r /run/secrets/opencode/go-api-key ]; then export OPENCODE_GO_API_KEY="$(cat /run/secrets/opencode/go-api-key)"; fi' \
                    --set OPENCODE_DISABLE_LSP_DOWNLOAD true \
                    --set OPENCODE_DISABLE_CLAUDE_CODE_PROMPT true \
                    --set OPENCODE_DISABLE_CLAUDE_CODE_SKILLS true
            '';
            inherit (pkgs.opencode) meta;
        };
    in {
        # services.qdrant.enable = true;  # broken: qdrant package missing zstd buildInput

        sops.secrets."opencode/go-api-key" = {
            owner = s.users.main;
            mode = "0400";
        };

        environment.systemPackages = [ opencode ];
    };
}
