# NFP TUI (Phase 2) Implementation Plan (Rough Draft)

**Goal:** Transform the read-only registry from Phase 1 into an interactive, stateful Tree UI where options can be toggled on/off, with changes written back to Nix configuration files.

**Architecture:** Extend Bubbletea with `github.com/charmbracelet/bubbles/list` and `bubbles/key` or a specialized tree component. The application will track modified states and write changes back to `layers/90-profiles/tags/*.nix` or `machines/*/default.nix` depending on the scope of the edit.

**Tech Stack:** Go, Bubbletea, Bubbles, regular expressions/AST parsing for Go-to-Nix writes.

---

## Task 1: Integrate Bubbles Components

- Add list/tree Bubbles to `tui/model.go`.
- Implement navigation (j/k, up/down, pgup/pgdown).
- Implement selection highlighting.

## Task 2: Implement Toggling State

- Add a `Modified` boolean to the `MachineState` structs.
- Map the spacebar/enter key to flip `true/false` states in memory.
- Add visual indicators (e.g., `[✓]` -> `[*]`) for unsaved changes.

## Task 3: Build the Nix Writer (tui-overrides.nix)

- Create `registry/writer.go`.
- Rather than risking in-place modifications to user files, implement a separate machine-managed override mechanism:
  - Implement `GenerateOverride` or `WriteOverride` in `registry/writer.go` to emit/maintain a minimal override module (`tui-overrides.nix` or a JSON overrides file converted to a Nix fragment).
  - The generated override module will set target options (e.g. `activities.office.enable = true/false;`) using standard module imports or higher priority (e.g., `lib.mkForce`).
  - Ensure the writer only writes to/modifies the `tui-overrides.nix` file.
  - Implement durable serialization (e.g., JSON -> Nix conversion or direct Nix fragment writing).
  - Document/ensure the main NixOS configuration imports `tui-overrides.nix` (e.g. via `imports = [ ./tui-overrides.nix ];` in host defaults), ensuring user comments/files remain completely untouched and merge conflicts are avoided.

## Task 4: User Confirmation and Save Flow

- Add a "Press 'S' to Save" keybinding.
- Build an intermediate diff-view model showing pending changes.
- Execute the save, then trigger a re-run of `eval-registry.nix` to ensure ground truth matches memory.
