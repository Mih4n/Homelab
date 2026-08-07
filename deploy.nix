{ self, inputs, ... }: {
    options.flake.deploy.nodes = inputs.nixpkgs.lib.mkOption {
        type = inputs.nixpkgs.lib.types.lazyAttrsOf inputs.nixpkgs.lib.types.raw;
        default = {};
    };

    config.flake = {
        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy.lib;
    };
}