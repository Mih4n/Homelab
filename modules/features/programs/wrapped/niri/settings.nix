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

                # Like the 3px accent markers on the portfolio. A border, not a
                # focus ring: it is drawn around every window and takes the same
                # space on all of them, so only the color tells the focused one.
                focus-ring.off = exist;
                border = {
                    width = 3;
                    active-color = p.blue;
                    inactive-color = p.bg;
                };
            };

            cursor = {
                xcursor-theme = "capitaine-cursors";
                xcursor-size = 32;
            };

            input = {
                # Only focus windows that are already fully on screen, so
                # touching the screen edge doesn't scroll to the next column.
                focus-follows-mouse = _: { props.max-scroll-amount = "0%"; };

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
                    geometry-corner-radius = 0;
                }
                {
                    matches = [
                        {
                            app-id = "^openlogi-action-ring$";
                        }
                    ];
                    open-floating = true;
                    open-focused = true;
                    focus-ring.off = exist;
                    border.off = exist;
                }
            ];

            xwayland-satellite.path = xwayland;
        };
    };
}
