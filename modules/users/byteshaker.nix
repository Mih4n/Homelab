{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.userByteshaker = { ... }: {
        users.users.${s.users.shaker} = {
            isNormalUser = true;
            description = "shakes the bytes";
            hashedPassword = "$6$bvLqmJC9EkyWW3OO$tBffaJnR4W299C8PR8hdfohBaVZLT9cBqzXsCM133uKFOy/GjeFOQ/ZY3sZv58rBr4CF3qH.zsioXe3T29mS11";
            extraGroups = [ "networkmanager" "wheel" ];
            openssh.authorizedKeys.keys = s.sshKeys.yubikeys ++ [
                s.sshKeys.bytes
            ];
        };
    };
}
