# Base Modules Documentation

Base modules provide essential system-level configuration that's shared across all hosts (apps, infra, obs, dev, template).

## Overview

Base modules handle:
- System core settings (state version, package management, flakes)
- Time synchronization and locale
- Networking and firewall
- SSH access and security
- Docker containerization
- User management

All base modules are imported by each role and applied to their respective hosts.

## Module Breakdown

### `system.nix`

**Purpose:** Core system-wide configuration

**Features:**
- `system.stateVersion = "25.11"` - NixOS version compatibility
- `nixpkgs.config.allowUnfree = true` - Allows proprietary packages
- Flakes experimental features (`nix-command`, `flakes`)
- Automatic Nix garbage collection (weekly, deletes 30+ day old packages)
- NTP time synchronization via Chrony
- No swap configured at base; prefer per-host `swapDevices` in hardware config
- Imports `tools.nix` for packages and configuration

**When to modify:**
- Changing NixOS version (stateVersion)
- Enabling a global swap configuration (otherwise do it per-host)
- Enabling/disabling core services

**Note:** All hosts share this, so changes affect all (apps, infra, obs, dev, template)

---

### `tools.nix`

**Purpose:** System packages, aliases, and tool configuration

**Features:**
- Essential system packages: vim, git, curl, htop, tree, dnsutils, lsof, ss, nmap
- Bash aliases for navigation, safety, shortcuts, and utilities
- System-wide curl configuration (show-error, progress-bar, location)
- System-wide git configuration (user info, editor, push/pull defaults, merge tools)

**When to modify:**
- Adding/removing system-wide packages
- Adding new bash aliases
- Adjusting curl or git defaults

**Note:** All hosts share this, so changes affect all (apps, infra, obs, dev, template)

---

### `docker.nix`

**Purpose:** Docker container runtime configuration

**Features:**
- Docker daemon enabled
- Auto-cleanup (weekly) - removes unused images/containers
- Integrated with user groups (admin user has docker group)

**When to modify:**
- Changing docker storage drivers
- Adding docker daemon options
- Adjusting cleanup frequency

**Note:** Essential for service modules that use containerized apps

---

### `locale.nix`

**Purpose:** Internationalization and timezone settings

**Current Configuration:**
- **Timezone:** `Australia/Brisbane` (UTC+10)
- **Locale:** `en_AU.UTF-8` (Australian English)
- **Console keymap:** `US`

**Locale categories set to en_AU.UTF-8:**
- LC_ADDRESS, LC_IDENTIFICATION, LC_MEASUREMENT
- LC_MONETARY, LC_NAME, LC_NUMERIC
- LC_PAPER, LC_TELEPHONE, LC_TIME

**When to modify:**
- If you're in a different timezone/region
- To change currency/date/time formats
- To use different keyboard layouts

**Change example:**
```nix
time.timeZone = "Europe/London";
i18n.defaultLocale = "en_GB.UTF-8";
console.keyMap = "uk";
```

---

### `network.nix`

**Purpose:** Networking and firewall configuration

**Current Configuration:**
- Firewall enabled
- SSH port 22 allowed (TCP)

**When to modify:**
- Adding firewall rules (service modules do this)
- Changing default firewall policy
- Adding port forwarding/routing

**Important:** Service ports are typically opened on a per-host basis. The base `network.nix` only allows SSH (22). Each host configuration should specify its required ports based on the Docker Compose services it runs.

Example per-host ports:
```nix
# hosts/apps/configuration.nix
networking.firewall.allowedTCPPorts = [ 80 443 ]; # Nextcloud, Immich

# hosts/infra/configuration.nix
networking.firewall.allowedTCPPorts = [ 5432 6379 ]; # PostgreSQL, Redis

# hosts/obs/configuration.nix
networking.firewall.allowedTCPPorts = [ 3000 9090 ]; # Grafana, Prometheus
```

---

### `ssh.nix`

**Purpose:** SSH server hardening and security

**Current Configuration:**
- SSH enabled on port 22
- Root login disabled (`PermitRootLogin = "no"`)
- Password auth disabled (`PasswordAuthentication = false`)
- Public key auth enabled (`PubkeyAuthentication = true`)
- X11 forwarding disabled (`X11Forwarding = false`)
- No MOTD (`PrintMotd = false`)

**Security Notes:**
- Keys only - no passwords
- Can't login as root (use admin + sudo instead)
- X11 forwarding off (security for headless servers)
- No unnecessary services enabled

**When to modify:**
- Changing SSH port (also update firewall)
- Adding additional SSH hardening
- Adjusting auth methods

**Note:** VS Code Remote SSH needs nix-ld (added in dev module only)

---

### `users.nix`

**Purpose:** User account management

**Current Configuration:**
- **Username:** `admin`
- **Type:** Normal user (can use sudo)
- **Groups:** `wheel` (sudo access), `docker` (docker commands)
- **SSH Key:** Your public key (ssh-ed25519)
- **Sudo:** No password required for wheel group

**User Details:**
```nix
users.users.admin = {
  isNormalUser = true;
  description = "Admin user";
  extraGroups = [ "wheel" "docker" ];
  openssh.authorizedKeys.keys = [ "your-public-key" ];
}
```

**When to modify:**
- Adding additional users
- Changing group memberships
- Updating SSH keys
- Enabling password auth (not recommended)

**Group Explanations:**
- `wheel` - Unix tradition for admins, grants sudo access
- `docker` - Docker group, can run docker commands without sudo

**Security Note:** This is your only non-root user. Can't login as root via SSH (by design).

---

## How Base Modules Work

### Import Chain

```
Host Configuration (hosts/*/configuration.nix)
  └── Role (roles/*.nix)
      └── Base Modules (modules/base/*.nix)
          └── System configuration
```

Example (`roles/prod.nix`):
```nix
{ ... }:
{
  imports = [
    ../modules/base/system.nix
    ../modules/base/locale.nix
    ../modules/base/users.nix
    ../modules/base/docker.nix
    ../modules/base/network.nix
    ../modules/base/ssh.nix
  ];
}
```

**Note:** Service applications (Nextcloud, Immich, Prometheus, Grafana, etc.) are deployed using Docker Compose, not as NixOS modules. Base modules provide the foundation (Docker daemon, networking, users), and services run in containers managed by docker-compose.

### Hardware Configuration Conventions

Each host includes a generated `hardware-configuration.nix` that we keep aligned with these conventions:

- Root and boot mounts reference disks by-partlabel:
  - `/` → `/dev/disk/by-partlabel/root`
  - `/boot` → `/dev/disk/by-partlabel/boot`
- Boot filesystem options use `fmask=0022, dmask=0022`.
- Swap is disabled by default: `swapDevices = [ ];`

If you need swap on a specific host, set it in that host's hardware file, for example:

```nix
swapDevices = [
  { device = "/swapfile"; size = 4096; }
];
```

### NixOS Module Merging

NixOS automatically merges configuration from multiple modules:

```nix
# system.nix defines
environment.systemPackages = [ vim git curl ];

# ssh.nix defines (separate file)
services.openssh.enable = true;

# Result: Both applied
```

For lists (like firewall ports), NixOS concatenates:
```nix
# network.nix
networking.firewall.allowedTCPPorts = [ 22 ];

# nginx.nix (when added)
networking.firewall.allowedTCPPorts = [ 80 443 ];

# Result: [ 22 80 443 ]
```

---

## Customization Guide

### Per-Host Customization

To customize a specific host **without changing the base**:

Edit `hosts/HOST/configuration.nix`:
```nix
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../roles/ROLE.nix
  ];

  # Host-specific overrides
  networking.hostName = "myhost";

  # Example: override packages for this host only
  environment.systemPackages = with pkgs; [
    additional-tool
  ];
}
```

### Per-Role Customization

To customize all hosts in a role, edit `roles/ROLE.nix`:
```nix
{ ... }:
{
  imports = [
    ../modules/base/system.nix
    # ... other base modules
  ];

  # Role-specific settings applied to all hosts using this role
  custom.setting = true;
}
```

### System-Wide Customization

To change something for **all hosts**, modify base modules:
- Change timezone → edit `modules/base/locale.nix`
- Add packages → edit `modules/base/system.nix`
- Enable swap globally → edit `modules/base/system.nix` (otherwise set per-host in `hosts/*/hardware-configuration.nix`)

---

## Deployment

### Prerequisites
- SSH key pair (used in users.nix)
- Hardware configuration for each host
- Sufficient disk space (32GB minimum shown in your setup)

### Deployment Options

**Option 1: Direct NixOS deployment (if already running NixOS)**
```bash
sudo nixos-rebuild switch --flake .#HOSTNAME
```

**Option 2: Remote deployment (nixos-anywhere)**
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#HOSTNAME root@TARGET_IP
```

**Option 3: Manual/VM testing**
```bash
nix build .#nixosConfigurations.HOSTNAME.config.system.build.vm
./result/bin/run-*-vm
```

---

## Common Tasks

### Add a new package to all hosts
Edit `modules/base/tools.nix`, add to `environment.systemPackages`

### Add a package to dev host only
Edit `modules/dev/tools.nix`, add to `environment.systemPackages`

### Add a bash alias
Edit `modules/base/tools.nix`, add to `environment.shellAliases`

### Change git configuration
Edit `modules/base/tools.nix`, update git config in `environment.etc."gitconfig".text`

### Change curl defaults
Edit `modules/base/tools.nix`, update `environment.etc."curl/curlrc".text`

### Change timezone
Edit `modules/base/locale.nix`, update `time.timeZone`

### Add SSH port forwarding
Edit `modules/base/ssh.nix`, add to `services.openssh.settings`

### Update SSH authorized keys
Edit `modules/base/users.nix`, add key to `openssh.authorizedKeys.keys`

### Add a firewall rule for a service
Service ports for Docker Compose services can be added to `modules/base/network.nix`:
```nix
networking.firewall.allowedTCPPorts = [ 22 80 443 9090 3000 ];
```

Or create host-specific overrides in `hosts/*/configuration.nix`:
```nix
networking.firewall.allowedTCPPorts = [ 9090 3000 ]; # Prometheus, Grafana
```

---

## Service Deployment

This NixOS configuration provides the **base infrastructure** (system, Docker, networking, users, SSH). Application services are deployed separately using **Docker Compose**.

### Architecture
- **NixOS modules** → System foundation (base modules)
- **Docker Compose** → Application services (Nextcloud, Immich, Prometheus, Grafana, etc.)

### Deployment Workflow

1. **Deploy NixOS base:**
   ```bash
   nixos-rebuild switch --flake .#apps
   ```

2. **Deploy Docker Compose services:**
   ```bash
   cd docker-compose/apps
   cp .env.example .env
   # Edit .env with your configuration
   docker-compose up -d
   ```

### Benefits of this approach
- **Declarative system** - NixOS manages OS-level config
- **Flexible services** - Docker Compose for easy updates and rollbacks
- **Separation of concerns** - System config separate from application config
- **Easy testing** - Can test compose stacks on dev host before prod
- **Portability** - Compose stacks can run on any host with Docker

---

## Troubleshooting

### Can't SSH after deployment
- Verify SSH key is correct in `modules/base/users.nix`
- Check firewall allows port 22: `sudo iptables -L | grep 22`
- Try: `ssh -v admin@HOST` for verbose output

### Docker commands fail
- Verify admin user is in docker group: `id admin`
- May need to logout/login for group to take effect
- Try: `sudo usermod -aG docker admin` (shouldn't be needed)

### Locale/timezone not applied
- Run `timedatectl` to verify timezone
- Run `locale` to check locale settings
- May need reboot after configuration change

### Swap not created
- Swap is disabled by default in this setup. If you enabled it per-host, then:
- Check: `swapon --show`
- Verify filesystem has space: `df -h`
- Check logs: `journalctl -u systemd-makefs`

---

## Security Considerations

1. **SSH Key Security**
   - Keep private key secure (not in repo)
   - Public key in repo is safe
   - Rotate keys periodically

2. **Sudo without password**
   - Convenience vs security tradeoff
   - Only for trusted networks
   - Consider removing for exposed systems

3. **Root access disabled**
   - Can't login directly as root
   - Use admin + sudo instead
   - Improves audit trail

4. **Firewall**
   - Only SSH (22) allowed by default
   - Services add their own ports
   - Review final ruleset: `sudo nft list ruleset`

5. **Package management**
   - Unfree packages allowed (needed for infrastructure)
   - Flakes locked for reproducibility
   - Weekly cleanup prevents disk fill

---

## Next Steps

1. Verify all base modules match your requirements
2. Customize hostname/timezone if needed
3. Add hardware configurations per host
4. Configure service modules (Nginx, Prometheus, etc.)
5. Deploy to infrastructure

Base is solid - ready for services!
