{
    inputs = {
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
 
    outputs = { nixpkgs, ... } @inputs: 
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

        nixosConfigurations.base = nixpkgs.lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/base/configuration.nix ];
        };

        nixosConfigurations.bytes = nixpkgs.lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/bytes/configuration.nix ];
        };

        nixosConfigurations.nextcloud = nixpkgs.lib.nixosSystem {
            inherit lib;
            inherit pkgs;
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [ ./systems/nextcloud/configuration.nix ];
        };
    };
}