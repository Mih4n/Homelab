{ ... }: {
    flake.nixosModules.hostPolygonSqlserver = { ... }: {
        virtualisation.oci-containers.containers."mssql" = {
            image = "mcr.microsoft.com/mssql/server:2025-latest";
            environment = {
                ACCEPT_EULA = "Y";
                MSSQL_SA_PASSWORD = "YourStrong!Passw1rd";
            };
            ports = [ "1433:1433" ];
            volumes = [ "/data/mssql:/var/opt/mssql" ];
        };
    };
}