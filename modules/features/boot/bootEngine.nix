{ ... }: {
    flake.nixosModules.bootEngine = { config, pkgs, lib, ... }: let
        bootMode = config.bytes.boot.mode;
        bytesDisk = config.bytes.disk.type;

        isLegacy = bootMode == "legacy-grub";
        isUefiGrub = bootMode == "uefi-grub";
        isSystemdBoot = bootMode == "uefi-systemd-boot";
    in
    {
        config = {
            boot.kernelPackages = pkgs.linuxPackages_latest;
            boot.supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" "ntfs" "xfs" ];

            boot.loader.systemd-boot.enable = isSystemdBoot;
            boot.loader.efi.canTouchEfiVariables = isSystemdBoot || isUefiGrub;

            boot.loader.grub = {
                enable = !isSystemdBoot;
                efiSupport = isUefiGrub;
                efiInstallAsRemovable = isUefiGrub;
                devices = lib.mkIf isLegacy (lib.mkForce [ "/dev/${bytesDisk}" ]);
            };
        };
    };
}