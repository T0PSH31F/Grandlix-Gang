# NFP TUI (Phase 3) Implementation Plan (Rough Draft)

**Goal:** Create a "Fleet Status Dashboard" that actively checks the health and status of machines and services configured in the registry.

**Architecture:** Use Go's goroutines and channels to perform asynchronous checks without blocking the UI. For reachability, use native Go ICMP ping or SSH checks. For service status, execute `systemctl status` commands over SSH.

**Tech Stack:** Go (Goroutines, Channels), `golang.org/x/crypto/ssh` (for remote execution).

---

## Task 1: Asynchronous SSH Worker Pool

- Create `status/checker.go`.
- Implement a secure SSH client that:
  - Supports configurable SSH key paths and optional passphrases with fallback to `ssh-agent`.
  - Enforces strict host-key verification using a `known_hosts`-based callback (e.g., `knownhosts.New`) or explicit fingerprint validation. Avoids insecure `InsecureIgnoreHostKey` fallback, but exposes a safe override flag for bootstrapping.
  - Keeps a persistent, thread-safe `ssh.Client` per host using connection pooling/reuse (mutex-protected checkout with keepalives) rather than initiating a new handshake per task.
  - Implements timeouts, retries, and detailed logging for auth and host-key failures.
- Setup a worker pool to execute machine checks concurrently.
- Detect/handle privilege escalation for commands like `systemctl` (e.g., run via `sudo` when required or document/verify that the service is accessible to the invoking user).

## Task 2: Service Verification (with Service-to-Unit Mapping)

- Define a service-to-unit mapping registry or naming convention in the Phase 1 JSON registry output (e.g., adding a `"units"` array or `"unitPattern"` field per service option path).
- Resolve Nix option paths (e.g., `layers.layer-20.services.config.adguard.enable`) to one or more concrete systemd unit names:
  - Handle template units (e.g., `container@NAME.service`).
  - Support multiple units per service (e.g., `[ "matrix-synapse.service", "matrix-synapse-register.service" ]`).
- Parse the registry for services that are *expected* to be running (e.g., `adguard.enable == true`).
- For each enabled service, iterate and resolve all corresponding systemd unit names, then remotely execute `systemctl is-active [unit-name]` for each.
- Map the aggregate responses back to expected UI states (Running, Failed, Missing).

## Task 3: Build Dashboard View

- Create a new Bubbletea model `tui/dashboard.go`.
- Use a split layout: Top half shows machine up/down status, bottom half shows service health matrix.
- Use Lipgloss colors: Green (Healthy), Red (Failed/Offline), Yellow (Pending).

## Task 4: Live Polling & Updates

- Implement a `tea.Tick` command that re-runs checks every X seconds.
- Handle connection timeouts gracefully so the UI never hangs.
