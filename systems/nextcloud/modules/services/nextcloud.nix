{ pkgs, config, ... }: {
    services.nextcloud = {                
        enable = true;                   
        package = pkgs.nextcloud28;
        
        config = {
            dbtype = "pgsql";
            dbhost = "/run/postgresql";
            dbname = "nextcloud";
            dbuser = "nextcloud";

            hostName = "0.0.0.0";
            settings = {
                adminuser = config.sops.secrets."nextcloud/adminname".path; 
                adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
            };
        };

        extraApps = {
            inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
        };
        extraAppsEnable = true;
    };
}