{ config, lib, ... }: {
    options.bytes.disk = {
        type = lib.mkOption {
            type = lib.types.enum [ "sda" "vda" ];
            default = "sda";
            description = "changes disk type";
        };
    };

    config = {
        disko.devices = {
            disk = {
                main = {
                    device = "/dev/" + config.bytes.disk.type; 
                    type = "disk";
                    content = {
                        type = "gpt";
                        partitions = {
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
                        };
                    };
                };
            };
        };
    };
}