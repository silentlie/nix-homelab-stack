{ config, pkgs, ... }:

{
  # Admin user configuration
  users.users.admin = {
    isNormalUser = true;
    description = "Admin user";
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxBpUUqNe+y14bfpC/68sE4okqzLZ7vPsu4H92rMopW admin"
    ];
  };

  # Allow sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;
}
