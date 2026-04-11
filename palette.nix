{ ... }: let 
    palette = {
        bg_hard   = "#1d2021"; 
        bg        = "#282828";
        bg_soft   = "#32302f";
        bg_sel    = "#3c3836";
        bg_med    = "#504945";
        
        fg        = "#ebdbb2";
        fg_muted  = "#a89984";
        fg_bright = "#fbf1c7";

        red       = "#cc241d";
        green     = "#98971a";
        yellow    = "#d79921";
        blue      = "#458588";
        purple    = "#b16286";
        aqua      = "#689d6a";
        orange    = "#d65d0e";
        gray      = "#928374";

        bright_red    = "#fb4934";
        bright_green  = "#b8bb26";
        bright_yellow = "#fabd2f";
        bright_blue   = "#83a598";
        bright_purple = "#d3869b";
        bright_aqua   = "#8ec07c";
        bright_orange = "#fe8019";
    };

    stripHash = str:
        if builtins.substring 0 1 str == "#"
        then builtins.substring 1 (builtins.stringLength str - 1) str
        else str;

    paletteNoHash = builtins.mapAttrs (_: v: stripHash v) palette;
in {
    flake = { inherit palette paletteNoHash; };
}