{ config, lib, pkgs, inputs, ... }: {
  imports = [ 
    ../.modules

    ./hardware-configuration.nix
    inputs.minegrub-world-sel-theme.nixosModules.default
  ];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    gfxmodeEfi = "1920x1080";
    minegrub-world-sel = {
      enable = true;
      customIcons = with config.system; [
        {
          inherit name;
          lineTop = with nixos; distroName + " " + codeName + " (" + version + ")";
          lineBottom = "Survival Mode, No Cheats, Version: " + nixos.release;
          imgName = "nixos";
        }
      ];
    };
    efiSupport = true;
  };
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = false;

  environment.systemPackages = with pkgs; [
    nerd-fonts.jetbrains-mono
    dbeaver-bin
    libreoffice
    tinymist
    typst
    typship
    plantuml
    dotnet-ef
    alsa-scarlett-gui
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.nh = {
    flake = lib.mkForce "/home/mih4n/NixOs";
  };

  bytes = {
    tailscale.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  bytes.hostName = "desktop";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Minsk";

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
  };

  programs.ssh = {
    startAgent = true;
  };
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.mih4n = {
    isNormalUser = true;
    description = "Mikhail";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      (with dotnetCorePackages; combinePackages [
        sdk_9_0
        sdk_10_0
      ])
      git
      discord
      telegram-desktop
      kitty
      vscode-fhs
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };  

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  system.stateVersion = "25.11";

}
