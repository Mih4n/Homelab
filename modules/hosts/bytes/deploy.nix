{ inputs, self, ... }: let
    s = self.settings;
in {
    flake = {
        deploy.nodes.bytes = {
            hostname = s.hosts.bytes;
            profiles.system = {
                user = "root";
                sshUser = s.users.shaker;
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.bytes;
            };
            profiles.home = {
                user = s.users.keeper;
                sshUser = s.users.keeper;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.home-manager
                    self.homeConfigurations.${s.users.keeper};
            };
        };
    };
}
