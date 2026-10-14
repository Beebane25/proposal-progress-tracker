-- =============================================================
-- Proposal Progress Tracker — Supabase Database Schema
-- Project: Perancangan LLM Agent Berbasis Tool dengan Deteksi dan
--          Pertahanan Indirect Prompt Injection serta Explainable
--          Security Decision untuk Skenario Cybersecurity
--
-- Jalankan di: Supabase Dashboard > SQL Editor (atau `supabase db query`)
-- Urutan: 001_schema.sql -> 002_seed.sql (opsional) -> 003_policies
--         sudah termasuk di file ini.
-- =============================================================

-- ---------- 0. Extension ----------
create extension if not exists "pgcrypto";

-- ---------- 1. Projects (root entity) ----------
create table if not exists public.projects (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  deadline    date,
  notes       text default '',
  owner_id    uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ---------- 2. Team members ----------
create table if not exists public.members (
  id               uuid primary key default gen_random_uuid(),
  project_id       uuid not null references public.projects (id) on delete cascade,
  client_id        text not null,                -- id dari sisi klien ('m1','m2',...)
  name             text not null,
  role             text not null default '',
  description      text default '',
  responsibilities jsonb not null default '[]'::jsonb,
  sort_order       int not null default 0,
  unique (project_id, client_id)
);

-- ---------- 3. Tasks ----------
create table if not exists public.tasks (
  id            uuid primary key default gen_random_uuid(),
  project_id    uuid not null references public.projects (id) on delete cascade,
  client_id     text not null,                 -- 'task-0', 'det-A1', ...
  title         text not null,
  description   text not null default '',
  why           text not null default '',
  output        text not null default '',
  done          text not null default '',
  owner         text not null default '',      -- nama owner (dipakai di UI)
  section       text not null default '',
  priority      text not null default 'Sedang'
                check (priority in ('Rendah','Sedang','Tinggi','Kritis')),
  status        text not null default 'Belum Dimulai'
                check (status in ('Belum Dimulai','Sedang Dikerjakan','Menunggu Review','Terhambat','Selesai')),
  due           date,
  deps          jsonb not null default '[]'::jsonb,  -- array of client_id task
  tags          jsonb not null default '[]'::jsonb,
  weight        numeric check (weight is null or weight > 0),
  verified_note text not null default '',
  sort_order    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (project_id, client_id)
);

-- ---------- 4. Literature sources ----------
create table if not exists public.sources (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects (id) on delete cascade,
  client_id   text not null,
  title       text not null default '',
  authors     text not null default '',
  year        text not null default '',
  venue       text not null default '',
  doi         text not null default '',
  url         text not null default '',
  objective   text,
  method      text not null default '',
  findings    text,
  limitations text not null default '',
  relevance   text not null default '',
  section     text not null default '',
  status      text not null default '',
  verified    boolean not null default false,
  citation    text not null default '',
  notes       text not null default '',
  created_at  timestamptz not null default now(),
  unique (project_id, client_id)
);

-- Normalisasi DOI/URL untuk deteksi duplikat (dipakai domain.ts di klien juga)
create or replace function public.normalize_identifier(s text)
returns text language sql immutable as $$
  select rtrim(
           regexp_replace(
             lower(trim(coalesce(s, ''))),
             '^https?://(dx\.)?doi\.org/', ''
           ),
           '/'
         );
$$;

create unique index if not exists sources_project_doi_uniq
  on public.sources (project_id, public.normalize_identifier(doi))
  where doi <> '';
create unique index if not exists sources_project_url_uniq
  on public.sources (project_id, public.normalize_identifier(url))
  where url <> '';

-- ---------- 5. Proposal chapters ----------
create table if not exists public.chapters (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects (id) on delete cascade,
  client_id   text not null,                -- 'cover','toc','sec-0',...
  label       text not null default '',     -- 'Front matter','BAB I',...
  title       text not null,
  purpose     text not null default '',
  status      text not null default 'Belum Ditulis'
              check (status in ('Belum Ditulis','Draft','Direview Internal','Disetujui Internal')),
  draft       text not null default '',
  checklist   jsonb not null default '[]'::jsonb,
  comment     text not null default '',
  sort_order  int not null default 0,
  unique (project_id, client_id)
);

-- ---------- 6. Security policies (ALLOW/SANITIZE/QUARANTINE/BLOCK) ----------
create table if not exists public.policies (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects (id) on delete cascade,
  name        text not null
              check (name in ('ALLOW','SANITIZE','QUARANTINE','BLOCK')),
  trigger     text not null default '',
  behavior    text not null default '',
  approval    text not null default '',
  unique (project_id, name)
);

-- ---------- 7. Evaluation metrics ----------
create table if not exists public.metrics (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects (id) on delete cascade,
  name        text not null,
  sort_order  int not null default 0,
  unique (project_id, name)
);

-- ---------- 8. Final readiness checklist (manual items) ----------
create table if not exists public.readiness_checks (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects (id) on delete cascade,
  item_index  int not null,                 -- index pada readinessLabels di domain.ts
  checked     boolean not null default false,
  unique (project_id, item_index)
);

-- ---------- 9. updated_at trigger ----------
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists projects_touch on public.projects;
create trigger projects_touch before update on public.projects
  for each row execute function public.touch_updated_at();

drop trigger if exists tasks_touch on public.tasks;
create trigger tasks_touch before update on public.tasks
  for each row execute function public.touch_updated_at();

-- ---------- 10. Performance indexes ----------
create index if not exists tasks_project_idx    on public.tasks (project_id);
create index if not exists tasks_status_idx     on public.tasks (project_id, status);
create index if not exists sources_project_idx  on public.sources (project_id);
create index if not exists chapters_project_idx on public.chapters (project_id);
create index if not exists members_project_idx  on public.members (project_id);

-- ---------- 11. Row Level Security ----------
-- Model akses: pemilik project (owner_id) full akses.
-- Anggota tim yang login dengan akun Supabase bisa ditambahkan lewat
-- tabel project_collaborators di bawah.

create table if not exists public.project_collaborators (
  project_id  uuid not null references public.projects (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  role        text not null default 'editor' check (role in ('viewer','editor')),
  created_at  timestamptz not null default now(),
  primary key (project_id, user_id)
);

create or replace function public.is_project_member(pid uuid)
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from public.projects p
    where p.id = pid and p.owner_id = (select auth.uid())
  ) or exists (
    select 1 from public.project_collaborators c
    where c.project_id = pid and c.user_id = (select auth.uid())
  );
$$;

alter table public.projects               enable row level security;
alter table public.members                enable row level security;
alter table public.tasks                  enable row level security;
alter table public.sources                enable row level security;
alter table public.chapters               enable row level security;
alter table public.policies               enable row level security;
alter table public.metrics                enable row level security;
alter table public.readiness_checks       enable row level security;
alter table public.project_collaborators  enable row level security;

-- projects
create policy "projects select" on public.projects for select to authenticated
  using (public.is_project_member(id));
create policy "projects insert" on public.projects for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy "projects update" on public.projects for update to authenticated
  using (public.is_project_member(id)) with check (public.is_project_member(id));
create policy "projects delete" on public.projects for delete to authenticated
  using (owner_id = (select auth.uid()));

-- child tables: pola sama — member project boleh baca/tulis
do $$
declare t text;
begin
  foreach t in array array['members','tasks','sources','chapters','policies','metrics','readiness_checks'] loop
    execute format('create policy %I on public.%I for select to authenticated using (public.is_project_member(project_id))', t||'_select', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (public.is_project_member(project_id))', t||'_insert', t);
    execute format('create policy %I on public.%I for update to authenticated using (public.is_project_member(project_id)) with check (public.is_project_member(project_id))', t||'_update', t);
    execute format('create policy %I on public.%I for delete to authenticated using (public.is_project_member(project_id))', t||'_delete', t);
  end loop;
end $$;

-- collaborators: owner manage, member bisa lihat dirinya sendiri
create policy "collab select" on public.project_collaborators for select to authenticated
  using (public.is_project_member(project_id));
create policy "collab insert" on public.project_collaborators for insert to authenticated
  with check (exists (select 1 from public.projects p where p.id = project_id and p.owner_id = (select auth.uid())));
create policy "collab delete" on public.project_collaborators for delete to authenticated
  using (exists (select 1 from public.projects p where p.id = project_id and p.owner_id = (select auth.uid())));

-- ---------- 12. Grant akses Data API ----------
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage on schema public to authenticated;
