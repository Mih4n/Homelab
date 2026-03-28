{ ... }: {
    flake.nixosModules.basicEnv = { lib, pkgs, ... }: {
        environment.systemPackages = with pkgs; [ 
            vim
            wget
            btop
            nil
            nixd
            sops
            age
        ];

        programs.nh = {
            enable = lib.mkDefault true;
            clean.enable = true;
            clean.extraArgs = "--keep-since 4d --keep 3";
            flake = lib.mkDefault "/home/bytekeeper/nixos";
        };

        services.openssh = {
            enable = true;
            settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
            };
        };

        programs.git = {
            enable = lib.mkDefault true;
            config = {
                user.name = "mih4n";
                user.email = "losevmisha0@gmail.com";
            };
        };
    };
}