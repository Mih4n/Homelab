{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.userMih4n = { config, ... }: {
        # Decrypted before the users are created.
        sops.secrets."users/${s.users.main}".neededForUsers = true;

        users.users.${s.users.main} = {
            isNormalUser = true;
            description = "Mikhail";
            hashedPasswordFile = config.sops.secrets."users/${s.users.main}".path;
            extraGroups = [ "networkmanager" "wheel" "docker" ];
            openssh.authorizedKeys.keys = s.sshKeys.yubikeys ++ [
                s.sshKeys.bytes
            ];
        };
    };
}
