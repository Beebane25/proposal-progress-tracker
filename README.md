# Proposal Progress Tracker

Local-first research proposal planning workspace for the project:

> Perancangan LLM Agent Berbasis Tool dengan Deteksi dan Pertahanan Indirect Prompt Injection serta Explainable Security Decision untuk Skenario Cybersecurity

## Features

- Dashboard progress derived from task records
- 20-phase proposal roadmap
- Task checklist with ownership, priority, status, and completion evidence
- Team workstreams and cross-member dependency view
- Literature manager with DOI/URL duplicate detection and CSV/JSON export
- Research gap canvas separating verified facts, interpretation, and hypotheses
- LLM Agent & Integration workspace for ALLOW/SANITIZE/QUARANTINE/BLOCK policies
- Proposal chapter writing tracker for front matter, BAB I, BAB II, and BAB III
- Schedule and final readiness review
- Local JSON backup and restore
- No API key or external AI service required

## Run locally

```bash
npm install
npm run dev
```

Open http://localhost:5173.

## Cloud sync dengan Supabase (opsional)

Aplikasi tetap berfungsi penuh secara local-first tanpa Supabase. Untuk mengaktifkan sinkronisasi cloud:

1. Buat project di [supabase.com](https://supabase.com) (gratis).
2. Di dashboard Supabase, buka **SQL Editor** lalu jalankan isi file:
   - `supabase/migrations/001_schema.sql` — membuat tabel, index, RLS policy, dan trigger.
   - `supabase/migrations/002_seed.sql` — mengisi data awal (task, member, chapter, policy, metrik) sesuai seed aplikasi.
   - `supabase/migrations/003_anon_access.sql` — **wajib jika aplikasi dipakai tanpa login** (misalnya hosting statis publik). Membuka akses baca/tulis untuk role `anon`. Siapa pun dengan anon key bisa mengubah data; jangan simpan rahasia di tracker.
3. Salin `.env.example` menjadi `.env` dan isi:
   - `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` dari **Project Settings > API**.
   - `VITE_SUPABASE_PROJECT_ID` dengan `id` baris di tabel `public.projects` (lihat hasil seed di Table Editor).
4. `npm run dev` — panel **Settings > Cloud sync** akan menampilkan status koneksi.

### Deploy ke Vercel

`.env` sudah ter-gitignore dan tidak akan ter-push ke GitHub. Untuk hosting publik, tambahkan ketiga variabel `VITE_SUPABASE_*` di **Vercel Dashboard → Project → Settings → Environment Variables**, lalu redeploy. Vite meng-inline env saat build, jadi env lokal tidak ikut terbawa otomatis.

### Mode akses

- **Tanpa login (default saat ini):** jalankan `003_anon_access.sql`; semua device membaca/menulis project yang sama.
- **Dengan login (opsional, lebih privat):** lewati `003_anon_access.sql`, aktifkan Email auth, dan gunakan policy bawaan `001_schema.sql` (owner + `project_collaborators`).

## Data boundary

Mode default single-user/local: state disimpan di browser (localStorage + IndexedDB). Jika Supabase diaktifkan, state juga di-upsert ke tabel-tabel di atas dengan debounce 300ms. Tidak ada telemetry tersembunyi atau panggilan AI eksternal.

## Verify

```bash
npm run build
npm test -- --environment jsdom
npm audit --audit-level=moderate
```

## License

MIT
