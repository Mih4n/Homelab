{ self, ... }: {
    flake.nixosConfigurations.vpn = { ... }: {
        imports = [
            self.nixosModules.hostVpn
        ];
    };

    flake.nixosModules.hostVpn = { config, ... }: let 
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
            self.nixosModules.networkingLocal
            self.nixosModules.diskoStandard
            self.nixosModules.noPasswordSudo

            # host hardware
            self.nixosModules.hostVpnHardware

            # host specific features
            self.nixosModules.hostVpnBoot
            self.nixosModules.hostVpnTraefik
            self.nixosModules.hostVpnHeadscale
            self.nixosModules.hostVpnNetworking
        ];

        networking.hostName = "vpn";

        bytes = {
            disk.type = "sda";
            boot.mode = "legacy-grub";

            headscale = {
                subnetRouters = [
                    "bytes"
                ];
            };
            
            tailscale = {
                isExiteNode = true;
                authKeyFile = secrets."headscale/vpn".path;
            };
        }; 

        system.stateVersion = "25.05";
    };
}