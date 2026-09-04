# KenoAi Dashboard - Download & Setup Guide untuk Termux

## 📥 Download File dari GitHub

Jalankan command ini di Termux:

```bash
# 1. Download file zip dari GitHub
wget https://github.com/KenopsiaHUB-101/Generator/raw/main/ai-website-updated.zip

# 2. Ekstrak file
unzip ai-website-updated.zip -d ai-website

# 3. Masuk ke folder
cd ai-website

# 4. Install dependencies
npm install

# 5. Jalankan aplikasi
npm start
```

---

## 🎯 Quick Start (Copy-Paste)

```bash
# Satu perintah lengkap
wget https://github.com/KenopsiaHUB-101/Generator/raw/main/ai-website-updated.zip && unzip ai-website-updated.zip -d ai-website && cd ai-website && npm install && npm start
```

---

## 📋 File Structure Setelah Extract

```
ai-website/
├── src/
│   ├── App.jsx              (Main component - sudah updated)
│   ├── App.css              (NEW! Modern dark theme)
│   ├── Header.jsx           (NEW! Modern header)
│   ├── SidebarMemo.jsx      (NEW! Optimized sidebar)
│   ├── MessageCard.jsx      (NEW! Modern messages)
│   ├── ComposerMemo.jsx     (NEW! Modern input)
│   ├── Composer.jsx         (Old version)
│   ├── Sidebar.jsx          (Old version)
│   ├── Message.jsx
│   ├── Landing.jsx
│   ├── Login.jsx
│   ├── Markdown.jsx
│   ├── icons.jsx
│   ├── lib.js
│   └── main.jsx
├── .env                     (Environment variables - sudah configured)
├── package.json
├── package-lock.json
├── server.js
├── index.html
├── vite.config.js
├── INTEGRATION_STEPS.md     (NEW! Integration guide)
├── UI_UPDATE_GUIDE.md       (NEW! Design documentation)
└── README.md
```

---

## 🔧 Integration di Termux

Setelah extract, Anda perlu integrate komponen baru ke App.jsx:

### Option 1: Manual Integration (Recommended)

1. **Edit `src/App.jsx`** dengan editor di Termux:
   ```bash
   nano src/App.jsx
   ```

2. **Tambahkan imports** di bagian atas file (setelah line 11):
   ```jsx
   import Header from './Header.jsx';
   import SidebarMemo from './SidebarMemo.jsx';
   import MessageCard from './MessageCard.jsx';
   import ComposerMemo from './ComposerMemo.jsx';
   ```

3. **Ganti old header** dengan new Header component

4. **Save** (Ctrl+X → Y → Enter di nano)

5. **Build & Run**:
   ```bash
   npm run build
   npm start
   ```

### Option 2: Use Backup & Auto Integration

Jika sudah ada backup `App.jsx.backup`, Anda bisa:
```bash
# Compare old vs new
diff src/App.jsx.backup src/App.jsx

# Restore if needed
cp src/App.jsx.backup src/App.jsx
```

---

## ✅ Environment Setup

File `.env` sudah dikonfigurasi dengan environment variables:

```env
OPENROUTER_API_KEY=your_openrouter_api_key_here
VITE_GOOGLE_CLIENT_ID=654939343672-5j1e742gmrcgcbclsf304c6tai8v1o7j.apps.googleusercontent.com
PORT=5100
NODE_ENV=development
```

**PENTING**: Update `.env` dengan token Anda yang valid! Jangan commit token ke GitHub!

---

## 🚀 Running the App

```bash
# Development mode dengan hot reload
npm run dev

# Production build
npm run build

# Start production server
npm start
```

---

## 🎨 What's New in This Update

✅ **App.css** - Complete dark theme design system
✅ **Header.jsx** - Modern professional header
✅ **SidebarMemo.jsx** - Optimized sidebar with React.memo
✅ **MessageCard.jsx** - Professional message components
✅ **ComposerMemo.jsx** - Modern message input
✅ **UI_UPDATE_GUIDE.md** - Complete design documentation
✅ **INTEGRATION_STEPS.md** - Step-by-step integration guide

---

## 📱 Responsive Breakpoints

Dashboard works on:
- 🖥️ **Desktop** (1024px+) - Full UI
- 📱 **Tablet** (640-1024px) - Optimized layout
- 📲 **Mobile** (<640px) - Touch-friendly

---

## 🎯 Access Application

Setelah `npm start`, aplikasi akan tersedia di:

```
http://localhost:5100
```

Jika menggunakan Termux di Android, akses dari browser dengan:
```
http://127.0.0.1:5100
```

Atau jika device lain di network yang sama:
```
http://<TERMUX_IP>:5100
```

Untuk cek IP Termux:
```bash
ifconfig | grep inet
```

---

## 🛠️ Troubleshooting

### Error: Module not found
```bash
# Clear node_modules dan reinstall
rm -rf node_modules
npm install
```

### CSS not loading
```bash
# Clear cache dan rebuild
npm run build
npm start
# Also clear browser cache (Ctrl+Shift+Delete)
```

### Port already in use
```bash
# Change port di .env
PORT=5101
```

### npm start fails
```bash
# Check Node version
node --version
# Should be v16+ (check with: node -v)

# Update npm
npm install -g npm@latest
```

---

## 📚 Documentation Files Included

1. **INTEGRATION_STEPS.md** - Detailed integration tutorial
2. **UI_UPDATE_GUIDE.md** - Design system & component docs
3. **SETUP.md** - Original setup guide
4. **README.md** - Project overview

---

## 💡 Tips for Termux

### Install Node.js if not installed
```bash
apt update
apt install nodejs npm
```

### Speed up development
```bash
# Use npm ci for faster install
npm ci

# Use pnpm if available (faster alternative)
npm install -g pnpm
pnpm install
```

### Keep app running in background
```bash
# Using tmux or screen
tmux new-session -d -s kenoai 'npm start'

# Check running sessions
tmux ls

# Reattach to session
tmux attach-session -t kenoai
```

---

## 📝 Next Steps

1. ✅ Download zip file
2. ✅ Extract to folder
3. ✅ Run `npm install`
4. ✅ Follow INTEGRATION_STEPS.md untuk integrate komponen
5. ✅ Run `npm start`
6. ✅ Access http://localhost:5100
7. ✅ Test Google OAuth login
8. ✅ Enjoy modern dashboard! 🎉

---

## 🆘 Need Help?

- Check console errors: Browser F12 → Console
- Check terminal logs: Look at npm start output
- Read INTEGRATION_STEPS.md for detailed guide
- Verify .env file has correct tokens

---

**Version:** 2.0.0 (Updated)  
**Last Updated:** September 2026  
**Status:** ✅ Production Ready

Happy coding! 🚀
