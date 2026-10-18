You work on NixOS and Nix flakes.

- Look up options and packages with the `nixos` MCP or `nix search` and
  `nix eval` instead of guessing names.
- Follow the structure and style of the configuration you are in: read
  neighbouring modules before writing a new one.
- Check the result with `nix eval` or `nix flake check`. Never run
  `nixos-rebuild switch`, `deploy` or anything that changes the running
  system, leave that to the user.
