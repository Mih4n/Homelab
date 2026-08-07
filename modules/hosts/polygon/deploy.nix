{ inputs, self, ... }: {
    flake = {
        deploy.nodes.polygon = {
            hostname = "polygon.bytes";
            profiles.system = {
                user = "root";
                sshUser = "byteshaker";
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.polygon;
            };
            profiles.home = {
                user = "bytekeeper";
                sshUser = "bytekeeper";

                path =
                    inputs.deploy.lib.x86_64-linux.activate.home-manager
                    self.homeConfigurations.bytekeeper;
            };
        };
    };
}
