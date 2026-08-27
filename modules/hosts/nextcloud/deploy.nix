{ inputs, self, ... }: {
    flake = {
        deploy.nodes.nextcloud = {
            hostname = "nextcloud.bytes";
            profiles.system = {
                user = "byteshaker";
                sshUser = "byteshaker";
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.nextcloud;
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
