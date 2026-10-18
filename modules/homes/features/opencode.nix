{ ... }: {
    # The rest of opencode is configured system wide in the localAi feature,
    # the TUI only reads its settings from the user's config directory.
    flake.homeModules.opencode = { ... }: {
        xdg.configFile."opencode/tui.json".text = builtins.toJSON {
            "$schema" = "https://opencode.ai/tui.json";
            # Dark medium, the same palette as settings/palette.nix.
            theme = "gruvbox";
        };
    };
}
