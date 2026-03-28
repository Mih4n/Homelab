{ ... }: {
    flake.nixosModules.diskoStandard = { lib, config, ... }: let
        bytesDisk = config.bytes.disk.type;
        isLegacy = config.bytes.boot.mode == "legacy-grub";
    in {
        disko.devices = {
            disk = {
                main = {
                    device = "/dev/${bytesDisk}";
                    type = "disk";
                    content = {
                        type = "gpt";
                        partitions = lib.mkMerge [
                            (lib.mkIf isLegacy {
                                BIOS = {
                                    size = "1M";
                                    type = "EF02";
                                };
                            })

                            {
                                ESP = {
                                    size = "500M";
                                    type = "EF00";
                                    content = {
                                        type = "filesystem";
                                        format = "vfat";
                                        mountpoint = "/boot";
                                        mountOptions = [ "umask=0077" ];
                                    };
                                };

                                root = {
                                    size = "100%";
                                    content = {
                                        type = "filesystem";
                                        format = "ext4";
                                        mountpoint = "/";
                                    };
                                };
                            }
                        ];
                    };
                };
            };
        };
    };
}