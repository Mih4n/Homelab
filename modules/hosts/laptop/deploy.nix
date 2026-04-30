{ inputs, self, ... }: {
    flake = {
        deploy.nodes.laptop = {
            hostname = "nixos.bytes";
            profiles.system = {
                user = "root";
                sshUser = "mih4n";
                interactiveSudo = true;

                path = 
                    inputs.deploy.lib.x86_64-linux.activate.nixos 
                    self.nixosConfigurations.laptop;
            };
            profiles.home = {
                user = "mih4n";
                sshUser = "mih4n";

                path = 
                    inputs.deploy.lib.x86_64-linux.activate.home-manager 
                    self.homeConfigurations.mih4n;
            };
        };
    };
}