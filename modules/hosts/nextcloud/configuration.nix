{ self, inputs, ... }: {
    flake.nixosConfigurations.nextcloud = inputs.nixpkgs.lib.nixosSystem {
        imports = [
            self.nixosModules.hostNextcloud
        ];
    };

    flake.nixosModules.hostNextcloud = { config, ... }: let 
        secrets = config.sops.secrets;
    in {
        imports = [
            # features options
            self.nixosModules.features

            # users
            self.nixosModules.userByteshaker
            self.nixosModules.userBytekeeper

            # environment
            self.nixosModules.basicEnv

            # disks
            self.nixosModules.diskoStandard

            # shared features
            self.nixosModules.nix
            self.nixosModules.sops
            self.nixosModules.shell
            self.nixosModules.locale
            self.nixosModules.tailscale
            self.nixosModules.bootEngine
            self.nixosModules.networking
            self.nixosModules.noPasswordSudo
            self.nixosModules.localNetworking

            # host hardware
            self.nixosModules.hostNextcloudHardware

            # host specific features
            self.nixosModules.nextcloudServer
        ];

        networking.hostName = "nextcloud";

        bytes = {
            networking.local = {
                ip = "192.168.192.11";
            };

            tailscale = {
                authKeyFile = secrets."headscale/nextcloud".path;
            };
        };

        system.stateVersion = "25.05";
    };
}