{ self, inputs, ... }: {
    perSystem = { pkgs, ... }: {
        packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            imports = [ self.wrappedModules.niri ];
        };
    };

    flake.wrappedModules.niri = { config, lib, pkgs, ... }: {
        imports = [
            self.wrappedModules.niriBinds
            self.wrappedModules.niriScripts
            self.wrappedModules.niriSettings
        ];

        config.scripts = {
            colorPicker = {
                bind = "Mod+Shift+C";
                packages = with pkgs; [ hyprpicker wl-clipboard ];
                text = ''
                    hyprpicker | wl-copy
                '';
            };

            screenshotRegion = {
                bind = "Mod+Shift+S";
                packages = with pkgs; [ grim slurp wl-clipboard ];
                text = ''
                    grim -g "$(slurp -w 0)" - | wl-copy
                '';
            };

            # Print takes a shot of the monitor that currently has focus.
            screenshotOutput = {
                bind = "Print";
                packages = with pkgs; [ grim jq wl-clipboard ];
                text = ''
                    output=$(${lib.getExe' config.package "niri"} msg --json focused-output | jq -r .name)
                    grim -o "$output" - | wl-copy
                '';
            };
        };
    };
}
