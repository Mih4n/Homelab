{ ... }: let
    fonts = {
        ui = "JetBrainsMono Nerd Font";
        mono = "JetBrainsMonoNL Nerd Font";
        size = 10;
    };
in {
    flake = { inherit fonts; };
}
