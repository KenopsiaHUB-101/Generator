# KenoAi Pro v2 — Built Frontend (dist) + Dashboard SaaS

**File:** `kenoai-dist-v2.zip` (532 KB) — hasil build Vite siap pakai, tidak perlu build ulang.
**File:** `kenoai-pro-v2.zip` (976 KB) — source lengkap (src/ + server.js + dist/ + README) untuk pengembangan.

## Baru di v2
- **Dashboard SaaS 7 tab** (Ctrl+D atau tombol Dashboard di sidebar): Overview (stat + grafik 14 hari + donut model + info akun OpenRouter), Analytics, Conversations (tabel + search + export), Models (katalog + ganti model + Test live), Billing (free tier + estimasi biaya), Settings (backup export/import, tema, persona), Activity Log.
- **Model selector di topbar** (ikon robot) — pilih model per-request, persist, 18 gratis + 4 berbayar.
- **Usage tracking nyata** — token prompt/completion asli dari OpenRouter (include_usage), durasi, error, tersimpan lokal (max 800 record).
- **GET /api/account** — status akun (free tier, spend, rate limit) tanpa mengekspos API key ke browser.
- **Fix bug kritis**: race condition React 18 di handleSend yang bikin "loading stuck forever" saat kirim cepat 2x — sekarang dihitung sinkron dari sessionsRef.

## Cara pakai (Termux / Linux / Windows)
```bash
# 1. Download kenoai-dist-v2.zip dari release, atau:
wget https://github.com/KenopsiaHUB-101/Generator/releases/download/kenoai-dist-v2/kenoai-dist-v2.zip

# 2. Ekstrak ke project Anda (zip berisi folder dist/):
cd ~/ai-website
unzip kenoai-dist-v2.zip -d .

# 3. Verifikasi:
ls dist/index.html dist/assets/Dashboard-*.js   # harus ada (chunk dashboard baru)

# 4. Pastikan server.js versi v2 (yang punya /api/account + include_usage)
#    — tersedia di kenoai-pro-v2.zip, atau salin dari repo.

# 5. Jalankan:
npm start
# buka http://localhost:5000 → tekan Ctrl+D untuk dashboard
```

## Config server
Pastikan `.env` di root project berisi:
```
OPENROUTER_API_KEY=sk-or-v1-key-anda
KENOAI_MODEL=google/gemma-4-31b-it:free
```
Daftar 22 model (18 gratis): `GET /api/models` — atau lihat langsung di tab **Models** di dashboard.

## Tips model gratis
Model gratis kadang kena `429 rate-limited upstream` saat sibuk. Ganti model instan lewat selector topbar (mis. `minimax/minimax-m3:free`, `z-ai/glm-5.2:free`, atau `openrouter/free` yang auto-pilih model gratis yang hidup). Tombol **Test live** di tab Models memberi tahu dalam ~1 detik apakah model sedang responsif.
