{ ... }: {
    flake.nixosModules.base = { lib, config, ... }: {
        options.theme = {
            hostIcon = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
            };
        };

        config = {
            environment.variables = { 
                HOST_ICON = lib.mkIf (config.theme.hostIcon != null) config.theme.hostIcon;
            };
        };
    };
}