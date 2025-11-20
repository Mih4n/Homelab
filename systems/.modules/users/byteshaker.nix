{ config, lib, ... }: {
    options.bytes.users.byteshaker = { 
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable byteshaker user";
        };
    };

    config = {
        users.users.byteshaker = lib.mkIf config.bytes.users.byteshaker.enable {
            isNormalUser = true;
            description = "shackes the bytes";
            hashedPassword = "$6$bvLqmJC9EkyWW3OO$tBffaJnR4W299C8PR8hdfohBaVZLT9cBqzXsCM133uKFOy/GjeFOQ/ZY3sZv58rBr4CF3qH.zsioXe3T29mS11";
            extraGroups = [ "networkmanager" "wheel" ];
            openssh.authorizedKeys.keys = [ 
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG2HopF+e5dNqiwacnU8SCt1wSgCSLn0DEK4oDyqN2R bytekeeper@bytes"
            ];
        };
    };
}