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
                # netbird keeps ManagementURL in config.json as a serialised url.URL
                # object, so a plain string written through `config` makes the daemon
                # die on startup; passed as an env var it is the `netbird up` flag
                # instead, and the cli persists it in the format the daemon expects
                environment.NB_MANAGEMENT_URL = cfg.managementUrl;

                login.enable = cfg.setupKeyFile != null;
                login.setupKeyFile = cfg.setupKeyFile;
                login.systemdDependencies = lib.optionals (cfg.setupKeyFile != null) [
                    "sops-install-secrets.service"
                ];
            };
        };
    };
}
