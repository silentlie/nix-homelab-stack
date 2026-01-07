{ config, pkgs, ... }:

{
  # Essential system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
    tree
    dnsutils
    lsof
    iproute2 # includes ss command
    nmap
  ];

  # Bash aliases
  environment.shellAliases = {
    # Navigation & Listing
    ll = "ls -la";
    la = "ls -A";
    l = "ls -CF";
    ".." = "cd ..";
    "..." = "cd ../..";

    # Safety
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";

    # Shortcuts
    c = "clear";
    h = "history";
    grep = "grep --color=auto";
    df = "df -h";
    du = "du -h";
    free = "free -h";

    # Misc
    please = "sudo";
    fucking = "sudo";
    myip = "curl ifconfig.me";
    ports = "netstat -tulanp";
  };

  # System-wide curl config
  environment.etc."curl/curlrc".text = ''
    show-error
    progress-bar
    location
  '';

  # System-wide git config
  environment.etc."gitconfig".text = ''
    [user]
      name = Linh Tuan Nguyen
      email = 52875747+silentlie@users.noreply.github.com
    [core]
      editor = code --wait
    [push]
      default = simple
      autoSetupRemote = true
    [pull]
      ff = only
    [diff]
      tool = default-difftool
    [difftool "default-difftool"]
      cmd = code --wait --diff $LOCAL $REMOTE
    [merge]
      tool = code
    [mergetool "code"]
      cmd = code --wait --merge $REMOTE $LOCAL $BASE $MERGED
  '';
}
