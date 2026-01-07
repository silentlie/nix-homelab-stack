{ config, pkgs, ... }:

{
  # Programming languages
  environment.systemPackages = with pkgs; [
    go
    python3
    python311Packages.pip
    nodejs
    rustup
    zsh
  ];
}
