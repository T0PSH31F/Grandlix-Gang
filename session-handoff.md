# Session Handoff

> Compact state for the next session. Overwrite entirely at the end of each session.

- **Active feature:** kong-consumer-per-agent, polyfloor-registry, agent-sandbox-images, control-surface-adr, memory-governance-plane — passing (PR #9 opened: https://github.com/T0PSH31F/NFP/pull/9)
- **Last verified green:** Phase 3 Governance + Swarm (`kong-gateway.nix`, `kong-secrets.nix`, `polyfloor.nix`, `agent-sandbox.nix`, `0001-control-surface-swarm-governance.md`, `memory-governance.nix`) implemented and verified with clean Nix evaluations on `z0r0` and `luffy`, 2026-08-26
- **Blockers:** none
- **Exact next command:** Start new thread for Phase 4: `Zellij + homepage` (`zellij-persistence-bars`, `homepage-rewrite`)
- **Do not touch:** `clean-state-checklist.md` on main (must remain an unchecked template)

