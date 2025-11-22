{ inputs, system, ... }: {
    environment.systemPackages = [
       inputs.colmena.packages.${system}.colmena
    ];
}