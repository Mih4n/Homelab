{ inputs, self, ... }:let
    s = self.settings;
in {
    flake.nixosConfigurations.git = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostGit
        ];
    };

    flake.nixosModules.hostGit =  { config, ... }: let
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
            self.nixosModules.hostGitHardware

            # host specific features
            self.nixosModules.gitServer
        ];

        theme.hostIcon = "";
        networking.hostName = "git";

        virtualisation.podman.enable = true;

        bytes = {
            disk.type = "sda";
            boot.mode = "uefi-systemd-boot";

            networking.local = {
                ip = s.net.ips.git;
            };

            tailscale = {
                authKeyFile = secrets."headscale/git".path;
            };
        };

        system.stateVersion = "25.05";
    };
}
