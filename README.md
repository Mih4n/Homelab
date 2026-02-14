# Homelab

## Networking

```bash
ip route | grep default # let u get all devices that are connected to your virtual bridge

ip neigh show dev vmbrlo
```

## Sops 

```bash 
sops updatekeys ./secrets/secrets.yaml
```

## Agekey generation

```bash
# generates key
sudo nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key | nix shell nixpkgs#age -c age-keygen -y
```

## ISO image generation

```bash
#genereate iso
nix run nixpkgs#nixos-generators -- --format iso --flake /etc/nixos/#base -o result

#apply initial config to the system 
nix run github:nix-community/nixos-anywhere -- --flake .#base --generate-hardware-config nixos-generate-config ./hardware-configuration.nix user@host
```