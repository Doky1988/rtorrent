#!/usr/bin/env bash
set -euo pipefail

echo "=== rTorrent + ruTorrent Update Script ==="
echo

INSTALL_DIR="/opt/rtorrent-rutorrent"

# Mappa ellenőrzése
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "❌ Hiba: A telepítés nem található itt: $INSTALL_DIR"
  exit 1
fi

cd "$INSTALL_DIR"

echo "📥 Legújabb image-ek letöltése..."
docker compose pull

echo
echo "🔄 Konténerek frissítése..."
docker compose up -d

echo
echo "🧹 Régi, nem használt image-ek törlése..."
docker system prune -f

echo
echo "============================================"
echo "      ✔ Frissítés sikeresen befejeződött"
echo "============================================"
echo
echo "🚀 rTorrent + ruTorrent a legújabb verzióval fut!"
echo
