# 📥 KenoAi Dashboard - Direct Download untuk Termux

## ⚡ Quick Download Command

Copy & paste satu command ini di Termux:

```bash
wget https://github.com/KenopsiaHUB-101/Generator/raw/main/ai-website-updated.zip && unzip ai-website-updated.zip -d ai-website && cd ai-website && npm install && npm start
```

---

## 📋 Step-by-Step (Jika error)

### 1️⃣ Download File
```bash
wget https://github.com/KenopsiaHUB-101/Generator/raw/main/ai-website-updated.zip
```

**Output yang diharapkan:**
```
Saving to: 'ai-website-updated.zip'
ai-website-updated.zip   [=====>] 510K  1.23MB/s    in 0.4s
```

---

### 2️⃣ Ekstrak Zip
```bash
unzip ai-website-updated.zip -d ai-website
```

**Output:**
```
Archive:  ai-website-updated.zip
  inflating: ai-website/.env
  inflating: ai-website/package.json
  inflating: ai-website/server.js
  ... (files terus ditampilkan)
```

---

### 3️⃣ Masuk Folder
```bash
cd ai-website
```

---

### 4️⃣ Install Dependencies
```bash
npm install
```

**Ini akan memakan waktu 2-5 menit. Tunggu sampai selesai:**
```
added 254 packages in 4s
```

---

### 5️⃣ Jalankan Aplikasi
```bash
npm start
```

**Output yang seharusnya muncul:**
```
KenoAi backend + SPA on http://localhost:5100
  model  : google/gemma-4-31b-it:free (default)
  key    : loaded OK
  models : 18 free + 4 paid — list at GET /api/models
```

---

## 🎯 Access Application

### Dari Device yang Sama (Termux)
```
http://127.0.0.1:5100
```
atau
```
http://localhost:5100
```

### Dari Browser Desktop di Network yang Sama
Cari IP Termux terlebih dahulu:
```bash
# Di Termux, jalankan:
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Hasilnya seperti: `192.168.1.100`

Kemudian buka di desktop browser:
```
http://192.168.1.100:5100
```

---

## 🚦 Troubleshooting

### ❌ Error: wget: command not found
```bash
# Install wget
apt install wget

# Atau gunakan curl
curl -L -o ai-website-updated.zip https://github.com/KenopsiaHUB-101/Generator/raw/main/ai-website-updated.zip
```

### ❌ Error: unzip: command not found
```bash
apt install unzip
```

### ❌ Error: npm: command not found
```bash
# Install Node.js & npm
apt update
apt install nodejs npm

# Verify
node --version
npm --version
```

### ❌ Error: port 5100 already in use
```bash
# Edit .env
nano .env

# Ubah PORT=5100 menjadi PORT=5101
# Save: Ctrl+X → Y → Enter

# Kemudian jalankan lagi
npm start
```

### ❌ Aplikasi loading sangat lambat
```bash
# Coba dengan npm cache yang bersih
npm cache clean --force
npm install
npm start
```

---

## 📝 File-File Penting di Folder

```
ai-website/
├── .env                      ← UPDATE INI DENGAN TOKEN ANDA!
├── src/
│   ├── App.css              ← NEW Modern dark theme
│   ├── Header.jsx           ← NEW Modern header
│   ├── SidebarMemo.jsx      ← NEW Optimized sidebar
│   ├── MessageCard.jsx      ← NEW Modern messages
│   ├── ComposerMemo.jsx     ← NEW Modern input
│   └── App.jsx              ← Main component
├── INTEGRATION_STEPS.md     ← Panduan integrasi detail
├── UI_UPDATE_GUIDE.md       ← Design documentation
├── TERMUX_DOWNLOAD_GUIDE.md ← Panduan ini
└── package.json             ← Dependencies list
```

---

## ✅ Yang Sudah Dikonfigurasi

✅ `.env` dengan OpenRouter API Key
✅ `.env` dengan Google OAuth Client ID
✅ `npm install` sudah included
✅ CSS modern dark theme sudah siap
✅ Komponen baru sudah dibuat
✅ Production build siap

---

## 🔐 PENTING: Update API Keys

Sebelum mulai, **UPDATE `.env` file** dengan token Anda:

```bash
nano .env
```

Ubah:
```env
OPENROUTER_API_KEY=your_api_key_here
VITE_GOOGLE_CLIENT_ID=your_client_id_here
```

**Dapatkan token dari:**
- OpenRouter: https://openrouter.ai/keys
- Google OAuth: https://console.cloud.google.com

---

## 🚀 Verifikasi Berhasil

Setelah `npm start`, Anda seharusnya melihat:

```
KenoAi backend + SPA on http://localhost:5100
  model  : google/gemma-4-31b-it:free (default)
  key    : loaded OK ✅
  models : 18 free + 4 paid — list at GET /api/models
```

---

## 💡 Tips

1. **Keep app running**: Gunakan tmux untuk background process
   ```bash
   tmux new-session -d -s kenoai 'npm start'
   ```

2. **Stop app**: Jika ada error, tekan `Ctrl+C` untuk stop

3. **Restart app**: Jalankan `npm start` lagi

4. **Check logs**: Lihat output di terminal untuk debugging

---

## 📞 Bantuan

- 📚 Baca: `INTEGRATION_STEPS.md` untuk integrasi detail
- 🎨 Baca: `UI_UPDATE_GUIDE.md` untuk design documentation
- ⚙️ Baca: `SETUP.md` untuk setup asli
- 🐛 Check: Console browser (F12) untuk errors

---

## ✨ What's New

✅ Modern dark theme (#0f172a background)
✅ High contrast text (#f0f9ff)
✅ Professional components dengan React.memo
✅ Smooth animations & transitions
✅ Responsive design (mobile, tablet, desktop)
✅ No more emoji - professional icons

---

**Status**: ✅ Production Ready
**Download Size**: ~510 KB
**After Extract + npm install**: ~500+ MB (node_modules)

Selamat! Enjoy modern KenoAi dashboard! 🎉
