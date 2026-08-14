# NFP TUI: Future Iterations & Ideas

The following concepts were brainstormed for future updates to the `nfpu` TUI to improve usability and feature-completeness.

## 1. Fleet Provisioning / Adding Deployments
- Currently, the TUI displays existing machines and their configurations.
- **Goal:** Add an option to "Add a Deployment".
- **Functionality:** Allow users to define, configure, and provision a new deployment from scratch directly within the TUI.
- **Targets:** VM, Container, Cloud Server (VPS/VPC), or Bare-metal machines.
- **Benefits:** Makes provisioning quick, painless, and fully integrated into the NFP workflow.

## 2. Tag Management (Step 2.5)
- Tags (e.g., `ai-server`, `workstation`, `gaming`) act as macro-toggles that define which core modules are imported.
- Because tags are evaluated before Nix options are populated, they cannot be toggled via `machine.options`.
- **Goal:** Introduce a dedicated "Tag Management" step.
- **Functionality:** 
  - Parse available tags from `layers/90-profiles/tags/`.
  - Parse the target machine's `default.nix` to read currently active tags.
  - Allow the user to toggle tags on/off.
  - *Implementation detail:* Requires AST text manipulation of the `.nix` file to update the `imports` array dynamically, rather than just flipping an `enable` boolean.

## 3. Tab-Based UI Redesign
- The current single-list view is clean, but for thousands of options, it can become overwhelming.
- **Goal:** Transition the Registry View into a Tabbed UI (using a Bubbletea tabs component).
- **Proposed Tab Structure:**
  - **Tab 1: Machine Config Layers & Tags** (Tag Management, as described above).
  - **Tab 2: LAYER-10 (System)**
  - **Tab 3: LAYER-20 (Services)** - Lists individual service toggles (e.g., Karakeep, Signal-CLI).
  - **Tab 4: LAYER-30 (Theming)** - *Special Tab!* Needs **Dropdown Menus** for mutually exclusive options (e.g., Cursor, Icon Theme, GTK4 Theme, Boot/Grub Theme, SDDM Theme, Theme Engine like Stylix/Noctalia).
  - **Tab 5: LAYER-40 (Desktop)** - Simple selection: Headless, Hyprland, Niri, Gnome, etc.
  - **Tab 6: LAYER-50 (CLI/TUI)** - Pick shell, nix tools, python, editors (nvim, emacs, helix).
  - **Tab 7: LAYER-60 (GUI Programs)** - Standard checkboxes for GUI apps.
  - **Tab 8: LAYER-70 (Activities)** - E.g., pentesting, gaming, office, audio/video production.

## 4. Enhanced Option Metadata
- **Descriptions:** Continue extracting descriptions from `mkEnableOption` calls.
- **Simplified Names:** Hide the verbose paths (e.g., `layer-10.system.mobile.android.enable`) and show plain English names (`Android`).
- **Parent/Child Enabling Constraints:** Clarify to users that parent enables (e.g., `peripherals.enable`) do not necessarily activate child options (e.g., `peripherals.corsair.enable`) unless strictly defined with defaults in the underlying Nix module code.
