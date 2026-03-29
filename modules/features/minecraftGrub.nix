{ inputs, ... }: {
    flake.nixosModules.minecraftGrub = { config, ... }: {
        imports = [
            inputs.minegrub-world-sel-theme.nixosModules.default
        ];

        boot.loader.grub = {
            enable = true;
            device = "nodev";
            useOSProber = true;
            gfxmodeEfi = "1920x1080";
            minegrub-world-sel = {
                enable = true;
                customIcons = with config.system; [
                    {
                        inherit name;
                        lineTop = with nixos; distroName + " " + codeName + " (" + version + ")";
                        lineBottom = "Survival Mode, No Cheats, Version: " + nixos.release;
                        imgName = "nixos";
                    }
                ];
            };
            efiSupport = true;
        };

        boot.loader.efi.efiSysMountPoint = "/boot";
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.systemd-boot.enable = false;
    };
}