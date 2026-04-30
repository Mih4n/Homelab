{ ... }: {
    flake.nixosModules.hostLaptopHardware = { lib, config, modulesPath, ... }: { 
        imports = [ 
            (modulesPath + "/installer/scan/not-detected.nix") 
        ];

        boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        fileSystems."/" = { 
            device = "/dev/disk/by-uuid/8fcb7727-4d0a-4add-8499-4eeb735c34c9";
            fsType = "ext4";
        };

        fileSystems."/boot" = { 
            device = "/dev/disk/by-uuid/5CB5-FE28";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };

        swapDevices = [ ];
        networking.useDHCP = lib.mkDefault true;

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}