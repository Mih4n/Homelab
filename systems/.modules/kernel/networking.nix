{ lib, ... }: {
    networking.useDHCP = lib.mkDefault true;
    networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
}