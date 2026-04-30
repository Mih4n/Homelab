{ self, inputs, ... }: {
    flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostLaptop
        ];
    };

    flake.nixosModules.hostLaptop = { pkgs, ... }: let 
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
            self.nixosModules.sops
            self.nixosModules.shell
            self.nixosModules.locale
            self.nixosModules.tailscale
            self.nixosModules.networking
            self.nixosModules.noPasswordSudo

            # host hardware
            self.nixosModules.hostLaptopHardware
            self.nixosModules.hostLaptopGraphics
        ];

        networking.hostName = "laptop";

        environment.systemPackages = with pkgs; [
            nautilus
            polkit_gnome 
        ];

        virtualisation.podman.enable = true;
        virtualisation.docker.enable = true;

        programs.nh.flake =  "/home/mih4n/NixOs";

        networking.firewall.enable = false;
        networking.nftables.enable = true;

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

        boot.plymouth.enable = true;

        hardware.bluetooth.enable = true;
        hardware.cpu.intel.updateMicrocode = true;

        system.stateVersion = "25.11";
    };
}
