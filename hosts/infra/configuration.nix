{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/prod.nix
  ];

  networking = {
    hostName = "infra";
    useDHCP = false;
    interfaces.ens18 = {
      useDHCP = true;
      ipv4.addresses = [
        { address = "192.168.1.20"; prefixLength = 24; }
        { address = "192.168.1.21"; prefixLength = 24; }
      ];
    };
    firewall = {
      interfaces.ens18.allowedTCPPorts = [ 80 443 53 ];
      interfaces.ens19.allowedTCPPorts = [ 80 443 53 ];
      interfaces.ens18.allowedUDPPorts = [ 53 ];
      interfaces.ens19.allowedUDPPorts = [ 53 ];
    };
  };
}
