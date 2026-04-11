{inputs, ...}: {
    imports = [
        inputs.wrapper-modules.flakeModules.wrappers
    ];

    options = {
        flake = inputs.parts.lib.mkSubmoduleOptions {
            wrappedModules = inputs.nixpkgs.lib.mkOption {
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