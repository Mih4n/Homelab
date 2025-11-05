{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        sops-nix.url = "github:Mic92/sops-nix";
        authentik.url = "github:nix-community/authentik-nix";
        impermanence.url = "github:nix-community/impermanence";
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
                inputs.sops-nix.nixosModules.sops
                inputs.authentik.nixosModules.default
                inputs.vscode-server.nixosModules.default
                inputs.proxmox-nixos.nixosModules.proxmox-ve
                inputs.impermanence.nixosModules.impermanence

                ./system/configuration.nix
            ];
        };
    };
}
