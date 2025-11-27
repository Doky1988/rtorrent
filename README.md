# 🚀 rTorrent + ruTorrent Telepítő (crazy-max) – IP / DOMAIN mód  
**Debian 13 | Docker | Caddy HTTPS (opcionális)**  
**Transdrone kompatibilis ✔️**  
**WebDAV támogatás – jelszóval védhető ✔️**

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/rTorrent-Enabled-00aa00?style=for-the-badge" />
  <img src="https://img.shields.io/badge/ruTorrent-WebUI-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/WebDAV-Secure-ff8800?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Caddy-HTTPS-green?style=for-the-badge&logo=caddy" />
  <img src="https://img.shields.io/badge/Transdrone-Compatible-ffcc00?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Author-Doky-purple?style=for-the-badge&logo=github" />
</p>

Ez a projekt egy teljesen automatizált telepítő scriptet tartalmaz a crazy-max/rtorrent-rutorrent konténerhez.  
A telepítés során választható:

- IP mód → WebUI: http://IP:8080  
- DOMAIN mód → HTTPS (Caddy) + IP tiltás (403)

Mindkét mód teljes XMLRPC authent használ → 100% kompatibilis Transdrone applikációval.  
A telepítő emellett opcionálisan WebDAV hitelesítést is kérdez, amellyel biztonságosan elérhető a /downloads/complete mappa.

---

## ⭐ Funkciók

- Teljesen automatizált telepítés Debian 13 alatt  
- rTorrent + ruTorrent (crazy-max)  
- Opcionális WebDAV védelem felhasználónév / jelszó párossal  
- XMLRPC jelszó → stabil Transdrone kapcsolat  
- IP vagy Domain mód választható  
- Domain módban automatikus Let’s Encrypt tanúsítvány  
- Javított Caddyfile → ruTorrent hibamentes  
- Torrent portok automatikusan nyitva vannak  
- WebDAV védelem beállítása után automatikus konténer-újraindítás

---

## 🧱 Telepítés

1) Telepítőfájl létrehozása:
   ```bash
   nano rtorrent_installer.sh

2) Másold bele az itt található **rtorrent_installer.sh** script tartalmát, majd mentsd el.

3) Futási jog adása:
   ```bash
   chmod +x rtorrent_installer.sh

4) Telepítés futtatása:
   ```bash
   ./rtorrent_installer.sh

A script megkérdezi:

- IP vagy Domain mód  
- Domain név (HTTPS esetén)  
- Felhasználónév  
- Jelszó  
- WebDAV jelszóvédelem szükséges-e  

---

## 🌐 Elérési módok

### 🔵 IP mód
WebUI:  
http://IP:8080

Transdrone: IP:8000  
WebDAV: http://IP:9000

---

### 🟢 DOMAIN mód (HTTPS + Caddy)
WebUI:  
https://sajat.domain.hu

- Automatikus Let’s Encrypt  
- IP-ről WebUI tiltva → 403  
- Transdrone továbbra is IP:8000  
- WebDAV továbbra is IP:9000  

---

## 🗂 WebDAV – /downloads/complete elérése

A crazy-max image alapértelmezetten WebDAV-on teszi elérhetővé a /downloads/complete mappát a 9000-es porton.

A telepítő rákérdez:

- Nyilvános WebDAV (jelszó nélkül, nem biztonságos)  
- VAGY WebDAV lezárása felhasználónév + jelszó párossal  

A telepítő automatikusan létrehozza a passwd/webdav.htpasswd fájlt,  
és újraindítja az rtorrent konténert → a védelem azonnal életbe lép.

WebDAV URL:  
http://IP:9000

---

## 📲 Transdrone

A legkényelmesebb mobilos torrent-kezeléshez ajánlott alkalmazás:

**Transdrone – Remote torrent manager**

Letöltés Google Play Áruházból:  
https://play.google.com/store/apps/details?id=org.transdroid.lite

A telepítő által generált XMLRPC beállításokkal teljesen kompatibilis.

Telepítés után:

1. Nyisd meg a Transdrone-t  
2. Add hozzá → *Add normal, custom server*  
3. **Töltsd ki az adatokat:**

  - Név: Bármi lehet
  - Szerver típus: rTorrent
  - IP vagy hostnév: Szervered IP-je
  - Felhasználónév: Telepítőben megadott!
  - Jelszó: Telepítőben megadott!

**Haladó beállítások:**

   - Port szám: 8000
   - SCGI csatlakozási pont: /RPC2
 
4. Kész – távoli vezérlés és torrent kezelés már mobilról is működik.

FONTOS: Domain módban is **IP-t kell használni** Transdrone-hoz, mert a mobilapp nem működik HTTPS reverse proxy mögött.

---

## 🔥 Portok

8080/tcp → WebUI (IP mód)  
8000/tcp → XMLRPC / Transdrone  
9000/tcp → WebDAV  
50000/tcp → Torrent TCP bejövő port  
6881/udp → DHT  
80/tcp → Caddy HTTP (domain mód)  
443/tcp → Caddy HTTPS (domain mód)

---

## 🔧 Konténerek kézi frissítése

cd /opt/rtorrent-rutorrent  
docker compose pull  
docker compose up -d  
docker image prune -f

---

## 🔄 Frissítés (UPDATE script)

1) Frissítőfájl létrehozása:
    ```bash
    nano /opt/rtorrent-rutorrent/rtorrent_updater.sh

2) Másold bele az itt található **rtorrent_updater.sh** script tartalmát, majd mentsd el.

3) Futási jog adása:
    ```bash
    chmod +x /opt/rtorrent-rutorrent/rtorrent_updater.sh

4) Futtatás:
    ```bash
    /opt/rtorrent-rutorrent/rtorrent_updater.sh

A frissítő:

- Letölti a legújabb image-eket  
- Újraindítja rTorrent-et  
- Domain módban újraindítja a Caddyt  
- Minden beállítás megmarad  

---

## 🎉 Kész!

Ez a README lefedi:

- IP / DOMAIN mód  
- HTTPS működés  
- Transdrone kompatibilitás  
- WebDAV használat + biztonság  
- Portlista  
- Frissítési útmutató  

---

## ❤️ Készítette: Doky  
📅 2025.11.25
