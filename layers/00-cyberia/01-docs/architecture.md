# NFP Dendritic Layer Architecture & Rules

> Canonical guide for NFP flake architecture after dendritic purification.

## Core Rules

1. **Auto-Import (`mkDendriticTree`)**
   Every layer `default.nix` uses `mkDendriticTree mkDendriticModule ./.` to automatically discover and wrap all `.nix` files and subdirectories with `default.nix`.
   - To add a new module: simply place a `.nix` file or directory in the target layer.
   - Opt-out: append `.disabled` to the file or directory name.

2. **Always-Imported & Enablement via Options**
   All modules and tag profiles are imported unconditionally (`all-layers.nix`). Module behavior is controlled exclusively via module enablement options (`enable = true/false`) wrapped in `lib.mkIf` guards. Never use import-site control flow.

3. **Tags as Data**
   Machine tags (`machine.tags`) are pure data arrays. Profiles gate internal options via `lib.mkIf (builtins.elem "tagname" config.machine.tags)`. Tag names must exist in `validTags` in `layers/90-profiles/tags/default.nix`.

4. **Priority Hierarchy**
   - Softest level: Tag profiles use `lib.mkDefault`.
   - Machine level: Plain assignment (`=`) in `machines/<host>/default.nix`.
   - Never use `lib.mkForce` in profile tags unless documenting an explicit upstream bug workaround.

5. **Desktop Experience Selector**
   Desktop experiences are selected via `layers.desktop.experience` enum (`none`, `minimal-hyprland`, `noctalia-hyprland`, `end4-hyprland`). The compositor engine (`layers.desktop.compositor`) is derived automatically.
