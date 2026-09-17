{ self, inputs, ... }: {
    flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostDesktop
        ];
    };

    # Staged migration, see docs/desktop-migration.md.
    flake.nixosConfigurations.desktop-stage-main = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostDesktop
            { bytes.disks.manage = [ "main" ]; }
        ];
    };

    flake.nixosConfigurations.desktop-stage-data = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostDesktop
            { bytes.disks.manage = [ "data" "archive" ]; }
        ];
    };

    flake.nixosModules.hostDesktop = { pkgs, config, ... }: let
        secrets = config.sops.secrets;
    in {
        imports = [
            self.nixosModules.base

            # users
            self.nixosModules.userMih4n

            # environment
            self.nixosModules.nvf
            self.nixosModules.niriEnv
            self.nixosModules.basicEnv
            self.nixosModules.desktopEnv
            self.nixosModules.minecraftGrub

            # shared features
            self.nixosModules.nix
            self.nixosModules.qmk
            self.nixosModules.sops
            self.nixosModules.preservation
            self.nixosModules.shell
            self.nixosModules.locale
            self.nixosModules.tailscale
            self.nixosModules.netbird
            self.nixosModules.networking
            self.nixosModules.noPasswordSudo

            # host hardware
            self.nixosModules.hostDesktopDisko
            self.nixosModules.hostDesktopHardware
            self.nixosModules.hostDesktopGraphics
        ];

        theme.hostIcon = "󰟀";
        networking.hostName = "desktop";

        bytes.niri.monitors = {
            "DP-1" = {
                mode = "2560x1440@239.970";
                scale = 1.33;
                position = { x = 0; y = 0; };
                focusAtStartup = true;
            };

            "DP-2" = {
                mode = "1920x1080@143.981";
                transform = "270";
                position = { x = 2560; y = -420; };
            };
        };

        bytes.netbird.setupKeyFile = secrets."netbird/setup-key".path;

        # sops runs in the activation script, before preservation links
        # /etc/ssh, so the age key has to be read from the persistent volume.
        sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

        bytes.impermanence = {
            enable = true;
            device = "/dev/disk/by-label/system";

            directories = [
                "/var/lib/containers"
                "/var/lib/docker"
                "/var/lib/libvirt"
                "/var/lib/netbird-default"
                "/var/lib/sddm"
                "/var/lib/waydroid"
            ];

            ephemeralHome.mih4n = [
                ".cache"
                ".local/share/Trash"
            ];
        };

        environment.systemPackages = with pkgs; [
            ollama-rocm
            roslyn
            roslyn-ls
            spotify
            yubioath-flutter
            lmstudio
            polkit_gnome 
            nautilus
        ];


        virtualisation.podman.enable = true;
        virtualisation.docker.enable = true;
        virtualisation.waydroid.enable = true;
        virtualisation.virtualbox.host.enable = true;
        users.extraGroups.vboxusers.members = [ "mih4n" ];

        programs.nh.flake =  "/home/mih4n/NixOs";

        services = {
            flatpak.enable = true;
            displayManager = {
                sddm.enable = true;
                autoLogin = {
                    user = "mih4n";
                    enable = true;
                };
            };
        };

        hardware.graphics.enable32Bit = true;

        services.printing = {
            enable = true;
            drivers = [ pkgs.canon-cups-ufr2 pkgs.gutenprintBin ]; # Добавляет фильтры в пути CUPS
        };

        boot.plymouth.enable = true;

        boot.kernelPackages = pkgs.linuxPackages_zen;
        boot.kernelModules = [ "bridge" "tun" "nft_chain_nat_ipv4" ];

        # hardware.bluetooth.enable = true;
        hardware.cpu.amd.updateMicrocode = true;

        system.stateVersion = "25.11";
    };
}
