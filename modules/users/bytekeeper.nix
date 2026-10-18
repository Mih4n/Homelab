{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.userBytekeeper = { config, ... }: {
        # Decrypted before the users are created.
        sops.secrets."users/${s.users.keeper}".neededForUsers = true;

        users.users.${s.users.keeper} = {
            isNormalUser = true;
            description = "bytekeeper";
            extraGroups = [ "networkmanager" "wheel" ];
            hashedPasswordFile = config.sops.secrets."users/${s.users.keeper}".path;
            openssh.authorizedKeys.keys = [
                s.sshKeys.book
                s.sshKeys.desktop
            ] ++ s.sshKeys.yubikeys;
        };
    };
}
