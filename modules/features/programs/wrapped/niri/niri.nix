{ self, inputs, ... }: {
    perSystem = {pkgs, ...}: {
        packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            imports = [self.wrappedModules.niri];
        };
    };

    flake.wrappedModules.niri = { config, lib, pkgs, ... }: let
        xwayland = lib.getExe config.pkgs.xwayland-satellite;
        noctalia = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaShell;

        externalConfig = pkgs.writeText "external-config.kdl" (builtins.readFile ./config.kdl);
        internalConfig = ''
            include "${externalConfig}" 

            layout {
                gaps 10
                focus-ring {
                    width 2
                    active-color "${self.palette.blue}"
                }
            }

            binds {
                "Mod+T" { spawn "kitty"; } 
                "Mod+Return" { spawn "kitty"; } 
                "Mod+D" { spawn-sh "${noctalia} ipc call launcher toggle"; }
                "Mod+Shift+S" { spawn-sh "${lib.getExe (config.pkgs.writeShellApplication {
                        name = "screenshot";
                        text = ''
                            ${lib.getExe config.pkgs.grim} -g "$(${lib.getExe config.pkgs.slurp} -w 0)" - \
                            | ${config.pkgs.wl-clipboard}/bin/wl-copy
                        '';
                    })}"; 
                }
            }

            xwayland-satellite {
                path "${xwayland}"
            }

            spawn-at-startup "${noctalia}"
        '';
    in {
        config = {
            "config.kdl".content = internalConfig;
        };
    };
}