# KenoAi Pro v2

A rebuilt, production-grade AI chat app: React 18 + Vite frontend with an Express backend that streams from OpenRouter — **now with a full SaaS-style dashboard, live model selector, and real usage analytics**.

## What's new in v2

### 7. SaaS Dashboard (Ctrl + D)
A full-screen, professional dashboard with seven tabs, lazy-loaded as its own bundle chunk:

- **Overview** — 4 stat cards (requests with day-over-day delta, tokens, avg response time, conversations), 14-day area chart with hover tooltips, model donut chart, OpenRouter account card (free-tier status, spend, rate limits), recent activity feed.
- **Analytics** — requests-by-hour bar chart (peak hours at a glance), top models by tokens, persona usage bars, error breakdown with rate.
- **Conversations** — searchable, sortable table of all chats (recent / messages / title) with open, rename, export JSON, and delete actions.
- **Models** — full catalogue (18 free + 4 paid), free-only filter, per-model chips (FREE badge, image input, context length), set as active model, and **Test live** (fires a tiny real request, shows latency + reply).
- **Billing** — free-tier daily cap bar, 7-day request bars, spend from OpenRouter, and a what-if cost estimate at paid-model pricing.
- **Settings** — theme toggle, default persona, **export full backup** (sessions + settings + usage as JSON), **import backup**, and clear analytics with inline confirm.
- **Activity Log** — filterable request log (All / Success / Errors): when, model, persona, tokens, duration, status.

### 8. Live model selector
A model picker in the topbar (robot icon): pick any catalogue model — free or paid — persists across reloads, and every request sends your chosen `model` id per-request to override the server default. Shows FREE/PAY grouping and the active model label.

### 9. Real usage tracking
The server now asks OpenRouter for **real token counts** (`stream_options: { include_usage: true }`) — every request records model, persona, duration, prompt/completion tokens, and errors to local storage (capped at 800 entries). The dashboard aggregates this into daily series, per-model, per-hour, and per-persona views. No more guesswork about usage.

### 10. Account endpoint
`GET /api/account` proxies OpenRouter's key endpoint server-side — the browser can see tier/usage/limits **without ever seeing your API key**.

### 11. Streaming reliability fix
Fixed a React 18 race in `handleSend`: the next-session list is now computed **synchronously** from the committed `sessionsRef` instead of inside a `setState` updater side-effect (React may defer updaters — that caused "loading stuck forever" + unhandled rejections on rapid sends).

### 12. Keyboard shortcuts (updated)
Ctrl+K search · **Ctrl+D dashboard** · Ctrl+Shift+O new chat · Ctrl+/ focus composer · Enter send · Shift+Enter newline · Esc close (dashboard closes first).

---

## What was fixed & upgraded in v1

### 1. Typing lag & crashes — eliminated
The old app re-rendered the entire chat (up to 50 messages, each re-parsing Markdown + full Prism highlighting) on **every keystroke**, and wrote every session (including base64 images) to localStorage after every update.

- **Uncontrolled composer**: the textarea is now plain DOM — typing triggers **zero React re-renders**. The value is read only when you press send.
- **Isolated streaming**: streamed tokens accumulate in a local variable and are committed via `requestAnimationFrame` batching — one re-render per frame max, touching only the streaming bubble (stable `id` keys, not array indexes).
- **Memoized everything**: `Message` bubbles never re-render while you type or while other messages stream.
- **Quota-safe persistence**: debounced 700ms save; if localStorage is full it strips embedded images from history instead of throwing.
- **Client-side image compression** (max 1152px, WebP/JPEG ~85%) before upload — smaller payloads, no crashes on big photos.

### 2. Professional navigation & neat menu
- Sidebar with **search** (Ctrl+K), **pin**, **rename**, **export as Markdown**, date-grouped history (Pinned / Today / Yesterday / Previous 7 & 30 Days / Older), plus a **Dashboard** button in the footer.
- Header kebab menu: new chat, search, export, dashboard, clear chat, delete all, keyboard shortcuts.
- Confirm dialogs replace `alert()`/`window.confirm`; toasts for feedback; ARIA roles & focus-visible rings throughout.

### 3. Responsive design
- Mobile (<768px): overlay sidebar + backdrop. Tablet (768–1023px): same overlay with roomier layout. Desktop (≥1024px): persistent, collapsible sidebar. Wide (≥1440px): wider content column.
- `100dvh` (no mobile URL-bar jump), safe-area insets, 44px touch targets, `prefers-reduced-motion` support, print styles, light & dark themes.

### 4. Fast loading
- Vite build with vendor/markdown chunk splitting; syntax highlighter + language grammars are **lazy-loaded** and only when a code block appears; the dashboard is a lazy chunk too.
- System font stack (zero webfont requests); all icons are inline SVG (no icon font). Zero-dependency SVG charts (no chart library).
- Total initial JS ≈ 60–70 kB gzipped (vs. ~600 kB+ before).

### 5. SEO
Semantic HTML, meta description/keywords, Open Graph + Twitter cards, canonical, JSON-LD `WebApplication` schema, `robots.txt`, `sitemap.xml`, PWA manifest, favicons & apple-touch-icon, `noscript` fallback.

### 6. Backend hardening
- Same-origin `/api` (no CORS), default model `google/gemma-4-31b-it:free` (free tier) with a curated catalogue of 18 free + 4 paid OpenRouter models — `GET /api/models`, `GET /api/account`, `/api/health`. Persona ids match the UI (`casual`, not `santai`).
- `.env` auto-loaded by server.js itself (zero-dependency loader) — Node does NOT read `.env` on its own; this fixes `key: MISSING`.
- Per-IP rate limiting, security headers, SSE keep-alive pings, upstream + client abort propagation (Stop button works), normalized error payloads, static `dist/` serving with SPA fallback.
- **API key moved to environment variable** — it is no longer hardcoded in source (the old key was exposed; rotate it on OpenRouter).

## Quick start (pre-built dist — no build tools needed)

If you downloaded `kenoai-dist-v2.zip` (contains `dist/` already built):

```bash
unzip kenoai-dist-v2.zip
# place dist/ in your project root next to server.js & package.json
npm install
cp .env.example .env     # add your OPENROUTER_API_KEY
npm start                # serves dist/ + API on http://localhost:5000
```

From full source (`kenoai-pro-v2.zip`):

```bash
npm install
cp .env.example .env      # add your OPENROUTER_API_KEY
npm run build             # build the frontend into dist/
npm start                 # serve app + API on http://localhost:5000
```

Development with hot reload:

```bash
npm run start:dev         # backend on :5000
npm run dev               # vite on :5173, proxies /api → :5000
```

## Project structure

```
├── index.html          # SEO meta, JSON-LD, theme bootstrap
├── public/             # icons, manifest, robots, sitemap
├── src/
│   ├── App.jsx         # app shell, streaming, model selector, shortcuts, menus
│   ├── Composer.jsx    # uncontrolled input (the lag fix)
│   ├── Message.jsx     # memoized bubble
│   ├── Markdown.jsx    # lazy syntax highlighting
│   ├── Sidebar.jsx     # search, groups, pin/rename/delete, dashboard button
│   ├── Dashboard.jsx   # 7-tab SaaS dashboard (lazy chunk, SVG charts)
│   ├── icons.jsx       # inline SVG icons
│   ├── lib.js          # uid, storage, compression, SSE parser, usage analytics
│   ├── App.css         # design system (light/dark, responsive, dashboard)
│   └── main.jsx
├── server.js           # Express: static SPA + /api streaming + /api/account
└── vite.config.js
```

## Tips for free-tier models

Free OpenRouter models occasionally return `429 rate-limited upstream` when busy. Use the topbar model selector to switch instantly (e.g. `minimax/minimax-m3:free`, `z-ai/glm-5.2:free`, or `openrouter/free` which auto-routes to a live free model). The **Models** tab's "Test live" button tells you in ~1s whether a model is responsive right now.

## Security note

The original `server.js` had an OpenRouter API key hardcoded in source. Treat it as compromised — revoke it in your OpenRouter dashboard and use `.env` instead.
