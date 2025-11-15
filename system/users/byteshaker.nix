{ config, lib, ... }: {
    options.bytes.users.byteshaker = { 
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable byteshaker user";
        };
    };

    config = lib.mkIf config.bytes.users.byteshaker.enable {
        users.users.byteshaker = {
            isNormalUser = true;
            description = "shackes the bytes";
            extraGroups = [ "networkmanager" "wheel" ];
            openssh.authorizedKeys.keys = [  ];
        };
    };
}