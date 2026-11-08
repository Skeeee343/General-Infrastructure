# oak-pi3b — always-on DNS + KMS (Pi 3B+ 1GB)

Pi OS Lite 64-bit, hostname `oak-pi3b`, Ethernet, DHCP (static skipped for now).
No Docker / desktop / Unbound — 1GB RAM, light blocklists only.

## Stack (install in this order)

1. Base update
2. DuckDNS cron (keeps dynamic DNS fresh)
3. py-kms via systemd ([Py-KMS-Organization/py-kms](https://github.com/Py-KMS-Organization/py-kms))
4. Pi-hole last (official installer, takes over DNS/HTTP)

## Ports

| Port      | Service     | Notes                          |
|-----------|-------------|--------------------------------|
| 53/tcp+udp| Pi-hole     | LAN DNS                        |
| 80/tcp    | Pi-hole web | admin UI, set password there   |
| 1688/tcp  | py-kms      | LAN-only, never port-forward   |

## Rebuild from clean flash

```bash
# on the Pi (public repo — no login needed, replace YOU after first push)
curl -sSL https://raw.githubusercontent.com/Skeeee343/General-Infrastructure/main/oak-pi3b/setup.sh -o setup.sh
curl -sSL https://raw.githubusercontent.com/Skeeee343/General-Infrastructure/main/oak-pi3b/.env.example -o .env
nano .env   # fill DUCKDNS_DOMAIN + DUCKDNS_TOKEN
sudo bash ./setup.sh
```

Better: `git clone https://github.com/Skeeee343/General-Infrastructure.git`, then
`cd General-Infrastructure/oak-pi3b && cp .env.example .env && nano .env && sudo ./setup.sh`.
