import { useEffect, useState, type FormEvent } from 'react';
import { ArrowRight, Eye, EyeOff, Lock, LogOut } from 'lucide-react';
import { signIn } from './supabase';

const BOOT_LINES = [
  '$ ./boot research-vault --project proposal-ta',
  '> memuat security policies .......... 4 ditemukan',
  '  ALLOW       · trigger belum disepakati',
  '  SANITIZE    · trigger belum disepakati',
  '  QUARANTINE  · trigger belum disepakati',
  '  BLOCK       · trigger belum disepakati',
  '> evidence log ...................... menunggu review',
  '> auth handler ...................... standby',
  'status: MENUNGGU KREDENSIAL',
];

function useTypewriter(lines: string[], speed = 230) {
  const [n, setN] = useState(0);
  useEffect(() => {
    if (n >= lines.length) return;
    const t = setTimeout(() => setN(v => v + 1), n === 0 ? 420 : speed);
    return () => clearTimeout(t);
  }, [n, lines.length, speed]);
  return lines.slice(0, n);
}

function Brand() {
  return (
    <div className="login-brand">
      <div className="brand-mark">P</div>
      <div><strong>Proposal<span>Tracker</span></strong><small>research vault</small></div>
    </div>
  );
}

export function Login() {
  const [email, setEmail] = useState('');
  const [pw, setPw] = useState('');
  const [show, setShow] = useState(false);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState('');
  const lines = useTypewriter(BOOT_LINES);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (busy) return;
    setBusy(true);
    setErr('');
    try {
      await signIn(email.trim(), pw);
      // Berhasil: listener onAuthChange di App mengambil alih tampilan.
    } catch (ex: any) {
      const m = String(ex?.message || '');
      setErr(
        m.includes('Invalid login') ? 'Email atau password salah.'
        : m.includes('Email not confirmed') ? 'Email belum dikonfirmasi — centang "Auto Confirm User" saat membuat akun di dashboard Supabase.'
        : m || 'Login gagal. Coba lagi.'
      );
      setBusy(false);
    }
  };

  return (
    <div className="login-root">
      <aside className="login-side">
        <Brand />
        <div className="login-hero">
          <div className="eyebrow mint-text">VAULT RISET // TA KEAMANAN SIBER</div>
          <h1>Setiap klaim butuh bukti.<br />Setiap sesi butuh kredensial.</h1>
          <p className="login-sub">Perancangan LLM Agent Berbasis Tool dengan Deteksi dan Pertahanan Indirect Prompt Injection serta Explainable Security Decision untuk Skenario Cybersecurity.</p>
        </div>
        <div className="term" aria-hidden="true">
          <div className="term-head"><span /><span /><span /><em>security-layer.log</em></div>
          <div className="term-body">
            {lines.map((l, i) => <div key={i} className={l.startsWith('status') ? 'term-status' : l.startsWith('$') ? 'term-cmd' : ''}>{l}</div>)}
            <span className="cursor" />
          </div>
        </div>
        <div className="login-meta">
          <span>POLITEKNIK NEGERI BATAM</span>
          <span>CYBER SECURITY · 2026</span>
          <span>SINGLE PROJECT · CLOUD SYNC</span>
        </div>
      </aside>
      <main className="login-panel">
        <form className="login-card" onSubmit={submit}>
          <i className="tick tl" /><i className="tick tr" /><i className="tick bl" /><i className="tick br" />
          <div className="mobile-brand"><Brand /></div>
          <div className="eyebrow mint-text">AKSES TERBATAS</div>
          <h2>Masuk workspace</h2>
          <p className="login-note">Tidak ada pendaftaran publik — akun dibuat manual oleh admin lewat Supabase Auth.</p>
          <div className="field">
            <label className="field-label" htmlFor="login-email">EMAIL</label>
            <div className="field-box">
              <b>&gt;</b>
              <input id="login-email" type="email" required autoFocus autoComplete="email" placeholder="nama@polibatam.ac.id" value={email} onChange={e => setEmail(e.target.value)} />
            </div>
          </div>
          <div className="field">
            <label className="field-label" htmlFor="login-password">PASSWORD</label>
            <div className="field-box">
              <b>&gt;</b>
              <input id="login-password" type={show ? 'text' : 'password'} required autoComplete="current-password" placeholder="••••••••" value={pw} onChange={e => setPw(e.target.value)} />
              <button type="button" className="peek" onClick={() => setShow(s => !s)} aria-label={show ? 'Sembunyikan password' : 'Tampilkan password'}>{show ? <EyeOff size={15} /> : <Eye size={15} />}</button>
            </div>
          </div>
          {err && <div className="login-error" role="alert">! {err}</div>}
          <button className="login-btn" disabled={busy || !email || !pw}>
            {busy ? 'Memverifikasi…' : <>Autentikasi <ArrowRight size={15} /></>}
          </button>
          <div className="login-foot"><Lock size={12} /> Sesi tersimpan di browser ini · akses data dijaga Row Level Security</div>
        </form>
      </main>
    </div>
  );
}

export function Gate({ kind, onRetry, onOffline, onLogout }: { kind: 'checking' | 'error'; onRetry?: () => void; onOffline?: () => void; onLogout?: () => void }) {
  return (
    <div className="login-root gate">
      <div className="gate-box">
        {kind === 'checking' ? (
          <>
            <div className="spinner" />
            <p className="gate-text">memeriksa sesi<span className="dots"><i>.</i><i>.</i><i>.</i></span></p>
          </>
        ) : (
          <>
            <div className="eyebrow mint-text">SINKRONISASI GAGAL</div>
            <h2>Workspace tidak bisa dimuat</h2>
            <p className="login-note">Kemungkinan akun ini belum terdaftar sebagai anggota project, atau koneksi ke Supabase terputus.</p>
            <div className="gate-actions">
              <button className="login-btn" onClick={onRetry}>Coba lagi</button>
              <button className="gate-ghost" onClick={onOffline}>Lanjut mode lokal</button>
              <button className="gate-ghost danger" onClick={onLogout}><LogOut size={14} /> Keluar</button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
