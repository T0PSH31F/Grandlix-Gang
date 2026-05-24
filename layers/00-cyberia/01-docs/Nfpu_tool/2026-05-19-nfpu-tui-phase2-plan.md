# NFP TUI (Phase 2) Implementation Plan (Rough Draft)

**Goal:** Transform the read-only registry from Phase 1 into an interactive, stateful Tree UI where options can be toggled on/off, with changes written back to Nix configuration files.

**Architecture:** Extend Bubbletea with `github.com/charmbracelet/bubbles/list` and `bubbles/key` or a specialized tree component. The application will track modified states and write changes back to `layers/90-profiles/tags/*.nix` or `machines/*/default.nix` depending on the scope of the edit.

**Tech Stack:** Go, Bubbletea, Bubbles, regular expressions/AST parsing for Go-to-Nix writes.

---

### Task 1: Integrate Bubbles Components
- Add list/tree Bubbles to `tui/model.go`.
- Implement navigation (j/k, up/down, pgup/pgdown).
- Implement selection highlighting.

### Task 2: Implement Toggling State
- Add a `Modified` boolean to the `MachineState` structs.
- Map the spacebar/enter key to flip `true/false` states in memory.
- Add visual indicators (e.g., `[✓]` -> `[*]`) for unsaved changes.

### Task 3: Build the Nix Writer
- Create `registry/writer.go`.
- Implement logic to locate the corresponding `.nix` file (e.g., if toggling `activities.office.enable` on a tag, parse the tag's file).
- Use regex or an AST parser to safely inject or modify `.enable = true/false;`.

### Task 4: User Confirmation and Save Flow
- Add a "Press 'S' to Save" keybinding.
- Build an intermediate diff-view model showing pending changes.
- Execute the save, then trigger a re-run of `eval-registry.nix` to ensure ground truth matches memory.
