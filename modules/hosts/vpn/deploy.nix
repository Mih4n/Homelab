{ inputs, self, ... }: let
    s = self.settings;
in {
    flake = {
        deploy.nodes.vpn = {
            hostname = s.domains.root;
            profiles.system = {
                user = s.users.keeper;
                sshUser = s.users.keeper;
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.vpn;
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
