#!/usr/bin/env bash
set -euo pipefail

echo "============================================="
echo " rTorrent + ruTorrent Telepítő (CrazyMax)"
echo " IP vagy DOMAIN alapú WebUI + Jelszóvédelem"
echo " Debian 13 | by Doky"
echo "============================================="
sleep 1

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
  echo "A scriptet rootként kell futtatni!"
  exit 1
fi

# --- Felhasználónév + Jelszó bekérése ---
read -rp "Add meg a WebUI felhasználónevet: " WEBUSER
read -rsp "Add meg a WebUI jelszót: " WEBPASS
echo ""

# --- IP vagy Domain választás ---
echo ""
echo "Hogyan szeretnéd elérni a WebUI-t?"
echo "1) IP címmel (http://IP:8080)"
echo "2) Domainnel + HTTPS (https://domain.hu)"
read -rp "Válassz (1 vagy 2): " CHOICE

USE_DOMAIN="no"
DOMAIN=""

if [ "$CHOICE" = "2" ]; then
  USE_DOMAIN="yes"
  read -rp "Add meg a domaint (pl. rt.zsolti.hu): " DOMAIN
fi

# --- Rendszer frissítése ---
echo "== Rendszer frissítése =="
apt update -y && apt upgrade -y

# --- Docker telepítése ---
echo "== Docker telepítése =="
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

echo "== Könyvtárak létrehozása =="
mkdir -p /opt/rtorrent/data
mkdir -p /opt/rtorrent/caddy

cd /opt/rtorrent

# --- BCRYPT HASH generálása Caddy-vel (Caddy image-ből) ---
echo "== Jelszó hash generálása Caddy-vel (bcrypt) =="
HASH=$(docker run --rm caddy:latest caddy hash-password --plaintext "$WEBPASS")

echo "Generált hash:"
echo "$HASH"
echo ""

# --- docker-compose.yml generálása ---
echo "== docker-compose.yml generálása =="

if [ "$USE_DOMAIN" = "no" ]; then
  # IP-s mód (HTTP, port 8080, Caddy reverse proxy + basic_auth)
  cat > /opt/rtorrent/docker-compose.yml <<EOF
version: "3.8"

services:
  rtorrent-rutorrent:
    image: crazymax/rtorrent-rutorrent:latest
    container_name: rtorrent-rutorrent
    restart: unless-stopped
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

  echo "== Caddyfile generálása (IP mód) =="
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
  # DOMAIN mód (HTTPS, Caddy + Let's Encrypt)
  cat > /opt/rtorrent/docker-compose.yml <<EOF
version: "3.8"

services:
  rtorrent-rutorrent:
    image: crazymax/rtorrent-rutorrent:latest
    container_name: rtorrent-rutorrent
    restart: unless-stopped
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

  echo "== Caddyfile generálása (DOMAIN mód) =="
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

echo "== Konténerek indítása =="
docker compose up -d

IP=$(hostname -I | awk '{print $1}')

echo "============================================="
echo "   ✔ Telepítés kész!"
echo ""
if [ "$USE_DOMAIN" = "yes" ]; then
  echo "   🌍 WebUI (HTTPS): https://${DOMAIN}/"
  echo "   (Figyelj rá, hogy a domain A rekordja erre az IP-re mutasson: ${IP})"
else
  echo "   🌍 WebUI (HTTP):  http://${IP}:8080/"
fi
echo ""
echo "   👤 Felhasználó: ${WEBUSER}"
echo "   🔑 Jelszó: (amit megadtál)"
echo ""
echo "   Letöltések: /opt/rtorrent/data/downloads"
echo "   Watch mappa: /opt/rtorrent/data/watch"
echo "============================================="
