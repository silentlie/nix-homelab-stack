{ config, pkgs, ... }:

{
  imports = [
    ./languages.nix
    ./tools.nix
  ];

  # Enable nix-ld for VS Code Remote SSH compatibility
  programs.nix-ld.enable = true;
}
