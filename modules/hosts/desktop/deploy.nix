{ inputs, self, ... }: let
    s = self.settings;
in {
    flake = {
        deploy.nodes.desktop = {
            hostname = s.hosts.desktop;
            profiles.system = {
                user = "root";
                sshUser = s.users.main;
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.desktop;
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
