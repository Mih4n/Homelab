{ self, inputs, ... }: {
    perSystem = { pkgs, ... }: {
        packages.btop = inputs.wrapper-modules.wrappers.btop.wrap {
            inherit pkgs;
            imports = [ self.wrappedModules.btop ];
        };
    };

    flake.wrappedModules.btop = { ... }: let
        p = self.palette;
    in {
        config = {
            settings = {
                color_theme = "palette";
                theme_background = true;
                truecolor = true;
                rounded_corners = true;
                vim_keys = true;
            };

            themes.palette = ''
                theme[main_bg]="${p.bg}"
                theme[main_fg]="${p.fg}"
                theme[title]="${p.fg_bright}"
                theme[hi_fg]="${p.bright_blue}"
                theme[selected_bg]="${p.blue}"
                theme[selected_fg]="${p.on_accent}"
                theme[inactive_fg]="${p.bg4}"
                theme[graph_text]="${p.fg_muted}"
                theme[meter_bg]="${p.bg_sel}"
                theme[proc_misc]="${p.bright_aqua}"
                theme[cpu_box]="${p.border_strong}"
                theme[mem_box]="${p.border_strong}"
                theme[net_box]="${p.border_strong}"
                theme[proc_box]="${p.border_strong}"
                theme[div_line]="${p.border}"
                theme[temp_start]="${p.bright_aqua}"
                theme[temp_mid]="${p.bright_yellow}"
                theme[temp_end]="${p.bright_red}"
                theme[cpu_start]="${p.bright_green}"
                theme[cpu_mid]="${p.bright_yellow}"
                theme[cpu_end]="${p.bright_red}"
                theme[free_start]="${p.aqua}"
                theme[free_mid]="${p.aqua}"
                theme[free_end]="${p.bright_aqua}"
                theme[cached_start]="${p.blue}"
                theme[cached_mid]="${p.blue}"
                theme[cached_end]="${p.bright_blue}"
                theme[available_start]="${p.yellow}"
                theme[available_mid]="${p.yellow}"
                theme[available_end]="${p.bright_yellow}"
                theme[used_start]="${p.red}"
                theme[used_mid]="${p.red}"
                theme[used_end]="${p.bright_red}"
                theme[download_start]="${p.blue}"
                theme[download_mid]="${p.bright_blue}"
                theme[download_end]="${p.bright_aqua}"
                theme[upload_start]="${p.purple}"
                theme[upload_mid]="${p.bright_purple}"
                theme[upload_end]="${p.bright_orange}"
                theme[process_start]="${p.bright_green}"
                theme[process_mid]="${p.bright_yellow}"
                theme[process_end]="${p.bright_red}"
            '';
        };
    };
}
