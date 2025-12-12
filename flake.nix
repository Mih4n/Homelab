{
    inputs = {
        colmena.url = "github:zhaofengli/colmena";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        authentik.url = "github:nix-community/authentik-nix";
        proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
        vscode-server.url = "github:nix-community/nixos-vscode-server";

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
 
    outputs = { nixpkgs, colmena, ... } @inputs: 
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
        nixosConfigurations.vpn = lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/vpn/configuration.nix ];
        };

        nixosConfigurations.base = lib.nixosSystem {
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

        colmenaHive = let 
            user = "byteshaker";
        in colmena.lib.makeHive {
            meta = {
                nixpkgs = import nixpkgs { inherit system; };
                specialArgs = { inherit inputs system; };
            };

            vpn = {
                deployment = {
                    targetUser = user;
                    targetHost = "79.137.205.90";
                };
                
                imports = [
                    ./systems/vpn/configuration.nix
                ];
            };

            nextcloud = {
                deployment = {
                    targetUser = user;
                    targetHost = "192.168.192.11";
                };
                
                imports = [
                    ./systems/nextcloud/configuration.nix
                ];
            };
        };
    };
}