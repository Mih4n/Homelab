{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.userByteshaker = { config, ... }: {
        # Decrypted before the users are created.
        sops.secrets."users/${s.users.shaker}".neededForUsers = true;

        users.users.${s.users.shaker} = {
            isNormalUser = true;
            description = "shakes the bytes";
            hashedPasswordFile = config.sops.secrets."users/${s.users.shaker}".path;
            extraGroups = [ "networkmanager" "wheel" ];
            openssh.authorizedKeys.keys = s.sshKeys.yubikeys ++ [
                s.sshKeys.bytes
            ];
        };
    };
}
