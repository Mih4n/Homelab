{
    networking.useDHCP = false;
    networking.hostName = "bytes";
    networking.firewall.enable = false;
    networking.interfaces.enp4s0.useDHCP = false;

    networking.bridges.vmbr0.interfaces = [ "enp4s0" ];
    networking.interfaces.vmbr0.useDHCP = true;
}
