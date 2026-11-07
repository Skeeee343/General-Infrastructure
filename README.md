# General-Infrastructure

Homelab source of truth. No snowflake Pis — every machine rebuilds from its folder.

## Layout

- `oak-pi3b/` — always-on DNS box (Pi 3B+ 1GB, Pi OS Lite 64-bit, hostname `oak-pi3b`)
- `<next-device>/` — same pattern: `README.md` (what/why/ports) + `setup.sh` + `.env.example`

## Rules

1. Rebuild from clean flash using only the device folder.
2. Secrets never committed. Real `.env` stays on the machine, only `.env.example` is tracked.
3. Public repo is fine because of rule 2 — it lets headless Pis `curl` setup.sh with no login.

## Add a new device

1. Copy `oak-pi3b/` skeleton to `<hostname>/`.
2. Write README (what/why/ports) first, then minimal `setup.sh`.
3. Test from clean flash before calling it done.
