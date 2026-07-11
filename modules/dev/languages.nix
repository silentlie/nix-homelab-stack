{ config, pkgs, ... }:

{
  # Programming languages
  environment.systemPackages = with pkgs; [
    go
    python3
    python3Packages.pip
    nodejs
    rustup
    zsh
  ];
}
