{ ... }: {
    flake.nixosModules.hostPolygonMySql = { pkgs, ... }: {
        services.mysql = {
            enable = true;
            package = pkgs.mariadb;
            initialDatabases = [
                { name = "enterprice"; }
            ];
        };
    };
}