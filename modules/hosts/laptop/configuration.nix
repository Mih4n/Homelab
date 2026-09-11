{ self, inputs, ... }: {
    flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostLaptop
        ];
    };

    flake.nixosModules.hostLaptop = { pkgs, config, ... }: let
        secrets = config.sops.secrets;
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
            self.nixosModules.netbird
            self.nixosModules.networking
            self.nixosModules.noPasswordSudo

            # host hardware
            self.nixosModules.hostLaptopHardware
            inputs.hardware.nixosModules.framework-amd-ai-300-series
        ];

        theme.hostIcon = " ";
        networking.hostName = "laptop";

        environment.systemPackages = with pkgs; [
            scilab-bin
            nautilus
            polkit_gnome
        ];

        bytes.niri.monitors = {
            "eDP-1" = {
                scale = 1.33;
                mode = "2256x1504@59.999";
                position = { x = 0; y = 0; };
            };
        };

        bytes.netbird.setupKeyFile = secrets."netbird/setup-key".path;

        virtualisation.podman.enable = true;
        virtualisation.docker.enable = true;
        virtualisation.virtualbox.host.enable = true;
        users.extraGroups.vboxusers.members = [ "mih4n" ];

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
        hardware.cpu.amd.updateMicrocode = true;

        system.stateVersion = "25.11";
    };
}
