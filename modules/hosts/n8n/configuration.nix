{ self, inputs, ... }: let
    s = self.settings;
in {
    flake.nixosConfigurations.n8n = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostN8n
        ];
    };

    flake.nixosModules.hostN8n = { config, ... }: let
        secrets = config.sops.secrets;
    in {
        # Только у этого хоста есть n8n-нода в headscale, поэтому и секрет
        # объявлен здесь, а не в общем sops-модуле: иначе его отсутствие
        # ломает активацию на всех остальных хостах.
        sops.secrets."headscale/n8n" = {};

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

            # used by the n8n Assistant for web search
            self.nixosModules.searx

            # host hardware
            self.nixosModules.hostN8nHardware

            # host specific features
            self.nixosModules.n8nServer
        ];

        theme.hostIcon = "󰚩";
        networking.hostName = "n8n";

        bytes = {
            disk.type = "sda";
            boot.mode = "uefi-systemd-boot";

            networking.local = {
                ip = s.net.ips.n8n;
            };

            tailscale = {
                authKeyFile = secrets."headscale/n8n".path;
            };
        };

        system.stateVersion = "25.05";
    };
}
