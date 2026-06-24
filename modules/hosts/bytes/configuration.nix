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
        
        networking.hostName = "bytes";

        bytes = {
            boot.mode = "uefi-systemd-boot";
            tailscale = {
                isExiteNode = true;
                subnetRoutes = [
                    "192.168.192.0/24"
                ];
                authKeyFile = secrets."headscale/bytes".path;
            };
        };

        system.stateVersion = "25.05";
    };
}
