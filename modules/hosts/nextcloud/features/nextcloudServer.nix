{ self, ... }: let
    ignore = self.nextcloud.ignore;
    s = self.settings;
in {
    flake.nixosModules.nextcloudServer = { config, lib, pkgs, ... }: {
        sops.secrets."nextcloud/oidc-client-secret".owner = "nextcloud";

        services.nextcloud = {
            enable = true;
            https = true;
            package = pkgs.nextcloud35;
            hostName = "localhost";
            configureRedis = true;
            extraApps = {
                user_oidc = pkgs.fetchNextcloudApp {
                    appName = "user_oidc";
                    appVersion = "8.13.0";
                    license = "agpl3Plus";
                    url = "https://github.com/nextcloud-releases/user_oidc/releases/download/v8.13.0/user_oidc-v8.13.0.tar.gz";
                    sha256 = "sha256-bxP6BHcUSmgS2GSGJsZM7pGAfR0LYMpBQkVDCGueJ3U=";
                };
            };
            config = {
                dbtype = "sqlite";
                # adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
            };
            datadir = "/byteshaker/media/nextcloud";
            # 100.64.0.8 — tailnet-адрес git-хоста, у nextcloud 100.64.0.4;
            # оставлено как было, менять вслепую не стал
            settings.trusted_domains = [ s.domains.cloud s.net.ips.nextcloud "100.64.0.8" ];
            # .htaccess — значение по умолчанию, список его заменяет, а не дополняет
            settings.forbidden_filenames = [ ".htaccess" ] ++ ignore.names;
            settings.forbidden_filename_extensions = [ ".filepart" ] ++ ignore.extensions;
        };

        # The client secret must not end up in the Nix store, so configure the
        # user_oidc provider through occ after Nextcloud is installed.
        systemd.services.nextcloud-oidc = {
            description = "Configure Nextcloud Authentik OIDC provider";
            after = [ "nextcloud-setup.service" "phpfpm-nextcloud.service" ];
            requires = [ "phpfpm-nextcloud.service" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
                Type = "oneshot";
                User = "nextcloud";
                Group = "nextcloud";
            };

            script = let
                occ = lib.getExe config.services.nextcloud.occ;
            in ''
                set -eu
                if ${occ} user_oidc:provider 2>/dev/null | grep -q authentik; then
                    echo "OIDC provider already exists"
                    exit 0
                fi
                ${occ} user_oidc:provider authentik \
                    --clientid=${s.oidc.nextcloud.clientId} \
                    --clientsecret="$(cat ${config.sops.secrets."nextcloud/oidc-client-secret".path})" \
                    --discoveryuri="https://${s.domains.auth}/application/o/nextcloud/.well-known/openid-configuration" \
                    --scope="openid profile email" \
                    --mapping-uid=preferred_username \
                    --mapping-display-name=name \
                    --mapping-email=email
            '';
        };
    };
}
