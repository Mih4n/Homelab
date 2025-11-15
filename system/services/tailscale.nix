{
    services.tailscale = {
        enable = true;
        useRoutingFeatures = "server";
    };

    services.tailscale.extraUpFlags = [
        "--advertise-routes=192.168.0.0/24"
    ];
}