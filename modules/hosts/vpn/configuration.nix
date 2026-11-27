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
            self.nixosModules.hostVpnHeadplane
            self.nixosModules.hostVpnAuthentikProxy
            self.nixosModules.hostVpnNetworking
        ];

        theme.hostIcon = "󰖂";
        networking.hostName = "vpn";

        # Listen only on the VPN address; do not expose an open proxy to the
        # public network. Headscale addresses for the two client machines.
        services.tinyproxy = {
            enable = true;
            settings = {
                Listen = "100.64.0.1";
                Port = 8888;
                Allow = [ "100.64.0.7" "100.64.0.10" ];
            };
        };

        # tailscaled can start before its address has been assigned.
        systemd.services.tinyproxy = {
            after = [ "tailscaled.service" ];
            wants = [ "tailscaled.service" ];
            serviceConfig = {
                Restart = "on-failure";
                RestartSec = 10;
            };
            unitConfig.StartLimitIntervalSec = 0;
        };

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
