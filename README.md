# NetBird VPS control plane (phase 2)

Target: Ubuntu 26.04 / Docker Compose / Caddy + caddy-l4 / PostgreSQL 17.

## Doppler secrets (set in your existing Doppler project/config)

- `NETBIRD_PG_PASSWORD`: `openssl rand -hex 24` (hex prevents Postgres DSN quoting trouble)
- `NETBIRD_RELAY_SECRET`: `openssl rand -hex 32`
- `NETBIRD_DATA_KEY`: `openssl rand -base64 32` (KEEP STABLE)
- `NETBIRD_COOKIE_KEY`: `openssl rand -base64 32` (KEEP STABLE)

## Check the Docker subnet

Confirm 172.30.0.0/24 does not overlap a host route or existing Docker network. If it does, update both the `compose.yaml` network/IP and `config.yaml.tpl` trusted IPs before starting.

## Start

```bash
sudo apt-get update && sudo apt-get install -y gettext-base
doppler run -- sh -eu -c '
  umask 077
  mkdir -p runtime
  envsubst '\''${NETBIRD_PG_PASSWORD}'\'' < config.yaml.tpl > runtime/config.yaml
  test -s runtime/config.yaml
  docker compose config -q
  docker compose up -d --build
'
```

Confirm `NETBIRD_PG_PASSWORD` is hex only (suggested above); it is safely interpolated into the quoted DSNs in `config.yaml.tpl`.

## Validate

```bash
docker compose ps
docker compose logs --tail=60 postgres netbird-server caddy dashboard
curl -fsSI https://netbird.jjcasa.net/
```

Then browse `https://netbird.jjcasa.net/setup` to create the first local administrator. Never commit `runtime/config.yaml`, database volume contents, the Doppler scoped token, or output from `docker compose config` (which may show secrets).

## Notes

The server's main store, embedded IdP store, and activity event store all use PostgreSQL databases on the same instance. Reverse proxy access logs follow the main store and thus use PostgreSQL by default in current NetBird. Caddy layer4 is installed but not enabled until phase 3. The host firewall should expose only 80/tcp, 443/tcp, 3478/udp and your restricted SSH port. No PostgreSQL port is published.
