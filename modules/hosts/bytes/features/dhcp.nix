{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.hostBytesDhcp = { ... }: {
        services.dnsmasq = {
            enable = true;
            # Не трогаем резолвер самого bytes: он ходит через systemd-resolved.
            resolveLocalQueries = false;

            settings = {
                # bytes (192.168.192.5) — DNS-сервер для vmbrlo: localNetworking
                # на всех хостах указывает nameservers именно сюда.
                port = 53;
                interface = "vmbrlo";
                # bind-interfaces падает с "unknown interface vmbrlo", если
                # dnsmasq стартует раньше networkd. bind-dynamic отслеживает
                # интерфейс и подхватывает его, когда тот появляется.
                bind-dynamic = true;

                no-resolv = true;
                server = [ "8.8.8.8" "1.1.1.1" ];

                dhcp-range = "192.168.192.50,192.168.192.100,255.255.255.0,12h";

                dhcp-option = [
                    "3,${s.net.gateway}"
                    "6,${s.net.dns}"
                ];

                dhcp-host = [
                    "bc:24:11:a7:fb:50,${s.net.ips.homeassistant}"
                ];
            };
        };

        # DHCP-запросы приходят на broadcast 255.255.255.255:67. Без этого
        # правила nixos-fw их дропает, и dnsmasq просто не видит клиентов.
        # 53 — чтобы клиенты vmbrlo могли ходить на 192.168.192.5 как в DNS.
        networking.firewall = {
            allowedTCPPorts = [ 53 ];
            allowedUDPPorts = [ 53 67 ];
        };

        # Не стартовать раньше, чем networkd настроит vmbrlo. Раньше здесь
        # упоминался несуществующий vmbrlo-nic.service, который ничего не ждал.
        systemd.services.dnsmasq = {
            after = [
                "network-online.target"
                "sys-subsystem-net-devices-vmbrlo.device"
            ];
            wants = [
                "network-online.target"
                "sys-subsystem-net-devices-vmbrlo.device"
            ];
        };
    };
}
