{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/prod.nix
  ];

  networking.hostName = "apps";

  networking.useDHCP = false;

  networking.interfaces.ens18.ipv4.addresses = [{
    address = "192.168.1.40";
    prefixLength = 24;
  }];
}
