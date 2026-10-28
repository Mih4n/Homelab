{ self, ... }: {
    flake.wrappedModules.niriSettings = { config, lib, ... }: let
        p = self.palette;
        exist = _: {};
        xwayland = lib.getExe config.pkgs.xwayland-satellite;
    in {
        config.settings = {
            prefer-no-csd = exist;

            layout = {
                gaps = 10;

                focus-ring.off = exist;

                border = {
                    width = 1;
                    active-color = p.blue;
                    inactive-color = p.border;
                };
            };

            input = {
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
