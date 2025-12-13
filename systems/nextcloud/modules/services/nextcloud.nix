{ pkgs, config, ... }: {
    services.nextcloud = {                
        enable = true;                   
        package = pkgs.nextcloud32;

        hostName = "localhost";

        config = {
            adminuser = "mih4n";
            adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
 
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