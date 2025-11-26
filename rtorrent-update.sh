#!/usr/bin/env bash
set -euo pipefail

echo "=== rTorrent + ruTorrent UPDATE (crazy-max) ==="

INSTALL_DIR="/opt/rtorrent-rutorrent"
cd "$INSTALL_DIR"

CONTAINER="rtorrent_rutorrent"
CADDY_CONTAINER="caddy"

# Ellenőrzés
if [ ! -f "$INSTALL_DIR/docker-compose.yml" ]; then
  echo "HIBA: Nincs docker-compose.yml! Rossz könyvtár vagy nincs telepítés?"
  exit 1
fi

echo "Telepítési könyvtár: $INSTALL_DIR"
echo

# 1) Legújabb image letöltése
echo "→ Legújabb rTorrent image letöltése..."
docker pull crazymax/rtorrent-rutorrent:latest

# 2) Konténer leállítása
echo "→ rTorrent konténer leállítása..."
docker stop "$CONTAINER" >/dev/null 2>&1 || true

# 3) Konténer törlése (csak a futó container, az adat megmarad)
echo "→ rTorrent konténer eltávolítása..."
docker rm "$CONTAINER" >/dev/null 2>&1 || true

# 4) Új rTorrent konténer indítása a docker-compose alapján
echo "→ Konténerek újraindítása docker-compose segítségével..."
docker compose up -d rtorrent_rutorrent

# 5) Ha van Caddy, azt nem kell törölni — csak optional restart
if docker ps --format '{{.Names}}' | grep -q "^${CADDY_CONTAINER}$"; then
  echo "→ Caddy konténer frissítetlen, de újraindítjuk hogy stabil maradjon..."
  docker restart "$CADDY_CONTAINER" >/dev/null 2>&1 || true
fi

echo
echo "=== KÉSZ! rTorrent + ruTorrent sikeresen FRISSÍTVE. ==="
echo
echo "Elérés:"
if docker ps --format '{{.Names}}' | grep -q "^${CADDY_CONTAINER}$"; then
  echo "  HTTPS WebUI: (domained)"
else
  echo "  http://<IP>:8080"
fi

echo
echo "Napló megtekintés:"
echo "  docker logs -f $CONTAINER"
echo
echo "Jó seedelést továbbra is! 🚀"