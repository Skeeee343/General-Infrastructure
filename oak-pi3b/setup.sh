#!/usr/bin/env bash
# oak-pi3b rebuild: base -> duckdns cron -> py-kms (systemd) -> pi-hole (last, interactive).
# Usage: cp .env.example .env && nano .env && sudo ./setup.sh
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run as root: sudo ./setup.sh"; exit 1; }
DEVICE_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$DEVICE_DIR/.env"
[ -f "$ENV_FILE" ] || { echo "Missing $ENV_FILE — cp .env.example .env first"; exit 1; }
set -a; . "$ENV_FILE"; set +a
: "${DUCKDNS_DOMAIN:?set DUCKDNS_DOMAIN in .env}"
: "${DUCKDNS_TOKEN:?set DUCKDNS_TOKEN in .env}"

# 0. hostname
[ "$(hostname)" = "oak-pi3b" ] || hostnamectl set-hostname oak-pi3b

# 1. base
apt-get update && apt-get full-upgrade -y
apt-get install -y git python3 curl cron

# 2. duckdns cron (every 5 min)
cat > /usr/local/sbin/duckdns-update.sh <<EOF
#!/bin/sh
curl -fsS "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&ip=" -o /var/log/duckdns.log
EOF
chmod +x /usr/local/sbin/duckdns-update.sh
echo "*/5 * * * * root /usr/local/sbin/duckdns-update.sh" > /etc/cron.d/duckdns
/usr/local/sbin/duckdns-update.sh || echo "DuckDNS first update failed — check domain/token"

# 3. py-kms (maintained Py-KMS-Organization fork; SystemRage is abandoned, breaks on py3.10+) on tcp/1688, LAN-only = do not port-forward
if [ -d /opt/py-kms/.git ]; then git -C /opt/py-kms pull --ff-only; else rm -rf /opt/py-kms && git clone --depth 1 https://github.com/Py-KMS-Organization/py-kms.git /opt/py-kms; fi
cat > /etc/systemd/system/py-kms.service <<EOF
[Unit]
Description=py-kms KMS emulator
After=network-online.target
Wants=network-online.target
[Service]
Type=simple
Restart=always
RestartSec=1
User=root
WorkingDirectory=/opt/py-kms/py-kms
ExecStart=/usr/bin/python3 /opt/py-kms/py-kms/pykms_Server.py 0.0.0.0 1688
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now py-kms

# 4. pi-hole LAST — official installer, interactive (takes over ports 53/80)
curl -sSL https://install.pi-hole.net | bash

echo "Done. Pi-hole on :80, KMS on :1688 (LAN-only). Reboot recommended."
