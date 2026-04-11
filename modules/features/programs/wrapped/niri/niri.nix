{ self, inputs, ... }: {
    perSystem = {pkgs, ...}: {
        packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            imports = [self.wrappedModules.niri];
        };
    };

    flake.wrappedModules.niri = { config, lib, pkgs, ... }: let
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
            }
            
            spawn-at-startup "${lib.getExe config.pkgs.xwayland-satellite}" ":" "12"
            spawn-at-startup "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaShell}"
        '';
    in {
        config = {
            "config.kdl".content = internalConfig;
        };
    };
}