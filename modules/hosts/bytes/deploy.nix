{ inputs, self, ... }: {
    flake = {
        deploy.nodes.bytes = {
            hostname = "bytes.bytes";
            profiles.system = {
                user = "root";
                sshUser = "bytekeeper";
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.bytes;
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
