{ inputs, ... }: {
    imports = [
        inputs.wrapper-modules.flakeModules.wrappers
        inputs.homeManager.flakeModules.default
    ];

    options = {
        flake = inputs.parts.lib.mkSubmoduleOptions {
            wrappedModules = inputs.nixpkgs.lib.mkOption {
                type = inputs.nixpkgs.lib.types.lazyAttrsOf inputs.nixpkgs.lib.types.raw;
                default = {};
            };
        };
    };

    config = {
        systems = [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
        ];
    };
}