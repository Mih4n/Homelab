{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
        vscode-server.url = "github:nix-community/nixos-vscode-server";
    };
 
    outputs = { nixpkgs, ... } @inputs: 
    let
        lib = nixpkgs.lib;
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
    in {
        nixosConfigurations.bytes = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs system; };

            modules = [
                inputs.vscode-server.nixosModules.default
                inputs.proxmox-nixos.nixosModules.proxmox-ve

                ./system/configuration.nix
            ];
        };
    };
}
