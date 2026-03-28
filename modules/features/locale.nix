{ ... }: {
    flake.nixosModules.locale = { ... }: {
        i18n.defaultLocale = "en_DK.UTF-8";
        time.timeZone = "Europe/Minsk";
    };
}