{ config, pkgs, ... }:

{
  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  dhcp.enable = true;
  dhcp.dns = true;

  networking.defaultGateway = "192.168.1.1";
  networking.search = [
    "home.arpa"
    "silencelie.dev"
  ];
}
