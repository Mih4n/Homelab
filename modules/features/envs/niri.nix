{ self, inputs, ... }: {
    flake.nixosModules.niriEnv = { config, lib, pkgs, ... }: let
        selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};

        cfg = config.bytes.niri;

        mkOutput = monitor:
            lib.filterAttrs (_: value: value != null) {
                inherit (monitor) mode scale transform;
            }
            // lib.optionalAttrs (monitor.position != null) {
                position = _: { props = { inherit (monitor.position) x y; }; };
            }
            // lib.optionalAttrs monitor.focusAtStartup {
                focus-at-startup = _: { };
            }
            // lib.optionalAttrs (!monitor.enable) {
                off = _: { };
            }
            // lib.optionalAttrs (monitor.variableRefreshRate != null) {
                variable-refresh-rate = _:
                    lib.optionalAttrs (monitor.variableRefreshRate == "on-demand") {
                        props.on-demand = true;
                    };
            }
            // monitor.extra;

        niri = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            imports = [
                self.wrappedModules.niri
                {
                    inherit (cfg) scripts;

                    settings = lib.mkMerge [
                        cfg.settings
                        { outputs = lib.mapAttrs (_: mkOutput) cfg.monitors; }
                    ];
                }
            ];
        };
    in {
        options.bytes.niri = {
            monitors = lib.mkOption {
                default = { };
                description = "Monitors of this host, keyed by niri output name (`niri msg outputs`).";
                example = lib.literalExpression ''
                    {
                        "DP-1" = {
                            mode = "2560x1440@239.970";
                            scale = 1.33;
                            position = { x = 0; y = 0; };
                            focusAtStartup = true;
                        };
                    }
                '';
                type = lib.types.attrsOf (lib.types.submodule {
                    options = {
                        enable = lib.mkOption {
                            type = lib.types.bool;
                            default = true;
                            description = "Whether niri should use this output at all.";
                        };

                        mode = lib.mkOption {
                            type = lib.types.nullOr lib.types.str;
                            default = null;
                            example = "2560x1440@239.970";
                            description = "Resolution and refresh rate, null to let niri pick.";
                        };

                        scale = lib.mkOption {
                            type = lib.types.nullOr (lib.types.either lib.types.int lib.types.float);
                            default = null;
                            example = 1.33;
                            description = "Fractional scale of the output.";
                        };

                        transform = lib.mkOption {
                            type = lib.types.nullOr (lib.types.enum [
                                "normal" "90" "180" "270"
                                "flipped" "flipped-90" "flipped-180" "flipped-270"
                            ]);
                            default = null;
                            description = "Rotation of the output.";
                        };

                        position = lib.mkOption {
                            default = null;
                            description = "Position in the global coordinate space, null to place automatically.";
                            type = lib.types.nullOr (lib.types.submodule {
                                options = {
                                    x = lib.mkOption { type = lib.types.int; };
                                    y = lib.mkOption { type = lib.types.int; };
                                };
                            });
                        };

                        focusAtStartup = lib.mkOption {
                            type = lib.types.bool;
                            default = false;
                            description = "Focus this output when niri starts.";
                        };

                        variableRefreshRate = lib.mkOption {
                            type = lib.types.nullOr (lib.types.enum [ "always" "on-demand" ]);
                            default = null;
                            description = "Enables VRR, either always or only for fullscreen windows.";
                        };

                        extra = lib.mkOption {
                            type = lib.types.attrs;
                            default = { };
                            example = lib.literalExpression ''{ background-color = "#282828"; }'';
                            description = "Raw niri output settings merged on top of the ones above.";
                        };
                    };
                });
            };

            scripts = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = { };
                description = ''
                    Host specific shell programs bound to a key, see `scripts` of the niri wrapper.
                '';
                example = lib.literalExpression ''
                    {
                        lock = {
                            bind = "Mod+Shift+L";
                            packages = [ pkgs.swaylock ];
                            text = "swaylock -f";
                        };
                    }
                '';
            };

            settings = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = { };
                description = "Host specific niri settings merged into the shared config.";
                example = lib.literalExpression ''{ layout.gaps = 4; }'';
            };
        };

        config = {
            programs.niri = {
                enable = true;
                package = niri;
                useNautilus = true;
            };

            xdg.portal = {
                enable = true;
                extraPortals = [
                    pkgs.xdg-desktop-portal-gnome
                ];
                config.common.default = "*";
            };

            qt = {
                enable = true;
                platformTheme = lib.mkForce "gnome";
            };

            environment.systemPackages = [
                niri
                selfpkgs.noctaliaShell
                pkgs.qgnomeplatform
            ];

            services = {
                gvfs.enable = true;
                udisks2.enable = true;
            };

            security.polkit.enable = true;

            environment.sessionVariables = {
                NIXOS_OZON_WL = "1";
                XDG_CURRENT_DESKTOP = "niri";
                QT_QPA_PLATFORMTHEME = "gnome";
            };

            services.gnome.gnome-keyring.enable = true;
        };
    };
}
