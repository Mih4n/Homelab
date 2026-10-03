{ inputs, self, ... }: {
    flake = {
        deploy.nodes.git = {
            hostname = "git.bytes";
            profiles.system = {
                user = "bytekeeper";
                sshUser = "bytekeeper";
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.git;
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
