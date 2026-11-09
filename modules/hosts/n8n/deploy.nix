{ inputs, self, ... }: let
    s = self.settings;
in {
    flake = {
        deploy.nodes.n8n = {
            hostname = s.hosts.n8n;
            profiles.system = {
                user = "root";
                sshUser = s.users.keeper;
                interactiveSudo = true;

                path =
                    inputs.deploy.lib.x86_64-linux.activate.nixos
                    self.nixosConfigurations.n8n;
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
