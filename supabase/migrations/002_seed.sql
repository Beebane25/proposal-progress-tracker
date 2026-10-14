-- 002_seed.sql — Data awal Proposal Progress Tracker
-- Jalankan SETELAH 001_schema.sql. Ganti nilai :PROJECT_ID dengan id project Anda,
-- atau gunakan blok DO di bawah (membuat project baru bila variabel tidak di-set).

do $$
declare v_project uuid;
begin
  -- Pakai project pertama milik user yang login, atau buat baru:
  select id into v_project from public.projects order by created_at limit 1;
  if v_project is null then
    insert into public.projects (title, deadline, notes, owner_id)
    values (
      'Perancangan LLM Agent Berbasis Tool dengan Deteksi dan Pertahanan Indirect Prompt Injection serta Explainable Security Decision untuk Skenario Cybersecurity',
      null,
      'Catatan proyek lokal. Jangan masukkan rahasia atau dokumen sensitif.',
      (select auth.uid())
    ) returning id into v_project;
  end if;

  -- Members ----------
  insert into public.members (project_id, client_id, name, role, description, responsibilities, sort_order)
  values (v_project, 'm1', 'Saya', 'LLM Agent & Integration', 'Bertanggung jawab atas arsitektur agent, integrasi tool dan detector, security layer, benchmark, serta pengujian agent.', '["LLM Agent design", "LangGraph", "Tool integration", "Detector integration", "ALLOW / SANITIZE / QUARANTINE / BLOCK", "AgentDojo", "InjecAgent", "Task success, latency, testing"]'::jsonb, 0)
  on conflict (project_id, client_id) do nothing;
  insert into public.members (project_id, client_id, name, role, description, responsibilities, sort_order)
  values (v_project, 'm2', 'Rule-based Detector', 'Detection Method & Robustness Testing', 'Mengembangkan mekanisme deteksi Indirect Prompt Injection berbasis aturan, menguji ketahanan detektor, dan mengevaluasi kinerjanya.', '["Rule design dan IPI categories", "Risk scoring, preprocessing, normalization", "PDF extraction dan detector evaluation", "Robustness testing dan error analysis"]'::jsonb, 1)
  on conflict (project_id, client_id) do nothing;
  insert into public.members (project_id, client_id, name, role, description, responsibilities, sort_order)
  values (v_project, 'm3', 'Dataset, XAI & Evidence Evaluation', 'Dataset Management, Explainability & Evidence-Based Evaluation', 'Mengelola dataset, merancang evaluasi explainability, dan memastikan setiap keputusan keamanan didukung bukti yang dapat ditelusuri.', '["Dataset dan benchmark management", "Ground-truth spans dan annotation guide", "Evidence extraction dan rule explanations", "Evidence precision, recall, F1 dan XAI evaluation"]'::jsonb, 2)
  on conflict (project_id, client_id) do nothing;

  -- Tasks: workstream LLM Agent ----------
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-0', 'Pelajari perbedaan chatbot dan tool-using agent', 'D1 · LLM Agent Design', 'Memahami siklus input → action → observation sebelum merancang komponen.', 'Catatan desain agent dengan batasan dan diagram sederhana.', 'Catatan selesai atau tautan bukti', 'LLM Agent & Integration', '3.1.1 Arsitektur Sistem', 'Tinggi', 'Sedang Dikerjakan', null, '[]'::jsonb, '["proposal"]'::jsonb, 0)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-1', 'Baca dokumentasi resmi LangGraph', 'D2 · LangGraph', 'Sumber primer diperlukan sebelum memilih state, node, edge, dan routing.', 'Ringkasan dokumentasi + sumber resmi.', 'Ringkasan dengan URL dan catatan bagian', 'LLM Agent & Integration', '2.1.4 LangGraph', 'Sedang', 'Sedang Dikerjakan', null, '[]'::jsonb, '["proposal"]'::jsonb, 1)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-2', 'Sepakati kontrak output detector', 'D4 · Detector Integration', 'Integrasi tidak boleh mengarang schema atau threshold yang belum disepakati.', 'Draft kontrak input/output, status keputusan, evidence, dan error.', 'Dokumen kontrak disetujui grup', 'LLM Agent & Integration', '3.1.4 Integrasi Agent dan Security Layer', 'Kritis', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 2)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-3', 'Definisikan kebijakan ALLOW', 'D5 · Security Policy', 'Aksi harus memiliki trigger, perilaku, logging, dan test case yang dapat ditinjau.', 'Baris decision table ALLOW.', 'Decision table + approval teammate', 'LLM Agent & Integration', '3.1.5 ALLOW/SANITIZE/QUARANTINE/BLOCK', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 3)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-4', 'Definisikan kebijakan SANITIZE', 'D5 · Security Policy', 'Sanitasi harus menjelaskan perubahan konten dan risiko kehilangan informasi.', 'Baris decision table SANITIZE.', 'Decision table + approval teammate', 'LLM Agent & Integration', '3.1.5 ALLOW/SANITIZE/QUARANTINE/BLOCK', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 4)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-5', 'Definisikan kebijakan QUARANTINE', 'D5 · Security Policy', 'Quarantine memisahkan konten mencurigakan dari alur eksekusi.', 'Baris decision table QUARANTINE.', 'Decision table + approval teammate', 'LLM Agent & Integration', '3.1.5 ALLOW/SANITIZE/QUARANTINE/BLOCK', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 5)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-6', 'Definisikan kebijakan BLOCK', 'D5 · Security Policy', 'Block wajib mencegah side effect dan memberi penjelasan kepada pengguna.', 'Baris decision table BLOCK.', 'Decision table + approval teammate', 'LLM Agent & Integration', '3.1.5 ALLOW/SANITIZE/QUARANTINE/BLOCK', 'Kritis', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 6)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-7', 'Riset AgentDojo dan threat model-nya', 'D6 · AgentDojo', 'Membedakan studi benchmark, rencana penggunaan, dan eksperimen aktual mencegah klaim palsu.', 'Catatan paper, dokumentasi, scope, limitasi.', 'Catatan dengan sumber yang dibaca', 'LLM Agent & Integration', '2.1.5 AgentDojo, InjecAgent, dan Benchmark', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 7)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-8', 'Riset InjecAgent dan attack model-nya', 'D7 · InjecAgent', 'Tidak semua benchmark langsung kompatibel dengan detector PDF yang dirancang.', 'Catatan kompatibilitas dan adaptasi.', 'Catatan dengan sumber yang dibaca', 'LLM Agent & Integration', '2.1.5 AgentDojo, InjecAgent, dan Benchmark', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 8)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-9', 'Definisikan task success, attack success, dan latency', 'D8–D10 · Evaluation', 'Denominator, timing boundary, partial success, dan failure harus eksplisit.', 'Protocol evaluasi dan format pencatatan run.', 'Protocol disetujui tim', 'LLM Agent & Integration', '3.1.6 Pengujian dan Evaluasi', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 9)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-10', 'Buat test case normal, attack, dan edge case', 'D11 · Agent Testing', 'Regression test menjaga kebijakan keamanan tidak hanya menjadi dokumentasi.', 'Tabel test case dengan expected vs actual.', 'Minimal satu kasus per security action', 'LLM Agent & Integration', '3.1.6 Pengujian dan Evaluasi', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 10)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'task-11', 'Susun literature matrix awal', 'Literature Review', 'Matrix membantu mengidentifikasi gap berdasarkan bukti, bukan asumsi dari satu abstrak.', 'Matrix minimal beberapa sumber yang benar-benar dibaca.', 'Sumber memiliki status baca yang jujur', 'Pribadi', '2.1 Studi Literatur', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '["proposal"]'::jsonb, 11)
  on conflict (project_id, client_id) do nothing;

  -- Tasks: workstream Rule-based Detector ----------
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-A1', 'Mempelajari pendekatan rule-based detection untuk prompt injection.', 'Studi literatur metode rule-based detection dan batasan evidencenya.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 100)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-A2', 'Mengidentifikasi karakteristik instruksi berbahaya dan pola serangan.', 'Catat pola, indikator, dan variasi serangan yang didukung sumber.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 101)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-A3', 'Menentukan indikator, aturan, dan kriteria deteksi.', 'Rancangan indikator, rule ID, dan kriteria keputusan.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 102)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-A4', 'Menyusun spesifikasi dan dokumentasi rule-based detector.', 'Spesifikasi kontrak input/output dan dokumentasi desain.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 103)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-B1', 'Membuat modul detektor yang dapat menerima input teks.', 'Implementasi modul input teks yang dapat diuji.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 104)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-B2', 'Mengimplementasikan aturan deteksi yang terdokumentasi.', 'Rule engine sesuai spesifikasi dan rule ID.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 105)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-B3', 'Menghasilkan keputusan deteksi dan indikator risiko yang dapat dijelaskan.', 'Output decision, evidence, dan indikator risiko; bukan probabilitas tanpa kalibrasi.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 106)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-B4', 'Mengintegrasikan detektor dengan pipeline LLM Agent.', 'Integrasi yang dapat dipanggil oleh workflow agent.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 107)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-B5', 'Menyediakan antarmuka atau fungsi untuk security layer.', 'API/fungsi kontrak detector untuk security layer.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 108)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C1', 'Menguji serangan dengan instruksi berbahaya langsung dalam dokumen eksternal.', 'Hasil uji dengan expected dan actual outcome.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 109)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C2', 'Menguji variasi paraphrasing.', 'Kasus uji paraphrase dan analisis error.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 110)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C3', 'Menguji karakter yang dipisahkan, misalnya “i g n o r e previous instructions”.', 'Kasus uji spaced characters dan hasil deteksi.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 111)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C4', 'Menguji variasi huruf besar-kecil, spasi, dan tanda baca.', 'Kasus uji normalization dan hasil deteksi.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 112)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C5', 'Menguji teknik encoding atau obfuscation yang relevan.', 'Kasus uji obfuscation dalam ruang lingkup.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 113)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C6', 'Menguji instruksi berbahaya yang bercampur dengan teks normal.', 'Hasil uji mixed benign/malicious text.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 114)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C7', 'Menguji variasi format dokumen jika termasuk ruang lingkup.', 'Hasil uji format dokumen yang disetujui.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 115)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-C8', 'Mencatat detection result, false negative, false positive, dan failure.', 'Log hasil eksperimen dan error taxonomy.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 116)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-D1', 'Menghitung precision, recall, F1-score, dan false positive rate.', 'Tabel metrik dengan formula dan denominator.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 117)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-D2', 'Membandingkan hasil dengan baseline detector yang relevan.', 'Perbandingan yang menyatakan baseline dan batasannya.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 118)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-D3', 'Mendokumentasikan keterbatasan pendekatan berbasis aturan.', 'Limitasi yang didukung hasil pengujian.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 119)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-D4', 'Menyiapkan tabel hasil eksperimen dan analisis error.', 'Tabel hasil dan error analysis.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 120)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'det-D5', 'Menyerahkan dokumentasi integrasi kepada owner LLM Agent & Integration.', 'Dokumentasi integrasi dan unresolved decisions.', 'Detektor perlu dibangun dan diuji sebelum klaim robustness dibuat.', 'Bukti kerja dan catatan yang dapat direview.', '', 'Rule-based Detector', '3.1.3 Rule-based Detector', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 121)
  on conflict (project_id, client_id) do nothing;

  -- Tasks: workstream Dataset, XAI & Evidence ----------
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A1', 'Mempelajari dokumentasi benchmark AgentDojo.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 200)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A2', 'Mempelajari dokumentasi benchmark InjecAgent.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 201)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A3', 'Menentukan subset dataset yang relevan dengan threat model penelitian.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 202)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A4', 'Mengidentifikasi contoh serangan Indirect Prompt Injection.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 203)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A5', 'Menyiapkan contoh input normal sebagai data pengujian non-serangan.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 204)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A6', 'Menentukan label ground truth dan pedoman anotasi.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 205)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A7', 'Mendokumentasikan sumber, lisensi, versi, dan prosedur pemrosesan dataset.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 206)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A8', 'Membuat pemisahan data pengembangan dan pengujian jika diperlukan.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 207)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-A9', 'Memastikan data tidak dipakai secara tidak tepat untuk tuning sekaligus evaluasi final.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 208)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-B1', 'Mengidentifikasi informasi yang dibutuhkan untuk menjelaskan keputusan detektor.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 209)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-B2', 'Menentukan format bukti untuk ALLOW, SANITIZE, QUARANTINE, atau BLOCK.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 210)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-B3', 'Menentukan cara menunjukkan potongan teks yang memicu aturan.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 211)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-B4', 'Menghubungkan bukti dengan rule ID, sumber input, dan lokasi teks.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 212)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-B5', 'Merancang format penjelasan untuk peneliti dan pengguna.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 213)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-B6', 'Memastikan penjelasan tidak mengarang bukti atau hasil deteksi.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 214)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-C1', 'Menentukan skema pencatatan bukti untuk setiap keputusan keamanan.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 215)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-C2', 'Mengevaluasi apakah bukti benar-benar berasal dari input.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 216)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-C3', 'Mengevaluasi keterkaitan bukti, aturan terpicu, dan keputusan akhir.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 217)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-C4', 'Mengukur kelengkapan bukti.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 218)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-C5', 'Mengukur konsistensi keputusan dan penjelasan terhadap aturan.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 219)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-C6', 'Menyusun pedoman evaluasi manual jika diperlukan.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 220)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-C7', 'Mendokumentasikan keputusan benar dengan penjelasan tidak memadai.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Sedang', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 221)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-D1', 'Menyusun protokol evaluasi yang dapat diulang.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 222)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-D2', 'Menetapkan metrik dan rumus sebelum eksperimen final.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 223)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-D3', 'Mengukur precision, recall, F1, dan false positive rate bila menjadi tanggung jawab bersama.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 224)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-D4', 'Mengukur evidence grounding atau kesesuaian bukti dengan input.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 225)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-D5', 'Mengukur explanation completeness dan consistency dengan kriteria terdokumentasi.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 226)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-D6', 'Melakukan analisis error terhadap false positive dan false negative.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 227)
  on conflict (project_id, client_id) do nothing;
  insert into public.tasks (project_id, client_id, title, description, why, output, done, owner, section, priority, status, due, deps, tags, sort_order)
  values (v_project, 'data-D7', 'Menyusun tabel, grafik, dan laporan untuk Bab III dan Bab IV.', 'Catat evidence, prosedur, keputusan yang belum selesai, dan batas validitas metrik.', 'Evaluasi harus dapat ditelusuri ke input dan protokol yang disepakati.', 'Dataset/evidence record atau protokol yang dapat direview.', '', 'Dataset, XAI & Evidence Evaluation', '3.1.2 Dataset dan Skenario Serangan', 'Tinggi', 'Belum Dimulai', null, '[]'::jsonb, '[]'::jsonb, 228)
  on conflict (project_id, client_id) do nothing;

  -- Task dependencies ----------
  update public.tasks set deps = '["det-A4", "det-B3", "data-B2"]'::jsonb where project_id = v_project and client_id = 'task-2';
  update public.tasks set deps = '["det-B1", "det-B2", "det-B3"]'::jsonb where project_id = v_project and client_id = 'det-B4';
  update public.tasks set deps = '["data-A6"]'::jsonb where project_id = v_project and client_id = 'det-C8';
  update public.tasks set deps = '["det-B3"]'::jsonb where project_id = v_project and client_id = 'data-C3';

  -- Chapters ----------
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'cover', 'Front matter', 'Halaman Sampul', 'Identitas proposal dan tim.', 'Belum Ditulis', '["Identitas lengkap", "Judul konsisten", "Tanggal diperbarui"]'::jsonb, 0)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'toc', 'Front matter', 'Daftar Isi, Gambar, dan Tabel', 'Navigasi proposal dan inventaris visual.', 'Belum Ditulis', '["Nomor halaman diperiksa", "Gambar memiliki caption", "Tabel dirujuk dalam teks"]'::jsonb, 1)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-0', 'BAB I', '1.1 Latar Belakang', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 2)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-1', 'BAB I', '1.2 Rumusan Masalah', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 3)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-2', 'BAB I', '1.3 Tujuan', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 4)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-3', 'BAB I', '1.4 Manfaat', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 5)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-4', 'BAB I', '1.5 Ruang Lingkup', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 6)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-5', 'BAB II', '2.1 Studi Literatur', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 7)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-6', 'BAB II', '2.1.1 Indirect Prompt Injection', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 8)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-7', 'BAB II', '2.1.2 Rule-based Detector', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 9)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-8', 'BAB II', '2.1.3 LLM Agent dan Tool Integration', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 10)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-9', 'BAB II', '2.1.4 LangGraph', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 11)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-10', 'BAB II', '2.1.5 AgentDojo, InjecAgent, dan Benchmark', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 12)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-11', 'BAB II', '2.1.6 Explainable Security Decision', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 13)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-12', 'BAB II', '2.1.7 Metrik Evaluasi', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 14)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-13', 'BAB II', '2.2 Kajian Metodologi Rekayasa', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 15)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-14', 'BAB II', '2.3 Kajian Produk', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 16)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-15', 'BAB III', '3.1 Metode Rekayasa', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 17)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-16', 'BAB III', '3.1.1 Arsitektur Sistem', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 18)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-17', 'BAB III', '3.1.2 Dataset dan Skenario Serangan', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 19)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-18', 'BAB III', '3.1.3 Rule-based Detector', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 20)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-19', 'BAB III', '3.1.4 Integrasi Agent dan Security Layer', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 21)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-20', 'BAB III', '3.1.5 ALLOW/SANITIZE/QUARANTINE/BLOCK', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 22)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-21', 'BAB III', '3.1.6 Pengujian dan Evaluasi', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 23)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-22', 'BAB III', '3.2 Jadwal Pelaksanaan', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 24)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-23', 'BAB III', '3.3 Peran dan Tanggung Jawab', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 25)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-24', 'Front matter', 'Daftar Pustaka', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 26)
  on conflict (project_id, client_id) do nothing;
  insert into public.chapters (project_id, client_id, label, title, purpose, status, checklist, sort_order)
  values (v_project, 'sec-25', 'Front matter', 'Lampiran', 'Jawab pertanyaan inti bagian ini dengan bukti dan sumber yang dapat diverifikasi.', 'Belum Ditulis', '[]'::jsonb, 27)
  on conflict (project_id, client_id) do nothing;

  -- Security policies ----------
  insert into public.policies (project_id, name, trigger, behavior, approval)
  values (v_project, 'ALLOW', 'Belum disepakati', 'Konten/tool berjalan sesuai batasan yang disetujui.', 'Belum disetujui')
  on conflict (project_id, name) do nothing;
  insert into public.policies (project_id, name, trigger, behavior, approval)
  values (v_project, 'SANITIZE', 'Belum disepakati', 'Konten diubah lalu dicatat sebelum diteruskan.', 'Belum disetujui')
  on conflict (project_id, name) do nothing;
  insert into public.policies (project_id, name, trigger, behavior, approval)
  values (v_project, 'QUARANTINE', 'Belum disepakati', 'Konten ditahan untuk review manusia.', 'Belum disetujui')
  on conflict (project_id, name) do nothing;
  insert into public.policies (project_id, name, trigger, behavior, approval)
  values (v_project, 'BLOCK', 'Belum disepakati', 'Konten/tool action dihentikan dan side effect dicegah.', 'Belum disetujui')
  on conflict (project_id, name) do nothing;

  -- Evaluation metrics ----------
  insert into public.metrics (project_id, name, sort_order) values (v_project, 'Task Success Rate', 0) on conflict (project_id, name) do nothing;
  insert into public.metrics (project_id, name, sort_order) values (v_project, 'Attack Success Rate', 1) on conflict (project_id, name) do nothing;
  insert into public.metrics (project_id, name, sort_order) values (v_project, 'Benign Task Success Rate', 2) on conflict (project_id, name) do nothing;
  insert into public.metrics (project_id, name, sort_order) values (v_project, 'Latency', 3) on conflict (project_id, name) do nothing;
  insert into public.metrics (project_id, name, sort_order) values (v_project, 'Tool Misuse Rate', 4) on conflict (project_id, name) do nothing;
  insert into public.metrics (project_id, name, sort_order) values (v_project, 'Detector precision/recall/F1 — shared dependency', 5) on conflict (project_id, name) do nothing;
  insert into public.metrics (project_id, name, sort_order) values (v_project, 'Evidence precision/recall/F1 — shared dependency', 6) on conflict (project_id, name) do nothing;

end $$;
