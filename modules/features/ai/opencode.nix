{ self, ... }: {
    flake.nixosModules.aiOpencode = { lib, config, pkgs, ... }: let
        s = self.settings;
        cfg = config.bytes.ai;

        md = ./md;

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
            "git push*" "sudo *" "rm -rf*" "rm -fr*" "mkfs*" "dd *"
            "parted*" "fdisk*" "wipefs*" "nixos-rebuild*" "deploy*"
            "shutdown*" "reboot*" "poweroff*" "halt*"
        ];

        opencodeConfig = (pkgs.formats.json { }).generate "opencode.json" {
            "$schema" = "https://opencode.ai/config.json";

            instructions = [ "${md}/instructions.md" ];

            skills = [ "${md}/skills" ];

            lsp = true;

            mcp.servers = mcp;

            permissions = [
                { action = "edit"; resource = "*"; effect = "allow"; }
                { action = "webfetch"; resource = "*"; effect = "allow"; }
                { action = "shell"; resource = "*"; effect = "allow"; }
                { action = "subagent"; resource = "*"; effect = "deny"; }
            ] ++ map (resource: { action = "shell"; inherit resource; effect = "deny"; }) blockedCommands;

            agents = {
                general.disabled = true;
                explore.disabled = true;
            };
        };

        wrapArgs = ''
            --set OPENCODE_CONFIG ${opencodeConfig} \
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

        environment.systemPackages = [ opencode opencodeDesktop ];
    };
}
