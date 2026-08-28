# Antigravity Task — NFP Dendritic Purification + Desktop Experience Scaffolding

> Harness rules apply (AGENTS.md Startup Workflow): claim each feature in
> feature_list.json, one feature at a time, verification commands run and recorded
> as structured evidence, clean-state checklist, ONE PR per phase. `nix fmt`,
> `nix flake check`, deadnix, statix green at EVERY commit. Conventional commits
> with cross-machine impact footers.

**THIS IS A REFACTOR, NOT A REWRITE.** Do not create a new repo or scaffold from
scratch. Every phase preserves behavior on both machines unless a step explicitly
says behavior changes. The test for every step: both `nixosConfigurations`
(z0r0, luffy) evaluate, and `nix flake check` passes.

Repo: NFP — flake-parts + clan-core NixOS fleet (z0r0, luffy). Numbered dendritic
layers 00–90. mkDendriticModule dual-class wrapper (routes `nixos` output to NixOS
config, `home` output under home-manager.users.<primaryUser>). Impermanence,
clan vars, Kong/ExtremeRouter stack. The desktop layer is 40-desktop with
41-hyprland, 42-niri, 43-noctalia, 44-de-frameworks.

## PHASE 0 — Baseline measurements (claim: dendritic-baseline)

Before touching anything, capture and commit to the PR description:
1. `time nix eval --raw .#nixosConfigurations.z0r0.config.system.build.toplevel.drvPath`
   (and luffy) — eval time baseline.
2. `nix path-info -S` on both toplevels — closure size baseline.
3. Count: `find layers -name '*.nix' | wc -l`, and
   `grep -rn "mkDendriticModule" layers --include=default.nix | wc -l`.
4. `nix flake metadata | grep -c "Last modified"` style input inventory; note how
   many DISTINCT nixpkgs instances exist in flake.lock (`jq '[.nodes[].locked |
   select(.owner==\"NixOS\" and .repo==\"nixpkgs\")] | length' flake.lock`).
These numbers are the evidence the refactor improved things. Record in
feature_list.json.

## PHASE 1 — Dendritic anti-pattern purge (claims: dendritic-wrapper-fix,
## dendritic-auto-import, dendritic-imports-purity, dendritic-tags-as-data,
## dendritic-priority-hygiene)

Known anti-patterns to eliminate (verified on main):

1. **Make the wrapper use its name argument.** `mkDendriticModule` currently has
   signature `_name: module:` — the name is DISCARDED while every call site passes
   one. Change it to derive the option namespace from the name
   (e.g. `(mkDendriticModule \"claude-code\" ./71-coding/claude-code.nix)` at layer
   70 registers under `layers.layer-70.agent.claude-code`). Implement by having the
   wrapper inject a `_module` args value or merge the option path prefix; migrate
   leaf modules to declare only their leaf options. If full derivation is too
   invasive for one pass, minimally: keep the argument but add an assertion that
   the module's declared option path ENDS WITH the given name — catching mismatches
   at eval time. Document which behavior you implemented.
2. **True auto-import.** The previous refactor claimed auto-import but every
   default.nix still hand-enumerates imports. Write `mkDendriticTree` in
   80-lib/81-helpers using builtins.readDir: it scans a directory, wraps every
   `.nix` file (and every subdir with a default.nix) in mkDendriticModule with the
   file/dir name as the name argument, and returns the import list. Replace ALL
   manual import lists in layer default.nix files with it. Keep explicit opt-out
   possible (a `.disabled` suffix convention — NOT comments). No new flake inputs;
   keep it pure flake-parts + clan-core.
3. **Imports carry no semantics — purge import-site configuration.**
   - `layers/40-desktop/default.nix`: UNCOMMENT the niri import
     (`# (mkDendriticModule \"niri\" ./42-niri/default.nix)`) and gate niri entirely
     by its enable option inside the module. Verify niri options exist on all
     machines but niri is inactive where not enabled.
   - `layers/40-desktop/45-file-managers/default.nix`: `./file-managers-system.nix`
     is imported RAW alongside wrapped modules. Wrap it like the others (or fold
     it into a wrapped module) so every module in the tree goes through the same
     dual-class routing.
   - `layers/30-theming/default.nix`: still uses
     `import ../80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }` — convert
     to the injected `{ lib, mkDendriticModule, ... }:` pattern like all siblings.
   - Sweep the whole tree: `grep -rn \"import \\.\\./\" layers/` must return ZERO
     relative helper imports; `grep -rn \"# (mkDendriticModule\\|# \\./\" layers/**/default.nix`
     must return zero commented-out imports.
4. **Tags as data, not imports.** Currently `mkMachineFromTags` in clan.nix maps
   `machine.tags` to profile FILE PATHS (`./layers/90-profiles/tags/${tag}.nix`),
   so tags control whether options exist. Invert it: all tag profile modules are
   ALWAYS imported (via the auto-import tree), and each profile gates internally:
   `config = lib.mkIf (builtins.elem \"desktop\" config.machine.tags) { ... }`.
   Then DELETE `mkMachineFromTags` and its path mapping from clan.nix. The
   tag-registry validation added earlier becomes unnecessary — remove it and its
   negative test, replacing with ONE simpler negative test: a bogus tag must fail
   evaluation with a readable error via a single assertion in the tags default
   module comparing against a `validTags` list. Tags are now pure data.
5. **Priority hierarchy hygiene.** Tag profiles are the SOFTEST level.
   - Sweep `layers/90-profiles/tags/`: every `lib.mkForce` becomes `lib.mkDefault`
     (`sillytavern-app.enable = lib.mkForce false` and
     `opencompany.enable = lib.mkForce false` in ai-server.nix are the known ones —
     for modules that are broken/replaced, prefer deleting the module or setting
     the disabled default in the module itself, with a comment).
   - Machines override with plain `=` (default priority beats mkDefault); nothing
     in the fleet should need mkForce except documented bug workarounds with a
     linked issue/comment.
   - Sweep `or false` / `or [ ]` fallbacks that exist only because the owning
     module might not be imported (e.g. `config.layers.layer-10.system.config.impermanence.enable
     or false`, `osConfig.machine.tags or [ ]`). After Phase 1.4 all owning modules
     are always imported, so options always exist: remove the fallbacks. Any
     remaining `or` requires an inline comment justifying it.
   - Standardize the dual-context pattern: pick ONE way modules access NixOS
     config from HM contexts (`osConfig ? config` default-arg pattern is in use —
     make it uniform, document it in the nfp-module-authoring skill).

## PHASE 2 — Desktop experience scaffolding (claims: desktop-selector,
## hyprland-neutral-base, noctalia-experience-extraction, end4-experience)

SCOPE LIMIT: do NOT implement DMS, ML4W, or other desktop setups. Build the
architecture + migrate the existing Noctalia setup + ONE proof adapter (end-4).
The goal is scaffolding that makes future experiences a drop-in.

Restructure `layers/40-desktop/` (keep numbered-layer convention):

```
40-desktop/
├── 41-foundation/        # portals, polkit, pipewire/session base, wayland env
├── 42-compositors/
│   ├── 42.1-hyprland/    # NEUTRAL base — no shell references
│   └── 42.2-niri/        # neutral base
├── 43-experiences/
│   ├── 43.0-selector.nix
│   ├── 43.1-noctalia-hyprland/
│   └── 43.2-end4-hyprland/
├── 44-applications/      # shared terminals/browsers/file-managers (absorb 45-file-managers etc.)
└── 45-display/           # monitors, laptop
```

1. **Selector** (`43.0-selector.nix`), always imported:
   - `layers.desktop.experience`: enum `[ \"none\" \"minimal-hyprland\" \"noctalia-hyprland\"
     \"end4-hyprland\" ]`, default = `noctalia-hyprland` when `desktop` in
     machine.tags else `none`.
   - `layers.desktop.compositor`: READ-ONLY, derived via attrset lookup from
     experience (`noctalia-hyprland`/`end4-hyprland`/`minimal-hyprland` →
     `hyprland`; `none` → `none`).
   - Assertion: `server`-tagged machines must have experience == \"none\".
   - Machine boundary: set the enum in `machines/<host>/default.nix`
     (z0r0 = noctalia-hyprland to preserve current behavior). Tag profiles may set
     defaults with mkDefault; machines decide.
2. **Neutral Hyprland base** (`42.1-hyprland/`): gate on
   `osConfig.layers.desktop.compositor == \"hyprland\"`. KEEP: programs.hyprland.
   enable, UWSM compositor registration, package/portalPackage selection from
   inputs.hyprland, generic input defaults, NVIDIA cursor workarounds, generic
   layout/dwindle settings. MOVE OUT (to the noctalia experience): every `source`
   line referencing noctalia.conf/hyprtoolkit.conf, noctalia cache/theme hooks,
   shell-specific exec-once, notification/wallpaper/launcher/idle/lock ownership.
   This extraction is the heart of the phase — the current 41-hyprland module
   sources Noctalia files directly; after this phase it must reference zero
   shell-specific paths.
3. **Noctalia experience** (`43.1-noctalia-hyprland/`): gate everything on
   `experience == \"noctalia-hyprland\"`. Move all extracted Noctalia behavior here:
   HM noctalia module import (isolate external input imports INSIDE the adapter),
   hyprland settings sourcing noctalia.conf/hyprtoolkit.conf, exec-once, matugen/
   theme wiring, and any bar/notification/wallpaper/idle/lock/polkit ownership it
   claims. Replace all hardcoded `/home/t0psh31f/...` paths with
   `config.home.homeDirectory` / `config.xdg.configHome`.
   Generated-config layout (prevents cross-experience clobbering):
   `~/.config/hypr/base.conf` (neutral) + `~/.config/hypr/experiences/<name>.conf`
   per experience + declaratively generated `active-experience.conf` including the
   selected one.
4. **end-4 proof adapter** (`43.2-end4-hyprland/`): add input
   `github:xBLACKICEx/end-4-dots-hyprland-nixos` (the HM-module port of
   end-4/dots-hyprland). Gate on `experience == \"end4-hyprland\"`; enable its
   `illogical-impulse` HM module with its hyprland package/portal wiring and a
   minimal dotfiles selection (fish, kitty). Keep it fully encapsulated in the
   adapter; verify it EVALUATES on both machines and builds on the desktop host.
   If the input's eval is broken upstream, drop the input, leave the adapter as a
   documented skeleton, and mark the feature blocked-external with evidence — do
   not patch around it for hours.
5. **Ownership assertions** (in 43.0-selector.nix): shells are mutually exclusive
   by enum construction, but add executable guards for the resources they share:
   exactly one polkit agent (noctalia and end-4/DMS-style suites both ship one);
   no second notification daemon when an experience owns notifications;
   experience != none on server tag. Each assertion message must say WHAT to change.
6. Optional specialisations: DO NOT add them (extra closures = eval cost). The
   enum + rebuild is the switch mechanism. Document this decision in the module.

## PHASE 3 — Eval/closure performance (claim: eval-performance)

The suspected slowness has eval-side and runtime-side causes; attack the eval side
here (runtime desktop lag is usually matugen scripts/hyprland plugins — out of
scope, note in docs):
1. **Single nixpkgs instance.** Audit flake.lock for duplicate nixpkgs nodes
   (Phase 0 counted them). Add `follows` for inputs that can safely share
   (llm-agents is intentionally NOT followed if upstream cache depends on its own
   pin — keep that exception, comment it). Target: one nixpkgs rev in the lock
   graph wherever cache-compat allows.
2. Remove dead inputs/outputs: unused inputs, the `.supergraph` dir if vestigial,
   containers/hermes flake if superseded by agent-images/llmPkgs hermes-desktop.
3. Trim per-module wrapper overhead: after auto-import, confirm no module is
   imported twice (once via tree, once via explicit list left behind). Add a check
   asserting each file imports exactly once (readDir vs duplicates).
4. Re-run Phase 0 measurements; record before/after eval time + closure size as
   evidence. Expectation-setting comment in the PR: module-count reduction and
   single-nixpkgs typically cut eval time meaningfully; runtime feel is separate.

## PHASE 4 — Guardrails + docs (claims: dendritic-guardrails, dendritic-docs)

1. CI/checks additions (as flake checks so `nix flake check` enforces them):
   - zero relative helper imports (`grep` script)
   - zero commented-out imports in default.nix files
   - zero mkForce under layers/90-profiles/
   - no manual import lists where mkDendriticTree applies
   - both machines + BOTH desktop experiences evaluate (eval-check the end4
     experience on z0r0's config via a test override)
2. Docs: update `layers/00-cyberia/01-docs/architecture.md` (create if missing)
   with the final rules: always-imported modules, enablement via options only,
   tags as data, priority table (mkDefault in profiles < machine config),
   experience-selector usage, how to add a new desktop experience (checklist),
   how to add a new module (auto-import means: drop file in the right layer).
   Update `.agents/rules/` + `layers/70-agents/skills/nfp-module-authoring/SKILL.md`
   to match — the skill must teach mkDendriticTree + experience gating.
3. AGENTS.md stays under its line cap; move overflow into architecture.md.

## Acceptance criteria

- `grep -rn "import \.\./" layers/` → empty; no commented imports; no manual
  import lists; no mkForce in 90-profiles; `or false`/`or [ ]` only with
  justifying comments.
- niri options exist on both machines while niri runs on neither.
- Bogus tag fails eval with readable error; typo'd experience enum value fails at
  eval (enum), not at boot.
- `layers.desktop.experience = \"end4-hyprland\"` override evaluates for z0r0;
  switching back to noctalia-hyprland is a one-line change with zero shared-state
  clobbering (per-experience config paths).
- Hyprland base module contains zero noctalia references; noctalia experience
  module contains zero hardcoded /home paths.
- Phase 0 vs Phase 3 numbers recorded in feature_list.json evidence.
- `nix flake check` runs all guardrails; both toplevels build.
