// Supabase client + sinkronisasi AppState <-> database.
// Aktif hanya jika VITE_SUPABASE_URL dan VITE_SUPABASE_ANON_KEY di-set.
// Jika tidak, aplikasi tetap berjalan local-first (localStorage/IndexedDB).
import { createClient, type SupabaseClient, type Session } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

export const supabaseEnabled = Boolean(url && anonKey);

let client: SupabaseClient | null = null;
export function supabase(): SupabaseClient {
  if (!client) {
    if (!url || !anonKey) throw new Error('Supabase env belum di-set. Isi VITE_SUPABASE_URL dan VITE_SUPABASE_ANON_KEY di .env');
    client = createClient(url, anonKey);
  }
  return client;
}

// ---------- Row <-> AppState mapping ----------

type Row = Record<string, any>;

function taskFromRow(r: Row) {
  return {
    id: r.client_id,
    title: r.title ?? '',
    description: r.description ?? '',
    why: r.why ?? '',
    output: r.output ?? '',
    done: r.done ?? '',
    owner: r.owner ?? '',
    section: r.section ?? '',
    priority: r.priority ?? 'Sedang',
    status: r.status ?? 'Belum Dimulai',
    due: r.due ?? '',
    deps: Array.isArray(r.deps) ? r.deps : [],
    tags: Array.isArray(r.tags) ? r.tags : [],
    verifiedNote: r.verified_note ?? '',
  };
}

function taskToRow(projectId: string, t: any, sortOrder: number): Row {
  return {
    project_id: projectId,
    client_id: t.id,
    title: t.title ?? '',
    description: t.description ?? '',
    why: t.why ?? '',
    output: t.output ?? '',
    done: t.done ?? '',
    owner: t.owner ?? '',
    section: t.section ?? '',
    priority: t.priority ?? 'Sedang',
    status: t.status ?? 'Belum Dimulai',
    due: t.due || null,
    deps: t.deps ?? [],
    tags: t.tags ?? [],
    weight: t.weight ?? null,
    verified_note: t.verifiedNote ?? '',
    sort_order: sortOrder,
  };
}

// ---------- Load: rakit AppState dari semua tabel ----------

export async function loadStateFromSupabase(projectId: string) {
  const sb = supabase();
  const [project, members, tasks, sources, chapters, policies, metrics, readiness] = await Promise.all([
    sb.from('projects').select('*').eq('id', projectId).single(),
    sb.from('members').select('*').eq('project_id', projectId).order('sort_order'),
    sb.from('tasks').select('*').eq('project_id', projectId).order('sort_order'),
    sb.from('sources').select('*').eq('project_id', projectId).order('created_at'),
    sb.from('chapters').select('*').eq('project_id', projectId).order('sort_order'),
    sb.from('policies').select('*').eq('project_id', projectId),
    sb.from('metrics').select('*').eq('project_id', projectId).order('sort_order'),
    sb.from('readiness_checks').select('*').eq('project_id', projectId),
  ]);
  for (const q of [project, members, tasks, sources, chapters, policies, metrics, readiness]) {
    if (q.error) throw q.error;
  }

  const readinessMap: Record<string, boolean> = {};
  for (const r of readiness.data ?? []) readinessMap[String(r.item_index)] = r.checked;

  return {
    version: 1 as const,
    project: { title: project.data.title ?? '', deadline: project.data.deadline ?? '' },
    notes: project.data.notes ?? '',
    members: (members.data ?? []).map((m: Row) => ({
      id: m.client_id, name: m.name ?? '', role: m.role ?? '',
      description: m.description ?? '', responsibilities: m.responsibilities ?? [],
    })),
    tasks: (tasks.data ?? []).map(taskFromRow),
    sources: (sources.data ?? []).map((s: Row) => ({
      id: s.client_id, title: s.title ?? '', authors: s.authors ?? '', year: s.year ?? '',
      venue: s.venue ?? '', doi: s.doi ?? '', url: s.url ?? '', objective: s.objective ?? '',
      method: s.method ?? '', findings: s.findings ?? '', limitations: s.limitations ?? '',
      relevance: s.relevance ?? '', section: s.section ?? '', status: s.status ?? '',
      verified: !!s.verified, citation: s.citation ?? '', notes: s.notes ?? '',
    })),
    chapters: (chapters.data ?? []).map((c: Row) => ({
      id: c.client_id, label: c.label ?? '', title: c.title ?? '', purpose: c.purpose ?? '',
      status: c.status ?? 'Belum Ditulis', draft: c.draft ?? '',
      checklist: Array.isArray(c.checklist) ? c.checklist : [], comment: c.comment ?? '',
    })),
    policies: (policies.data ?? []).map((p: Row) => ({
      name: p.name ?? '', trigger: p.trigger ?? '', behavior: p.behavior ?? '', approval: p.approval ?? '',
    })),
    metrics: (metrics.data ?? []).map((m: Row) => m.name ?? ''),
    readiness: readinessMap,
    updated: project.data.updated_at ?? new Date().toISOString(),
  };
}

// ---------- Save: upsert seluruh state (debounced dari UI) ----------

export async function saveStateToSupabase(projectId: string, s: any) {
  const sb = supabase();

  const { error: projErr } = await sb.from('projects').update({
    title: s.project.title, deadline: s.project.deadline || null, notes: s.notes ?? '',
  }).eq('id', projectId);
  if (projErr) throw projErr;

  const memberRows = (s.members ?? []).map((m: any, i: number) => ({
    project_id: projectId, client_id: m.id, name: m.name ?? '', role: m.role ?? '',
    description: m.description ?? '', responsibilities: m.responsibilities ?? [], sort_order: i,
  }));
  if (memberRows.length) {
    const { error } = await sb.from('members').upsert(memberRows, { onConflict: 'project_id,client_id' });
    if (error) throw error;
  }

  const taskRows = (s.tasks ?? []).map((t: any, i: number) => taskToRow(projectId, t, i));
  if (taskRows.length) {
    const { error } = await sb.from('tasks').upsert(taskRows, { onConflict: 'project_id,client_id' });
    if (error) throw error;
  }

  const sourceRows = (s.sources ?? []).map((x: any) => ({
    project_id: projectId, client_id: x.id, title: x.title ?? '', authors: x.authors ?? '',
    year: x.year ?? '', venue: x.venue ?? '', doi: x.doi ?? '', url: x.url ?? '',
    objective: x.objective ?? null, method: x.method ?? '', findings: x.findings ?? null,
    limitations: x.limitations ?? '', relevance: x.relevance ?? '', section: x.section ?? '',
    status: x.status ?? '', verified: !!x.verified, citation: x.citation ?? '', notes: x.notes ?? '',
  }));
  if (sourceRows.length) {
    const { error } = await sb.from('sources').upsert(sourceRows, { onConflict: 'project_id,client_id' });
    if (error) throw error;
  }

  const chapterRows = (s.chapters ?? []).map((c: any, i: number) => ({
    project_id: projectId, client_id: c.id, label: c.label ?? '', title: c.title ?? '',
    purpose: c.purpose ?? '', status: c.status ?? 'Belum Ditulis', draft: c.draft ?? '',
    checklist: c.checklist ?? [], comment: c.comment ?? '', sort_order: i,
  }));
  if (chapterRows.length) {
    const { error } = await sb.from('chapters').upsert(chapterRows, { onConflict: 'project_id,client_id' });
    if (error) throw error;
  }

  const policyRows = (s.policies ?? []).map((p: any) => ({
    project_id: projectId, name: p.name, trigger: p.trigger ?? '', behavior: p.behavior ?? '', approval: p.approval ?? '',
  }));
  if (policyRows.length) {
    const { error } = await sb.from('policies').upsert(policyRows, { onConflict: 'project_id,name' });
    if (error) throw error;
  }

  const metricRows = (s.metrics ?? []).map((name: string, i: number) => ({ project_id: projectId, name, sort_order: i }));
  if (metricRows.length) {
    const { error } = await sb.from('metrics').upsert(metricRows, { onConflict: 'project_id,name' });
    if (error) throw error;
  }

  const readinessRows = Object.entries(s.readiness ?? {}).map(([k, v]) => ({
    project_id: projectId, item_index: Number(k), checked: !!v,
  }));
  if (readinessRows.length) {
    const { error } = await sb.from('readiness_checks').upsert(readinessRows, { onConflict: 'project_id,item_index' });
    if (error) throw error;
  }
}

// ---------- Project helpers ----------

export async function listMyProjects() {
  const { data, error } = await supabase()
    .from('projects').select('id, title, updated_at').order('updated_at', { ascending: false });
  if (error) throw error;
  return data ?? [];
}

export async function createProject(title: string) {
  const { data: userData, error: userErr } = await supabase().auth.getUser();
  if (userErr) throw userErr;
  const { data, error } = await supabase()
    .from('projects').insert({ title, owner_id: userData.user.id }).select('id').single();
  if (error) throw error;
  return data.id as string;
}

// ---------- Granular save per entitas (dipakai tombol Simpan manual) ----------

function activeProjectId(): string {
  return (import.meta.env.VITE_SUPABASE_PROJECT_ID as string | undefined) || '';
}

export async function saveChapterNow(ch: any, sortOrder?: number) {
  const pid = activeProjectId(); if (!pid) return;
  const row: Row = {
    project_id: pid, client_id: ch.id, label: ch.label ?? '', title: ch.title ?? '',
    purpose: ch.purpose ?? '', status: ch.status ?? 'Belum Ditulis', draft: ch.draft ?? '',
    checklist: ch.checklist ?? [], comment: ch.comment ?? '',
  };
  if (typeof sortOrder === 'number') row.sort_order = sortOrder;
  const { error } = await supabase().from('chapters').upsert(row, { onConflict: 'project_id,client_id' });
  if (error) throw error;
}

export async function deleteChapterNow(clientId: string) {
  const pid = activeProjectId(); if (!pid) return;
  const { error } = await supabase().from('chapters').delete()
    .eq('project_id', pid).eq('client_id', clientId);
  if (error) throw error;
}

export async function saveTaskNow(t: any, sortOrder = 0) {
  const pid = activeProjectId(); if (!pid) return;
  const { error } = await supabase().from('tasks').upsert(taskToRow(pid, t, sortOrder), { onConflict: 'project_id,client_id' });
  if (error) throw error;
}

export async function saveSourceNow(x: any) {
  const pid = activeProjectId(); if (!pid) return;
  const { error } = await supabase().from('sources').upsert({
    project_id: pid, client_id: x.id, title: x.title ?? '', authors: x.authors ?? '',
    year: x.year ?? '', venue: x.venue ?? '', doi: x.doi ?? '', url: x.url ?? '',
    objective: x.objective ?? null, method: x.method ?? '', findings: x.findings ?? null,
    limitations: x.limitations ?? '', relevance: x.relevance ?? '', section: x.section ?? '',
    status: x.status ?? '', verified: !!x.verified, citation: x.citation ?? '', notes: x.notes ?? '',
  }, { onConflict: 'project_id,client_id' });
  if (error) throw error;
}

export async function savePolicyNow(p: any) {
  const pid = activeProjectId(); if (!pid) return;
  const { error } = await supabase().from('policies').upsert({
    project_id: pid, name: p.name, trigger: p.trigger ?? '', behavior: p.behavior ?? '', approval: p.approval ?? '',
  }, { onConflict: 'project_id,name' });
  if (error) throw error;
}

export async function saveProjectMetaNow(title: string, deadline: string, notes: string) {
  const pid = activeProjectId(); if (!pid) return;
  const { error } = await supabase().from('projects').update({
    title, deadline: deadline || null, notes,
  }).eq('id', pid);
  if (error) throw error;
}

export async function saveReadinessNow(itemIndex: number, checked: boolean) {
  const pid = activeProjectId(); if (!pid) return;
  const { error } = await supabase().from('readiness_checks').upsert({
    project_id: pid, item_index: itemIndex, checked,
  }, { onConflict: 'project_id,item_index' });
  if (error) throw error;
}

// ---------- Auth (login-only; akun dibuat manual di dashboard Supabase) ----------

export async function getSession(): Promise<Session | null> {
  const { data } = await supabase().auth.getSession();
  return data.session ?? null;
}

export function onAuthChange(cb: (s: Session | null) => void) {
  const { data } = supabase().auth.onAuthStateChange((_e, s) => cb(s));
  return data.subscription;
}

export async function signIn(email: string, password: string) {
  const { error } = await supabase().auth.signInWithPassword({ email, password });
  if (error) throw error;
}

export async function signOut() {
  const { error } = await supabase().auth.signOut();
  if (error) throw error;
}
