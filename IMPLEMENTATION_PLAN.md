# Proposal Progress Tracker — Implementation Plan

## Environment decision
The workspace root is a personal home directory with no application repository. Existing relevant materials are static HTML in `materi-ta-llm-agent`, so they are preserved and not overwritten. A new standalone application will be created in `C:\\Users\\user\\Documents\\pribadi\\proposal-progress-tracker`.

## Architecture
- React + TypeScript + Vite SPA.
- Local-first persistence with a versioned JSON envelope in localStorage for this lightweight single-user MVP; storage is isolated behind `src/services/storage.ts` and can be upgraded to IndexedDB without changing UI models.
- Pure domain helpers for progress, readiness, dependency blocking, duplicate DOI/URL detection, and CSV/JSON export.
- No external AI/API dependency; all required workflows work offline.

## Pages/modules
- Dashboard: derived progress, blockers, deadlines, recommended action, activity.
- Roadmap: 20 editable phase cards with prerequisites, criteria, deliverables, and tasks.
- Tasks: CRUD, explicit completion verification, filters, sort, dependency warnings.
- Team: configurable members, workstreams, ownership, dependencies.
- Literature: structured source records, duplicate detection, matrix, CSV/JSON export.
- Research Gap: evidence/interpretation/hypothesis separation.
- Agent & Experiments: agent workspace, security policies, architecture/diagram source, test cases, metrics.
- Proposal Chapters: official BAB I–III/front matter structure, writing workflow, quality checks.
- Schedule: timeline/deadlines/milestones.
- Final Review: explicit readiness criteria and supervisor approval recording.
- Settings: project title, theme, backup/restore validation, sample-data reset.

## Data model
Versioned `AppState` contains project, proposal sections, tasks, team members, dependencies, literature sources/notes, research gaps, architecture components, tool definitions, security policies, test cases, experiment runs, metrics, milestones, review comments, attachment references, activity log, and settings. All records have stable IDs and timestamps. Derived progress is never stored as authoritative state.

## Verification strategy
- Unit tests for domain calculations and safe backup validation.
- `npm run build`, `npm test`.
- Run the actual Vite app and use browser smoke checks for navigation, task creation/completion, persistence, export/restore, and readiness state.

## Risks/assumptions
- This version is intentionally local/single-user: no authentication, sync, or multi-device collaboration.
- Attachment/file links are references only; files are not uploaded or executed.
- Calendar/timeline is implemented without inventing a university submission deadline.
- Full rich-text word processing is out of scope; Markdown/external links are used.
- Literature records are user-entered; the app never fabricates citations or verification.

## Build order
1. Types/default seed data/storage/domain utilities.
2. App shell, navigation, dashboard, tasks, roadmap, chapters.
3. Team, literature, research gap, agent/experiment, schedule, final review.
4. Backup/export/settings.
5. Tests, build, runtime/browser verification, defect fixes.

Created from inspection of the current workspace on 2026-07-23.
``` 

> Note: The date above is an implementation note only; the app does not assume or display a university deadline.
