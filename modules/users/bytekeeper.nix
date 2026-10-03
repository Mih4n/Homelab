{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.userBytekeeper = { ... }: {
        users.users.${s.users.keeper} = {
            isNormalUser = true;
            description = "bytekeeper";
            extraGroups = [ "networkmanager" "wheel" ];
            hashedPassword = "$6$INGxsfVqSAB.Il9c$8jOKz5AaQeCrfD8ivJj4Z4bSJFxPUnip1ibeTs07KHNLpkuFvl8pF45s8AZKt970I8pvFSSiGXKLnb5ZVW/3U1";
            openssh.authorizedKeys.keys = [
                s.sshKeys.book
                s.sshKeys.desktop
            ] ++ s.sshKeys.yubikeys;
        };
    };
}
