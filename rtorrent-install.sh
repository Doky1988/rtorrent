#!/usr/bin/env bash
set -euo pipefail

echo "============================================="
echo " rTorrent + ruTorrent Seed Telepítő"
echo " Portnyitással (50000 TCP/UDP, 50010 UDP)"
echo " Debian 13 | Docker | Caddy | HTTPS | Auth"
echo "============================================="
sleep 1

# --- Root check ---
if [ "$EUID" -ne 0 ]; then
  echo "Rootként futtasd!"
  exit 1
fi

# --- Felhasználónév + Jelszó ---
read -rp "Add meg a WebUI felhasználónevet: " WEBUSER
read -rsp "Add meg a WebUI jelszót: " WEBPASS
echo ""

# --- IP vagy Domain mód ---
echo ""
echo "Hogyan szeretnéd elérni a WebUI-t?"
echo "1) IP címmel (http://IP:8080)"
echo "2) Domainnel + HTTPS (https://torrent.domain.hu)"
read -rp "Válassz (1 vagy 2): " CHOICE

USE_DOMAIN="no"
DOMAIN=""

if [ "$CHOICE" = "2" ]; then
  USE_DOMAIN="yes"
  read -rp "Add meg a domaint (pl. torrent.domain.hu): " DOMAIN
fi

# --- Rendszer frissítés ---
apt update -y && apt upgrade -y

# --- Docker telepítés ---
apt install -y ca-certificates curl gnupg lsb-release openssl

install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin

# --- Könyvtárak ---
mkdir -p /opt/rtorrent/data
mkdir -p /opt/rtorrent/caddy
cd /opt/rtorrent

# --- Hash generálás ---
HASH=$(docker run --rm caddy:latest caddy hash-password --plaintext "$WEBPASS")

echo "Generált bcrypt hash:"
echo "$HASH"
echo ""

# --- docker-compose generálás ---
if [ "$USE_DOMAIN" = "no" ]; then

cat > /opt/rtorrent/docker-compose.yml <<EOF
version: "3.8"

services:
  rtorrent-rutorrent:
    image: crazymax/rtorrent-rutorrent:latest
    container_name: rtorrent-rutorrent
    restart: unless-stopped
    ports:
      - "50000:50000/tcp"
      - "50000:50000/udp"
      - "50010:50010/udp"
    environment:
      - RTORRENT__PORT_RANGE=50000-50000
      - RTORRENT__DHT_PORT=50010
      - RTORRENT__SCGI=127.0.0.1:50000
      - WEBROOT=/
    volumes:
      - /opt/rtorrent/data:/data
    networks:
      - rt-net

  rt-proxy:
    image: caddy:latest
    container_name: rt-proxy
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - /opt/rtorrent/caddy/Caddyfile:/etc/caddy/Caddyfile:ro
    networks:
      - rt-net

networks:
  rt-net:
    driver: bridge
EOF

cat > /opt/rtorrent/caddy/Caddyfile <<EOF
:80 {
    encode gzip
    reverse_proxy rtorrent-rutorrent:8080

    basic_auth * {
        ${WEBUSER} ${HASH}
    }
}
EOF

else

cat > /opt/rtorrent/docker-compose.yml <<EOF
version: "3.8"

services:
  rtorrent-rutorrent:
    image: crazymax/rtorrent-rutorrent:latest
    container_name: rtorrent-rutorrent
    restart: unless-stopped
    ports:
      - "50000:50000/tcp"
      - "50000:50000/udp"
      - "50010:50010/udp"
    environment:
      - RTORRENT__PORT_RANGE=50000-50000
      - RTORRENT__DHT_PORT=50010
      - RTORRENT__SCGI=127.0.0.1:50000
      - WEBROOT=/
    volumes:
      - /opt/rtorrent/data:/data
    networks:
      - rt-net

  rt-caddy:
    image: caddy:latest
    container_name: rt-caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /opt/rtorrent/caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - rt-net

volumes:
  caddy_data:
  caddy_config:

networks:
  rt-net:
    driver: bridge
EOF

cat > /opt/rtorrent/caddy/Caddyfile <<EOF
${DOMAIN} {
    encode gzip
    reverse_proxy rtorrent-rutorrent:8080

    basic_auth * {
        ${WEBUSER} ${HASH}
    }
}
EOF

fi

# --- Indítás ---
docker compose up -d

IP=$(hostname -I | awk '{print $1}')

echo "============================================="
echo "     ✔ Telepítés kész! Seed szerver aktív!"
echo ""
if [ "$USE_DOMAIN" = "yes" ]; then
  echo " WebUI (HTTPS): https://${DOMAIN}"
else
  echo " WebUI (HTTP):  http://${IP}:8080"
fi
echo ""
echo " Bejövő torrent port: 50000 TCP/UDP (megnyitva)"
echo " DHT port: 50010 UDP (megnyitva)"
echo ""
echo " Felhasználó: ${WEBUSER}"
echo " Jelszó: (amit megadtál)"
echo "============================================="
