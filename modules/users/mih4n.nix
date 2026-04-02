{ ... }: {
    flake.nixosModules.userMih4n = { ... }: {
        users.users.mih4n = {
            isNormalUser = true;
            description = "Mikhail";
            hashedPassword = "$6$INGxsfVqSAB.Il9c$8jOKz5AaQeCrfD8ivJj4Z4bSJFxPUnip1ibeTs07KHNLpkuFvl8pF45s8AZKt970I8pvFSSiGXKLnb5ZVW/3U1";
            extraGroups = [ "networkmanager" "wheel" "docker" ];
            openssh.authorizedKeys.keys = [ 
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG2HopF+e5dNqiwacnU8SCt1wSgCSLn0DEK4oDyqN2R bytekeeper@bytes"
            ];
        };
    };
}