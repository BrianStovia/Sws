# 🤖 VPN Seller & Autoscript Manager

Autoscript premium berbasis Linux (Ubuntu/Debian) untuk otomatisasi instalasi layanan VPN/SSH tunnel, dilengkapi dengan menu CLI interaktif serta **Telegram Seller Bot Panel** untuk manajemen akun pelanggan secara langsung melalui chat Telegram.

---

## 🚀 Fitur Utama

### 1. Layanan VPN & Tunneling
* **SSH & OpenVPN**: Port standar & HTTP WebSocket.
* **V2Ray / Xray Core**: VMess, VLess, dan Trojan (melalui TLS/gRPC).
* **NoobzVPN**: Protokol tunnel modern berkecepatan tinggi dengan limitasi bandwidth & device.
* **UDP Custom**: Mendukung koneksi UDP/Payload bypass.
* **SSLH Multiplexer**: Pembagi trafik port 443 ke Nginx, V2ray, dan SSH.
* **Google TCP BBR**: Optimasi TCP Bottleneck Bandwidth untuk throughput maksimal.
* **ZeroSSL / Let's Encrypt Fallback**: Pembuatan sertifikat otomatis dengan metode fallback mandiri untuk mencegah rate limit.

### 2. Telegram Bot Panel (Untuk Seller/Reseller)
Bot Daemon Python (`vpn-bot.service`) yang berjalan di latar belakang untuk melayani pembuatan akun secara real-time:
* **Pembuatan Akun Instan**: Dukungan pembuatan SSH, VMess, VLess, Trojan, dan NoobzVPN.
* **Monitoring Status**: Menampilkan statistik CPU, RAM, Disk, dan status keaktifan service VPS.
* **Manajemen Reseller**: Menambah, menghapus, atau melihat daftar Seller yang berhak menggunakan bot (Khusus Owner).

---

## 📂 Struktur Workspace

```text
f:/s/
├── install.sh                  # Script Auto-Installer utama untuk VPS
├── nginx.conf                  # Konfigurasi reverse proxy Nginx
├── issue.net                   # Banner login SSH premium (HTML/Catppuccin theme)
├── config.json                 # Konfigurasi inti V2Ray / Xray Core
├── main.zip                    # Bundel zip semua script sbin yang dikirim ke VPS
└── extracted_main/             # Source code script CLI & Telegram Bot
    ├── menu                    # Menu CLI utama (dipanggil dengan perintah 'menu')
    ├── bot-menu                # CLI konfigurasi Bot Telegram (Opsi 6 di menu)
    ├── vpn_telegram_bot.py     # Python Daemon Bot Telegram
    ├── add-ssh / add-vmess...   # Script pembuatan akun VPN individual
    └── api/                    # API endpoints pembuatan akun via REST API
```

---

## 🛠️ Instalasi & Setup VPS

### 1. Jalankan Script Auto-Installer
Unggah dan jalankan `install.sh` di VPS target Anda menggunakan user `root`:
```bash
wget -O install.sh "https://raw.githubusercontent.com/username/repo/main/install.sh"
chmod +x install.sh
./install.sh
```

### 2. Akses Menu CLI VPS
Setelah instalasi selesai, Anda dapat mengakses menu utama dengan mengetikkan perintah berikut di terminal VPS:
```bash
menu
```

---

## 🤖 Panduan Setup Telegram Bot Panel

Layanan Telegram Bot ini memungkinkan Anda/Seller melakukan administrasi akun VPN langsung via Telegram Chat.

### Langkah 1: Buat Bot di BotFather
1. Buka Telegram dan cari **@BotFather**.
2. Ketik `/newbot` dan ikuti instruksi untuk mendapatkan **API Bot Token**.
3. Dapatkan **Chat ID** Anda sendiri (bisa menggunakan bot `@userinfobot` atau sejenisnya).

### Langkah 2: Daftarkan Token di VPS
1. Jalankan perintah `menu` di terminal VPS.
2. Pilih opsi **`06. Menu Bot Telegram`**.
3. Pilih opsi **`1. Setup Bot Notification`**.
4. Masukkan **API Key Bot** dan **Chat ID** Anda sebagai Owner.
5. Konfirmasi kebenaran data dengan mengetik `y`.

### Langkah 3: Aktifkan Bot Daemon
1. Kembali ke **`06. Menu Bot Telegram`**.
2. Pilih opsi **`2. Setup Bot Panel All Menu`**.
3. Pilih opsi **`1. Aktifkan / Restart Bot Panel`**.
4. Sistem akan membuat systemd service `vpn-bot.service` dan menjalankannya secara otomatis.

---

## 💬 Daftar Perintah Bot Telegram

Berikut adalah perintah-perintah yang dapat dikirimkan ke Bot Telegram setelah diaktifkan:

### 👤 Perintah Seller (Pembuatan Akun)
* `/start` atau `/help` — Menampilkan panduan penggunaan dan daftar perintah.
* `/addssh <user> <pass> <days>` — Membuat akun SSH & OpenVPN baru.
* `/addvmess <user> <days>` — Membuat akun V2Ray VMess baru.
* `/addvless <user> <days>` — Membuat akun V2Ray VLess baru.
* `/addtrojan <user> <days>` — Membuat akun V2Ray Trojan baru.
* `/addnoobz <user> <limit_device> <bandwidth_gb> <days>` — Membuat akun NoobzVPN baru.

### 📊 Perintah Monitoring & Informasi
* `/status` — Memeriksa penggunaan CPU, RAM, Disk, Uptime, serta status aktif/mati semua service VPN.
* `/listssh` — Menampilkan daftar semua user SSH aktif di VPS.
* `/listnoobz` — Menampilkan daftar semua user NoobzVPN aktif di VPS.

### 👑 Perintah Owner Only (Manajemen Seller)
* `/addseller <chat_id>` — Mendaftarkan Chat ID baru agar bisa menggunakan perintah pembuatan akun.
* `/delseller <chat_id>` — Menghapus akses Seller berdasarkan Chat ID.
* `/listsellers` — Menampilkan semua daftar Seller terdaftar.

---

## 🔍 Troubleshooting (Pemecahan Masalah)

### Bot Telegram Tidak Merespons?
1. Periksa status service bot di terminal VPS:
   ```bash
   sudo systemctl status vpn-bot
   ```
2. Baca log kesalahan secara detail:
   ```bash
   sudo journalctl -u vpn-bot -n 50 --no-pager
   ```
3. **Error `HTTP Error 401: Unauthorized`**:
   Token Bot yang Anda masukkan salah atau sudah hangus. Jalankan kembali `menu` -> opsi `06` -> opsi `1` untuk memasukkan token baru yang valid dari @BotFather.
4. **Error `Permission Denied`**:
   Semua script di bawah `/usr/local/sbin/` harus memiliki hak akses eksekusi. Jalankan perintah ini untuk memperbaikinya:
   ```bash
   sudo chmod +x /usr/local/sbin/*
   sudo chmod +x /usr/local/sbin/api/*
   ```
