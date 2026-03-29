{ ... }: {
    flake.nixosModules.hostBytesHardware = { config, lib, modulesPath, ... }: {
        imports = [ 
            (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" =
            { device = "/dev/disk/by-uuid/f7e6e329-75c4-44c5-a49e-1fc151595e8f";
            fsType = "ext4";
            };

        fileSystems."/boot" =
            { device = "/dev/disk/by-uuid/6935-3FFD";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
            };

        swapDevices = [ ];

        networking.useDHCP = lib.mkDefault true;

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}