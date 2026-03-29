{ self, inputs, ... }: {
    flake.nixosModules.hostBytes = { config, pkgs, ... }: let 
        system = pkgs.stdenv.hostPlatform.system;
        secrets = config.sops.secrets;
    in {
        imports = [
            self.nixosModules.features

            # shared features
            self.nixosModules.nix
            self.nixosModules.sops
            self.nixosModules.shell
            self.nixosModules.locale
            self.nixosModules.basicEnv
            self.nixosModules.tailscale
            self.nixosModules.bootEngine
            self.nixosModules.networking
            self.nixosModules.diskoStandard
            self.nixosModules.noPasswordSudo

            # host specific features
            self.nixosModules.hostBytesBoot
            self.nixosModules.hostBytesDhcp
            self.nixosModules.hostBytesProxmox
            self.nixosModules.hostBytesNetworking
        ];

        environment.systemPackages = [
            inputs.colmena.packages.${system}.colmena
        ];

        networking.hostName = "bytes";

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
