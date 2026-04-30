{ ... }: {
    flake.nixosModules.gaming = { pkgs, ... }: {
        programs = {
            gamemode.enable = true;
            gamescope.enable = true;
            steam = {
                enable = true;
                protontricks.enable = true;
                remotePlay.openFirewall = true;
                dedicatedServer.openFirewall = true;
            };
        };  

        environment.systemPackages = with pkgs; [
            steam-run

            gamescope
            mangohud
            r2modman

            heroic
            # lutris
            # bottles

            er-patcher

            steamtinkerlaunch

            prismlauncher

            dxvk
            lsfg-vk
            lsfg-vk-ui
        ];
    };
}