# Prompt for Antigravity/Hermes: FHS Compatibility Fixes + Profiles Audit

Repo: github.com/T0PSH31F/NFP. Follow harness rules: claim in feature_list.json,
verify with evidence, one PR per group.

## Group A — Session PATH propagation (fixes agent-detection across the board)
1. Locate the Hyprland and Niri startup config (`layers/40-desktop/41-hyprland/`,
   `layers/40-desktop/42-niri/`). Confirm whether
   `dbus-update-activation-environment --systemd --all` (or the equivalent
   home-manager `wayland.windowManager.hyprland.systemd.variables = ["--all"]`)
   is present in the compositor startup sequence.
2. If missing, add it. This is the most likely single fix for AionUI,
   mission-control, and ExtremeRouter failing to detect Claude Code, Hermes,
   and OpenCode — GUI-launched processes under Hyprland/Niri don't inherit
   the same PATH as an interactive shell unless this is wired explicitly.
3. Verify by relaunching each orchestrator post-rebuild and confirming
   detection succeeds for all three CLI agents, not just one.

## Group B — buildFHSEnv wrapping for orchestrators that still fail
For whichever of AionUI / mission-control / ExtremeRouter still fail to
detect agents after Group A, or detect them but fail due to environment
mismatch:
1. Locate each orchestrator's Nix package definition (likely under
   `layers/20-services/22-ai/` or `layers/70-agents/74-ai-infra/`).
2. Wrap the orchestrator binary using `pkgs.buildFHSEnv`, giving it a
   filesystem view where `/usr/bin`, `/bin`, etc. resolve as they would on a
   standard FHS distro, so its own hardcoded-path detection logic and any
   subprocess environment expectations succeed without per-tool shims.
3. If `buildFHSEnv` is too heavy for a given case (e.g. only one hardcoded
   path check is failing), use a lighter `writeShellScriptBin` shim at the
   exact path the tool checks, exec-ing through to the real Nix-store
   binary, instead.
4. Verify each orchestrator's "install" button/detection actually completes
   an end-to-end action (not just shows green), since the user reported
   some install options are present but non-functional.

## Group C — MITM proxy CA trust (ExtremeRouter)
1. Find where ExtremeRouter's MITM proxy writes its generated root CA
   certificate (check its own config/data directory — likely somewhere
   under its state dir, not a standard location it can register itself).
2. Add that certificate file path to `security.pki.certificateFiles` in the
   appropriate machine or services module — this is the declarative NixOS
   equivalent of `update-ca-certificates`, which the proxy's own installer
   almost certainly assumes exists and silently fails to use.
3. Verify TLS interception actually works end-to-end after rebuild, not
   just that the cert file is present in the trust bundle.

## Group D — pxpipe: explicitly outside Nix
1. Do not attempt to package `pxpipe` via nixpkgs derivations for this pass.
2. Add `pipx` (or `uv`) to the relevant profile's packages if not already
   present, and document in `layers/00-cyberia/01-docs/` that `pxpipe` is
   intentionally installed via `pipx install pxpipe` / `uv tool install
   pxpipe` into `~/.local/pipx` (or uv's tool dir) rather than through Nix.
3. Add that directory to the impermanence persistence list so it survives
   reboots like any other user-state path.

## Group E — Profiles/machines regression audit (do this carefully)
The user suspects enable-logic was deleted from `machines/*/default.nix`
during the recent dendritic-layer migration without being relocated into
`layers/90-profiles/tags/`, which would be a functional regression, not just
a cleanliness issue.
1. Use `git log` and `git diff` across the dendritic migration commits
   (identify the relevant PR/commit range from `agent-progress.md`) to find
   every removed line under `machines/*/default.nix` that set a
   `layers.layer-NN.*.enable` value or equivalent feature toggle.
2. For each removed toggle, confirm whether an equivalent toggle now exists
   in `layers/90-profiles/tags/*.nix`, driven by the machine's tag list. If
   it does, no action needed — this was a correct migration.
3. For each removed toggle with NO equivalent restored anywhere, treat this
   as a regression: either restore it into the correct tag file (preferred,
   consistent with the tags-system design goal), or if it's genuinely
   machine-specific (not applicable to tag-based reuse), restore it directly
   in `machines/*/default.nix` as an explicit exception.
4. After this pass, confirm every `machines/*/default.nix` file contains
   ONLY: hardware/form-factor definitions, the machine's tag list, and truly
   seldom, machine-specific overrides — nothing that should be tag-driven
   general feature logic. Report any file that still violates this.
5. Do not guess — if a removed toggle's original intent is ambiguous from
   the diff alone, list it for the user to decide rather than silently
   picking a side.

## Verification checklist
- [ ] All three CLI agents (Claude Code, Hermes, OpenCode) detected by all
      three orchestrators (AionUI, mission-control, ExtremeRouter)
- [ ] Each orchestrator's install/detection action completes functionally,
      not just displays as available
- [ ] ExtremeRouter MITM proxy interception verified working end-to-end
- [ ] pxpipe installed via pipx/uv, persisted, documented as intentionally non-Nix
- [ ] Full list of any machines/* enable-logic regressions found, with
      restoration status for each (restored / confirmed-fine / needs-user-decision)
