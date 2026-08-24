# Session Handoff

> Compact state for the next session. Overwrite entirely at the end of each session.

- **Active feature:** dsh module, wl_shimeji module, llm-agents.nix catalog expansion & upstream swaps (P0-P4) — passing
- **Last verified green:** `llm-agents-catalog`, `replace-self-packaged-aionui`, `replace-self-packaged-paperclip`, `replace-self-packaged-hermes-desktop`, `dsh-module`, and `wl-shimeji-module` fully implemented and verified green with clean `./init.sh`, `nix flake check`, and top-level NixOS evaluations for `z0r0` and `luffy`, 2026-08-21
- **Blockers:** none
- **Exact next command:** `./init.sh && clan machines update z0r0`
- **Do not touch:** `clean-state-checklist.md` on main (must remain an unchecked template)
