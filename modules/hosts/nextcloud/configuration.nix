{ self, inputs, ... }: {
    flake.nixosConfigurations.nextcloud = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostNextcloud
        ];
    };

    flake.nixosModules.hostNextcloud = { config, ... }: let 
        secrets = config.sops.secrets;
    in {
        imports = [
            self.nixosModules.base

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

        theme.hostIcon = "";
        networking.hostName = "nextcloud";

        bytes = {
            boot.mode = "uefi-systemd-boot";

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