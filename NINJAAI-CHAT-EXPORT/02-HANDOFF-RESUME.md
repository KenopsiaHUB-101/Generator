# 🔄 KENOAI × NINJAAI — DOKUMEN HANDOFF (LANJUT DARI SINI)

> **Tujuan file ini:** Kalau Anda membuka sesi NinjaAI baru (akun Gmail baru), cukup berikan file ini (atau link GitHub-nya) ke agent di awal percakapan. Agent akan langsung paham seluruh konteks proyek tanpa mengulang dari nol.
>
> **Cara pakai:** copy link raw file ini dan paste di chat baru NinjaAI, contoh pesan:
> "Baca dulu konteks proyek saya di sini: https://raw.githubusercontent.com/KenopsiaHUB-101/Generator/main/NINJAAI-CHAT-EXPORT/02-HANDOFF-RESUME.md — lalu lanjutkan dari situ."

---

## 1. IDENTITAS PENGGUNA & LINGKUNGAN

- Bahasa: **Indonesia** (user komunikasi dalam Bahasa Indonesia, agent harus membalas Bahasa Indonesia).
- Device: **Android + Termux** — TIDAK bisa build frontend secara lokal (vite build berat untuk HP). Selalu **build di sandbox** agent lalu kirim hasil `dist/` sebagai zip via GitHub (user tidak bisa download file attachment dari agent secara langsung — jalur delivery satu-satunya adalah **GitHub repo**).
- Repo GitHub user: **https://github.com/KenopsiaHUB-101/Generator** (publik). User pernah membagikan PAT token `ghp_[REDACTED-GITHUB-TOKEN]` di chat — sudah dianjurkan revoke berkali-kali. **Jika user membagikan token baru, gunakan untuk push + release, lalu ingatkan revoke setelah selesai.**
- User juga punya riwayat request di luar KenoAi: game Lua "BUILD & FIGHTER" (`build_and_fighter.lua` di repo yang sama) dan skrip game lain.

## 2. PROYEK: KenoAi Pro (AI chat app)

**Stack:** React 18 + Vite 5 (frontend, build → `dist/`), Express 5 (backend `server.js`) yang streaming dari **OpenRouter**. Monorepo satu folder: SPA di-serve dari `dist/`, API same-origin `/api`.

**Jalankan di Termux user:**
```bash
cd ~/ai-website
npm install
cp .env.example .env   # isi OPENROUTER_API_KEY
npm start              # http://localhost:5000
```
(Frontend SUDAH dibuild oleh agent — user hanya `npm start`. **JANGAN minta user npm run build di Termux**.)

### File inti (versi terkini = v2)
| File | Peran |
|---|---|
| `server.js` | Express: serve `dist/` SPA, `/api/ai-stream` (SSE streaming OpenRouter dengan `stream_options:{include_usage:true}`), `/api/models` (katalog 22 model: 18 gratis + 4 berbayar, default `google/gemma-4-31b-it:free`), `/api/account` (proxy `GET openrouter.ai/api/v1/key` — browser tidak pernah lihat API key), `/api/health`, rate-limit per-IP, security headers, `.env` loader zero-dependency |
| `src/App.jsx` | App shell: streaming SSE, model selector topbar (state `model`, persist `kenoai_model`, dikirim per-request di body), dashboard lazy `dashOpen` (Ctrl+D / Esc), header menu, dialog confirm, toast, shortcut keyboard. **FIX KRITIS v2:** `history` dihitung SINKRON dari `sessionsRef.current` sebelum `setSessions(history)` — bukan side-effect di dalam updater (race React 18 → loading stuck) |
| `src/Dashboard.jsx` | Dashboard SaaS 7 tab (chunk lazy ~27KB): Overview (stat cards + delta, area chart 14 hari SVG, donut model, kartu akun `/api/account`, recent activity), Analytics (bar per jam, token per model, persona, error), Conversations (search + sort + open/rename/export/delete), Models (katalog + free-only filter + **Test live** = request SSE kecil "Reply with the single word: online" → tampil latency + balasan), Billing (bar free-tier harian, 7 hari, spend nyata, estimasi biaya $1/M in $4/M out), Settings (tema, persona default, export/import backup JSON `{app:'KenoAi',version:2,sessions,settings,usage}`, clear usage), Activity Log (filter All/Success/Errors) |
| `src/lib.js` | util + **usage analytics**: `recordUsage` (cap 800, key `kenoai_usage_v1`), `aggregateUsage` (total/today/yesterday, byModel, byPersona, byHour[24], series 14 hari), `chunkUsage` (parse usage dari chunk SSE terakhir), `fmtNum/fmtMs/fmtWhen` |
| `src/Sidebar.jsx` | search Ctrl+K, pin, rename, grup tanggal, tombol Dashboard di footer |
| `src/icons.jsx` | 36 ikon SVG inline |
| `src/App.css` | design system light/dark + ~280 baris CSS dashboard (`.dash`, stat-card, dtable, model-cards, billing, settings, `.model-sel`) |
| `index.html`, `public/` | SEO lengkap: meta, OG, JSON-LD WebApplication, manifest PWA, favicon set, robots, sitemap |

### localStorage keys
`kenoai_sessions_v2` (chat), `kenoai_usage_v1` (analytics, cap 800), `kenoai_model` (pilihan model), `kenoai_catalog` (cache /api/models), `kenoai_server_default`, `kenoai_dash_tab`, `kenoai_dash_sort`, `kenoai_dash_free_only`, `kenoai_theme`, `kenoai_persona`, `kenoai_sidebar_collapsed`.

## 3. RIWAYAT PENGERJAAN (ringkas)

**Session 1 — rebuild v1:** Diagnosis App.js lama (re-render tiap keystroke, localStorage tiap update, API key hardcode). Rebuild total: uncontrolled composer, streaming rAF-batched, memo Message, save debounced 700ms, kompresi gambar client (1152px WebP/JPEG), sidebar pro, dialog/toast, responsive 4 breakpoint, PWA+SEO, backend hardening. Deliver: `kenoai-dist.zip` → GitHub release `kenoai-dist-v1`.

**Session 2 — dashboard:** permintaan "Buatkan dashboard nya, dengan fitur lengkap saas dll etc. Profesional modern extend" (+ permintaan lama "tambahkan opsi untuk memilih model"). Buat Dashboard.jsx 7 tab, model selector, tracking usage, `/api/account`. Build + verifikasi browser semua tab.

**Session 3 — polish + deliver v2:** Perbaiki 7 typo authoring, lalu **bug kritis ditemukan saat test**: race React 18 di handleSend (`history` di-assign dalam updater setState, React defer → undefined → crash `Cannot read properties of undefined (reading 'find')` → loading stuck). Fix: hitung sinkron dari `sessionsRef.current`. Saat test juga menemukan `gemma-4-31b-it:free` kena 429 upstream → solusinya pindah model via selector baru (minimax-m3:free lancar). Deliver: `kenoai-dist-v2.zip` + `kenoai-pro-v2.zip` → release **kenoai-dist-v2** (MD5 dist: `7f682a02aa7092808e57dc8aa2e3280f`, pro: `5fe0a2a8b4bc9b5d7de83ccc30555824`). User sudah download + extract di Termux (jawab "A" saat unzip bertanya replace).

**Status: SEMUA request selesai & terkirim.** Tidak ada pekerjaan tertunda, kecuali request baru user.

## 4. PENGETAHUAN PENTING (agar tidak diulang)

- **Model gratis OpenRouter kadang 429** "rate-limited upstream" (gemma terjadi). Jangan anggap bug di app — arahkan user ganti model via selector topbar; `openrouter/free` auto-route ke model gratis yang hidup; tombol **Test live** di tab Models cek ~1 detik.
- **React 18**: JANGAN pernah assign variabel di dalam updater `setState(prev => {...})` lalu dibaca segera setelahnya — updater bisa di-defer ke render phase. Selalu hitung sinkron dari ref, lalu set.
- Sandbox agent: port 5000 dipakai nginx, jadi server app jalan di `PORT=5100` (`nohup node server.js > outputs/server_new.log`). Tunnel publik selalu 302 — jalur delivery file satu-satunya = GitHub.
- Verifikasi build JSX tanpa vite: `npx esbuild --loader:.jsx=jsx --jsx=automatic src/Dashboard.jsx` (cara menangkap typo sebelum build).
- Workflow GitHub delivery yang terbukti: clone dengan token di URL → copy file → commit → push → `POST /repos/.../releases` (tag, body Markdown Indonesia) → upload asset zip ke `uploads.github.com/repos/.../releases/{id}/assets?name=` → verifikasi download anonim + md5sum match.
- Key OpenRouter user (pernah hardcoded di App.js lama, dipakai via `.env` di sandbox): sudah dianjurkan rotate. Label akun free tier, spend ~$0.02.

## 5. CARA RESUME DI SESI BARU (untuk agent baru)

1. Baca file ini sampai habis.
2. Kalau butuh detail teknis lebih dalam, baca transkrip mentah di folder yang sama: `01-...` (index), `transcript-original_conversation_*.md` (3 sesi).
3. Kalau butuh source code: download `kenoai-pro-v2.zip` dari release `kenoai-dist-v2` di repo, atau minta user upload file project terbaru mereka.
4. **Jangan mengulang** pekerjaan yang sudah selesai (lihat §3). Tanyakan ke user: fitur/permintaan baru apa.
5. Balas dalam **Bahasa Indonesia**.

## 6. STATE TERAKHIR (per 2026-09-04)

- Release GitHub terbaru: **https://github.com/KenopsiaHUB-101/Generator/releases/tag/kenoai-dist-v2**
- Repo root berisi: `kenoai-dist-v2.zip`, `kenoai-pro-v2.zip`, `README.md` (v2), `KENOAI-DIST-README.md` (panduan Termux), `build_and_fighter.lua` (proyek lain), `NINJAAI-CHAT-EXPORT/` (folder ini).
- User terakhir: menanyakan prompt unzip ("replace?" → jawab **A**), lalu minta export chat ini ke GitHub (file ini adalah hasilnya).

*Di-generate otomatis oleh SuperNinja (NinjaAI) — secrets di-redact demi keamanan (lihat 01-INDEX).*
