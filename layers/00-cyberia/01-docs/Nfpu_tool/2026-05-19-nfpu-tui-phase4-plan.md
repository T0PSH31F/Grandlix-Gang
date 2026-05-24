# NFP TUI (Phase 4) Implementation Plan (Rough Draft)

**Goal:** Recreate the legacy `nfpu.sh` bash script workflow inside the Go TUI, providing a beautiful, unified deployment experience.

**Architecture:** Use `tea.Exec` to run blocking commands or `io.Reader` pipes to stream real-time command output into Bubbletea viewports.

**Tech Stack:** Go, Bubbletea Viewport component, `os/exec`.

---

### Task 1: Diff Visualization Panels
- Create a new model for the "Deployment Pipeline".
- Execute `git diff --color=always` and capture output.
- Execute `nix-diff` or the dry-run command.
- Display outputs using `bubbles/viewport` for scrolling.

### Task 2: nix-forecast Integration
- Add a panel that runs `nix-forecast` based on the evaluated build plan.
- Parse the forecast results to show Cache Hit rates visually (progress bars or percentages).

### Task 3: Interactive Deployment Flow
- Implement a wizard flow: `Diff -> Forecast -> Confirm -> Deploy`.
- Add an 'Y/N' confirmation step before proceeding to `clan machines update`.

### Task 4: Build Log Streaming
- When deploying, use `os/exec` to run `clan machines update 2>&1 | nix-output-monitor`.
- Hook the command's stdout pipe into a Bubbletea component that parses and displays the `nom` output in real-time.
- Handle graceful exit and final success/failure notification upon completion.
