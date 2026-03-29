{ ... }: {
    flake.homeModules.nextcloudClient = { pkgs, ... }: {
        programs.nextcloud-client = {
            enable = true;
            startInBackground = true;
        };

        home.packages = [ pkgs.nextcloud-client ];
    };
}