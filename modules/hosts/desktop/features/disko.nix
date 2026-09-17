{ inputs, ... }: {
    flake.nixosModules.hostDesktopDisko = { lib, config, ... }: let
        cfg = config.bytes.disks;

        # Directories of the data disk that are mounted into the home directory.
        dataDirectories = {
            "@games" = "Games";
            "@downloads" = "Downloads";
            "@videos" = "Videos";
            "@nextcloud" = "Nextcloud";
        };

        homeOf = name: "/home/mih4n/${name}";

        compressed = [ "compress=zstd" "noatime" ];
    in {
        imports = [
            inputs.disko.nixosModules.default
        ];

        options.bytes.disks.manage = lib.mkOption {
            type = lib.types.listOf (lib.types.enum [ "main" "data" "archive" ]);
            default = [ "main" "data" "archive" ];
            description = "Disks that disko partitions and that this host mounts.";
        };

        config.disko.devices.disk = lib.getAttrs cfg.manage {
            main = {
                type = "disk";
                device = "/dev/disk/by-id/nvme-KINGSTON_SKC3000S1024G_50026B7686AFCE2C";
                content = {
                    type = "gpt";
                    partitions = {
                        ESP = {
                            priority = 1;
                            size = "1G";
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
                                type = "btrfs";
                                extraArgs = [ "-f" "-L" "system" ];

                                subvolumes = {
                                    "@root" = {
                                        mountpoint = "/";
                                        mountOptions = compressed;
                                    };

                                    "@nix" = {
                                        mountpoint = "/nix";
                                        mountOptions = compressed;
                                    };

                                    "@persist" = {
                                        mountpoint = "/persist";
                                        mountOptions = compressed;
                                    };

                                    "@home" = {
                                        mountpoint = "/home";
                                        mountOptions = compressed;
                                    };

                                    "@log" = {
                                        mountpoint = "/var/log";
                                        mountOptions = compressed;
                                    };

                                    "@swap" = {
                                        mountpoint = "/swap";
                                        mountOptions = [ "noatime" ];
                                        swap.swapfile.size = "32G";
                                    };
                                };

                                # The initrd restores @root from this snapshot on every boot.
                                postCreateHook = ''
                                    MNTPOINT=$(mktemp -d)
                                    mount "$device" "$MNTPOINT" -o subvol=/
                                    trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT

                                    if ! btrfs subvolume show "$MNTPOINT/@root-blank" > /dev/null 2>&1; then
                                        btrfs subvolume snapshot -r "$MNTPOINT/@root" "$MNTPOINT/@root-blank"
                                    fi
                                '';
                            };
                        };
                    };
                };
            };

            data = {
                type = "disk";
                device = "/dev/disk/by-id/nvme-ADATA_LEGEND_850_LITE_2O5229A24SK2";
                content = {
                    type = "gpt";
                    partitions.data = {
                        size = "100%";
                        content = {
                            type = "btrfs";
                            extraArgs = [ "-f" "-L" "data" ];

                            subvolumes = {
                                "@data" = {
                                    mountpoint = "/mnt/data";
                                    mountOptions = compressed;
                                };
                            } // lib.mapAttrs (_: name: {
                                mountpoint = homeOf name;
                                mountOptions = compressed;
                            }) dataDirectories;
                        };
                    };
                };
            };

            archive = {
                type = "disk";
                device = "/dev/disk/by-id/ata-SAMSUNG_HM500JI_S20CJ9AB408641";
                content = {
                    type = "gpt";
                    partitions.archive = {
                        size = "100%";
                        content = {
                            type = "btrfs";
                            extraArgs = [ "-f" "-L" "archive" ];

                            subvolumes."@archive" = {
                                mountpoint = "/mnt/archive";
                                mountOptions = compressed;
                            };
                        };
                    };
                };
            };
        };

        # Fresh subvolumes belong to root.
        config.systemd.tmpfiles.settings.data-disk = lib.listToAttrs (map (path:
            lib.nameValuePair path { d = { user = "mih4n"; group = "users"; mode = "0755"; }; }
        ) (map homeOf (lib.attrValues dataDirectories) ++ [ "/mnt/data" "/mnt/archive" ]));
    };
}
