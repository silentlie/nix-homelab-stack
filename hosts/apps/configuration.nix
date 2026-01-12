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

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [
    "127.0.0.1"
    "192.168.1.1"
  ];
  networking.search = [
    "home.arpa"
    "silencelie.dev"
  ];
}
