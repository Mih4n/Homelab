{ config, pkgs, lib, ... }: let
    bytesDisk = config.bytes.disk.type;
    isLegacy = config.bytes.boot.mode == "legacy-grub";
    isUefiGrub = config.bytes.boot.mode == "uefi-grub";
    isSystemdBoot = config.bytes.boot.mode == "uefi-systemd-boot";
in
{
    options.bytes.boot = {
        mode = lib.mkOption {
            type = lib.types.enum [ "uefi-grub" "legacy-grub" "uefi-systemd-boot" ];
            default = "uefi-systemd-boot";
        };
    };

    config = {
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" "ntfs" "xfs" ];

        boot.loader.systemd-boot.enable = isSystemdBoot;
        boot.loader.efi.canTouchEfiVariables = isSystemdBoot || isUefiGrub;

        boot.loader.grub.enable = !isSystemdBoot;
        boot.loader.grub.efiSupport = isUefiGrub;
        boot.loader.grub.efiInstallAsRemovable = isUefiGrub;

        boot.loader.grub.devices = lib.mkIf isLegacy (lib.mkForce [ "/dev/${bytesDisk}" ]);
    };
}
