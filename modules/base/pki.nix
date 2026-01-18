{ config, pkgs, ... }:

{
  security.pki.certificates= [
    (builtins.readFile "/etc/nixos/ca/root-ca.cer")
  ];
}
