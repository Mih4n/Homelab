{ ... }: {
    flake.nixosModules.yubikey = { pkgs, ... }: {
        services.udev.packages = [ pkgs.yubikey-personalization ];

        programs.ssh.extraConfig = ''
            IdentityFile ${./keys/id_yk_usbc}
            IdentityFile ${./keys/id_yk_usba}
        '';

        programs.gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };

        services.pcscd.enable = true;

        systemd.tmpfiles.rules = [ "d /var/lib/yubico 0700 root root -" ];
        systemd.services."polkit-agent-helper@".serviceConfig.ReadWritePaths = [ "/var/lib/yubico" ];

        security.pam = {
            services = {
                login.u2fAuth = true;
                sudo.u2fAuth = true;
            };

            yubico = {
                enable = true;
                mode = "challenge-response";
                challengeResponsePath = "/var/lib/yubico";
                id = [
                    "30526977"
                    "20873179"
                ];
            };
        };
    };
}
