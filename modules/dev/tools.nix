{ config, pkgs, ... }:

{
  # Enable direnv integration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Enable and configure ZSH
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableGlobalCompInit = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    histFile = "$HOME/.cache/zsh/history";

    interactiveShellInit = ''
      # ZSH options
      setopt HIST_FIND_NO_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt SHARE_HISTORY
      setopt INC_APPEND_HISTORY

      # Vi key bindings
      bindkey -v
    '';
  };

  # Development and debugging tools
  environment.systemPackages = with pkgs; [
    vim
    colmena
    nixos-anywhere

    # Docker
    #docker
    #docker-compose

    # Enhanced command-line tools
    ripgrep # Fast grep (rg)
    fd # Fast find
    bat # Syntax-highlighted cat

    # Environment management
    direnv

    # Nix tools
    nixfmt # Nix code formatter
    nil # Nix language server

    # Shell tooling
    shellcheck # Shell linter
    shfmt # Shell formatter
    zsh # Z shell
  ];
}
