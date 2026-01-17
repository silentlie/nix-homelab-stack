{ config, pkgs, ... }:

{
  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  networking.dhcp.enable = true;
  networking.dns.enable = true;

  networking.defaultGateway = "192.168.1.1";
  networking.search = [
    "home.arpa"
    "silencelie.dev"
  ];
}
