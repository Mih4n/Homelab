{ inputs, self, ... }: let
    s = self.settings;
in {
    flake = {
        deploy.nodes.laptop = {
            hostname = s.hosts.laptop;
            profiles.system = {
                user = s.users.main;
                sshUser = s.users.main;
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.laptop;
            };
            profiles.home = {
                user = s.users.main;
                sshUser = s.users.main;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.home-manager
                    self.homeConfigurations.${s.users.main};
            };
        };
    };
}
