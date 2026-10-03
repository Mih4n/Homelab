{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.nextcloudServer = { config, pkgs, ... }: {
        services.nextcloud = {
            enable = true;
            https = true;
            package = pkgs.nextcloud35;
            hostName = "localhost";
            configureRedis = true;
            config = {
                dbtype = "sqlite";
                adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
            };
            datadir = "/byteshaker/media/nextcloud";
            # 100.64.0.8 — tailnet-адрес git-хоста, у nextcloud 100.64.0.4;
            # оставлено как было, менять вслепую не стал
            settings.trusted_domains = [ s.domains.cloud s.net.ips.nextcloud "100.64.0.8" ];
        };
    };
}
