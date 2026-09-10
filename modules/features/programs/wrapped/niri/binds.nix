{ self, ... }: {
    # Keybinds and startup programs.
    flake.wrappedModules.niriBinds = { lib, pkgs, ... }: let
        noctalia = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaShell;

        action = _: { };
    in {
        config.settings = {
            spawn-at-startup = [ noctalia ];

            binds = {
                "Mod+T".spawn = "kitty";
                "Mod+Return".spawn = "kitty";
                "Mod+D".spawn-sh = "${noctalia} ipc call launcher toggle";

                "Mod+Q".close-window = action;
                "Mod+O".toggle-overview = action;
                "Mod+M".maximize-column = action;
                "Mod+F".fullscreen-window = action;
                "Mod+Shift+F".toggle-window-floating = action;

                "Mod+K".focus-window-up = action;
                "Mod+J".focus-window-down = action;
                "Mod+H".focus-column-left = action;
                "Mod+L".focus-column-right = action;

                "Mod+Up".focus-window-up = action;
                "Mod+Down".focus-window-down = action;
                "Mod+Left".focus-column-left = action;
                "Mod+Right".focus-column-right = action;

                "Mod+Ctrl+H".set-column-width = "-5%";
                "Mod+Ctrl+L".set-column-width = "+5%";
                "Mod+Ctrl+J".set-window-height = "-5%";
                "Mod+Ctrl+K".set-window-height = "+5%";

                "Mod+Shift+K".move-window-up = action;
                "Mod+Shift+J".move-window-down = action;
                "Mod+Shift+H".move-column-left = action;
                "Mod+Shift+L".move-column-right = action;

                "Mod+Alt+H".focus-monitor-left = action;
                "Mod+Alt+L".focus-monitor-right = action;
                "Mod+Alt+Left".focus-monitor-left = action;
                "Mod+Alt+Right".focus-monitor-right = action;

                "Mod+Alt+K".focus-workspace-up = action;
                "Mod+Alt+J".focus-workspace-down = action;
                "Mod+Alt+Up".focus-workspace-up = action;
                "Mod+Alt+Down".focus-workspace-down = action;

                "XF86AudioRaiseVolume".spawn = [ "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%+" ];
                "XF86AudioLowerVolume".spawn = [ "wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%-" ];

                "Mod+WheelScrollUp".focus-column-right = action;
                "Mod+WheelScrollDown".focus-column-left = action;
                "Mod+Alt+WheelScrollUp".focus-workspace-up = action;
                "Mod+Alt+WheelScrollDown".focus-workspace-down = action;
            };
        };
    };
}
