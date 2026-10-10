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

## Verify

```bash
npm run build
npm test -- --environment jsdom
npm audit --audit-level=moderate
```

## Data boundary

The current version is single-user/local. Core state is stored in the browser. No hidden telemetry or external AI calls are included. Literature records and experiment results must be entered by the user; the app does not fabricate or infer verified research results.

## License

MIT
