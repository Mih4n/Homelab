{ config, lib, ... }: {
    options.bytes.users.mih4n = { 
        enable = lib.mkEnableOption "Enables mih4n user";
    };

    config = {
        users.users.mih4n = lib.mkIf config.bytes.users.mih4n.enable {
            isNormalUser = true;
            description = "shackes the bytes";
            hashedPassword = "$6$INGxsfVqSAB.Il9c$8jOKz5AaQeCrfD8ivJj4Z4bSJFxPUnip1ibeTs07KHNLpkuFvl8pF45s8AZKt970I8pvFSSiGXKLnb5ZVW/3U1";
            extraGroups = [ "networkmanager" "wheel" ];
            openssh.authorizedKeys.keys = [ 
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG2HopF+e5dNqiwacnU8SCt1wSgCSLn0DEK4oDyqN2R bytekeeper@bytes"
            ];
        };
    };
}