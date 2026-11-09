{ inputs, self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.gitServer = { lib, pkgs, config, ... }: let
        secrets = config.sops.secrets;
    in {
        imports = [
            inputs.sops.nixosModules.sops
        ];

        sops.secrets."forgejo/adminpass".owner = "forgejo";
        sops.secrets."forgejo/runner/token".owner = "forgejo";
        sops.secrets."forgejo/oidc-client-secret".owner = "forgejo";

        services.forgejo = {
            enable = true;
            lfs.enable = true;
            database.type = "postgres";

            settings = {
                server = {
                    DOMAIN = s.domains.git;
                    ROOT_URL = "https://${s.domains.git}";
                    SSH_PORT = s.ports.forgejoSsh;
                    HTTP_PORT = s.ports.forgejoHttp;
                    SSH_DOMAIN = s.domains.git;
                    SSH_LISTEN_PORT = lib.head config.services.openssh.ports;
                };
                actions = {
                    ENABLED = true;
                    DEFAULT_ACTIONS_URL = "github";
                };
                oauth2_client = {
                    ENABLE_AUTO_REGISTRATION = true;
                    OPENID_CONNECT_SCOPES = "email profile";
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

        # services.forgejo-runner = {
        #     instances.default = {
        #         enable = true;
        #         url = "https://${s.domains.git}";

        #         secrets.server.connections.default.token_url = config.sops.secrets."forgejo/runner/token";
        #         settings.server.connections.default.uuid = "";

        #         labels = [
        #           "ubuntu-latest:docker://node:22-bookworm"
        #           "ubuntu-22.04:docker://node:22-bookworm"
        #           "ubuntu-20.04:docker://node:22-bookworm"
        #           "ubuntu-18.04:docker://node:22-bookworm"
        #         ];
        #     };
        # };

        systemd.services.forgejo.preStart = let
            user = s.users.main;
            pwd = secrets."forgejo/adminpass";
            adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        in ''
          ${adminCmd} create --admin --email "${s.emails.forgejo}" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
          # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        '';

        # The OAuth2 client secret must not end up in the Nix store, so the
        # source is created through the Forgejo CLI after the service starts.
        systemd.services.forgejo-oidc = {
            description = "Configure Forgejo Authentik OIDC source";
            after = [ "forgejo.service" ];
            requires = [ "forgejo.service" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                Type = "oneshot";
                User = config.services.forgejo.user;
                Group = config.services.forgejo.group;
                WorkingDirectory = config.services.forgejo.stateDir;
                Environment = [ "FORGEJO_WORK_DIR=${config.services.forgejo.stateDir}" ];
            };

            script = let
                forgejo = lib.getExe config.services.forgejo.package;
            in ''
                set -eu
                if ${forgejo} admin auth list 2>/dev/null | grep -q authentik; then
                    echo "Authentik auth source already exists"
                    exit 0
                fi
                ${forgejo} admin auth add-oauth \
                    --provider=openidConnect \
                    --name=authentik \
                    --key=${s.oidc.forgejo.clientId} \
                    --secret="$(cat ${secrets."forgejo/oidc-client-secret".path})" \
                    --auto-discover-url="https://${s.domains.auth}/application/o/forgejo/.well-known/openid-configuration" \
                    --scopes="openid email profile"
            '';
        };
    };
}
