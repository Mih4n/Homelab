{ self, ... }: {
    flake.nixosModules.basicEnv = { pkgs, ... }: {
        imports = [
            self.nixosModules.nh
            self.nixosModules.git
            self.nixosModules.openssh
        ];

        environment.systemPackages = with pkgs; [ 
            vim
            wget
            btop
            nil
            nixd
            sops
            age
            kitty.terminfo
        ];
    };
}