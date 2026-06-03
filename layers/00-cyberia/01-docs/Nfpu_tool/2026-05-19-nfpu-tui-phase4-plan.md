# NFP TUI (Phase 4) Implementation Plan (Rough Draft)

**Goal:** Recreate the legacy `nfpu.sh` bash script workflow inside the Go TUI, providing a beautiful, unified deployment experience.

**Architecture:** Use `tea.Exec` to run blocking commands or `io.Reader` pipes to stream real-time command output into Bubbletea viewports.

**Tech Stack:** Go, Bubbletea Viewport component, `os/exec`.

---

## Task 1: Diff Visualization Panels

- Create a new model for the "Deployment Pipeline".
- Execute `git diff --color=always` and capture output.
- Execute `nix-diff` or the dry-run command.
- Display outputs using `bubbles/viewport` for scrolling.

## Task 2: nix-forecast Integration

- Add a panel that runs `nix-forecast` based on the evaluated build plan.
- Parse the forecast results to show Cache Hit rates visually (progress bars or percentages).

## Task 3: Interactive Deployment Flow (with Rollback & State Management)

- Implement a wizard flow: `Diff -> Forecast -> Confirm -> Deploy`.
  - **Confirm Step**: Display precisely which machines will change along with the exact diff (e.g., git/nix-diff per machine) in a confirm panel before proceeding.
  - **State Management & Partial Updates**: Maintain a transaction log of the deployment state (using per-machine status entries consumed by the Bubbletea component) to handle and track partial updates across the fleet.
  - **Rollback Procedure**: Document and implement a rollback strategy tied to `clan machines update`. Define:
    - How to invoke a reverse update to the previous Git/flake revision if a machine deployment fails.
    - Procedures for an emergency halt of the deployment queue.
    - Per-machine remediation steps in case of communication or bootstrap failure.

## Task 4: Build Log Streaming & Status Notifications

- When deploying, use `os/exec` to run `clan machines update [machine] 2>&1 | nix-output-monitor`.
- Hook the command's stdout pipe into the Bubbletea component (real-time consumer) to parse and display `nix-output-monitor` progress bars.
- Handle graceful exit, emergency cancel, and success/failure notification upon completion.
- Logging Guidance:
  - Write complete command outputs to local log files (e.g., `/var/log/nfpu/deploy-<timestamp>.log`).
  - Provide clear log retention and rotation guidance (e.g. keep last 10 logs).
  - On failure, show clear next-step instructions (re-run checklist or trigger rollback) in the UI, referencing the log file path.
