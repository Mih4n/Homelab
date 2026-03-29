{ self, inputs, ... }: {
    flake.nixosConfigurations.bytes = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostBytes
        ];
    };

    flake.nixosModules.hostBytes = { config, pkgs, ... }: let 
        system = pkgs.stdenv.hostPlatform.system;
        secrets = config.sops.secrets;
    in {
        imports = [
            # features options
            self.nixosModules.features

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
            self.nixosModules.diskoStandard
            self.nixosModules.noPasswordSudo

            # host hardware
            self.nixosModules.hostBytesHardware

            # host specific features
            self.nixosModules.hostBytesBoot
            self.nixosModules.hostBytesDhcp
            self.nixosModules.hostBytesProxmox
            self.nixosModules.hostBytesNetworking
        ];
        
        networking.hostName = "bytes";

        environment.systemPackages = [
            inputs.colmena.packages.${system}.colmena
        ];

        bytes = {
            tailscale = {
                enable = true;
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
