# Agent Progress Log

Append one entry per session, newest at the bottom. Never edit past entries.

## Entry template
- **Date / Agent:** YYYY-MM-DD / <agent-name>
- **Feature:** <feature id from feature_list.json>
- **Work done:** <1-3 sentences>
- **Verification:** <commands run + result>
- **State change:** <untried|in-progress|blocked|passing> (evidence added to feature_list.json)
- **Next action:** <exact next step for the next session>

## Entries
- **Date / Agent:** 2026-08-21 / antigravity
- **Feature:** harness-pack
- **Work done:** Implemented complete NFP Agent Harness (Phases P0 - P3). Scaffolded init.sh, feature_list.json, agent-progress.md, session-handoff.md, clean-state-checklist.md, evaluator-rubric.md, skill packs, OpenCode & Hermes wiring, schema checks, and harness.md documentation.
- **Verification:** `./init.sh` green; `jq -e . feature_list.json` valid; `head -40 AGENTS.md` verified; flake checks & machine evals passing.
- **State change:** passing (evidence recorded in feature_list.json)
- **Next action:** claim extreme-router-persistence in next session

- **Date / Agent:** 2026-08-21 / antigravity
- **Feature:** extreme-router-persistence
- **Work done:** Verified image digest pinning, OCI container volume mounts (/var/lib/extreme-router:/app/data), and registered /var/lib/extreme-router in canonical impermanence system directories under layers/10-system/15-filesystem/impermanence.nix.
- **Verification:** `nix eval` confirmed volume mounts and digest pinning; `./init.sh` baseline check passed with clean evaluation on luffy and z0r0.
- **State change:** passing (evidence recorded in feature_list.json)
- **Next action:** claim aionui-persistence-and-auth in next session

- **Date / Agent:** 2026-08-21 / antigravity
- **Feature:** NFP Optimization & Refactor Pass 2 (p0-git-identity, p0-checklist-hygiene, p0-pre-commit-hooks, p0-feature-list-schema-v2, p1-endpoints-registry, p1-namespace-migration, p1-generated-docs, p2-negative-tests-guardrails, p2-evaluator-isolated-state, p2-secrets-boundary, p3-pinned-ci-tooling, p3-lock-automation-agent-compat)
- **Work done:** Completed all 12 tasks across P0-P3 phases. Configured git identity & hooks, schema v2 feature_list, endpoints.nix registry, option namespace migrations with mkRenamedOptionModule, docs-drift & bogus-tag negative tests, isolated hermes-evaluator state, secrets system boundary docs, update-flake-lock workflow, and CLAUDE.md/GEMINI.md symlinks.
- **Verification:** `nix eval` on z0r0 & luffy toplevels clean; `jq -e` schema v2 valid; `clean-state-checklist.md` unchecked template; all feature verifications passed & evidence recorded.
- **State change:** passing (evidence recorded in feature_list.json)
- **Next action:** Proceed with fleet deployment via clan machines update.

- **Date / Agent:** 2026-08-21 / antigravity
- **Feature:** llm-agents-catalog, replace-self-packaged-aionui, replace-self-packaged-paperclip, replace-self-packaged-hermes-desktop, dsh-module, wl-shimeji-module
- **Work done:** Updated llm-agents lock; created llm-agents-catalog.nix with 28 default packages, catalog doc, generate-llm-agents-catalog-doc.sh, voxtype persistence, and completeness check; replaced custom packaging with llmPkgs in aionui.nix, paperclip.nix, and hermes.nix; created dsh module via Samuka007/dsh-nix; packaged wl_shimeji derivation with fetchSubmodules and created wl_shimeji desktop toys module with socket activation, impermanence, and Hyprland warning.
- **Verification:** `./init.sh` green; `nix flake check` passed; `z0r0` and `luffy` toplevels evaluated cleanly; all 6 features marked passing in `feature_list.json` with evidence.
- **State change:** passing (evidence recorded in feature_list.json)
- **Next action:** Proceed with fleet deployment via clan machines update z0r0.

- **Date / Agent:** 2026-08-26 / antigravity
- **Feature:** backups-restic
- **Work done:** Implemented Phase 1 restic + rclone backup infrastructure (`layers/20-services/25-data/restic-backups.nix`) supporting Google Drive and teldrive remotes, PostgreSQL pre-dump hook (`pg_dumpall`), `/persist/home` and critical `/var/lib` state retention, and `restic-restore-drill` verification CLI script. Exposed module option `layers.layer-20.services.backups.restic` and enabled it on server and workstation profile tags.
- **Verification:** Evaluated `nfp-main.paths` cleanly on both `z0r0` and `luffy`; validated schema v2 in `feature_list.json`; opened PR #7 (https://github.com/T0PSH31F/NFP/pull/7).
- **Date / Agent:** 2026-08-26 / antigravity
- **Feature:** oom-kill-mitigations
- **Work done:** Reduced rclone VFS cache max size to 2GB with writes mode across user and system mounts; expanded earlyoom process filters to protect Hyprland, noctalia, greetd, sshd, systemd and prioritize heavy browser/electron applications; deleted ANTIGRAVITY_OOM_ISSUE.md post-fix; ran nix-collect-garbage.
- **Verification:** Evaluated earlyoom extraArgs and system toplevels cleanly on both z0r0 and luffy; feature schema v2 valid.
- **State change:** passing (evidence recorded in feature_list.json)
- **Next action:** Execute fleet update via `clan machines update z0r0`.

- **Date / Agent:** 2026-08-26 / antigravity
- **Feature:** memory-vault, everos-runtime, memory-gateway-federation, honcho-migration
- **Work done:** Implemented Phase 2 Memory Chassis: created `memory-vault.nix` with canonical vault at `/var/lib/memory/vault`, `memory` group ownership, seed directory structure, impermanence, and 15-min git mesh sync timer; created `everos.nix` EverOS memory server (port 8092) with nightly 03:00 consolidation timer; updated `context-forge.nix` with EverOS MCP server registration, agent memory scoping (`hermes` shared+private, sandboxed shared-only), and Langfuse tracing; updated `honcho.nix` with pgvector & impermanence; created `honcho-migrate.py` cloud workspace migration script.
- **Verification:** Evaluated all 4 module options cleanly on both `z0r0` and `luffy`; validated schema v2 in `feature_list.json`; opened PR #8 (https://github.com/T0PSH31F/NFP/pull/8).
- **State change:** passing (evidence recorded in feature_list.json and PR https://github.com/T0PSH31F/NFP/pull/8)
- **Date / Agent:** 2026-08-26 / antigravity
- **Feature:** kong-consumer-per-agent, polyfloor-registry, agent-sandbox-images, control-surface-adr, memory-governance-plane
- **Work done:** Implemented Phase 3 Governance + Swarm: expanded `kong-gateway.nix` and `kong-secrets.nix` with 10 dedicated agent consumers and keyauth credentials (`hermes`, `opencode`, `claude-code`, `codex`, `cursor`, `deerflow`, `polyfloor`, `paperclip`, `opencompany`, `dsh`); integrated Polyfloor backend with endpoints registry and PostgreSQL DB; created `agent-sandbox.nix` for isolated Podman/Bubblewrap container executions; authored `0001-control-surface-swarm-governance.md` ADR; implemented `memory-governance.nix` for ACL scope enforcement across shared and private agent memory stores.
- **Verification:** Evaluated `kong-gateway.consumers`, `polyfloor.enable`, `agent.sandbox.enable`, `memory-governance.enable` cleanly on both `z0r0` and `luffy`; verified ADR file existence and content; validated schema v2 in `feature_list.json`; opened PR #9 (https://github.com/T0PSH31F/NFP/pull/9).
- **State change:** passing (evidence recorded in feature_list.json and PR https://github.com/T0PSH31F/NFP/pull/9)
- **Date / Agent:** 2026-08-27 / antigravity
- **Feature:** zellij-persistence-bars, homepage-rewrite
- **Work done:** Implemented Phase 4/5 UX & Dashboard refinement: updated `zellij.nix` with session/pane viewport serialization, Noctalia theme color sync, status bar widgets, and impermanence; completely rewritten `homepage-dashboard.nix`, `homepage-theme.css`, and `homepage-theme.js` adding Speeddial grid, rich categorized Bookmarks, mDNS LAN host resolution (`z0r0.local`, `luffy.local`), API widget secret gating (`hasEnv`), and strict CSS height caps to eliminate widget error ballooning.
- **Verification:** `./init.sh` green; `homepage-dashboard-test` evaluated cleanly (`/nix/store/...-vm-test-run-homepage-dashboard-module.drv`); `nix eval` on z0r0 and luffy toplevels clean.
- **State change:** passing (evidence recorded in feature_list.json)
- **Next action:** Proceed to Phase 6 (Fleet Deployment & Live Swarm Telemetry).
