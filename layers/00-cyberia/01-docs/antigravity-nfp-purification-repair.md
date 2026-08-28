# Antigravity Task — Purification Repair: Finish What the Crash-Recovery Skipped

> Harness rules apply with EXTRA STRICTNESS: the previous session completed a
> 5-phase refactor in ~5 minutes after a context crash and skipped its core work
> while claiming completion. For every feature below, evidence must include the
> VERIFICATION COMMAND OUTPUT, not summaries. One PR per phase. If a check fails,
> the feature is `blocked` with the error pasted — never mark passing on faith.
> First run ./init.sh; if the baseline is red, fixing it is your only feature.

Context: commit ddc5b22 "complete 5-phase dendritic purification" landed PARTIAL
work. Verified present: mkDendriticTree helper (layers/80-lib/81-helpers/), leaf
default.nix stubs, tag profiles with internal mkIf gating, 43.0-selector.nix
(experience enum), 43.2-end4-hyprland adapter skeleton, dendritic-structure-test
updates. Verified MISSING (listed below per phase).

## PHASE 1 — Remove misfiled artifacts (claim: docs-artifact-cleanup)

Commit ddc5b22 committed prompt files into docs:
- layers/00-cyberia/01-docs/antigravity-nfp-dendritic-purification.md
- layers/00-cyberia/01-docs/ag-prompt-after-purification.md
- layers/00-cyberia/01-docs/nfp-audit-ci-cache-iso.md
Move them OUT of the canonical docs set — either to `layers/00-cyberia/06-scripts/prompts/`
(if you want prompt history kept in-repo) or delete them (they're the user's
working files; git history preserves regardless). Also fold
layers/00-cyberia/01-docs/architecture.md (24 lines, added in the crash commit)
into the real architecture doc work from the docs-overhaul spec — a 24-line
architecture.md is a stub, not documentation.
Verification: `ls layers/00-cyberia/01-docs/` contains zero prompt/recovery files.

## PHASE 2 — Actually extract Noctalia from Hyprland (claim:
## noctalia-experience-extraction — REOPEN it; it was closed without the work)

This is the core of the purification and was skipped. Verified still-coupled:
- layers/40-desktop/41-hyprland/default.nix sources
  ~/.config/hypr/noctalia.conf, hyprtoolkit.conf, and .cache/noctalia overlay paths
- 41-hyprland/scripts.nix contains the Noctalia theme-switch pipeline
  (noctalia msg wallpaper-set etc.)
- 41-hyprland/rules.nix has noctalia namespace blur/anim rules
- 41-hyprland/keybinds.nix binds $ipc = "noctalia msg"

Do the extraction:
1. Create layers/40-desktop/43-experiences/43.1-noctalia-hyprland/ (currently
   absent). Gate everything on `layers.desktop.experience == "noctalia-hyprland"`.
2. Move INTO it: the noctalia/hyprtoolkit source lines, the theme-switch script
   and its reload chain, the noctalia layer-rules, the noctalia IPC keybinds,
   noctalia package/HM module enablement, wallpaper/notification/idle/lock/polkit
   ownership that noctalia claims.
3. Neutral base: 41-hyprland (or 42.1-hyprland if you complete the compositor
   renumbering — optional, low priority) gates on
   `layers.desktop.compositor == "hyprland"` and must contain ZERO occurrences of
   "noctalia" afterward (`grep -ri noctalia layers/40-desktop/41-hyprland/` →
   empty is the verification command).
4. Generated-config layout: ~/.config/hypr/base.conf (neutral) +
   ~/.config/hypr/experiences/noctalia.conf (the extracted includes) +
   active-experience.conf generated from the selector. No hardcoded /home paths —
   config.home.homeDirectory.
5. Selector integration: 43.0-selector.nix exists — verify it declares the enum
   including "noctalia-hyprland", derives `compositor` read-only, defaults to
   noctalia-hyprland for desktop tags (behavior preservation for z0r0), and has
   the server-tag assertion. Fix any gaps.
6. Verification (paste outputs): both machines evaluate with experience
   noctalia-hyprland; the end4 override evaluates for z0r0
   (`nix eval` with a test module setting experience = "end4-hyprland"); grep
   proof the base is shell-free; behavior preserved — the desktop session must
   come up identically on the next real rebuild.

## PHASE 3 — Import-site purity leftovers (claim: dendritic-imports-purity —
## reopen)

1. `grep -n "niri" layers/40-desktop/default.nix`: if the niri import is still
   commented out, uncomment it and gate niri inside its module by enable option.
   Verify: `nix eval` shows niri options exist on both machines; niri inactive.
2. layers/40-desktop/45-file-managers/default.nix: file-managers-system.nix must
   go through the same wrapper/tree path as siblings (ddc5b22 only changed 1 line
   here — verify it actually did).
3. mkDendriticTree adoption audit: the helper exists — but check whether manual
   import lists remain anywhere:
   `grep -rn "mkDendriticModule \"" layers/ --include=default.nix` should only
   appear inside mkDendriticTree itself or as documented opt-outs. Convert any
   remaining manual lists to the tree.
4. mkDendriticModule name argument: ddc5b22 touched it (+9/-2) — verify whether
   the name is now USED (option-path assertion or derivation) or still discarded.
   If discarded, implement at minimum the assertion that declared option paths end
   with the given name.
5. mkForce sweep in 90-profiles: `grep -rn "mkForce" layers/90-profiles/` →
   the ai-server.nix mkForce false entries should be gone or justified with
   comments; if the tag profiles were rewritten with mkIf gating in ddc5b22,
   confirm mkDefault usage is consistent (softest level).
6. `or false` sweep: after always-import, remove fallbacks on options whose owners
   are now guaranteed imported (impermanence.enable, machine.tags). Remaining
   `or` requires an inline justification comment.

## PHASE 4 — Skipped Phase 3: eval performance (claim: eval-performance)

Never done. Do it now:
1. Baseline NOW (post-refactor): time both machine evals, closure sizes, and count
   nixpkgs nodes: `jq '[.nodes[].locked | select(.owner=="NixOS" and .repo=="nixpkgs")] | length' flake.lock`
2. Add follows where cache-safe to reach ONE nixpkgs instance (llm-agents stays
   unfollowed — upstream cache depends on its pin; comment it). Remove dead
   inputs (grep for usage first; list removals in PR body).
3. Duplicate-import check: after tree adoption, no module file imported twice.
   Add it to the dendritic structure test.
4. Record numbers as evidence. Note in docs that RUNTIME lag (matugen storms,
   crash loops) is a separate axis partially mitigated by 0c10174 (earlyoom,
   rclone caps, z0r0 service trimming).

## PHASE 5 — Guardrails completion (claim: dendritic-guardrails — reopen)

Extend layers/00-cyberia/05-tests/dendritic-structure-test.nix (or checks) to
enforce ALL of: zero relative helper imports; zero commented-out imports in
default.nix files; zero mkForce under layers/90-profiles/; hyprland base contains
zero "noctalia" strings; both desktop experiences evaluate; each layer file
imported exactly once. Wire into flake checks so nix flake check enforces.

## PHASE 6 — Reconcile the harness state (claim: harness-state-reconciliation)

The crash-recovery marked features passing without evidence. Audit
feature_list.json + agent-progress.md:
- For every feature touched by ddc5b22, check the evidence field actually contains
  command output. Any feature closed with summary-only or missing evidence gets
  reopened to `in-progress`, re-verified in this session, and closed with REAL
  output — or stays open.
- agent-progress.md gets an entry recording this audit honestly: what the crash
  recovery claimed vs. what was verified present/missing.
- Update session-handoff.md.
- Add one line to .agents/rules/ (or harness-session-protocol SKILL.md): "After
  context loss/crash, NEVER re-mark prior work passing from memory — re-run the
  verification commands or reopen the feature."

## Acceptance criteria

- `grep -ri noctalia layers/40-desktop/41-hyprland/` → empty (paste output).
- `43.1-noctalia-hyprland/` exists and holds all shell ownership; z0r0 desktop
  behavior unchanged after a real rebuild (note the rebuild result in evidence).
- end4 override evaluates; selector assertions present.
- No prompt/recovery files in 01-docs.
- Zero relative helper imports; zero commented imports; tree adoption complete;
  mkForce gone from profiles; `or` fallbacks justified.
- flake.lock has one nixpkgs node (llm-agents exception commented); before/after
  eval numbers in evidence.
- Structure test enforces all guardrails via nix flake check.
- feature_list.json contains zero passing features without real command output.
