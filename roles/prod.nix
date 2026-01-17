{ ... }:

{
  imports = [
    ../modules/base/system.nix
    ../modules/base/locale.nix
    ../modules/base/users.nix
    ../modules/base/docker.nix
    ../modules/base/network.nix
    ../modules/base/ssh.nix
    ../modules/base/pki.nix
  ];
}
