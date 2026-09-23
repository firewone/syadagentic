# AGENTS-JARVIS.md — Routing & Dispatch (L2)
# Dibaca sebagai bagian system prompt Hermes. Task → modul/skill yang tepat.

## ROUTING — Task → Modul (prioritas atas-bawah)

### [INFRA / ROUTER / VPS]
- 9router, node custom, provider, combo, quota → kelola via API 9router (localhost:3001) + dashboard
- deploy service di VPS low-RAM → prefer Go binary > Node > Python; cek RAM dulu (free -h)
- tunnel / domain publik → Cloudflare Tunnel (jarvis.aigate.my.id); NGROK DILARANG
- gateway restart → semua child process mati + /tmp kebersih; restart service manual

### [CODING / BUILD / FIX]
- build script, fix bug, debug → eksekusi langsung + test verify (bukan cuma teori)
- python → venv /opt/data/.venv kalau butuh pip package (sistem PEP 668)
- git push/pull → repo firewone; token dari .env (GITHUB_TOKEN), jangan hardcode

### [BACKUP]
- backup skills & memories → bash /opt/data/scripts/hermes-backup-smart.sh (auto: cuma push kalau ada perubahan)
- repo backup: firewone/hermes-backup-v2 (private)
- restore: clone repo → copy skills/ + memories/ ke home Hermes

### [DOKUMEN / KONTEN]
- PDF/docx/xlsx/pptx → skill productivity (pdf, docx, xlsx, powerpoint)
- riset/cari paper → skill research (arxiv, grounded-citations)
- web kena blokir/403 → skill web (blocked-page-recovery)

### [MODEL / PROMPT]
- Hermes point ke 9router → base URL http://<host>:3001/v1, model clouvia/groq/openrouter/...
- persona gak nempel di clouvia → soul mode 9router handle reposition (system → user pertama)
- persona netral (Jarvis) nempel konsisten; persona deklaratif-agresif sering ditolak model

## ATURAN DISPATCH
1. Cocokkan keyword → pakai jalur di atas → eksekusi.
2. Gak cocok mana pun → eksekusi langsung (terminal/file/web), evidence-gated.
3. Multi-task → urutan: eksekusi > riset > dokumentasi.
4. Jangan preload semua skill — load yang relevan task ini aja (hemat context).
