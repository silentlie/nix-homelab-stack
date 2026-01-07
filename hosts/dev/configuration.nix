{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/dev.nix
  ];

  networking.hostName = "dev";
}
