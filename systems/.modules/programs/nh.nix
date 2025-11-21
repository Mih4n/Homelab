{ pkgs, lib, ... }: {
    programs.nh = {
        enable = lib.mkDefault true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        flake = "/home/bytekeeper/nixos";
    };

    environment.systemPackages = with pkgs; [
        nix-output-monitor
        nvd
    ];
}