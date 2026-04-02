{ self, inputs, ... }: {
    flake.nixosConfigurations.polygon = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostPolygon
        ];
    };

    flake.nixosModules.hostPolygon = { config, ... }: let 
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
            self.nixosModules.hostPolygonHardware

            # host specific features
            self.nixosModules.hostPolygonPostgres
            self.nixosModules.hostPolygonSqlserver
        ];

        networking.hostName = "polygon";

        virtualisation.docker.enable = true;
        virtualisation.oci-containers.backend = "docker";

        bytes = {
            disk.type = "sda";
            boot.mode = "uefi-systemd-boot";

            networking.local = {
                ip = "192.168.192.12";
            };

            tailscale = {
                authKeyFile = secrets."headscale/polygon".path;
            };
        };

        system.stateVersion = "25.05";
    };
}