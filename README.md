# Nix Homelab Stack

Base NixOS configs plus Docker Compose stacks for apps, infra, and observability.

## Layout
- `flake.nix` – NixOS entries for `apps`, `infra`, `obs`
- `hosts/` – per-host entrypoints (imports hardware + role)
- `roles/` – `prod.nix` (base) and `dev.nix` (base + dev tools)
- `modules/base/` – system, locale, users, ssh, network, docker, docs (`BASE.md`)
- `modules/dev/` – languages, tools, docs (`DEV.md`)
- `docker-compose/` – `apps/`, `infra/`, `obs/` stacks with `.env.example` and configs

## Usage
1) Copy hardware config per host (or template with /dev/sdX) and set hostname in `hosts/*/configuration.nix`.
2) Fill `docker-compose/*/.env` from `.env.example`.
3) Deploy NixOS:
	```bash
	nixos-rebuild switch --flake .#apps   # or infra / obs
	```
4) Start compose stacks on each host:
	```bash
	cd docker-compose/apps  && docker-compose up -d
	cd docker-compose/infra && docker-compose up -d
	cd docker-compose/obs   && docker-compose up -d
	```

## Notes
- SSH: key-only, root login disabled, firewall allows 22.
- Base packages include docker CLI; dev host adds extra tooling.
- Docs: see `modules/base/BASE.md` and `modules/dev/DEV.md`.
- License: GNU GPL v3.0 (see `LICENSE`).
