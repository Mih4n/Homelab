{ ... }: {
    flake.homeModules.opencode = { ... }: {
        xdg.configFile."opencode/tui.json".text = builtins.toJSON {
            "$schema" = "https://opencode.ai/tui.json";
            theme = "gruvbox";
        };
    };
}
