# Homelab

## Networking

```bash
ip route | grep default # let u get all devices that are connected to your virtual bridge

ip neigh show dev vmbrlo
```

## ISO image generation

```bash
nix run nixpkgs#nixos-generators -- --format iso --flake /etc/nixos/#base -o result
```