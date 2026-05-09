# Debt Destroyer Backend Deployment on Oracle Cloud Always Free

## Recommended Oracle shape

- **VM shape:** `VM.Standard.A1.Flex`
- **CPU / RAM:** up to `4 OCPU` and `24 GB RAM` (Always Free allocation)
- **OS:** Ubuntu 22.04/24.04 ARM64

## 1) Install Docker and Compose plugin

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

Log out/in once after adding your user to the docker group.

## 2) Prepare backend environment

```bash
cd backend
cp .env.example .env
```

Set production values in `.env`:

- `NODE_ENV=production`
- `TRUST_PROXY=true` (when behind Caddy/Nginx)
- strong JWT secrets
- valid `POSTGRES_URL` and `REDIS_URL` (service names are already defaulted in compose)
- valid Gemini and Google Play credentials

## 3) Build and run

```bash
docker compose build
docker compose up -d
docker compose ps
```

## 4) Logs and health checks

```bash
docker compose logs -f backend
curl -fsS http://127.0.0.1:8787/health/live
curl -fsS http://127.0.0.1:8787/health/ready
```

## 5) Database backup and restore

### Backup

```bash
docker compose exec -T postgres pg_dump -U postgres -d debt_destroyer > debt_destroyer_$(date +%F).sql
```

### Restore

```bash
cat debt_destroyer_2026-01-01.sql | docker compose exec -T postgres psql -U postgres -d debt_destroyer
```

## 6) Upgrade / rollback

### Upgrade

```bash
git pull
docker compose build backend
docker compose up -d backend
```

### Rollback

```bash
git checkout <previous_commit_or_tag>
docker compose build backend
docker compose up -d backend
```

## 7) Firewall and networking guidance

- Expose only **80/443** publicly via reverse proxy.
- Keep backend port `8787` private to localhost/internal network where possible.
- In OCI:
  - security list / NSG must allow inbound 80/443
  - allow SSH (22) only from trusted IPs
  - ensure route table + subnet + host firewall are aligned

## 8) Reverse proxy TLS (recommended)

Place Caddy or Nginx in front of backend:

- terminate TLS at proxy
- set `X-Forwarded-For` and `X-Forwarded-Proto`
- set `TRUST_PROXY=true` in backend

## 9) Oracle Always Free gotchas

1. Use **ARM64-compatible images** only.
2. Keep memory usage conservative (`NODE_OPTIONS=--max-old-space-size=512` as baseline).
3. Use persistent Docker volumes (`postgres_data`, `redis_data`).
4. Reserve static public IP if you need stable DNS mapping.
5. Monitor disk growth from Postgres and logs.
