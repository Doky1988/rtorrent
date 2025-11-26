# 🚀 rTorrent + ruTorrent Telepítő (crazy-max) – IP / DOMAIN mód  
**Debian 13 | Docker | Caddy HTTPS (opcionális)**  
**Transdrone / Transdroid kompatibilis ✔️**

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/rTorrent-Enabled-00aa00?style=for-the-badge" />
  <img src="https://img.shields.io/badge/ruTorrent-WebUI-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Caddy-HTTPS-green?style=for-the-badge&logo=caddy" />
  <img src="https://img.shields.io/badge/Transdrone-Compatible-ffcc00?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Author-Doky-purple?style=for-the-badge&logo=github" />
</p>

Ez a projekt egy teljesen automatizált telepítő scriptet tartalmaz a crazy-max/rtorrent-rutorrent konténerhez.  
A telepítés során választható:

- **IP mód** → WebUI: http://IP:8080  
- **DOMAIN mód** → HTTPS (Caddy) + IP tiltás (403)

Mindkét mód teljes XMLRPC authent használ → 100% kompatibilis Transdrone / Transdroid appokkal.

---

## ⭐ Funkciók

- Teljesen automatizált telepítés **Debian 13** alatt  
- rTorrent + ruTorrent (crazy-max)  
- XMLRPC jelszó → stabil Transdrone kapcsolat  
- IP vagy Domain mód választható  
- DOMAIN módban automatikus Let’s Encrypt tanúsítvány  
- Javított Caddyfile → ruTorrent UI hibamentes  
- Torrent portok automatikusan nyitva vannak Dockerben

---

## 🧱 Telepítés

1) Telepítőfájl létrehozása:  
   ```bash
   nano rtorrent_installer.sh

2) Másold bele a teljes telepítő scriptet, és mentsd el.

3) Futási jog adása:  
   ```bash
   chmod +x rtorrent_installer.sh

4) Telepítés futtatása:  
   ```bash
   ./rtorrent_installer.sh

A script megkérdezi:

- IP / Domain mód  
- Domain név (ha HTTPS-t választottad)  
- Felhasználónév  
- Jelszó  

---

## 🌐 Elérési módok

### 🔵 IP mód
WebUI:  
http://IP:8080  

Egyszerű, gyors, proxy nélkül.  
Transdrone: továbbra is IP:8000 porton működik.

### 🟢 DOMAIN mód (HTTPS + Caddy)
WebUI:  
https://te.domained.hu  

- Automatikus Let’s Encrypt tanúsítvány  
- IP-ről WebUI → 403 Forbidden  
- ruTorrent UI hibátlan (javított proxy)  
- Transdrone → továbbra is IP:8000 (nem proxyzva)

---

## 📱 Transdrone / Transdroid beállítás

A telepítő script XMLRPC jelszavas elérést készít elő.

Beállítások:

- Típus: rTorrent  
- Host: IP  
- Port: 8000  
- Felhasználó: telepítéskor megadott  
- Jelszó: telepítéskor megadott  
- RPC Path: /RPC2  

FONTOS: Domain módban is **IP-t kell használni** Transdrone-hoz, mert a mobilapp nem működik HTTPS reverse proxy mögött.

---

## 📲 Transdrone letöltése (Android – Google Play)

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
  - IP vagy hostnév: IP-t írd!
  - Felhasználónév: Telepítőben megadott!
  - Jelszó: Telepítőben megadott!

**Haladó beállítások:**

   - Port szám: 8000
   - SCGI csatlakozási pont: /RPC2
 
4. Kész – távoli vezérlés és torrent kezelés már mobilról is működik

---

## 🔥 Portok (mind nyitva vannak Dockerben)

8080/tcp → ruTorrent WebUI (IP mód)  
8000/tcp → XMLRPC (Transdrone)  
9000/tcp → SCGI backend  
50000/tcp → Torrent bejövő port ✔️  
6881/udp → DHT / uTP port ✔️  
80/tcp → Caddy HTTP (DOMAIN mód)  
443/tcp → Caddy HTTPS (DOMAIN mód)

A torrentezéshez fontos portok automatikusan nyitva vannak:

- 50000/tcp – incoming TCP  
- 6881/udp – DHT  

---

## 🔄 Frissítés (UPDATE script)

A projekt frissítő scriptet is tartalmaz, amely:

- Letölti a legújabb rTorrent image-et  
- Újraindítja a rTorrent konténert  
- DOMAIN módban automatikusan újraindítja a Caddyt  
- Minden beállítás megmarad  

1) Frissítőfájl létrehozása:  
   ```bash
   nano /opt/rtorrent-rutorrent/rtorrent_updater.sh

2) Másold bele a teljes telepítő scriptet, és mentsd el.

3) Futási jog adása:  
   ```bash
   chmod +x /opt/rtorrent-rutorrent/rtorrent_updater.sh

4) Frissítés futtatása:  
   ```bash
   /opt/rtorrent-rutorrent/rtorrent_updater.sh

---

## 🎉 Kész!

Ez a README teljesen lefedi a telepítést, IP/DOMAIN módot, portokat, HTTPS működést és a Transdrone kompatibilitást.

**Készítette: Doky**  
**2025-11-25**