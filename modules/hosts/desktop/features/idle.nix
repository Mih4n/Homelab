{ ... }: {
    flake.nixosModules.hostDesktopIdle = { lib, config, pkgs, ... }: let
        niri = lib.getExe config.programs.niri.package;
        openrgb = lib.getExe pkgs.openrgb;

        lightsOff = "${openrgb} --profile lightsoff";
        lightsOn = "${openrgb} --profile default";
    in {
        services.logind.settings.Login.IdleAction = "ignore";

        systemd.user.services.desktop-idle = {
            description = "Turns the monitors and RGB off when idle";
            partOf = [ "graphical-session.target" ];
            after = [ "graphical-session.target" ];
            wantedBy = [ "graphical-session.target" ];

            serviceConfig = {
                ExecStart = lib.escapeShellArgs [
                    (lib.getExe pkgs.swayidle) "-w"
                    "timeout" "300" "${niri} msg action power-off-monitors; ${lightsOff}"
                    "resume" "${niri} msg action power-on-monitors; ${lightsOn}"
                ];
                Restart = "on-failure";
            };
        };
    };
}
