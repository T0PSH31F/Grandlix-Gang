# Clean-State Checklist

Complete every item before ending a session. If any item fails, the session is not done.

- [ ] `nix fmt -- --check` clean
- [ ] `nix flake check` passes
- [ ] Both machines evaluate (`nix eval .#nixosConfigurations.{luffy,z0r0}.config.system.build.toplevel.drvPath > /dev/null`)
- [ ] Every new module file is imported by its layer's `default.nix`
- [ ] `feature_list.json` updated: state + evidence (commit SHA, command output)
- [ ] `agent-progress.md` entry appended
- [ ] `session-handoff.md` overwritten with current state
- [ ] Docs in sync if behavior changed (`ports.md`, `AGENTS.md`, `layers/00-cyberia/01-docs/`)
- [ ] Commit footers note cross-machine impact (shared layers affect z0r0 AND luffy)
- [ ] Working tree clean or remaining changes explicitly documented in handoff
