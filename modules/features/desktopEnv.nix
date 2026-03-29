{ inputs, ... }: {
    flake.nixosModules.desktopEnv = { pkgs, ... }: {
        services.xserver.enable = true;

        networking.networkmanager.enable = true;

        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
            stdenv.cc.cc
            zlib
            openssl
            icu
            curl
        ];

        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };

        programs.steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
        };  

        services.xserver.xkb = {
            layout = "us,ru";
            variant = "";
        };

        programs.gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };

        services.printing.enable = true;

        environment.systemPackages = with pkgs; [
            # --- Communication & Social ---
            discord
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

            # --- Document Processing (Typst) ---
            typst
            typship
            tinymist
            plantuml

            # --- Compatibility & Virtualization ---
            docker
            bottles
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
            # 
        ];
    };
}