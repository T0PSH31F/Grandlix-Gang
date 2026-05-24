# NFP TUI (Phase 3) Implementation Plan (Rough Draft)

**Goal:** Create a "Fleet Status Dashboard" that actively checks the health and status of machines and services configured in the registry.

**Architecture:** Use Go's goroutines and channels to perform asynchronous checks without blocking the UI. For reachability, use native Go ICMP ping or SSH checks. For service status, execute `systemctl status` commands over SSH.

**Tech Stack:** Go (Goroutines, Channels), `golang.org/x/crypto/ssh` (for remote execution).

---

### Task 1: Asynchronous SSH Worker Pool
- Create `status/checker.go`.
- Implement an SSH client that reads `~/.ssh/config` or uses `tailscale status` and keys to connect to machines (Z0R0, Luffy).
- Setup a worker pool to ping machines concurrently.

### Task 2: Service Verification
- Parse the registry for services that are *expected* to be running (e.g., `adguard.enable == true`).
- For each enabled service, remotely execute `systemctl is-active [service-name]`.
- Map the responses back to expected UI states (Running, Failed, Missing).

### Task 3: Build Dashboard View
- Create a new Bubbletea model `tui/dashboard.go`.
- Use a split layout: Top half shows machine up/down status, bottom half shows service health matrix.
- Use Lipgloss colors: Green (Healthy), Red (Failed/Offline), Yellow (Pending).

### Task 4: Live Polling & Updates
- Implement a `tea.Tick` command that re-runs checks every X seconds.
- Handle connection timeouts gracefully so the UI never hangs.
