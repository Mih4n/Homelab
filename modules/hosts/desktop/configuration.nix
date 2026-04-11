{ self, inputs, ... }: {
    flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostDesktop
        ];
    };

    flake.nixosModules.hostDesktop = { pkgs, ... }: let 
    in {
        imports = [
            # users
            self.nixosModules.userMih4n

            # environment
            self.nixosModules.niriEnv
            self.nixosModules.basicEnv
            self.nixosModules.desktopEnv
            self.nixosModules.minecraftGrub

            # shared features
            self.nixosModules.nix
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

        environment.systemPackages = with pkgs; [
            lmstudio
        ];

        services.flatpak.enable = true;

        hardware.cpu.amd.updateMicrocode = true;

        boot.plymouth.enable = true;
        boot.kernelPackages = pkgs.linuxPackages_zen;

        virtualisation.podman.enable = true;
        virtualisation.docker.enable = true;

        networking.hostName = "desktop";

        programs.nh.flake =  "/home/mih4n/NixOs";

        boot.kernelModules = [ "bridge" "tun" "nft_chain_nat_ipv4" ];

        networking.firewall.enable = true;
        networking.nftables.enable = true;

        networking.firewall.trustedInterfaces = [ "waydroid0" ];
        virtualisation.waydroid.enable = true;

        services.displayManager.sddm.enable = true;
        services.desktopManager.plasma6.enable = false; 

        system.stateVersion = "25.11";
    };
}
