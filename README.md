<h1 align="center">🚀 rTorrent + ruTorrent Seed Szerver Telepítő</h1>
<p align="center">
  <b>Debian 13 | Docker | Caddy | HTTPS | Basic Auth</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/rTorrent-CrazyMax-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/WebUI-ruTorrent-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/HTTPS-Let's Encrypt-yellow?style=for-the-badge&logo=letsencrypt" />
</p>

---


Ez a projekt egy teljesen automatizált seed szerver telepítő scriptet tartalmaz, amely Dockerben hozza létre az rTorrent + ruTorrent környezetet, opcionális domain-es HTTPS eléréssel és jelszóvédelemmel.

A telepítő támogatja:

- IP alapú WebUI elérés (http://IP:8080)
- Domain alapú WebUI elérés (HTTPS + Let's Encrypt → https://torrent.domained.hu)
- Basic Auth jelszóvédelem (bcrypt)
- Automatikus Docker telepítés
- rTorrent + ruTorrent CrazyMax image
- Teljesen automatizált Caddy reverse proxy
- Letöltési mappák automatikus létrehozása

--------------------------------------------

## 🚀 Funkciók

- Teljesen automatizált telepítés Debian 13-ra  
- Docker + Compose telepítése  
- Jelszó bekérése → bcrypt hash generálás  
- IP vs. Domain alapú üzemmód választása  
- Domain esetén automatikus HTTPS (Let's Encrypt)  
- ruTorrent WebUI jelszóval védve  
- Stabil seed szerver CrazyMax alapokon  

--------------------------------------------

## 📦 Követelmények

- Debian 13
- Root hozzáférés
- Domain opció esetén A rekord a szerver IP-jére

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
   - Domain esetén → add meg a saját domained, pl.: **torrent.domain.hu**

--------------------------------------------

## 🌍 Elérés

### IP mód esetén
http://ip-címed:8080

### Domain mód esetén (HTTPS)
https://torrent.domain.hu

--------------------------------------------

## 🔐 Hitelesítés

A WebUI alapértelmezés szerint jelszóval védett.  
A telepítő:
- bekéri a felhasználónevet  
- bekéri a jelszót  
- bcrypt hash-t generál Caddy számára  

--------------------------------------------

## 🧩 Használt Docker konténerek

- crazymax/rtorrent-rutorrent  
  (rTorrent + ruTorrent + Nginx + PHP-FPM egy konténerben)

- caddy:latest  
  (Reverse proxy + HTTPS a domain módhoz)

--------------------------------------------

## ✨ Készítette

**Doky**  
2025.11.25
