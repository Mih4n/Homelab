{ ... }: {
    flake.nixosModules.netbird = { lib, config, ... }: {
        options.bytes.netbird = {
            managementUrl = lib.mkOption {
                type = lib.types.str;
                default = "https://netbird.mih4n.xyz";
                description = "URL of the self-hosted Netbird management server";
            };
            setupKeyFile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = "Path to a file containing a Netbird setup key, used for automated login";
            };
        };

        config = let
            cfg = config.bytes.netbird;
        in {
            services.netbird.enable = true;

            services.netbird.clients.default = {
                config.ManagementURL = cfg.managementUrl;

                login.enable = cfg.setupKeyFile != null;
                login.setupKeyFile = cfg.setupKeyFile;
                login.systemdDependencies = lib.optionals (cfg.setupKeyFile != null) [
                    "sops-install-secrets.service"
                ];
            };
        };
    };
}
