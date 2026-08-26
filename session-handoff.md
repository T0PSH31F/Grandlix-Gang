# Session Handoff

> Compact state for the next session. Overwrite entirely at the end of each session.

- **Active feature:** backups-restic — passing (PR #7 opened: https://github.com/T0PSH31F/NFP/pull/7)
- **Last verified green:** `backups-restic` module (`layers/20-services/25-data/restic-backups.nix`), PostgreSQL `pg_dumpall` pre-hook, `/persist/home` + critical `/var/lib` state retention, `restic-restore-drill` verification CLI script, and profile tag integration (`luffy`, `z0r0`), 2026-08-26
- **Blockers:** none
- **Exact next command:** Start new thread for Phase 2: `memory-vault + everos-runtime + memory-gateway-federation`
- **Do not touch:** `clean-state-checklist.md` on main (must remain an unchecked template)

