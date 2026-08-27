{ ... }: {
    flake.nixosModules.hostPolygonWebsites = { ... }: {
        virtualisation.oci-containers.containers."takeapunch" = {
            image = "ghcr.io/mih4n/takeapunch:main";
            ports = [ "3001:3000" ];
        };

        virtualisation.oci-containers.containers."portfolio" = {
            image = "ghcr.io/mih4n/portfolio:main";
            ports = [ "3002:3000" ];
        };
    };
}