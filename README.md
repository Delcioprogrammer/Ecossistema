# 🎬 Estúdio Viral Pro

App web de edição de vídeo com IA — React + FastAPI + Gemini.

## Stack
| Camada | Tecnologia | Deploy |
|---|---|---|
| Frontend | React + Vite | Vercel (grátis) |
| Backend | FastAPI + Python | Railway (grátis) |
| IA | Google Gemini 1.5 Pro | API key grátis |

---

## 🚀 Deploy em produção

### 1. Backend → Railway

1. Cria conta em [railway.app](https://railway.app)
2. New Project → Deploy from GitHub → seleciona este repositório
3. Em **Settings → Root Directory** define: `backend`
4. Adiciona variável de ambiente:
   ```
   FRONTEND_URL=https://teu-app.vercel.app
   ```
5. Railway usa o `Procfile` automaticamente para iniciar com `uvicorn`
6. Copia a URL gerada (ex: `https://estudio-viral.up.railway.app`)

### 2. Frontend → Vercel

1. Cria conta em [vercel.com](https://vercel.com)
2. New Project → Import Git Repository
3. Em **Environment Variables** adiciona:
   ```
   VITE_API_URL=https://estudio-viral.up.railway.app
   ```
4. Deploy! O `vercel.json` já configura tudo.

---

## 💻 Desenvolvimento local

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Frontend
```bash
cd frontend
npm install
npm run dev
# Abre http://localhost:5173
```

O Vite já tem proxy configurado: `/api` → `http://localhost:8000`

---

## 🔑 API Key

Obtém a tua chave **gratuita** do Gemini em:
👉 [aistudio.google.com](https://aistudio.google.com)

Na app, vai a **Configurações** e cola a key.

---

## ✨ Funcionalidades

| Feature | Descrição |
|---|---|
| ✂️ Cortes com IA | Gemini analisa o vídeo visualmente e gera cortes automáticos |
| 📝 Legendas Auto | Transcrição + SRT + embutir legendas no vídeo |
| 🌍 Tradução | Transcreve, traduz e gera SRT ou vídeo dublado |
| 🎨 Template/Overlay | Sobreposição de templates com auto-crop inteligente |

---

## 📁 Estrutura

```
estudio-viral/
├── frontend/
│   ├── src/
│   │   ├── App.jsx        ← UI completa
│   │   ├── main.jsx
│   │   └── index.css
│   ├── package.json
│   ├── vite.config.js
│   └── index.html
├── backend/
│   ├── main.py            ← FastAPI app
│   ├── routers/
│   │   ├── cuts.py        ← /api/cuts
│   │   ├── subtitles.py   ← /api/subtitles
│   │   ├── translation.py ← /api/translation
│   │   └── template.py    ← /api/template
│   ├── services/
│   │   └── utils.py       ← Helpers partilhados
│   ├── requirements.txt
│   └── Procfile
└── vercel.json
```
