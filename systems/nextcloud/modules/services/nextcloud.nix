{ pkgs, config, ... }: {
    services.nextcloud = {                
        enable = true;                   
        package = pkgs.nextcloud32;

        hostName = "0.0.0.0";

        config = {
            adminuser = config.sops.secrets."nextcloud/adminname".path;
            adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
        };
        
        config = {
            dbtype = "pgsql";
            dbhost = "/run/postgresql";
            dbname = "nextcloud";
            dbuser = "nextcloud";
        };

        extraApps = {
            inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
        };
        extraAppsEnable = true;
    };
}