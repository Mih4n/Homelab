{ lib, ... }: {
    programs.git = {
        enable = lib.mkDefault true;
        config = {
            user.name = "mih4n";
            user.email = "losevmisha0@gmail.com";
        };
    };
}