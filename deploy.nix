{ self, inputs, ... }: {
    flake = {
        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy.lib;
    };
}