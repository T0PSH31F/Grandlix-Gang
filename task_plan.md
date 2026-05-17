# Task Plan: Clan NFP Dendritic Layered Refactoring & Modernization

## Goal
Execute a comprehensive layered refactoring of the dendritic NixOS config to improve modularity, readability, scalability, and developer experience. This will turn the codebase into a pristine, professional portfolio showpiece.

## Current Phase
Phase 1: Pre-Refactor Discovery & Safety Checkpoint

## Phases

### Phase 1: Pre-Refactor Discovery & Safety Checkpoint
- [x] Disable blur layerrules on Luffy to ensure UI performance stability.
- [x] Remove failing mic92.cachix.org substituters to fix build blocks.
- [x] Complete Matrix Synapse & Bridges migration to Luffy and enable them properly.
- [x] Stage, commit, and push initial updates to origin/main.
- [x] Document safety checkpoint.
- **Status:** complete

### Phase 2: Layer & Directory Refactoring (Phase 1 of Refactor)
- [ ] Rename/Move Layers:
  - Rename 15 to `15-filesystem`.
  - Rename 12 to `12-processor`.
  - Rename 19 to `19-optimizations`.
  - Move 18 to layer 70 (`70-agents` or `70-virtualization`).
  - Move Peripherals to the available layer 18 (`18-peripherals`).
  - Move layers 84-87 (templates/libs) up to layer 00 (`00-cyberia` or new layer prefix).
- [ ] Distribute Layer 13 Packages:
  - Move package modules from layer 13 and distribute them where appropriate.
  - Remaining/unplaced package modules to layer 60 (`60-gui-programs`).
  - Move user config (t0psh31f.nix etc.) to the now open layer 13 (`13-users` or `13-identity`).
- [ ] Theming Layer Reorganization:
  - Rename layer 30 to theming/identity.
  - Break out gtk, qt, and cursor configs to layers 31 (`31-cursor`), 33 (`33-gtk`), and 34 (`34-qt`).
- **Status:** pending

### Phase 3: Feature Architecture & Granular Toggle Templates (Phase 2 of Refactor)
- [ ] Break up 16-mobile into separate modules and toggles for iOS and Android.
- [ ] Consolidate Peripherals into a single hardware enable toggle (including xbone, dualshock).
- [ ] Create a comprehensive system default config template showing all available toggles.
- [ ] Implement granular GUI activity enables:
  - Music production (reaper, llms, etc.)
  - Image editing (gifsicle, exiftool, pixeluvo, drawio, libresprite, pixieditor, etc.)
  - Office (openoffice/libreoffice suite, texlive packages, etc.)
  - Recording (obs-studio, video editing software)
  - Pentesting subcategories (wifi, enumeration, web app, recon)
- [ ] Add `feh` module and integrate `stylix` as layer 35.
- **Status:** pending

### Phase 4: Tidy-up, Optimization, & CI Integration
- [ ] Remove Garnix configurations and optimize CI/CD with nix flake check.
- [ ] Perform cleanup of old/redundant files (Nami-specific, old configs).
- [ ] Update README.md system specs for z0r0 to LG Gram 17z90q.
- **Status:** pending

### Phase 5: Verification & Delivery
- [ ] Perform a full Nix evaluation/check on all configurations.
- [ ] Review codebase cleanliness, formatting, and structural elegance.
- [ ] Final commit & push to main.
- **Status:** pending

## Key Questions
1. How are user home-manager files organized inside layer 13 vs layer 30?
2. Which package modules in layer 13 can be distributed to layers 40, 50, 60?
3. Where are 84-87 templates and overlays currently located, and how should they map to 00?

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Bypassed clan-core matrix-synapse | Prevent infinite recursion in Nginx/ACME options in new Nixpkgs |
| Enabled matrix-server & mautrix-bridges directly on Luffy | Consolidate and centralize services from decommissioned Nami workstation |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| mic92.cachix.org timeout | 1 | Removed from flake.nix to prevent blocking builds |

## Notes
- Ensure all Nix files compile cleanly using `nix flake check` or similar dry-run evaluation.
- Retain modular dendritic pattern properties using flake-parts.
