{ config, pkgs, ... }:

{
  # SSH Server Configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      X11Forwarding = false;
      PrintMotd = false;
    };
    ports = [ 22 ];
  };
}
