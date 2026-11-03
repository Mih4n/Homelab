{ self, ... }: {
    flake.nixosModules.basicEnv = { pkgs, ... }: let
        selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
        imports = [
            self.nixosModules.nh
            self.nixosModules.git
            self.nixosModules.openssh
        ];

        environment.systemPackages = with pkgs; [ 
            vim
            wget
            selfpkgs.btop
            nil
            nixd
            sops
            age
            ffmpeg
            kitty.terminfo
        ];
    };
}