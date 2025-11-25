#!/usr/bin/env bash
set -euo pipefail

echo "============================================="
echo "  rTorrent + ruTorrent Update Script"
echo "  (Doky-féle seed szerver frissítő)"
echo "============================================="
sleep 1

# --- Root check ---
if [ "$EUID" -ne 0 ]; then
  echo "Ezt a scriptet rootként kell futtatni!"
  exit 1
fi

INSTALL_DIR="/opt/rtorrent"
COMPOSE_FILE="${INSTALL_DIR}/docker-compose.yml"

# --- Ellenőrzés: létezik-e a docker-compose.yml ---
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "HIBA: Nem találom a docker-compose.yml fájlt itt: $COMPOSE_FILE"
  echo "Biztos, hogy a Doky-féle telepítő scriptet használtad?"
  exit 1
fi

cd "$INSTALL_DIR"

echo "== Docker image-ek frissítése (pull) =="
docker compose pull

echo "== Konténerek újraindítása (up -d) =="
docker compose up -d

echo "== Nem használt image-ek törlése (prune) =="
docker image prune -f

echo ""
echo "============================================="
echo "  ✔ Frissítés kész!"
echo ""
echo "  A futó konténerek:"
docker compose ps
echo "============================================="
