# 📝 MEMORY.MD — ATURAN & STRUKTUR PROYEK KENOAI

> **Untuk agent NinjaAI sesi baru:** Baca file ini DULU sebelum berbuat apa-apa. Ini adalah "konstitusi" proyek — apa yang boleh, tidak boleh, dan struktur file yang TIDAK boleh diubah/dirusak.

---

## ⛔ LARANGAN MUTLAK (JANGAN PERNAH LAKUKAN INI)

### 1. JANGAN UBAH/HAPUS FOLDER INI
```
src/
├── App.jsx         ← CORE
├── App.css         ← CORE
├── Dashboard.jsx   ← SaaS dashboard v2
├── Sidebar.jsx
├── Message.jsx
├── Composer.jsx
├── Markdown.jsx
├── icons.jsx
├── lib.js          ← usage analytics + util
└── main.jsx        ← entry point
```
**Kalau ada error di file-file ini, PERBAIKI — jangan buat file baru.** Misal kalau ada typo di Dashboard.jsx, gunakan `str_replace` untuk perbaikan, bukan buat `Dashboard-v2.jsx` atau semacamnya.

### 2. JANGAN UBAH STRUKTUR FOLDER INI
```
dist/              ← HASIL BUILD SAJA (dihasilkan npm run build)
public/            ← static: favicon, manifest, robots.txt, sitemap.xml (READ-ONLY)
scripts/           ← util aja (cdp_resize.py, make_icons.py)
```
**JANGAN tambah file sembarangan ke folder ini.**

### 3. JANGAN UBAH FILE-FILE KRITIS INI
```
package.json       ← dependency list (React 18, Vite 5, Express 5) — boleh update version, jangan ubah struktur
vite.config.js     ← build config (lazy chunk Dashboard) — JANGAN ubah tanpa alasan serius
server.js          ← backend utama — perbaiki kalau ada error, tapi JANGAN tambah endpoint random
index.html         ← entry HTML + meta SEO — hanya perbaiki meta/SEO yang benar, jangan ubah struktur
```

### 4. JANGAN BUAT FILE .env DI REPO PUBLIK
```
.env               ← LOKAL SANDBOX AGENT SAJA, JANGAN PUSH KE GITHUB
.env.example       ← TEMPLATE SAJA (placeholder, boleh push)
```

### 5. JANGAN PERNAH PUSH TOKEN/KEY KE GITHUB
- OpenRouter API key (`sk-or-v1-...`)
- GitHub PAT (`ghp_...`)
- Kalau user memberikan token → gunakan untuk push/release → lalu ingatkan **REVOKE setelah selesai**

---

## ✅ YANG BOLEH DILAKUKAN

| Aksi | Boleh? | Catatan |
|---|---|---|
| Perbaiki bug di `src/*.jsx` | ✅ | Gunakan `str_replace`, jangan buat file baru |
| Update CSS di `App.css` | ✅ | Tambah gaya baru, jangan hapus yang ada (backward compat) |
| Tambah icon baru ke `src/icons.jsx` | ✅ | Ikuti format SVG inline yang sudah ada |
| Update `README.md` dengan fitur baru | ✅ | Dokumentasi harus selalu sinkron dengan kode |
| Push hasil build ke GitHub via release | ✅ | Workflow: build → zip → commit → push → release + upload asset |
| Edit `lib.js` untuk tambah utility | ✅ | Tapi JANGAN ubah signature fungsi yang sudah pakai di jsx lain |
| Verifikasi di browser sebelum deliver | ✅ | Wajib: cek di Chromium sandbox, ambil screenshot, buktikan kerja |
| Update `.env.example` dengan config baru | ✅ | Template untuk user — harus selalu actual vs kode |

---

## 📦 STRUKTUR FILE FINAL (JANGAN DIUBAH)

```
/workspace/
├── .env                    ← LOKAL ONLY, gitignore
├── .env.example            ← template, boleh push
├── package.json            ← Node dependencies
├── package-lock.json
├── vite.config.js          ← Vite build config
├── index.html              ← SPA entry + meta
├── server.js               ← Express backend v2 (include_usage, /api/account)
│
├── src/
│   ├── main.jsx            ← React entry
│   ├── App.jsx             ← app shell (model selector, dashboard toggle, streaming)
│   ├── App.css             ← design system + dashboard CSS
│   ├── Dashboard.jsx       ← 7-tab SaaS (lazy chunk ~27KB)
│   ├── Sidebar.jsx         ← search, pin, rename, history
│   ├── Message.jsx         ← chat bubble (memoized)
│   ├── Composer.jsx        ← uncontrolled textarea (0 re-render)
│   ├── Markdown.jsx        ← lazy syntax highlighting
│   ├── icons.jsx           ← 36 SVG inline
│   └── lib.js              ← util + usage analytics
│
├── public/                 ← static (READ-ONLY kalau tidak ada alasan)
│   ├── favicon-32.png
│   ├── icon-192.png, icon-64.png
│   ├── apple-touch-icon.png
│   ├── manifest.webmanifest
│   ├── robots.txt
│   └── sitemap.xml
│
├── dist/                   ← BUILD OUTPUT (regenerate: npm run build)
│   ├── index.html
│   ├── assets/             ← ~40 chunk JS+CSS
│   └── ... (icons, manifest, etc)
│
├── scripts/
│   ├── cdp_resize.py       ← viewport resize untuk testing
│   └── make_icons.py       ← (historical, tidak dipakai sekarang)
│
├── README.md               ← dokumentasi v2 (selalu UPDATE saat ada fitur baru)
└── NINJAAI-CHAT-EXPORT/    ← folder export chat + handoff
    ├── 00-INDEX.md
    ├── 02-HANDOFF-RESUME.md
    ├── 03-MEMORY.md        ← FILE INI
    └── transcript-*.md     ← 3 sesi lengkap
```

---

## 🔑 localStorage KEYS (JANGAN UBAH TANPA ALASAN)

Agent boleh BACA keys ini untuk debugging, tapi jangan ubah schema tanpa tanya user dulu:

| Key | Type | Cap | Fungsi |
|---|---|---|---|
| `kenoai_sessions_v2` | Array JSON | unlimited | chat history |
| `kenoai_usage_v1` | Array JSON | 800 entries | analytics: token, ms, model, persona, error |
| `kenoai_model` | string | — | pilihan model user (persist topbar selector) |
| `kenoai_catalog` | Array JSON | — | cache `/api/models` (22 models) |
| `kenoai_server_default` | string | — | last seen server default model |
| `kenoai_dash_tab` | string | — | selected tab di Dashboard |
| `kenoai_dash_sort` | string | — | sort order Conversations tab |
| `kenoai_dash_free_only` | bool | — | filter free-only di Models tab |
| `kenoai_theme` | 'light'\|'dark' | — | tema user |
| `kenoai_persona` | string | — | pilihan persona (casual/formal/creative) |
| `kenoai_sidebar_collapsed` | bool | — | sidebar state |

---

## 🚀 BUILD & DEPLOY WORKFLOW (YANG BENAR)

### Kalau mau test di sandbox agent:
```bash
cd /workspace
npm install          # sekali saja
npm run build        # generate dist/
npm start            # jalankan server PORT=5100
# browser: http://localhost:5100
```

### Kalau mau deliver ke user (di Termux):
```bash
# Agent di sandbox:
npm run build
zip -r kenoai-dist-v2.zip dist
# → push ke GitHub release → user download + extract

# User di Termux:
wget https://github.com/.../releases/download/.../kenoai-dist-v2.zip
unzip kenoai-dist-v2.zip -d .
npm start
# http://localhost:5000
```

---

## 🐛 BUG FIX YANG SUDAH DILAKUKAN (JANGAN LAKUKAN ULANG)

| Bug | Status | Solusi |
|---|---|---|
| Typing lag (re-render tiap keystroke) | ✅ FIXED | Uncontrolled composer (plain DOM) |
| Full localStorage write tiap keystroke | ✅ FIXED | Debounce 700ms save, strip images kalau penuh |
| Image crash (base64 → localStorage penuh) | ✅ FIXED | Client-side compress 1152px WebP/JPEG ~85% |
| API key hardcoded di kode | ✅ FIXED | Move ke `.env`, `.env.example` template |
| Model selector tidak ada | ✅ FIXED | Topbar selector (persist, per-request override) |
| No usage analytics | ✅ FIXED | `include_usage` OpenRouter, `recordUsage`, agregasi 14 hari |
| React 18 race — loading stuck | ✅ FIXED | History sync dari `sessionsRef`, bukan updater side-effect |

**Kalau lihat salah satu bug ini lagi, itu berarti agent MENGACAK kode. Jangan lakukan.**

---

## 📋 API ENDPOINTS (JANGAN TAMBAH SEMBARANGAN)

Backend sudah punya semua endpoint yang dibutuhkan. Kalau user minta endpoint baru, **konsultasi dulu** — jangan tambah langsung:

| Endpoint | Method | Fungsi |
|---|---|---|
| `/` | GET | Serve `dist/index.html` (SPA fallback) |
| `/api/health` | GET | Health check |
| `/api/models` | GET | Return 22 models (18 free + 4 paid) |
| `/api/account` | GET | Proxy OpenRouter key info (tier, usage, limit) — **JANGAN expose API key** |
| `/api/ai-stream` | POST | Main: body = `{prompt, image?, model?, persona}` → SSE streaming |

---

## 🎨 DESIGN SYSTEM (YANG SUDAH FINAL)

- **Font:** system sans-serif (0 webfont request)
- **Colors:** CSS custom properties `--bg-*`, `--text-*`, `--border-*` (light/dark mode)
- **Breakpoints:** mobile (<768px) / tablet (768-1023px) / desktop (1024-1439px) / wide (≥1440px)
- **Components:** stat-card, dtable, model-card, bill-bar, btn-sm, btn-ghost, btn-danger, etc.
- **Animations:** fade-in, slide-in, `prefers-reduced-motion` respect
- **Icons:** all 36 inline SVG (no icon font, no external sprite)
- **Charts:** zero-dependency SVG (AreaChart, Donut, Spark, bar)

**Kalau mau tambah warna/gaya baru: ikuti pattern existing, jangan ubah yang sudah kerja.**

---

## 💬 KOMUNIKASI BAHASA

- **Dengan user:** Selalu **Bahasa Indonesia** (user prefer Indonesian)
- **Di kode comment:** Boleh Inggris atau Indo, sesuaikan dengan konteks
- **Di git commit message:** Bahasa Indonesia, jelas & ringkas
- **Di README/docs:** Bahasa Indonesia

---

## 📞 SAAT USER MINTA HAL BARU

**Template pertanyaan untuk clarify:**

> "Baik, saya paham request Anda: [parafrase request].
> 
> Sebelum mulai, saya perlu confirm:
> 1. Ini di mana? (di tab mana Dashboard, di topbar, di chat, dll)
> 2. Ini ada impact ke localStorage key atau endpoint baru? 
> 3. Ini butuh ubah server.js atau hanya frontend?
> 4. User akan test di Termux, jadi kami deliver dist.zip v3 ke GitHub — setuju?
> 
> Kalau clear, saya langsung mulai — jangan edit file sebelum clarify dulu."

---

## 🔒 SECURITY CHECKLIST

Sebelum push ke GitHub (public repo):

- [ ] Tidak ada secret di commit (key, token, password)
- [ ] `.env` TIDAK di-track (gitignore)
- [ ] Transkrip chat di-redact (ganti secret dengan `[REDACTED-...]`)
- [ ] Tidak ada console.log API key atau data sensitif
- [ ] CORS dibatasi (same-origin `/api` only)
- [ ] User diingatkan revoke token setelah release

---

## 📚 REFERENSI CEPAT

- **Repo publik:** https://github.com/KenopsiaHUB-101/Generator
- **Release terbaru:** kenoai-dist-v2 (Sept 2026)
- **Tech stack:** React 18 + Vite 5 + Express 5 + OpenRouter
- **User device:** Android Termux (build harus di agent sandbox)
- **Chat export:** NINJAAI-CHAT-EXPORT/ folder (untuk sesi berikutnya)

---

## 🎯 RINGKAS: APA YANG PENTING

1. **JANGAN ubah struktur folder** — App.jsx, Dashboard.jsx, server.js hanya diperbaiki, tidak diciptakan ulang
2. **JANGAN push secret** — redact key + token, ingatkan user revoke
3. **SELALU build di sandbox** — user tidak bisa npm run build di Termux
4. **SELALU deliver via GitHub** — user tidak bisa download file attachment dari agent
5. **SELALU balas Bahasa Indonesia**
6. **SELALU test di browser sebelum deliver**
7. **JANGAN mengacak localStorage schema** — selalu konsultasi kalau perlu ubah

**Kalau lihat pesan error atau user keluh "file jadi berantakan" atau "mana file saya?" — itu tandanya agent atau sesi sebelumnya udah buat kerusakan. STOP, baca memory.md ini, dan RECOVERY dengan GitHub repo (pull source terbaru).**

---

*Generated: 2026-09-04 — KenoAi Pro v2*
*Update memory.md ini kalau ada perubahan penting di struktur/aturan proyek.*
