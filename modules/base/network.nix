{ config, pkgs, ... }:

{
  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
}
