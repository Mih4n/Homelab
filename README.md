# Homelab

## Networking

```bash
ip route | grep default # let u get all devices that are connected to your virtual bridge

ip neigh show dev vmbrlo
```

## ISO image generation

```bash
#genereate iso
nix run nixpkgs#nixos-generators -- --format iso --flake /etc/nixos/#base -o result

#apply initial config to the system 
nix run github:nix-community/nixos-anywhere -- --flake .#base --generate-hardware-config nixos-generate-config ./hardware-configuration.nix user@host
```