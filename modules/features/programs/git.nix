{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.git = { ... }: {
        programs.git = {
            enable = true;
            config = {
                user.name = s.users.main;
                user.email = s.emails.personal;
            };
        };
    };
}