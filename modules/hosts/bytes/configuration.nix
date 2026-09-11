{ self, inputs, ... }: {
    flake.nixosConfigurations.bytes = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostBytes
        ];
    };

    flake.nixosModules.hostBytes = { config, ... }: let 
        secrets = config.sops.secrets;
    in {
        imports = [
            self.nixosModules.base

            # users
            self.nixosModules.userBytekeeper

            # environment
            self.nixosModules.basicEnv

            # shared features
            self.nixosModules.nix
            self.nixosModules.sops
            self.nixosModules.shell
            self.nixosModules.locale
            self.nixosModules.tailscale
            self.nixosModules.netbird
            self.nixosModules.bootEngine
            self.nixosModules.networking
            self.nixosModules.noPasswordSudo

            # host hardware
            self.nixosModules.hostBytesHardware

            # host specific features
            self.nixosModules.authentik
            self.nixosModules.hostBytesBoot
            self.nixosModules.hostBytesDhcp
            self.nixosModules.hostBytesProxmox
            self.nixosModules.hostBytesNetworking
        ];
        
        theme.hostIcon = "󰒋";
        networking.hostName = "bytes";

        swapDevices = [{
            device = "/swapfile";
            size = 8 * 1024;
        }];

        bytes = {
            boot.mode = "uefi-systemd-boot";
            tailscale = {
                isExiteNode = true;
                subnetRoutes = [
                    "192.168.192.0/24"
                ];
                authKeyFile = secrets."headscale/bytes".path;
            };
            netbird.setupKeyFile = secrets."netbird/setup-key".path;
        };

        system.stateVersion = "25.05";
    };
}
