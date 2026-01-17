{ config, pkgs, ... }:

{
  security.pki.certificates= [
    ../../ca/root-ca.crt
  ];
}
