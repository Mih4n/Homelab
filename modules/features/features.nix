{ ... }: {
    flake.nixosModules.features = { lib, ... }: {
        options.bytes = {
            disk.type = lib.mkOption { type = lib.types.str; };
            boot.mode = lib.mkOption { 
                type = lib.types.enum [ "legacy-grub" "uefi-grub" "uefi-systemd-boot" ]; 
            };
            networking.local = { 
                ip = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "ip address in local network";
                };

                mask = lib.mkOption {
                    type = lib.types.int;
                    default = 24;
                    description = "sets local network mask";
                };

                useDHCP = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "enables dhcp";
                };
            };
        };
    };  
}