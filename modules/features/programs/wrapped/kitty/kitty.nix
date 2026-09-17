{ self, inputs, ... }: {
    perSystem = { pkgs, ... }: {
        packages.kitty = inputs.wrapper-modules.wrappers.kitty.wrap {
            inherit pkgs;
            imports = [ self.wrappedModules.kitty ];
        };
    };

    flake.wrappedModules.kitty = { ... }: let
        p = self.palette;
    in {
        config = {
            font = {
                name = "JetBrainsMonoNL Nerd Font";
                size = 11;
            };

            settings = {
                window_padding_width = "25 0 25 0";
                confirm_os_window_close = 0;

                scrollback_lines = 1500;
                pixel_scroll = true;
                wheel_scroll_multiplier = 10.0;

                detect_urls = true;
                url_style = "curly";

                background_opacity = 1;
                sync_to_monitor = true;

                input_delay = 1;
                cursor_shape = "beam";
                cursor_beam_thickness = 1;
                cursor_blink_interval = 0;

                enable_audio_bell = false;

                foreground = p.fg;
                background = p.bg;

                cursor = p.gray;
                cursor_text_color = "background";

                selection_foreground = p.bg_med;
                selection_background = p.fg;

                url_color = p.bright_blue;

                visual_bell_color = p.bright_aqua;
                bell_border_color = p.bright_aqua;

                active_border_color = p.bright_purple;
                inactive_border_color = p.bg_med;

                active_tab_foreground = p.fg_bright;
                active_tab_background = p.bg_med;
                inactive_tab_foreground = p.fg_muted;
                inactive_tab_background = p.bg_sel;

                color0 = p.bg;
                color1 = p.red;
                color2 = p.green;
                color3 = p.yellow;
                color4 = p.blue;
                color5 = p.purple;
                color6 = p.aqua;
                color7 = p.fg_muted;

                color8 = p.gray;
                color9 = p.bright_red;
                color10 = p.bright_green;
                color11 = p.bright_yellow;
                color12 = p.bright_blue;
                color13 = p.bright_purple;
                color14 = p.bright_aqua;
                color15 = p.fg;
            };

            keybindings = {
                "ctrl+c" = "copy_or_interrupt";
                "ctrl+v" = "paste_from_clipboard";
            };
        };
    };
}
