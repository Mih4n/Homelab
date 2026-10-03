{ inputs, ... }: {
    flake.nixosModules.gitServer = { lib, pkgs, config, ... }: let
        secrets = config.sops.secrets;
    in {
        imports = [
            inputs.sops.nixosModules.sops
        ];

        sops.secrets."forgejo/adminpass".owner = "forgejo";
        sops.secrets."forgejo/runner/token".owner = "forgejo";

        services.forgejo = {
            enable = true;
            lfs.enable = true;
            database.type = "postgres";

            settings = {
                server = {
                    DOMAIN = "git.mih4n.xyz";
                    ROOT_URL = "https://git.mih4n.xyz";
                    HTTP_PORT = 3000;
                    SSH_PORT = lib.head config.services.openssh.ports;
                };
                actions = {
                    ENABLED = true;
                    DEFAULT_ACTIONS_URL = "github";
                };
                ui = {
                    DEFAULT_THEME = "gruvbox-auto";
                    THEMES = lib.concatStringsSep "," [
                        "gruvbox-auto" "gruvbox-light" "gruvbox-dark"
                        "forgejo-auto" "forgejo-light" "forgejo-dark"
                    ];
                };
            };
        };

        # Тема в духе mih4n.xyz: CSS, шрифты и логотип из ./theme кладутся в custom/public
        systemd.tmpfiles.rules = [
            "L+ '${config.services.forgejo.customDir}/public' - - - - ${./theme}"
        ];

        services.gitea-actions-runner = {
            package = pkgs.forgejo-runner;
            instances.default = {
                enable = true;
                name = "monolith";
                url = "https://git.mih4n.xyz";

                tokenFile = config.sops.templates."forgejo-runner.env".path;
                labels = [
                  "ubuntu-latest:docker://node:16-bullseye"
                  "ubuntu-22.04:docker://node:16-bullseye"
                  "ubuntu-20.04:docker://node:16-bullseye"
                  "ubuntu-18.04:docker://node:16-buster"
                ];
            };
        };

        systemd.services.forgejo.preStart = let
            user = "mih4n";
            pwd = secrets."forgejo/adminpass";
            adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        in ''
          ${adminCmd} create --admin --email "selfish@mih4n.xyz" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
          # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        '';
    };
}
