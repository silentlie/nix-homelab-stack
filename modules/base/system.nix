{ config, pkgs, ... }:

{
  imports = [
    ./tools.nix
  ];

  # System-wide configuration
  system.stateVersion = "25.11";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features for flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Automatic Nix garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # NTP time synchronization
  services.chrony.enable = true;

  # Swap configuration
  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];
}
