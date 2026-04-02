{ ... }: {
    flake.nixosModules.hostPolygonMySql = { pkgs, ... }: {
        services.mysql = {
            enable = true;
            package = pkgs.mariadb;
            initialDatabases = [
                { name = "enterprice"; }
            ];
            initialScript = pkgs.writeText "mariadb-init.sql" ''
                -- Существующий пользователь databarsik
                CREATE USER IF NOT EXISTS 'databarsik'@'localhost' IDENTIFIED BY 'databarsik';
                GRANT ALL PRIVILEGES ON *.* TO 'databarsik'@'localhost' WITH GRANT OPTION;

                -- НОВЫЙ ПОЛЬЗОВАТЕЛЬ: mih4n
                -- Если нужно подключаться извне (через VPN по IP), замените 'localhost' на '%'
                CREATE USER IF NOT EXISTS 'mih4n'@'localhost' IDENTIFIED BY 'mih4n_secure_pass';
                GRANT ALL PRIVILEGES ON enterprice.* TO 'mih4n'@'localhost';
                
                FLUSH PRIVILEGES;

                USE enterprice;
                CREATE TABLE IF NOT EXISTS enterprice(
                    Bank_Name TEXT(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    City TEXT(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    State TEXT(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    Cert TEXT(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    Acquiring_Institution TEXT(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    Closing_Date VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
                    Fund VARCHAR(500) NOT NULL,
                    PRIMARY KEY(Fund)
                );
            '';
        };
    };
}