{ config, lib, ... }: {
    options.bytes.users.bytekeeper = { 
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable bytekeeper user";
        };

        protection =  lib.mkOption {
            type = lib.types.enum [ "strict" "relaxed" ];
            default = "strict";
            description = "Determines how many SSH keys the user can authenticate with";
        };
    };

    config = lib.mkIf config.bytes.users.bytekeeper.enable {
        users.users.bytekeeper = {
            isNormalUser = true;
            description = "bytekeeper";
            extraGroups = [ "networkmanager" "wheel" ];
            hashedPassword = "$6$INGxsfVqSAB.Il9c$8jOKz5AaQeCrfD8ivJj4Z4bSJFxPUnip1ibeTs07KHNLpkuFvl8pF45s8AZKt970I8pvFSSiGXKLnb5ZVW/3U1";
            openssh.authorizedKeys.keys = let 
                book = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhGEuX/1xyax5qBKkpqj825TVcqVijbMbOHC5mVCA4I";
                desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvXrvxNmDVloK9YEOVrdj66uMy37crjc/3L7cgoQlro";
                desktop-resident = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGei9Q5d8VcpQ1XgsEVAC1Kty7EqYzel0RwpbwWDkJlIAAAACHNzaDptYWlu";

                allKeys = [ 
                    book 
                    desktop 
                    desktop-resident 
                ];
            in
                if config.bytes.users.bytekeeper.protection == "strict" then 
                    [ desktop-resident ]
                else 
                    allKeys; 
        };
    };
}