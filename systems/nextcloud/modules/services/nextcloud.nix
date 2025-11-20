{ pkgs, config, ... }: {
    services.nextcloud = {                
        enable = true;                   
        package = pkgs.nextcloud28;
        
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