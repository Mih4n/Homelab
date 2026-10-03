{ ... }: {
    flake.nixosModules.userByteshaker = { ... }: {
        users.users.byteshaker = {
            isNormalUser = true;
            description = "shakes the bytes";
            hashedPassword = "$6$bvLqmJC9EkyWW3OO$tBffaJnR4W299C8PR8hdfohBaVZLT9cBqzXsCM133uKFOy/GjeFOQ/ZY3sZv58rBr4CF3qH.zsioXe3T29mS11";
            extraGroups = [ "networkmanager" "wheel" ];
            openssh.authorizedKeys.keys = [
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDXIGLrBWkgdmTPpM1BKieVANmpUiYu1zonWsYg73uS+AAAACXNzaDpuaXhvcw== main-usbc@ssh"
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN2qiyNdRvCg162X494K+CWl4iBqLYN+ivtojBlAWccBAAAACXNzaDpuaXhvcw== main-usba@ssh"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG2HopF+e5dNqiwacnU8SCt1wSgCSLn0DEK4oDyqN2R bytekeeper@bytes"
            ];
        };
    };
}
