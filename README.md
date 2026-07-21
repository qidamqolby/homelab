# Homelab Infrastructure

Infrastructure as Code (IaC) repository for my personal development server.

This repository contains Docker Compose configurations, backup & restore scripts, and infrastructure-related automation.

---

## Environment

| Component | Value |
|----------|-------|
| OS | Ubuntu Server 24.04 LTS |
| Container Runtime | Docker Engine |
| Orchestration | Docker Compose |
| Network | `dev-network` |

---

## Repository Structure

```text
.
├── cloudflared/
├── databases/
│   ├── postgres/
│   ├── mariadb/
│   ├── mongodb/
│   └── redis/
├── minio/
├── scripts/
│   ├── backup/
│   ├── restore/
│   └── maintenance/
├── uptime-kuma/
├── .gitignore
└── README.md
```

---

## Services

| Service | Purpose |
|----------|---------|
| PostgreSQL | Relational Database |
| MariaDB | Relational Database |
| MongoDB | Document Database |
| Redis | Cache / In-memory Database |
| MinIO | S3-Compatible Object Storage |
| Uptime Kuma | Monitoring |
| Cloudflared | Cloudflare Tunnel |

---

## Backup & Restore

Backup scripts:

```text
scripts/backup/
```

Restore scripts:

```text
scripts/restore/
```

---

## Maintenance

Available utility scripts:

```text
scripts/maintenance/
```

- `docker-status.sh`
- `docker-cleanup.sh`

---

## Configuration

Each service provides:

```text
.env.example
```

Create your own configuration:

```bash
cp .env.example .env
```

Update the values according to your environment.

---

## Git Ignore

The following files and directories are intentionally excluded:

- `.env`
- database data
- backups
- logs
- runtime data

---

## License

Private repository.
