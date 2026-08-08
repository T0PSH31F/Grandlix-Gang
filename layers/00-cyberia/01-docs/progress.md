# Progress Log: Clan NFP Refactoring

## Session: 2026-05-17

### Phase 1: Pre-Refactor Discovery & Safety Checkpoint
- **Status:** complete
- **Started:** 2026-05-17 11:42
- Actions taken:
  - Put override in Hyprland rules to disable blur layerrules just for Luffy.
  - Removed failing mic92.cachix.org substituter and public key from `flake.nix` to prevent cache timeout build blocks.
  - Enabled and integrated `matrix-server` and `mautrix-bridges` on Luffy.
  - Performed `git add .`, committed, and successfully pushed changes to the remote `main` branch.
- Files created/modified:
  - `flake.nix` (modified)
  - `machines/luffy/default.nix` (modified)
  - `layers/40-desktop/41-hyprland/rules.nix` (modified)
  - `task_plan.md` (created)
  - `findings.md` (created)
  - `progress.md` (created)

### Phase 2: Layer & Directory Refactoring (Phase 1 of Refactor)
- **Status:** pending
- Actions taken:
  -
- Files created/modified:
  -

## Test Results
| Test | Input | Expected | Actual | Status |
|------|-------|----------|--------|--------|
| Git remote sync | `git push` | Push success | Push success | ✓ |

## Error Log
| Timestamp | Error | Attempt | Resolution |
|-----------|-------|---------|------------|
| 11:51 | mic92.cachix.org timeout | 1 | Removed substituter from `flake.nix` |

## 5-Question Reboot Check
| Question | Answer |
|----------|--------|
| Where am I? | Phase 1 (Pre-Refactor Discovery & Safety Checkpoint) is complete; transitioning to Phase 2. |
| Where am I going? | Complete Phase 2 Layer & Directory Refactoring. |
| What's the goal? | Comprehensive layered refactoring of the dendritic NixOS config for NFP workstation/server fleet. |
| What have I learned? | Stale binary cache hosts block evaluation; native Matrix synapse config resolves recursion issues. |
| What have I done? | Made first commit/push to establish pre-refactoring safety checkpoint. |

## Session: 2026-07-24

### Fixes Applied
- **Status:** complete
- Actions taken:
  - Fixed starship noctalia palette duplication: changed zsh init script from blind-append to marker-based replacement with atomic temp-file write. Prevents duplicate `[palettes.noctalia]` sections.
  - Moved yazi file picker to left in `ide` tab of opencode layout (swapped pane order).
  - Enabled Steam and Lutris after nixpkgs update to 2026-07-23.
  - Updated AGENTS.md known issues to reflect re-enabled status.
  - Verified noctalia sync: templates directory healthy, zellij-colors-sync and starship palette sync both use atomic write patterns.

## Session: 2026-08-07 — Build/cache optimization pass

### Goal
Reduce package builds + overlay usage; target <30min rebuilds.

### Changes (commit 4dbfa99)
- Purged dead/broken overlays from `82-overlays/custom-packages.nix`:
  hermes-paperclip-adapter (placeholder hashes, unreferenced), openldap i686
  doCheck (dead conditional), pipx test-disable (upstream fixed),
  noctalia-greeter overlay (dead — module uses flake input), desktop-file-utils
  patchelf overlay (glib-2.88 fix upstream).
- Cache ordering: cache.nixos.org first, numtide.com last (unreachable),
  mic92.cachix.org dropped (timeouts). Synced flake.nix nixConfig.
- nix-settings.nix: connect-timeout = 5.
- KEPT (still needed): buildFHSEnvBubblewrap glib/libmount fix, camoufox
  prebuilt + jo-camofox-browser override, lokb, supergraph, uni-pet,
  agentburn, noto-fonts-subset, zjstatus/yazelix wasm fetchers,
  radios pythonRelaxDeps.
- Kept overlays (flake inputs): camoufox-nix, nixpkgs-ai (opencode/ollama bleeding edge).

### Verification
- `nix eval` z0r0 + luffy system.name OK, substituters list verified.
- Dry-run toplevel z0r0: 462 drvs to build (mostly wrappers/fhsenv-rootfs/
  config generation — cheap), 1376 paths fetched. None of the removed
  overlays appear in the build list → they now cache-hit.
- NOTE: flake check has a PRE-EXISTING makeTest failure (fails on clean HEAD too) — not from this change.
- TODO: real `time clan machines update z0r0` run to get the actual baseline.

### Evaluation warnings cleanup (commit 194821f)
All evaluation warnings on z0r0 + luffy toplevel eval eliminated:
- overlays.nix `inherit (final) system` → `final.stdenv.hostPlatform`
- texlive.combined.scheme-small → texliveSmall (removal in 27.05)
- fzf fileWidget{Command,Options} → fileWidget.{command,options}
- programs.gemini-cli → programs.antigravity-cli
- omniroute oneshot unit: removed invalid Restart=always
- opencode tui settings moved to programs.opencode.tui (tui.json, v1.2.15+)
- home.pointerCursor.enable set explicitly
Verified: zero `evaluation warning` lines on both machines' toplevel eval.

### Garnix cache 503 + scipy build failure (2026-08-07)
- garnix.cachix.org: 502/503 since 2026-08-01. Already commented out in caches.nix + flake.nix. Nothing to do except wait for garnix to recover, then uncomment.
- scipy failure was caused by helix.nix pinning `python312Packages.python-lsp-server`, forcing a 39-minute scipy source build on Python 3.12 that fails on a 2e-09 floating-point tolerance in `TestDistributions::test_support_moments_sample[Normal]`. Fixed by switching to `python3Packages.python-lsp-server` (tracks nixpkgs' default cached interpreter). Dry-run after fix: 0 python3.12 derivations.
- Verified: nix build dry-run shows 0 python3.12 paths.
