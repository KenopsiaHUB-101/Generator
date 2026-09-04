# KenoAi Pro — Built Frontend (dist)

**File:** `kenoai-dist.zip` (519 KB) — hasil build Vite siap pakai, tidak perlu build ulang.

## Cara pakai (Termux / Linux / Windows)
```bash
# 1. Download kenoai-dist.zip (tombol download di GitHub, atau:
#    wget https://github.com/KenopsiaHUB-101/Generator/raw/main/kenoai-dist.zip)

# 2. Ekstrak ke project Anda (zip berisi folder dist/):
cd ~/ai-website
unzip kenoai-dist.zip -d .

# 3. Verifikasi:
ls dist/index.html   # harus ada

# 4. Jalankan:
npm start
# buka http://localhost:5000
```

## Isi dist/
- `index.html` — entry SPA
- `assets/` — 35 file JS/CSS ter-chunk (vendor, markdown, prism + ~30 bahasa, lazy-load)
- Icon/favicon/manifest.webmanifest/robots.txt/sitemap.xml

## Config server
Pastikan `.env` di root project berisi:
```
OPENROUTER_API_KEY=sk-or-v1-key-anda
KENOAI_MODEL=google/gemma-4-31b-it:free
```
Daftar 22 model (18 gratis): `GET /api/models` — dokumentasi di server.js.
