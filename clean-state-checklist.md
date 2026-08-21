# Clean-State Checklist

Complete every item before ending a session. If any item fails, the session is not done.

- [x] `nix fmt -- --check` clean
- [x] `nix flake check` passes
- [x] Both machines evaluate (`nix eval .#nixosConfigurations.{luffy,z0r0}.config.system.build.toplevel.drvPath > /dev/null`)
- [x] Every new module file is imported by its layer's `default.nix`
- [x] `feature_list.json` updated: state + evidence (commit SHA, command output)
- [x] `agent-progress.md` entry appended
- [x] `session-handoff.md` overwritten with current state
- [x] Docs in sync if behavior changed (`ports.md`, `AGENTS.md`, `layers/00-cyberia/01-docs/`)
- [x] Commit footers note cross-machine impact (shared layers affect z0r0 AND luffy)
- [x] Working tree clean or remaining changes explicitly documented in handoff
