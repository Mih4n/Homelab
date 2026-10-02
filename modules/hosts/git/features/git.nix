{ ... }: {
    flake.nixosModules.git = { lib, pkgs, config, ... }: let
        secrets = config.sops.secrets;
    in {
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
            };
        };

        services.gitea-actions-runner = {
            package = pkgs.forgejo-runner;
            instances.default = {
                enable = true;
                name = "monolith";
                url = "https://git.mih4n.xyz";

                tokenFile = secrets."forgejo/runner/token".path;
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
          ## uncomment this line to change an admin user which was already created
          # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        '';
    };
}
