# Dev Module

Development tools for the dev host.

## What it includes
- Programming languages: Go, Python3 + pip, Node.js, Rustup
- ZSH shell: enabled with completion, syntax highlighting, auto-suggestions, vi key bindings
- Dev tools: git, vim, curl, htop, nixos-rebuild, colmena, nixos-anywhere
- Containers: docker, docker-compose
- CLI upgrades: ripgrep (rg), fd, bat
- Environment: direnv (Bash + Zsh integration), nix-ld for VS Code remote
- Nix tooling: nixfmt (formatter), nil (language server)
- Shell tooling: shellcheck (linter), shfmt (formatter), zsh
- Extra CLI: jq, yq, tmux

## How it is wired
- Imported by `roles/dev.nix`
- `default.nix` enables `programs.nix-ld` for VS Code Remote SSH
- `tools.nix` contains:
  - `programs.zsh` configuration (completion, syntax highlighting, auto-suggestions)
  - `programs.direnv` enabled for Bash and Zsh
  - System packages (development tools, utilities)

## Typical usage
- Provision dev host with this module
- Use zsh as primary shell (configured with vi bindings)
- Use docker/docker-compose to test stacks
- Use direnv to load per-project `.env` files
- Use nixfmt + nil for Nix editing
- Use shellcheck + shfmt for shell scripts

## Customization
- Add more languages to `languages.nix`
- Add editor/CLI tools to `tools.nix`
- Modify ZSH configuration in `tools.nix` (`programs.zsh.interactiveShellInit`)
- If you prefer a different Nix language server, add `nixd` to `tools.nix`
