{ self, inputs, ... }: {
    flake.nixosConfigurations.vpn = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostVpn
        ];
    };

    flake.nixosModules.hostVpn = { config, ... }: let 
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

            # host hardware
            self.nixosModules.hostVpnHardware

            # host specific features
            self.nixosModules.hostVpnBoot
            self.nixosModules.hostVpnTraefik
            self.nixosModules.hostVpnHeadscale
            self.nixosModules.hostVpnNetworking
        ];

        networking.hostName = "vpn";

        documentation.man.enable = false;
        documentation.man.generateCaches = false;
        programs.fish.vendor.completions.enable = false;
        programs.fish.vendor.functions.enable = false;

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