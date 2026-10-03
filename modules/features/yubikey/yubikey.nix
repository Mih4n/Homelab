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

        security.pam = {
            services = {
                login.u2fAuth = true;
                sudo.u2fAuth = true;
            };

            yubico = {
                debug = true;
                enable = true;
                mode = "challenge-response";
                id = [
                    "30526977"
                    "20873179"
                ];
            };
        };
    };
}
