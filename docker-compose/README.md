# Docker Compose Deployment Guide

## Overview

Each host has its own docker-compose configuration managing containerized services:

- **apps/** - Nextcloud, Immich, PostgreSQL, Redis
- **infra/** - Traefik, Nginx, Vault, Authentik, Vaultwarden, Technitium DNS
- **obs/** - Prometheus, Grafana, Loki, Tempo, Uptime Kuma, Telegraf, Promtail

## Quick Start

### 1. Prepare Environment Variables

```bash
# For each directory, copy example to actual .env
cd docker-compose/apps
cp .env.example .env
# Edit .env with your values
nano .env

cd ../infra
cp .env.example .env
nano .env

cd ../obs
cp .env.example .env
nano .env
```

### 2. Deploy Services

```bash
# Apps host
cd docker-compose/apps
docker-compose up -d

# Infra host
cd docker-compose/infra
docker-compose up -d

# Obs host
cd docker-compose/obs
docker-compose up -d
```

### 3. Verify Services

```bash
docker-compose ps          # List services
docker-compose logs -f     # Follow logs
docker-compose health      # Check health
```

## Environment Configuration

### Apps Host (.env)

**Required variables:**
- `POSTGRES_PASSWORD` - Database password (strong!)
- `NEXTCLOUD_ADMIN_PASSWORD` - Nextcloud admin password
- `NEXTCLOUD_DOMAIN` - Your domain (e.g., nextcloud.example.com)

**Optional:**
- `NEXTCLOUD_PORT` - Default 8080
- `IMMICH_PORT` - Default 3001
- `POSTGRES_USER` - Default postgres

### Infra Host (.env)

**Required variables:**
- `AUTHENTIK_DB_PASSWORD` - Authentik database password
- `AUTHENTIK_SECRET_KEY` - Random string for secret key
- `VAULTWARDEN_DB_URL` - PostgreSQL connection string
- `LETSENCRYPT_EMAIL` - For Let's Encrypt certificates

**Optional:**
- DNS_PORT - Default 53
- TRAEFIK_HTTP_PORT - Default 80
- TRAEFIK_HTTPS_PORT - Default 443

### Obs Host (.env)

**Required variables:**
- `GRAFANA_ADMIN_PASSWORD` - Grafana admin password

**Optional:**
- `PROMETHEUS_PORT` - Default 9090
- `GRAFANA_PORT` - Default 3000
- `LOKI_PORT` - Default 3100
- `TEMPO_PORT` - Default 3200

## Network Architecture

All services on each host communicate via Docker network `homelab`:

```
Apps Host:
  ├── Nextcloud → PostgreSQL
  ├── Immich → PostgreSQL + Redis
  └── All in 'homelab' network

Infra Host:
  ├── Traefik → External traffic routing
  ├── Nginx → Internal traffic routing
  ├── Vault → Secrets
  ├── Authentik → Authentication
  └── All in 'homelab' network

Obs Host:
  ├── Prometheus → Metrics collection
  ├── Grafana → Visualization
  ├── Loki → Log aggregation
  ├── Tempo → Distributed tracing
  └── All in 'homelab' network
```

## Common Tasks

### View logs
```bash
docker-compose logs -f nextcloud
docker-compose logs -f prometheus --tail=100
```

### Restart service
```bash
docker-compose restart nextcloud
```

### Stop all services
```bash
docker-compose down
```

### Update images
```bash
docker-compose pull
docker-compose up -d
```

### Backup volumes
```bash
# Backup PostgreSQL
docker-compose exec -T postgres pg_dump -U postgres nextcloud > backup.sql

# Backup Nextcloud data
docker cp nextcloud:/var/www/html ./nextcloud_backup
```

### Access services

**Apps:**
- Nextcloud: http://HOST_IP:8080
- Immich: http://HOST_IP:3001

**Infra:**
- Traefik Dashboard: http://HOST_IP:8080
- Nginx: http://HOST_IP:8081
- Vault: http://HOST_IP:8200
- Authentik: http://HOST_IP:9000
- Vaultwarden: http://HOST_IP:8000
- Technitium DNS: http://HOST_IP:5380

**Obs:**
- Prometheus: http://HOST_IP:9090
- Grafana: http://HOST_IP:3000
- Loki: http://HOST_IP:3100

## Health Checks

Each service has healthchecks defined. Monitor with:

```bash
docker-compose ps
docker stats
```

## Persistence

All data persisted in Docker volumes:

**Apps:**
- `postgres_data` - Nextcloud + Immich databases
- `redis_data` - Immich cache
- `nextcloud_data` - Nextcloud files
- `immich_*` - Immich library and uploads

**Infra:**
- `vault_data` - Vault secrets
- `authentik_*` - Authentik data
- `vaultwarden_data` - Password manager data

**Obs:**
- `prometheus_data` - Metrics
- `grafana_data` - Dashboards and config
- `loki_data` - Logs
- `tempo_data` - Traces

Volumes survive container recreation and updates.

## Security Notes

1. **Change all passwords** in .env files
2. **Keep .env out of git** (add to .gitignore)
3. **Use strong passwords** (min 16 chars with mixed case/numbers/symbols)
4. **Network isolation** - Services only expose needed ports
5. **Health checks** - Automatically restart failed services

## Troubleshooting

### Port conflicts
```bash
# Find what's using the port
sudo lsof -i :8080
# Change port in .env or docker-compose.yml
```

### Out of disk space
```bash
# Clean up unused images/volumes
docker image prune
docker volume prune
```

### Container won't start
```bash
# Check logs
docker-compose logs -f SERVICE_NAME
# Verify env variables
docker-compose config
```

## Next Steps

1. Populate all .env files with actual values
2. Deploy to each host via NixOS (post-deployment)
3. Configure health monitoring in Prometheus
4. Set up Grafana dashboards
5. Configure Traefik SSL certificates

See main README.md for deployment workflow.
