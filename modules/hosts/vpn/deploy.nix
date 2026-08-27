{ inputs, self, ... }: {
    flake = {
        deploy.nodes.vpn = {
            hostname = "vpn.bytes";
            profiles.system = {
                user = "byteshaker";
                sshUser = "byteshaker";
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.vpn;
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
