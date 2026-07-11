{ config, lib, pkgs, ... }:

{
  imports = [
    ./languages.nix
    ./tools.nix
  ];

  # Support foreign executables such as VS Code Remote components.
  programs.nix-ld.enable = true;

  # Nix-built interpreters do not use NIX_LD_LIBRARY_PATH when loading
  # native modules installed by pip into a virtual environment.
  #
  # Expose the GCC runtime required by packages such as PyTorch.
  environment.sessionVariables.LD_LIBRARY_PATH =
    lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
    ];
}
