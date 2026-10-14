-- 003_anon_access.sql — Akses publik tanpa login (mode single-project, no-auth)
--
-- Jalankan SETELAH 001_schema.sql dan 002_seed.sql jika aplikasi dipakai
-- TANPA layar login (misalnya hosting statis publik di Vercel).
--
-- PERINGATAN: siapa pun yang memegang anon key bisa membaca & mengubah SEMUA
-- data project. Anon key memang sengaja diekspos di bundle frontend.
-- Cocok untuk tracker pribadi/kelompok kecil. Jangan simpan rahasia.
-- Jika nanti ingin multi-user privat, tambahkan login dan jalankan
-- 004_relock.sql (drop policy public_*) untuk kembali ke mode auth.

-- ---------- 1. Grant Data API ke role anon ----------
grant usage on schema public to anon;
grant select, insert, update, delete on all tables in schema public to anon;

-- ---------- 2. Policy publik untuk semua tabel aplikasi ----------
-- projects
create policy "public_projects_select" on public.projects for select to anon using (true);
create policy "public_projects_insert" on public.projects for insert to anon with check (true);
create policy "public_projects_update" on public.projects for update to anon using (true) with check (true);
create policy "public_projects_delete" on public.projects for delete to anon using (true);

-- child tables
do $$
declare t text;
begin
  foreach t in array array['members','tasks','sources','chapters','policies','metrics','readiness_checks'] loop
    execute format('create policy %I on public.%I for select to anon using (true)', 'public_'||t||'_select', t);
    execute format('create policy %I on public.%I for insert to anon with check (true)', 'public_'||t||'_insert', t);
    execute format('create policy %I on public.%I for update to anon using (true) with check (true)', 'public_'||t||'_update', t);
    execute format('create policy %I on public.%I for delete to anon using (true)', 'public_'||t||'_delete', t);
  end loop;
end $$;

-- collaborators: tetap khusus authenticated (tidak dipakai di mode no-auth,
-- tapi sengaja tidak dibuka ke anon supaya daftar user tidak bocor).
