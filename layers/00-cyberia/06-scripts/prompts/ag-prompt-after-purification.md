# Agent Task — NFP Housekeeping: Flake Hygiene + Shell/Terminal/Desktop Polish

> Agent-agnostic (Hermes/OpenCode/Antigravity). Harness rules apply: claim each
> feature in feature_list.json, verification + evidence, one PR per phase.
> PREREQUISITE: do not start until the in-flight "remaining program" Phase 6 PR is
> merged — this work touches the same files. Run ./init.sh first; if red, fixing
> baseline is your only feature.
> IMPORTANT SEQUENCING: the dendritic-purification prompt (5 phases) may run AFTER
> this one lands — structure all new modules to be purification-compatible
> (mkDendriticModule-wrapped, enable-gated, no relative imports, no mkForce in
> profiles, no `or false` without justification comments).

Repo: NFP — flake-parts + clan-core, numbered dendritic layers, mkDendriticModule
dual-class wrapper, impermanence, clan vars, noctalia/matugen theming on Hyprland
(primary) and Niri.

## PHASE 1 — Flake hygiene (claim: flake-hygiene)

1. Split flake.nix into flake-parts modules under a new `flake/` dir (or
   `layers/00-cyberia/00-flake/` following the numbering):
   - `flake/formatter.nix` — treefmt-nix config (nixfmt-rfc-style + deadnix-fail +
     statix via treefmt wrappers; also fixes the still-open git-hooks repair from
     the --no-verify incident)
   - `flake/devshells.nix` — default devShell (jq, deadnix, statix, nixfmt,
     clan CLI, sops, the harness deps)
   - `flake/checks.nix` — feature_list schema check, lint checks, both-machine
     eval checks
   - `flake/overlays.nix`, `flake/packages.nix` — wiring for 80-lib outputs
   flake.nix keeps ONLY inputs + outputs = flake-parts.lib.mkFlake importing ./flake.
2. Alphabetize: the inputs attrset in flake.nix (group with comment banners:
   core, desktop, agents, services — alphabetical within groups), and every long
   package list in the repo (environment.systemPackages blocks in ai-packages.nix,
   llm-agents-catalog.nix, base.nix, etc.). treefmt keeps nixfmt happy after.
3. Prune dead inputs while alphabetizing (comment evidence in PR body for any
   removal: no references found via grep).
4. Verification: `nix flake show` succeeds, outputs identical in kind to before,
   `nix flake check` green, both machines evaluate.

## PHASE 2 — Shell stack: nushell + carapace + starship (claims:
## nushell-module, carapace-module, starship-rework)

1. **Nushell** — new comprehensive module
   `layers/50-cli-tui-programs/51-shells/nushell.nix` (mkDendriticModule-wrapped,
   `layers.layer-50.cli.nushell.enable`, default off — zsh stays default shell):
   - programs.nushell with enable, settings (vi mode, completions, ls colors),
     environment variables, shellAliases shared with the existing zsh/bash alias
     source (extract aliases to ONE shared attrset consumed by all shell modules —
     no triplicated alias lists)
   - zoxide/navi/direnv integration blocks, matching what zsh currently gets
   - persist `.config/nushell` is already covered by blanket .config persistence —
     add a comment noting it; persist `.local/share/nushell` history explicitly
   - Cheatsheet: add a nushell section to the rofi cheatsheets
     (layers/40-desktop/48-rofi/cheatsheets.nix or wherever cheatsheets live):
     pipelines-vs-commands mental model, `each/where/reduce`, `open`/`save`,
     structured data (table/record/list), `help find`, config locations, and
     NFP-specific entries (fleet commands, harness commands).
2. **Carapace** — `layers/50-cli-tui-programs/51-shells/carapace.nix`:
   programs.carapace enable + bridge into nushell/zsh/bash completions;
   spec list option; cheatsheet section: what carapace is (multi-shell completion
   engine), `carapace --list`, bridging, flag/positional completion style,
   how it composes with nushell's native completions.
3. **Starship rework** — `layers/50-cli-tui-programs/55-prompt/starship.nix`:
   - Audit current settings; keep schema + add_newline; ensure it sources the
     matugen/noctalia palette (same palette variables as everything else — no
     hardcoded hex; this feeds the matugen-uniformity assertion later)
   - Integrate with carapace/nushell correctly (starship is shell-agnostic; just
     ensure enableNushellIntegration = true when nushell module on)
   - Remove duplicated/legacy modules from the format string; add the NFP-relevant
     modules (nix_shell, direnv, git, cmd_duration, kubernetes off, custom kong/
     extreme-router status indicator if cheap via env var).
   - Powerline style consistent with the zellij bottom bar so the terminal has one
     visual language.

## PHASE 3 — Ghostty cursor shader (claim: ghostty-cursor-shader)

Diagnosis: zero references to custom-shader or manga-slash.glsl exist in the repo
— the shader and its config were lost in a refactor. Restore properly this time:
1. Vendor the shader file at
   `layers/40-desktop/46-terminal-emulators/shaders/manga-slash.glsl` (recover
   from git history if present: `git log --all --oneline -- '*manga*'` /
   `git log -S 'custom-shader' --oneline`; else re-fetch from upstream source).
2. ghostty.nix: `programs.ghostty.settings.custom-shader` pointing at the vendored
   store path; `custom-shader-animation = true` if the shader needs it.
3. Add an eval-time assertion the file exists (builtins.pathExists) so a future
   refactor can't silently drop it again.
4. Document the known limitation in a comment: GLSL shaders don't render inside
   zellij/tmux panes (text-cell multiplexers) — expected, not a bug.
5. Verification: `ghostty +show-config | grep custom-shader` shows the path;
   open ghostty OUTSIDE zellij and confirm the cursor trail renders.

## PHASE 4 — Noctalia: plugins + rofi sync (claims: noctalia-plugins-fix,
## rofi-noctalia-sync)

1. **Community plugins**: settings reference plugin:assistant-panel and
   plugin:ip-monitor but nothing installs the plugin sources — that's the bug.
   Noctalia community plugins live in the noctalia-plugins repo and must exist
   under ~/.config/noctalia/plugins/<name>/. Implement declaratively:
   - Add a pinned fetchFromGitHub (or fetchzip) of the plugins repo (rev + hash)
   - Option `layers.layer-40.desktop.noctalia.plugins = [ "assistant-panel" "ip-monitor" ]`
     mapping names → symlinkJoin/linkFarm into ~/.config/noctalia/plugins via
     home.file (mkOutOfStoreSymlink NOT needed here — read-only store links are
     fine, plugins are code not state; but the plugins DIRECTORY must not fight
     noctalia's own writes: link per-plugin subdirs, never the whole dir)
   - Wire the enabled list into the noctalia settings JSON generation so enabled
     state and installed sources can't drift apart.
   - Verification: after rebuild, plugins appear in noctalia's plugin panel and
     activate without errors; `ls ~/.config/noctalia/plugins` shows the symlinks.
2. **Rofi ↔ Noctalia sync**: rofi is "almost there" — finish it:
   - Route rofi's theme through the same matugen palette template noctalia uses
     (find the existing matugen template for rofi under 30-theming or 48-rofi;
     complete missing color slots, remove any hardcoded colors)
   - Ensure the theme reload hook (the hyprland scripts.nix matugen reload chain)
     includes rofi config regeneration/reload so wallpaper changes propagate.
   - Match radius/padding/font to noctalia's design tokens for visual consistency.
   - Verification: change wallpaper → noctalia, rofi, ghostty, zellij bottom bar
     all reflect the new palette without a rebuild.

## Acceptance criteria

- flake.nix contains only inputs + mkFlake wiring; formatter/devshell/checks live
  in flake-parts modules; inputs and package lists alphabetized; PR body lists
  every removed input with grep evidence.
- nushell + carapace modules exist, enable-gated, aliases shared from one source;
  both cheatsheets present in the rofi cheatsheet system.
- starship sources matugen palette; nushell integration works when enabled.
- `ghostty +show-config` shows the vendored manga-slash shader; assertion guards
  against future loss.
- Noctalia plugins installed declaratively and activatable in the panel; rofi
  follows wallpaper-driven theme changes with no rebuild.
- Every module is purification-ready: wrapped, enable-gated, no relative imports,
  no mkForce, justified `or` only.
- nix flake check green; both machines evaluate; all claims passing with evidence.
