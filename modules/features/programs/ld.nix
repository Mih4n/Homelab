{ ... }: {
    flake.nixosModules.ld = { pkgs, ... }: {
        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
            stdenv.cc.cc
            zlib
            openssl
            icu
            curl
        ];
    };
}