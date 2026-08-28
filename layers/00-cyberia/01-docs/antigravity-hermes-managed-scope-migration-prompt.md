# Prompt for Hermes Agent: Adopt Managed Scope, Stop Config Reversion

Paste this directly into a Hermes session (CLI or Desktop) running against the
NFP repo, or into `hermes config set` scripting context. Hermes has direct
filesystem/tool access to its own repo, so it can execute this itself rather
than needing Antigravity as an intermediary.

---

You are working in the `T0PSH31F/NFP` repo. Your own configuration is
currently declared via a NixOS module (`services.hermes-agent.settings` in
`layers/70-agents/76-hermes-agent/hermes.nix`), which renders its full
settings attrset into `~/.hermes/config.yaml` — the exact file you also
write to via `hermes config set` and the Desktop settings UI. This causes
your own GUI toggles to revert after the next `nixos-rebuild switch`, because
the Nix module and your own writes are fighting over the same file.

Fix this using your own native Managed Scope feature
(https://hermes-agent.nousresearch.com/docs/user-guide/managed-scope) instead
of a workaround:

1. Run `hermes doctor` first and report the current managed-scope status and
   resolved `HERMES_MANAGED_DIR` before changing anything.
2. Read `layers/70-agents/76-hermes-agent/hermes.nix` in full. Identify every
   key currently inside `services.hermes-agent.settings` and classify each
   one as either:
   - **Pin** (portable across every machine/profile — model provider
     identity, security policy, shared provider base URLs), or
   - **Leave mutable** (anything you or the user would reasonably toggle at
     runtime — model default/fallback selection, terminal/voice backend
     choices, per-profile skill toggles, memory settings).
3. For everything classified "Pin," write it into `/etc/hermes/config.yaml`
   and `/etc/hermes/.env` (root-owned, `0644`) instead — via the NixOS
   module using `environment.etc`, not `services.hermes-agent.settings`. Do
   not put high-sensitivity secrets in the managed `.env` directly; route
   those through sops-nix and only expose non-sensitive shared values here.
4. For everything classified "Leave mutable," remove it from the Nix module
   entirely. Do not template `~/.hermes/config.yaml` or any per-profile
   `config.yaml` at all going forward — those become fully your own to
   write, exactly like before Nix was involved.
5. Wire in the Kong-primary / ExtremeRouter-fallback provider config from
   this session as part of the pinned layer:
   - `model.provider: kong`, `model.fallback: extremerouter/direct-model-id`
   - `providers.kong` and `providers.extremerouter` blocks with
     `base_url`/`api_key` referencing env vars, not literal secrets.
6. After the edit, run `hermes doctor` again and confirm it reports the
   correct pinned-key count and managed directory. Then have the user run
   `nixos-rebuild switch` and verify: toggle a previously-reverting setting
   in Hermes Desktop, wait past one activation cycle, and confirm it still
   holds.
7. Report back exactly which keys you moved to managed scope, which you left
   mutable, and the diff you applied to `hermes.nix` — do not silently
   commit this; show the user the classification decisions for review
   before finalizing, since some of your own guesses about "pin vs. mutable"
   may not match user intent.

Do not touch OpenCode or Hermes Desktop's own separate settings files in this
pass — those are handled separately via `mkOutOfStoreSymlink`, not Managed
Scope, since only you (Hermes) have this specific feature.
