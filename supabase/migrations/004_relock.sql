-- 004_relock.sql — Kembali ke mode AUTH (kunci akses anon setelah halaman login aktif)
--
-- Jalankan SETELAH:
--   1. Halaman login sudah dideploy (build terbaru ada di Vercel).
--   2. User sudah dibuat di Dashboard → Authentication → Users → Add User
--      (centang "Auto Confirm User").
--   3. UUID user sudah dicatat dan ditempel di bawah ini.
--
-- Cara pakai: ganti '<PASTE_USER_UUID>' dengan UUID dari dashboard, lalu
-- run seluruh file ini di Dashboard → SQL Editor.

-- ---------- 1. Assign owner project (WAJIB — owner_id saat ini NULL) ----------
update public.projects
set owner_id = '1aec4fbc-dc2f-479c-b5fd-fe5bcf5b206b'
where id = '320b049b-3e40-44aa-9a12-b453145b18ae';

-- ---------- 2. Hapus policy publik (yang dibuat 003_anon_access.sql) ----------
drop policy if exists "public_projects_select" on public.projects;
drop policy if exists "public_projects_insert" on public.projects;
drop policy if exists "public_projects_update" on public.projects;
drop policy if exists "public_projects_delete" on public.projects;

do $$
declare t text;
begin
  foreach t in array array['members','tasks','sources','chapters','policies','metrics','readiness_checks'] loop
    execute format('drop policy if exists %I on public.%I', 'public_'||t||'_select', t);
    execute format('drop policy if exists %I on public.%I', 'public_'||t||'_insert', t);
    execute format('drop policy if exists %I on public.%I', 'public_'||t||'_update', t);
    execute format('drop policy if exists %I on public.%I', 'public_'||t||'_delete', t);
  end loop;
end $$;

-- ---------- 3. Cabut grant Data API dari role anon ----------
revoke select, insert, update, delete on all tables in schema public from anon;

-- ---------- Opsional: tambah anggota tim lain (ulangi per user) ----------
-- insert into public.project_collaborators (project_id, user_id, role)
-- values ('320b049b-3e40-44aa-9a12-b453145b18ae', '<UUID_ANGGOTA>', 'editor');
