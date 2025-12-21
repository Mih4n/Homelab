{ inputs, ... }: {
    imports = [
        inputs.authentik.nixosModules.default
    ];
    # services.authentik = {
    #     enable = true;
    #     # settings = 
    # };
}