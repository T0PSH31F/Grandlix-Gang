# Findings & Decisions: Clan NFP Refactoring

## Requirements
- Move package modules out of layer 13 (`13-packages` or similar) and distribute them to appropriate layers (system, service, or desktop/cli).
- Any package module in layer 13 that doesn't fit a specific location must go to layer 60 (`60-gui-programs`).
- Move user configuration (e.g., `t0psh31f.nix` in `layers/30-identity/31-users/`) to layer 13 (which will now be open).
- Rename layer 30 to `30-theming`/`30-identity`. Break out:
  - Cursor configuration to layer 31 (`31-cursor`)
  - GTK configuration to layer 33 (`33-gtk`)
  - QT configuration to layer 34 (`34-qt`)
  - Stylix configuration + `feh` integration to layer 35 (`35-stylix`)
- Move layer 18 (`18-virtualization` or similar) to layer 70.
- Move peripheral configuration (controllers, hardware) to layer 18 (`18-peripherals`). Enable them under a single unified hardware switch.
- Rename the following layers:
  - 15 to `15-filesystem`
  - 12 to `12-processor`
  - 19 to `19-optimizations`
- Move layers 84-87 (templates/lib/overlays) up to layer 00.
- Break up 16-mobile into separate modules and toggles for iOS and Android.
- Create activity-focused GUI app enables (Music, Image editing, Office, Recording, Pentesting).
- Remove Garnix, optimize flake check.
- Update system specs for z0r0 in README.md to LG Gram 17z90q.

## Research Findings
- The repository uses a dendritic layering pattern with imports in directories such as `layers/10-system`, `layers/20-services`, `layers/30-identity`, `layers/40-desktop`.
- Active files to modify span these layer directories and need careful renaming to preserve references.
- Caddy acts as the reverse proxy on Luffy and needs to be kept in sync with any service changes.
- Nix Config extra-substituters has some stale/blocking caches (mic92.cachix.org), which we removed to accelerate evaluation times.

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| Custom matrix-server | Avoids clan-core's Nginx sslDhparam recursion bug |
| Placed user configs in Layer 13 | Keeps user identity and core profiles separate from visual/theme definitions |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| mic92.cachix.org timeouts | Removed from flake.nix |
| SDDM & Hyprland cursor size mismatch | Addressed in initial cursor configuration |

## Resources
- Flake entry point: [flake.nix](file:///home/t0psh31f/Clan/NFP/flake.nix)
- Luffy entry point: [machines/luffy/default.nix](file:///home/t0psh31f/Clan/NFP/machines/luffy/default.nix)
- Z0r0 entry point: [machines/z0r0/default.nix](file:///home/t0psh31f/Clan/NFP/machines/z0r0/default.nix)
- Documented plan: [Final-Layered-Refactor-Prompt.md](file:///home/t0psh31f/Clan/NFP/layers/00-cyberia/01-docs/Final-Layered-Refactor-Prompt.md)

## Visual/Browser Findings
- The custom prompt artifact is available in `/home/t0psh31f/Clan/NFP/layers/00-cyberia/01-docs/Final-Layered-Refactor-Prompt.md`.
