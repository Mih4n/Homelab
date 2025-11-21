{ pkgs, lib, ... }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" "ntfs" "xfs" ];
    
    boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
    ];

    boot.initrd.kernelModules = [ ];

    boot.kernelModules = [
        "kvm-amd"
    ];

    boot.extraModulePackages = [ ];
}