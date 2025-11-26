#!/usr/bin/env bash
set -euo pipefail

echo "=== crazy-max rTorrent + ruTorrent Telepítő (IP / DOMAIN mód) ==="
echo
echo "Válassz elérési módot:"
echo "1) IP-ről érhető el (http://IP:8080)"
echo "2) Domainről érhető el (HTTPS + Caddy, IP tiltva)"
echo

read -rp "Választás (1/2): " MODE

if [[ "$MODE" != "1" && "$MODE" != "2" ]]; then
    echo "Érvénytelen választás!"
    exit 1
fi

if [[ "$MODE" == "2" ]]; then
    read -rp "Add meg a domaint (pl. torrent.domain.hu): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        echo "A domain nem lehet üres!"
        exit 1
    fi
fi

INSTALL_DIR="/opt/rtorrent-rutorrent"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# --- Auth bekérése ---
RPC_USER=""
while [ -z "$RPC_USER" ]; do
  read -rp "Add meg a ruTorrent / RPC felhasználónevet: " RPC_USER
done

RPC_PASS1=""
RPC_PASS2=""
while true; do
  read -srp "Add meg a jelszót: " RPC_PASS1; echo
  read -srp "Add meg újra: " RPC_PASS2; echo
  [[ "$RPC_PASS1" == "$RPC_PASS2" && -n "$RPC_PASS1" ]] && break
  echo "A jelszavak nem egyeznek!"
done

mkdir -p "$INSTALL_DIR/data" "$INSTALL_DIR/downloads" "$INSTALL_DIR/passwd"

# --- Docker telepítése ---
if ! command -v docker >/dev/null 2>&1; then
  echo "=== Docker telepítése ==="
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# --- htpasswd generálás ---
docker run --rm -i httpd:2.4-alpine htpasswd -Bbn "$RPC_USER" "$RPC_PASS1" > "$INSTALL_DIR/passwd/rutorrent.htpasswd"
docker run --rm -i httpd:2.4-alpine htpasswd -Bbn "$RPC_USER" "$RPC_PASS1" > "$INSTALL_DIR/passwd/rpc.htpasswd"

chown -R 1000:1000 "$INSTALL_DIR"

# -----------------------------
#   DOCKER-COMPOSE + CADDYFILE
# -----------------------------

echo "=== Konfiguráció generálása ==="

# --- IP mód ---
if [[ "$MODE" == "1" ]]; then
cat > "$INSTALL_DIR/docker-compose.yml" <<EOF
services:
  rtorrent_rutorrent:
    image: crazymax/rtorrent-rutorrent:latest
    container_name: rtorrent_rutorrent
    environment:
      - TZ=Europe/Budapest
      - PUID=1000
      - PGID=1000
    volumes:
      - ./data:/data
      - ./downloads:/downloads
      - ./passwd:/passwd
    ports:
      - 6881:6881/udp
      - 8080:8080
      - 8000:8000
      - 9000:9000
      - 50000:50000
    restart: unless-stopped
EOF
fi

# --- DOMAIN + HTTPS mód ---
if [[ "$MODE" == "2" ]]; then

# Javított Caddyfile
cat > "$INSTALL_DIR/Caddyfile" <<EOF
$DOMAIN {

    encode gzip zstd

    @static {
        path /js/* /css/* /plugins/* /share/* /themes/* /lang/* /images/*
    }

    reverse_proxy rtorrent_rutorrent:8080

    @block_ip {
        not host $DOMAIN
    }
    respond @block_ip 403
}
EOF

# Docker compose
cat > "$INSTALL_DIR/docker-compose.yml" <<EOF
services:

  rtorrent_rutorrent:
    image: crazymax/rtorrent-rutorrent:latest
    container_name: rtorrent_rutorrent
    environment:
      - TZ=Europe/Budapest
      - PUID=1000
      - PGID=1000
    volumes:
      - ./data:/data
      - ./downloads:/downloads
      - ./passwd:/passwd
    ports:
      - 6881:6881/udp
      - 8000:8000
      - 9000:9000
      - 50000:50000
    restart: unless-stopped

  caddy:
    image: caddy:latest
    container_name: caddy
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
    restart: unless-stopped
EOF
fi

# --- Konténerek indítása ---
echo "=== Konténerek indítása ==="
docker compose up -d

echo
echo "=== KÉSZ! Telepítés befejezve. ==="
echo

if [[ "$MODE" == "1" ]]; then
  echo "✔️ WebUI IP-ről:"
  echo "   http://<IP>:8080"
fi

if [[ "$MODE" == "2" ]]; then
  echo "✔️ WebUI HTTPS-en:"
  echo "   https://$DOMAIN"
  echo "❌ IP-ről: 403 tiltva"
fi

echo
echo "Transdrone / Transdroid beállítás:"
echo "   Host: <IP>"
echo "   Port: 8000"
echo "   User: $RPC_USER"
echo "   Pass: (amit megadtál)"
echo "   Path: /RPC2"
echo
echo "rTorrent + ruTorrent működik. Jó seedelést! 🚀"