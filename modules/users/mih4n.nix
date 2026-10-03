{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.userMih4n = { ... }: {
        users.users.${s.users.main} = {
            isNormalUser = true;
            description = "Mikhail";
            hashedPassword = "$6$INGxsfVqSAB.Il9c$8jOKz5AaQeCrfD8ivJj4Z4bSJFxPUnip1ibeTs07KHNLpkuFvl8pF45s8AZKt970I8pvFSSiGXKLnb5ZVW/3U1";
            extraGroups = [ "networkmanager" "wheel" "docker" ];
            openssh.authorizedKeys.keys = s.sshKeys.yubikeys ++ [
                s.sshKeys.bytes
            ];
        };
    };
}
