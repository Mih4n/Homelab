{ self, inputs, ... }: {
    flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostDesktop
        ];
    };

    flake.nixosModules.hostDesktop = { pkgs, ... }: {
        imports = [
            # features options
            self.nixosModules.features

            # users
            self.nixosModules.userMih4n

            # environment
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
        ]; 

        boot.plymouth.enable = true;
        boot.kernelPackages = pkgs.linuxPackages_zen;

        networking.hostName = "desktop";

        programs.nh.flake =  "/home/mih4n/NixOs";

        boot.kernelModules = [ "bridge" "tun" "nft_chain_nat_ipv4" ];

        networking.firewall.enable = true;
        networking.nftables.enable = true;

        networking.firewall.trustedInterfaces = [ "waydroid0" ];
        virtualisation.waydroid.enable = true;

        services.displayManager.sddm.enable = true;
        services.desktopManager.plasma6.enable = true; 

        system.stateVersion = "25.11";
    };
}
