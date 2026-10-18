{ ... }: {
    flake.nixosModules.base = { lib, ... }: {
        options.bytes.preferences = {
            editor = {
                type = lib.types.str;
                default = "code";
            };

            terminal = lib.mkOption {
                type = lib.types.str;
                default = "kitty";
            };

            autostart = lib.mkOption {
                type = lib.types.listOf (lib.types.either lib.types.str lib.types.package);
                default = [];
            };
        };
    };
}