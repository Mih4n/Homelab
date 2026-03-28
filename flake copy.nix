{
    inputs = {
        colmena.url = "github:zhaofengli/colmena";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        authentik.url = "github:nix-community/authentik-nix";
        mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
        proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
        vscode-server.url = "github:nix-community/nixos-vscode-server";

        zen-browser = {
            url = "github:youwen5/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        
        minegrub-world-sel-theme = {
            url = "github:Lxtharia/minegrub-world-sel-theme";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        home = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree";
        wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    };
 
    outputs = { nixpkgs, colmena, home, ... } @inputs: 
    let
        lib = nixpkgs.lib;
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            config = {
                allowUnfree = true;
            };
        };
    in {
        nixosConfigurations.desktop = lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/desktop/configuration.nix ];
        };

        nixosConfigurations.vpn = lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/vpn/configuration.nix ];
        };

        nixosConfigurations.bytes = lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/bytes/configuration.nix ];
        };

        nixosConfigurations.polygon = lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/polygon/configuration.nix ];
        };

        homeConfigurations.mih4n = home.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs; inherit system; };

            modules = [ ./homes/mih4n/home.nix ];
        };

        homeConfigurations.bytekeeper = home.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs; inherit system; };

            modules = [ ./homes/bytekeeper/home.nix ];
        };

        colmenaHive = let 
            user = "byteshaker";
        in colmena.lib.makeHive {
            meta = {
                nixpkgs = pkgs;
                specialArgs = { inherit inputs system; };
            };

            vpn = {
                deployment = {
                    targetUser = user;
                    targetHost = "157.180.52.198";
                };
                
                imports = [
                    ./systems/vpn/configuration.nix
                ];
            };

            polygon = {
                deployment = {
                    targetUser = user;
                    targetHost = "polygon.bytes";
                };

                imports = [
                    ./systems/polygon/configuration.nix
                ];
            };

            nextcloud = {
                deployment = {
                    targetUser = user;
                    targetHost = "nextcloud.bytes";
                };
                
                imports = [
                    ./systems/nextcloud/configuration.nix
                ];
            };
        };
    };
}
