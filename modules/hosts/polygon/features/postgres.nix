{ ... }: {
    flake.nixosModules.hostPolygonPostgres = { ... }: {
        services.postgresql = {
            enable = true;
            dataDir = "/data/postgresql";
            enableTCPIP = true;

            authentication = ''
                # local connections (Unix socket)
                local   all             all                              trust

                # allow localhost TCP
                host    all             all             127.0.0.1/32     trust
                host    all             all             ::1/128          trust

                # allow your remote IP
                host    all             all             0.0.0.0/0        md5
                host    all             all             ::/0             md5
            '';
        }; 
    };
}