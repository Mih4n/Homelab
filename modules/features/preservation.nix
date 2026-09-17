{ inputs, ... }: {
    flake.nixosModules.preservation = { config, lib, pkgs, utils, ... }: let
        cfg = config.bytes.impermanence;

        deviceUnit = "${utils.escapeSystemdPath cfg.device}.device";

        # Not read from `users.users`: `fileSystems` is evaluated earlier and
        # would end up in an infinite recursion.
        mkEphemeral = f: lib.concatMapAttrs (user: paths:
            lib.listToAttrs (map (path: lib.nameValuePair "/home/${user}/${path}" (f user)) paths)
        ) cfg.ephemeralHome;
    in {
        imports = [
            inputs.preservation.nixosModules.preservation
        ];

        options.bytes.impermanence = {
            enable = lib.mkEnableOption "wiping the btrfs root subvolume on every boot";

            device = lib.mkOption {
                type = lib.types.str;
                example = "/dev/disk/by-label/system";
                description = "btrfs filesystem that holds the root subvolume.";
            };

            ephemeralHome = lib.mkOption {
                type = lib.types.attrsOf (lib.types.listOf lib.types.str);
                default = { };
                example = lib.literalExpression ''{ mih4n = [ ".cache" ]; }'';
                description = "Paths relative to `/home/<user>` that live in tmpfs instead of on disk.";
            };

            directories = lib.mkOption {
                type = lib.types.listOf lib.types.anything;
                default = [ ];
                description = "Host specific directories to preserve.";
            };

            files = lib.mkOption {
                type = lib.types.listOf lib.types.anything;
                default = [ ];
                description = "Host specific files to preserve.";
            };
        };

        config = lib.mkIf cfg.enable {
            boot.initrd.systemd.enable = true;
            boot.initrd.supportedFilesystems.btrfs = true;
            boot.initrd.systemd.initrdBin = [ pkgs.btrfs-progs ];

            boot.initrd.systemd.services.rollback = {
                description = "Rollback the root subvolume to a blank state";
                wantedBy = [ "initrd.target" ];
                requires = [ deviceUnit ];
                after = [ deviceUnit ];
                before = [ "sysroot.mount" ];
                unitConfig.DefaultDependencies = "no";
                serviceConfig.Type = "oneshot";
                script = ''
                    mkdir -p /btrfs
                    mount -t btrfs -o subvol=/ ${cfg.device} /btrfs

                    if [ -e /btrfs/@root ]; then
                        btrfs subvolume list -o /btrfs/@root | cut -f9 -d' ' | while read -r subvolume; do
                            btrfs subvolume delete "/btrfs/$subvolume"
                        done

                        btrfs subvolume delete /btrfs/@root
                    fi

                    btrfs subvolume snapshot /btrfs/@root-blank /btrfs/@root
                    umount /btrfs
                '';
            };

            # /etc/shadow does not survive the rollback.
            users.mutableUsers = false;

            fileSystems = lib.mkMerge [
                (mkEphemeral (_: {
                    device = "none";
                    fsType = "tmpfs";
                    options = [ "defaults" "mode=0700" "size=4G" ];
                }))

                {
                    "/persist".neededForBoot = true;
                    "/var/log".neededForBoot = true;
                }
            ];

            systemd.tmpfiles.settings.ephemeral-home = mkEphemeral (user: {
                d = { inherit user; group = "users"; mode = "0700"; };
            });

            systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

            systemd.services.systemd-machine-id-commit = {
                unitConfig.ConditionPathIsMountPoint = [ "" "/persist/etc/machine-id" ];
                serviceConfig.ExecStart = [ "" "systemd-machine-id-setup --commit --root /persist" ];
            };

            preservation = {
                enable = true;

                preserveAt."/persist" = {
                    directories = [
                        { directory = "/var/lib/nixos"; inInitrd = true; }

                        "/var/lib/systemd/backlight"
                        "/var/lib/systemd/coredump"
                        "/var/lib/systemd/linger"
                        "/var/lib/systemd/rfkill"
                        "/var/lib/systemd/timers"

                        "/etc/NetworkManager/system-connections"
                        "/var/lib/NetworkManager"
                        "/var/lib/bluetooth"
                        "/var/lib/tailscale"

                        "/var/lib/AccountsService"
                        "/var/lib/alsa"
                        "/var/lib/cups"
                        "/var/lib/flatpak"
                        "/var/lib/fwupd"
                    ] ++ cfg.directories;

                    files = [
                        { file = "/etc/machine-id"; inInitrd = true; }

                        # sops derives its age key from the host key, losing it
                        # means losing access to every secret of this host.
                        { file = "/etc/ssh/ssh_host_ed25519_key"; how = "symlink"; configureParent = true; }
                        { file = "/etc/ssh/ssh_host_ed25519_key.pub"; how = "symlink"; configureParent = true; }
                        { file = "/etc/ssh/ssh_host_rsa_key"; how = "symlink"; configureParent = true; }
                        { file = "/etc/ssh/ssh_host_rsa_key.pub"; how = "symlink"; configureParent = true; }

                        { file = "/var/lib/systemd/random-seed"; how = "symlink"; inInitrd = true; configureParent = true; }
                    ] ++ cfg.files;

                    users.root = {
                        home = "/root";
                        directories = [
                            { directory = ".ssh"; mode = "0700"; }
                        ];
                    };
                };
            };
        };
    };
}
