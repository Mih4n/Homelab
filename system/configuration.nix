{
    imports = [ 
        ./users/.users.nix
        ./modules/.modules.nix
        ./packages/.packages.nix
        ./services/.services.nix
        ./programs/.programs.nix
        ./hardware-configuration.nix
    ];

    time.timeZone = "Europe/Minsk";
    i18n.defaultLocale = "en_US.UTF-8";

    system.stateVersion = "25.05";
}
