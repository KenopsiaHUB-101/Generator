# 📖 NINJAAI CHAT EXPORT — KenoAi Pro

Folder ini berisi **dokumentasi lengkap** untuk melanjutkan proyek KenoAi di sesi NinjaAI **baru** (dengan akun Gmail baru).

## 📑 File di folder ini

1. **`03-MEMORY.md`** ⭐ **BACA INI DULU**
   - Aturan strict: apa yang boleh/tidak boleh dilakukan
   - Larangan mutlak: tidak boleh ubah folder/file tertentu
   - Workflow yang benar
   - Checklist keamanan
   - **Ini adalah "konstitusi" proyek — wajib dibaca agent baru**

2. **`02-HANDOFF-RESUME.md`**
   - Ringkas state proyek: identitas user, stack, riwayat 3 session, pengetahuan penting
   - File mana yang perlu diperbaiki kalau ada request baru
   - Cara resume tanpa mengulang

3. **`00-INDEX.md`**
   - Index transkrip chat (3 session: 237 + 195 + 220 pesan = 652 total)
   - Link ke setiap transcript mentah

4. **`transcript-original_conversation_*.md`** (3 file)
   - Transkrip lengkap setiap session: pesan user verbatim, narasi assistant, tool call diringkas
   - **Secrets sudah di-redact** (API key → `[REDACTED-...]`)
   - Berguna kalau agent baru perlu detail teknis yang detail

## 🚀 Cara pakai di sesi baru

### Opsi A: Copy-paste link raw di chat NinjaAI baru
```
"Baca konteks proyek saya dari sini:
https://raw.githubusercontent.com/KenopsiaHUB-101/Generator/main/NINJAAI-CHAT-EXPORT/03-MEMORY.md

Lalu baca juga:
https://raw.githubusercontent.com/KenopsiaHUB-101/Generator/main/NINJAAI-CHAT-EXPORT/02-HANDOFF-RESUME.md

Setelah itu ready untuk lanjut. Dimulai dari...?"
```

### Opsi B: Download folder lengkap
```bash
cd /workspace
git clone --depth 1 https://github.com/KenopsiaHUB-101/Generator.git
cat Generator/NINJAAI-CHAT-EXPORT/03-MEMORY.md
cat Generator/NINJAAI-CHAT-EXPORT/02-HANDOFF-RESUME.md
```

### Opsi C: Manual dari GitHub UI
- Buka: https://github.com/KenopsiaHUB-101/Generator/tree/main/NINJAAI-CHAT-EXPORT
- Klik raw `03-MEMORY.md` → copy text → paste ke NinjaAI baru

## 📝 Yang agent baru harus tahu

**SEBELUM berbuat apapun:**
1. Baca `03-MEMORY.md` (5 menit) — paham aturan & struktur
2. Baca `02-HANDOFF-RESUME.md` (5 menit) — paham state proyek & tech stack
3. Kalau masih perlu konteks detail: baca transkrip yang relevan dari `transcript-*.md`

**SETELAH itu:**
- Tanyakan ke user: "Fitur/permintaan baru apa?"
- Jangan pernah mengacak-acak struktur file yang sudah jadi
- Selalu build di sandbox, deliver via GitHub
- Selalu test di browser sebelum deliver
- Selalu balas Bahasa Indonesia

## ✅ Status proyek

- **Versi terbaru:** v2 (Sept 2026)
- **Release:** https://github.com/KenopsiaHUB-101/Generator/releases/tag/kenoai-dist-v2
- **Fitur siap:** 7-tab Dashboard, model selector, usage analytics, `/api/account`, React 18 race fix
- **Status:** ✅ Semua request delivered & terverifikasi
- **Maintenance:** Update memory.md kalau ada perubahan struktur/aturan penting

---

*Dokumentasi ini otomatis ter-generate oleh SuperNinja (NinjaAI) pada 2026-09-04.*
*Setiap session baru, pastikan dokumentasi ini selalu di-sync dengan kode terbaru di repo.*
