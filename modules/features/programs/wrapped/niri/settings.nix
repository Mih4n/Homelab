{ self, ... }: {
    # Host independent part of the niri config (former config.kdl).
    flake.wrappedModules.niriSettings = { config, lib, ... }: let
        p = self.palette;
        exist = _: {};
        xwayland = lib.getExe config.pkgs.xwayland-satellite;
    in {
        config.settings = {
            prefer-no-csd = exist;

            layout = {
                gaps = 10;

                focus-ring = {
                    width = 2;
                    active-color = p.blue;
                };
            };

            cursor = {
                xcursor-theme = "capitaine-cursors";
                xcursor-size = 32;
            };

            input = {
                focus-follows-mouse = exist;

                keyboard = {
                    xkb = {
                        layout = "us,ru";
                        options = "grp:alt_shift_toggle,caps:escape";
                    };

                    repeat-rate = 40;
                    repeat-delay = 250;
                };

                touchpad = {
                    tap = exist;
                    natural-scroll = exist;
                };

                mouse.accel-profile = "flat";
            };

            hotkey-overlay = {
                skip-at-startup = exist;
                hide-not-bound = exist;
            };

            window-rules = [
                {
                    clip-to-geometry = true;
                    geometry-corner-radius = 10;
                }
            ];

            xwayland-satellite.path = xwayland;
        };
    };
}
