{ self, inputs, ... }: {
    flake.nixosModules.desktopEnv = { pkgs, ... }: {
        imports = [            
            self.nixosModules.ld
            self.nixosModules.nh
            self.nixosModules.git
            self.nixosModules.gtk
            self.nixosModules.steam
            self.nixosModules.gnupg
            self.nixosModules.xserver
            self.nixosModules.openssh

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
            discord
            obs-studio
            thunderbird
            telegram-desktop

            # --- Productivity & Office ---
            obsidian
            libreoffice-qt6-fresh
            gimp
            mission-center # System monitor

            # --- Development Tools (General) ---
            git
            wget
            kitty
            direnv
            dbeaver-bin
            vscode-fhs
            zed-editor
            
            # --- Compilers & Runtimes ---
            # Rust
            cargo
            rustc
            # Java
            jdk
            maven
            # .NET
            (with dotnetCorePackages; combinePackages [
                sdk_9_0
                sdk_10_0
            ])
            dotnet-ef
            # Node.js
            nodejs
            # python
            uv
            python314

            # --- Document Processing (Typst) ---
            typst
            typship
            tinymist
            plantuml

            # --- Compatibility & Virtualization ---
            docker
            # bottles
            steam-run # Run binaries not compiled for NixOS

            # --- Archive & Fonts ---
            zip
            unzip
            corefonts
            vista-fonts
            nerd-fonts.jetbrains-mono

            # --- Browser & Media ---
            inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

            # --- Empty category for future use ---
            kdePackages.ark
            kdePackages.elisa
            kdePackages.okular
            kdePackages.dolphin
            kdePackages.kdenlive
            kdePackages.spectacle
        ];
    };
}