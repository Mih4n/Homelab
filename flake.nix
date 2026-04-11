{
    inputs = {
        colmena.url = "github:zhaofengli/colmena";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        authentik.url = "github:nix-community/authentik-nix";
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

        sops = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        homeManager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        winapps = {
            url = "github:winapps-org/winapps";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree";

        wrappers.url = "github:Lassulus/wrappers";
        wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    };
 
    outputs = inputs: let
        inherit (inputs.nixpkgs) lib;
        inherit (lib.fileset) toList fileFilter;

        isNixModule = file:
            file.hasExt "nix"
            && file.name != "flake.nix"
            && !lib.hasPrefix "_" file.name;

        importTree = path:
            toList (fileFilter isNixModule path);

        mkFlake = inputs.parts.lib.mkFlake {inherit inputs;};
    in
        mkFlake {imports = importTree ./.;};
}
