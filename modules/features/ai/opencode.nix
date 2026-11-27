{ self, ... }: {
    flake.nixosModules.aiOpencode = { lib, config, pkgs, ... }: let
        s = self.settings;
        cfg = config.bytes.ai;

        md = ./md;

        rtkPlugin = pkgs.writeTextDir "index.ts" (builtins.readFile ./plugins/rtk/index.ts);

        local = command: { type = "local"; inherit command; };

        mcp = {
            nixos = local [ (lib.getExe pkgs.mcp-nixos) ];
            context7 = local [ (lib.getExe pkgs.context7-mcp) ];
            searxng = local [ (lib.getExe pkgs.mcp-searxng) ] // {
                environment.SEARXNG_URL = cfg.searxUrl;
            };
            playwright = local [ (lib.getExe pkgs.playwright-mcp) ];
            firefox-devtools = local [
                (lib.getExe pkgs.firefox-devtools-mcp)
                "--firefox-path" (lib.getExe pkgs.firefox)
                "--tool-preset" "developer"
            ];
            basic-memory = local [ "${pkgs.uv}/bin/uvx" "basic-memory" "mcp" ];
        };

        blockedCommands = [
            "sudo *" "rm -rf*" "rm -fr*" "mkfs*" "dd *"
            "parted*" "fdisk*" "wipefs*" "nixos-rebuild*" "deploy*"
            "shutdown*" "reboot*" "poweroff*" "halt*"
        ];

        opencodeConfig = (pkgs.formats.json { }).generate "opencode.json" {
            "$schema" = "https://opencode.ai/config.json";

            model = "openai/gpt-6.1-terra";

            default_agent = "plan";

            instructions = [ "${md}/instructions.md" "${md}/tooling.md" ];

            plugins = [ "${rtkPlugin}" "@tarquinen/opencode-dcp@latest" ];

            skills = [ "${md}/skills" ];

            lsp = true;

            mcp.servers = mcp;

            permissions = [
                { action = "edit"; resource = "*"; effect = "allow"; }
                { action = "webfetch"; resource = "*"; effect = "allow"; }
                { action = "shell"; resource = "*"; effect = "allow"; }
                { action = "subagent"; resource = "*"; effect = "deny"; }
            ] ++ map (agent: { action = "subagent"; resource = agent; effect = "allow"; }) [
                "build" "plan" "general" "explore"
            ] ++ map (resource: { action = "shell"; inherit resource; effect = "deny"; }) blockedCommands;

            agents = {
                build = {
                    mode = "all";
                    model = "openai/gpt-6-luna";
                };
                plan = {
                    mode = "all";
                    model = "openai/gpt-6.1-terra";
                };
                general = {
                    mode = "subagent";
                    model = "openai/gpt-6-luna";
                };
                explore = {
                    mode = "subagent";
                    model = "openai/gpt-6-luna";
                };
            };
        };

        wrapArgs = ''
            --set OPENCODE_CONFIG ${opencodeConfig} \
            --set HTTP_PROXY http://100.64.0.1:8888 \
            --set HTTPS_PROXY http://100.64.0.1:8888 \
            --set NO_PROXY localhost,127.0.0.1,::1,.bytes \
            --run 'if [ -r /run/secrets/opencode/go-api-key ]; then export OPENCODE_GO_API_KEY="$(cat /run/secrets/opencode/go-api-key)"; fi' \
            --set OPENCODE_DISABLE_LSP_DOWNLOAD true \
            --set OPENCODE_DISABLE_CLAUDE_CODE_PROMPT true \
            --set OPENCODE_DISABLE_CLAUDE_CODE_SKILLS true
        '';

        opencode = pkgs.symlinkJoin {
            name = "opencode-local";
            paths = [ pkgs.opencode ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
                wrapProgram $out/bin/opencode ${wrapArgs}
            '';
            inherit (pkgs.opencode) meta;
        };

        opencodeDesktop = pkgs.symlinkJoin {
            name = "opencode-desktop-local";
            paths = [ pkgs.opencode-desktop ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
                wrapProgram $out/bin/opencode-desktop ${wrapArgs}
            '';
            inherit (pkgs.opencode-desktop) meta;
        };
    in {
        sops.secrets."opencode/go-api-key" = {
            owner = s.users.main;
            mode = "0400";
        };

        environment.systemPackages = [ opencode opencodeDesktop pkgs.rtk ];
    };
}
