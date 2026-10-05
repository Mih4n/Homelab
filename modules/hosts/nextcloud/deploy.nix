{ inputs, self, ... }: let
    s = self.settings;
in {
    flake = {
        deploy.nodes.nextcloud = {
            hostname = s.hosts.nextcloud;
            profiles.system = {
                user = "root";
                sshUser = s.users.keeper;
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.nextcloud;
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
