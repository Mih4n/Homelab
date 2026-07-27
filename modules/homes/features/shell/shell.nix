{ ... }: {
    flake.homeModules.shell = { ... }: {
        programs.fish = {
            enable = true;

            shellInit = ''
                set -x EDITOR code
            '';

            interactiveShellInit = ''
                fish_vi_key_bindings

                function fish_mode_prompt
                end

                set -g fish_greeting ""

                function rerender_on_bind_mode_change --on-variable fish_bind_mode
                    if test "$fish_bind_mode" != "paste" -a "$fish_bind_mode" != "$FISH__BIND_MODE"
                        set -gx FISH__BIND_MODE $fish_bind_mode
                        omp_repaint_prompt
                    end
                end
            '';

            shellAliases = {
                lf = "lfcd";
                os = "nh os";
                home = "nh home";
            };
        };

        programs.oh-my-posh = {
            enable = true;
            enableFishIntegration = true;
            configFile = ./themes/gruvbox.json;
        };
    };
}