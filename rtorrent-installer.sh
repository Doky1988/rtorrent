#!/usr/bin/env bash
set -euo pipefail

# --- Szerver IP lekérése ---
SERVER_IP=$(hostname -I | awk '{print $1}')

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
    read -rp "Add meg a domaint (pl. rt.domain.hu): " DOMAIN
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

# --- DOMAIN mód + HTTPS ---
if [[ "$MODE" == "2" ]]; then

# Caddyfile
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

# Docker compose domain módhoz
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

echo "=== Konténerek indítása ==="
docker compose up -d

echo
echo "============================================"
echo "      🎉 Telepítés sikeresen befejezve 🎉"
echo "============================================"
echo

if [[ "$MODE" == "1" ]]; then
  echo "🔧 Telepítési mód:"
  echo "   ➤ IP mód"
  echo
  echo "🌐 WebUI:"
  echo "   ➤ http://$SERVER_IP:8080"
else
  echo "🔧 Telepítési mód:"
  echo "   ➤ Domain mód"
  echo "     ⚠ IP-címről a WebUI tiltva van, de a Transdrone hozzáférést ez nem érinti."
  echo
  echo "🌐 WebUI:"
  echo "   ➤ https://$DOMAIN"
fi

echo
echo "📱 Transdrone:"
echo "   • Host: $SERVER_IP"
echo "   • Port: 8000"
echo "   • User: $RPC_USER"
echo "   • Pass: $RPC_PASS1"
echo "   • Path: /RPC2"
echo
echo "🚀 rTorrent + ruTorrent sikeresen fut!"
echo
