{ self, inputs, ... }: {
    flake.nixosModules.desktopEnv = { pkgs, ... }: let
        selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {
        imports = [
            self.nixosModules.ld
            self.nixosModules.gtk
            self.nixosModules.qt
            self.nixosModules.gnupg
            self.nixosModules.gaming
            self.nixosModules.xserver
            self.nixosModules.preferences

            self.nixosModules.lsp
            self.nixosModules.toolchains
            self.nixosModules.cliTools
            self.nixosModules.basicEnv
        ];

        networking.networkmanager.enable = true;

        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
        };

        services = {
            flatpak.enable = true;
            hardware.openrgb.enable = true;
        };

        services.printing.enable = true;

        fonts.packages = with pkgs; [
            corefonts
            vista-fonts
            nerd-fonts.jetbrains-mono
        ];

        environment.systemPackages = with pkgs; [
            # --- Communication & Social ---
            vesktop
            obs-studio
            easyeffects
            thunderbird
            telegram-desktop

            # --- Productivity & Office ---
            blender
            claude-code
            obsidian
            super-productivity
            libreoffice-qt6-fresh
            gimp
            onlyoffice-desktopeditors
            mission-center # System monitor

            # --- Development Tools (General) ---
            selfpkgs.kitty
            direnv
            dbeaver-bin
            vscode-fhs
            zed-editor
            devenv
            deploy-rs
            godot-mono

            # --- Compatibility & Virtualization ---
            docker
            # bottles
            steam-run # Run binaries not compiled for NixOS

            # --- Archive ---
            zip
            unzip

            # --- Browser & Media ---
            inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
            inputs.bedrock-on-linux.packages.${pkgs.stdenv.hostPlatform.system}.default

            # -- Gnome --
            loupe
            nautilus
            sushi

            # --- Media ---
            mpv

            # --- KDE ---
            kdePackages.ark
            kdePackages.elisa
            kdePackages.okular
            kdePackages.dolphin
            kdePackages.kdenlive
            kdePackages.spectacle
        ];
    };
}
