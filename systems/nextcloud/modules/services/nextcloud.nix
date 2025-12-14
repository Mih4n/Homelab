{ pkgs, config, ... }: {
    services.nextcloud = {
        enable = true;
        https = true;
        package = pkgs.nextcloud32;
        hostName = "localhost";
        config = {
            dbtype = "sqlite";
            adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
        };
        datadir = "/byteshaker/media/nextcloud";
        settings.trusted_domains = [ "nextcloud.mih4n.xyz" "192.168.192.11" "100.64.0.8" ];
    };
}