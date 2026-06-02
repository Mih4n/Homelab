{ self, inputs, ... }: {
    flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostDesktop
        ];
    };

    flake.nixosModules.hostDesktop = { pkgs, ... }: let 
    in {
        imports = [
            self.nixosModules.base

            # users
            self.nixosModules.userMih4n

            # environment
            self.nixosModules.niriEnv
            self.nixosModules.basicEnv
            self.nixosModules.desktopEnv
            self.nixosModules.minecraftGrub

            # shared features
            self.nixosModules.nix
            self.nixosModules.qmk
            self.nixosModules.sops
            self.nixosModules.shell
            self.nixosModules.locale
            self.nixosModules.tailscale
            self.nixosModules.networking
            self.nixosModules.noPasswordSudo

            # host hardware
            self.nixosModules.hostDesktopHardware
            self.nixosModules.hostDesktopGraphics
        ];

        networking.hostName = "desktop";

        environment.systemPackages = with pkgs; [
            ollama-rocm
            roslyn
            roslyn-ls
            spotify
            yubioath-flutter
            lmstudio
            winboat
            polkit_gnome 
            nautilus
        ];


        virtualisation.podman.enable = true;
        virtualisation.docker.enable = true;
        virtualisation.waydroid.enable = true;

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
