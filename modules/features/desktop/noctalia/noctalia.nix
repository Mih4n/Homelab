{ self, ... }: {
    perSystem = { pkgs, ... }: {
        packages.noctaliaShell = let
            p = self.palette;
            f = self.fonts;

            # Neutral surfaces, thin borders, the darker bg on hover and
            # light text over the accent fills, as on the portfolio.
            palette = {
                dark = {
                    mError = p.bright_red;
                    mHover = p.bg_hard;
                    mOnError = p.bg;
                    mOnHover = p.fg_bright;
                    mOnPrimary = p.on_accent;
                    mOnSecondary = p.on_accent;
                    mOnSurface = p.fg_bright;
                    mOnSurfaceVariant = p.fg;
                    mOnTertiary = p.on_accent;
                    mOutline = p.border;
                    mPrimary = p.blue;
                    mSecondary = p.aqua;
                    mShadow = p.bg_hard;
                    mSurface = p.bg;
                    mSurfaceVariant = p.bg;
                    mTertiary = p.green;
                    # Required: without it noctalia rejects the whole palette.
                    terminal = {
                        background = p.bg;
                        foreground = p.fg;
                        cursor = p.fg;
                        cursorText = p.bg;
                        selectionBg = p.bg_sel;
                        selectionFg = p.fg;
                        normal = {
                            black = p.bg; red = p.red; green = p.green; yellow = p.yellow;
                            blue = p.blue; magenta = p.purple; cyan = p.aqua; white = p.fg_muted;
                        };
                        bright = {
                            black = p.gray; red = p.bright_red; green = p.bright_green; yellow = p.bright_yellow;
                            blue = p.bright_blue; magenta = p.bright_purple; cyan = p.bright_aqua; white = p.fg;
                        };
                    };
                };
            };

            config = {
                theme = {
                    source = "custom";
                    custom_palette = "Portfolio";
                    mode = "dark";
                };

                shell = {
                    font_family = f.ui;
                    corner_radius_scale = 0.0;
                    avatar_path = "/home/mih4n/.face";
                    # Replaces polkit-gnome, don't run another agent next to it.
                    polkit_agent = true;
                    popup_shadows = false;
                    telemetry_enabled = false;
                    setup_wizard_enabled = false;
                    animation.speed = 0.7;
                    # Attached panels are drawn without a border.
                    panel = {
                        shadow = false;
                        control_center_placement = "floating";
                        session_placement = "floating";
                        wallpaper_placement = "floating";
                    };
                };

                bar.default = {
                    position = "bottom";
                    # Floating: margins from the screen edge and the ends.
                    margin_edge = 10;
                    margin_ends = 10;
                    radius = 0;
                    background_opacity = 0.93;
                    border_width = 1.0;
                    shadow = false;
                    capsule = false;
                    start = [ "launcher" ];
                    center = [ "workspaces" ];
                    end = [ "tray" "notifications" "battery" "brightness" "volume" "clock" "network" ];
                };

                widget = {
                    workspaces.labels_only_when_occupied = true;
                    clock = {
                        format = "{:%H:%M}";
                        tooltip_format = "{:%H:%M %a, %b %d}";
                    };
                    # Tray icons stay in a drawer until it's opened.
                    tray.drawer = true;
                    battery.display_mode = "graphic";
                    brightness.show_label = false;
                    volume.show_label = false;
                    network.show_label = false;
                };

                dock = {
                    enabled = true;
                    auto_hide = true;
                    border_width = 1.0;
                    shadow = false;
                    # Floating like the bar, flush to the edge the border is barely seen.
                    margin_edge = 10;
                    radius = 0;
                    # It hides anyway, reserving space only adds a gap above the bar.
                    reserve_space = false;
                };

                wallpaper.directory = "/home/mih4n/Pictures/Wallpapers";
                nightlight.enabled = true;
                # For the night light schedule and weather, the coordinates
                # are the fallback when geocoding the address fails offline.
                location = {
                    address = "Гомель";
                    latitude = 52.4345;
                    longitude = 30.9754;
                };

                # mpvpaper plays the wallpaper, mpv makes its thumbnails.
                plugins.enabled = [ "noctalia/mpvpaper" ];
            };

            configHome = pkgs.runCommand "noctalia-config" { } ''
                mkdir -p $out/noctalia/palettes
                cp ${(pkgs.formats.toml { }).generate "config.toml" config} $out/noctalia/config.toml
                cp ${pkgs.writeText "Portfolio.json" (builtins.toJSON palette)} $out/noctalia/palettes/Portfolio.json
            '';
        in pkgs.symlinkJoin {
            name = "noctalia-wrapped";
            paths = [ pkgs.noctalia ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
                rm $out/bin/noctalia
                makeWrapper ${pkgs.noctalia}/bin/noctalia $out/bin/noctalia \
                    --set NOCTALIA_CONFIG_HOME ${configHome} \
                    --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.mpvpaper pkgs.mpv ]}
            '';
            meta.mainProgram = "noctalia";
        };
    };
}
