<h1 align="center">🚀 rTorrent + ruTorrent Seed Szerver Telepítő</h1>
<p align="center">
  <b>Debian 13 | Docker | Caddy | HTTPS | Basic Auth | Portnyitás (50000/50010)</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/rTorrent-CrazyMax-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/WebUI-ruTorrent-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/HTTPS-Let's Encrypt-yellow?style=for-the-badge&logo=letsencrypt" />
</p>

---

Ez a projekt egy teljesen automatizált seed szerver telepítő scriptet tartalmaz, amely Dockerben hozza létre az rTorrent + ruTorrent környezetet, opcionális domain-es HTTPS eléréssel, jelszóvédelemmel és **kinyitott torrent portokkal** biztosítva a teljes értékű seeding működést.

A telepítő támogatja:

- IP alapú WebUI elérés (http://IP:8080)
- Domain alapú WebUI elérés (HTTPS + Let's Encrypt → https://torrent.domain.hu)
- Basic Auth jelszóvédelem (bcrypt)
- Automatikus Docker + Compose telepítés
- rTorrent + ruTorrent CrazyMax image
- Caddy reverse proxy automatikusan
- **Kinyitott torrent portok (50000 TCP/UDP + 50010 UDP) → FULL ACTIVE seeding**

--------------------------------------------

## 🚀 Funkciók

- Teljesen automatizált telepítés Debian 13-ra  
- Docker + Compose telepítése  
- WebUI felhasználónév és jelszó bekérése  
- bcrypt hash generálása Caddy-hez  
- IP vagy Domain alapú üzemmód választása  
- Domain esetén automatikus HTTPS (Let's Encrypt)  
- ruTorrent WebUI jelszóval védve  
- Stabil seed szerver CrazyMax alapokon  
- **Torrent portnyitás a hoston:**
  - **50000/tcp → bejövő kapcsolatok**
  - **50000/udp → UDP tracker / PEX**
  - **50010/udp → DHT működés**

--------------------------------------------

## 📦 Követelmények

- Debian 13 (Ezen lett **TESZTELVE** a script!)
- Root hozzáférés
- Domain mód esetén A rekord a szerver IP-jére

--------------------------------------------

## 📥 Telepítés

1. Hozd létre a telepítő scriptet:
   ```bash
   nano rtorrent_install.sh

2. Másold ki, majd illeszd be a script teljes tartalmát, és mentsd el.

3. Adj futási jogot:
    ```bash
    chmod +x rtorrent_install.sh

4. Indítsd el:
    ```bash
    ./rtorrent_install.sh

5. Kövesd a telepítő kérdéseit:
   - WebUI felhasználónév
   - WebUI jelszó
   - IP vagy Domain mód
   - Domain esetén → Add meg a saját domained, pl.: **torrent.domain.hu**

--------------------------------------------

## 🌍 Elérés

### 🔵 IP mód esetén:
http://ip-címed:8080

### 🟢 Domain mód esetén (HTTPS):
https://torrent.domain.hu

--------------------------------------------

## 🔐 Hitelesítés

A WebUI alapértelmezés szerint jelszóval védett.  
A telepítő:
- bekéri a felhasználónevet  
- bekéri a jelszót  
- bcrypt hash-t generál Caddy számára  

--------------------------------------------

## 🔥 Torrent Port Információk (FULL ACTIVE mód)

A telepítő automatikusan megnyitja:

| Port | Protokoll | Funkció |
|------|-----------|---------|
| **50000** | TCP | Bejövő seed kapcsolatok |
| **50000** | UDP | UDP tracker / Peer Exchange |
| **50010** | UDP | DHT node port |

Ez garantálja:

- aktív seed státuszt
- stabil peer-forgalmat
- gyors csatlakozást
- maximális sebességet

--------------------------------------------

## 🧩 Használt Docker konténerek

- **crazymax/rtorrent-rutorrent**  
  (rTorrent + ruTorrent + Nginx + PHP-FPM egy konténerben)

- **caddy:latest**  
  (Reverse proxy + HTTPS a domain módhoz)

--------------------------------------------

## 🔄 Update Script – rTorrent + ruTorrent frissítése

A projekt tartalmaz egy külön update scriptet is.

### Létrehozás: 
    nano /opt/rtorrent/update_rtorrent.sh

Másold ki, majd illeszd be a script teljes tartalmát, és mentsd el.

### Futási jog:
    chmod +x /opt/rtorrent/update_rtorrent.sh

### Indítás:
    /opt/rtorrent/update_rtorrent.sh

### Mit csinál?

- Frissíti az összes Docker image-et
- Újraindítja a konténereket
- Törli a nem használt régi image-eket
- Megőrzi:
  - a torrentek állapotát
  - konfigurációkat
  - jelszót
  - beállításokat

--------------------------------------------

## ✨ Készítette

**Doky**  
2025.11.25
