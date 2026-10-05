{ self, ... }: let
    ignore = self.nextcloud.ignore;
in {
    flake.homeModules.nextcloudClient = { pkgs, lib, ... }: {
        services.nextcloud-client = {
            enable = true;
            startInBackground = true;
        };

        home.packages = [ pkgs.nextcloud-client ];

        # Пользовательский список исключений, дополняет системный из пакета клиента.
        # force: клиент мог оставить тут свою копию, её заменяем.
        xdg.configFile."Nextcloud/sync-exclude.lst" = {
            force = true;
            text = lib.concatLines (
                [ "# managed by home-manager, see settings/nextcloud.nix" ]
                ++ ignore.names
                ++ map (ext: "*${ext}") ignore.extensions
            );
        };
    };
}
