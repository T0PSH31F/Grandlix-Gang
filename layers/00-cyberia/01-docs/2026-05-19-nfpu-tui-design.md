# NFPU TUI — System Design & Roadmap

**Date:** 2026-05-19
**Context:** Brainstorming the evolution of the `nfpu` script into a robust, full-featured Terminal User Interface (TUI) for managing the NFP (Nix Flake Pirates) dendritic architecture.
**Tech Stack:** Go + Bubbletea (Charm ecosystem)

## 1. Goal & Principles

The goal is to provide a single pane of glass for managing the NFP fleet. Currently, understanding what is enabled on which machine requires manually tracing imports across `layers/`, `90-profiles/tags/`, and `machines/*/default.nix`.

**Principles:**
1. **Learn & Build:** This project is a learning experience for Go and the Bubbletea Elm architecture.
2. **Coupled but Clean:** The tool will live within the NFP repository (`layers/00-cyberia/09-tools/nfpu/`) to intimately understand the dendritic layout, acting as a unique configuration manager.
3. **Hybrid Accuracy:** Fast UI rendering backed by accurate `nix eval` for ground truth.

---

## 2. The Four-Phase Roadmap

To ensure continuous delivery and manage complexity, the project is divided into four distinct phases. This spec focuses deeply on Phase 1.

### Phase 1: Option Registry (The Foundation)
A machine-readable catalog and documentation generator for every `mkEnableOption` and `.enable =` assignment across the repository. This provides the data backbone for all future phases.

### Phase 2: Interactive TUI Toggle (The Manager)
A stateful Bubbletea application that parses the Phase 1 registry and presents a browsable tree. Users can toggle services and features per machine or per tag, with the Go application automatically rewriting the underlying `.nix` files to reflect the changes.

### Phase 3: Fleet Status Dashboard (The Monitor)
Integration of live system data into the TUI. The app will spawn background goroutines to ping machines (via SSH/Tailscale) and query `systemctl status` for services marked as enabled in the registry, presenting a live "Expected vs. Actual" health matrix.

### Phase 4: Deploy Pipeline Integration (The Orchestrator)
Absorbing the existing `nfpu` shell script logic. The TUI will orchestrate the deployment workflow:
1. Show `nix-diff` and `git diff` in scrolling panes.
2. Run `nix-forecast` to predict binary cache hits.
3. Stream `nix-output-monitor` (nom) logs during `clan machines update`.

---

## 3. Deep Dive: Phase 1 - Option Registry

### 3.1. Architecture

The Option Registry requires a **Hybrid Generation** approach.

1. **Static Discovery (Fast):** A fast Go routine (or simple script) that traverses `layers/` to find all `mkEnableOption` declarations and map the directory structure. This groups options logically by Layer (e.g., `10-system`, `20-services`) and Domain (e.g., `Desktop`, `AI Stack`).
2. **Dynamic Validation (Accurate):** A `nix eval` call that resolves the actual enabled state for each machine in the fleet. This is necessary because tags (`90-profiles/tags/*.nix`) and machine overrides (`machines/*/default.nix`) combine in complex ways.

### 3.2. Implementation Strategy

**Step 1: The Nix Introspection Tool**
We will create a Nix file (e.g., `layers/00-cyberia/09-tools/nfpu/eval-registry.nix`) designed specifically to be evaluated by the TUI. It will output JSON.
*   It will iterate over all defined machines in `clan.nix`.
*   It will evaluate the `config.layers` and `config.services` trees for those machines.
*   It will export the `.enable` status of known services.

**Step 2: The Go CLI Foundation**
We will scaffold the Go project inside `layers/00-cyberia/09-tools/nfpu/`.
*   `go mod init nfpu`
*   Add dependencies: `github.com/charmbracelet/bubbletea`, `github.com/charmbracelet/lipgloss`.
*   Create a basic Bubbletea model.

**Step 3: State Management (The Model)**
The Go application will execute `nix eval --json -f layers/00-cyberia/09-tools/nfpu/eval-registry.nix` in a background `tea.Cmd`.
The resulting JSON will be unmarshaled into Go structs:

```go
type MachineState struct {
    Name     string
    Tags     []string
    Services map[string]bool // e.g., "layers.layer-20.services.config.adguard.enable" : true
}

type Registry struct {
    Machines map[string]MachineState
}
```

**Step 4: The Phase 1 UI**
The initial Bubbletea view will be a read-only list/tree of options, beautifully styled with Lipgloss, showing the status for a selected machine.
*   **Left Pane:** List of categories (System, Services, GUI, Activities, AI).
*   **Right Pane:** List of options in that category, with checkmarks `[✓]` or `[ ]` representing their state on the currently selected machine.

### 3.3. Location & Repository Structure

We will migrate the existing `tools/nfpu/` to `layers/00-cyberia/09-tools/nfpu/`.

```
layers/00-cyberia/09-tools/nfpu/
├── main.go             # Go/Bubbletea entry point
├── eval-registry.nix   # Nix file for JSON introspection
├── tui/                # Bubbletea views and update logic
│   ├── model.go
│   ├── view.go
│   └── update.go
├── registry/           # Logic for parsing Nix/JSON
│   └── parser.go
└── legacy/             # The old bash scripts (temporarily moved here)
    ├── nfpu.sh
    └── lib/
```

### 3.4. Success Criteria for Phase 1
*   [ ] Go project initialized in `layers/00-cyberia/09-tools/nfpu/`.
*   [ ] Legacy bash scripts moved to a `legacy/` subdirectory.
*   [ ] A Nix expression successfully evaluates the fleet's `.enable` state to JSON.
*   [ ] A basic Bubbletea TUI launches, parses the JSON, and displays a categorized, read-only list of options and their status per machine.
*   [ ] The codebase is cleanly structured using the Elm architecture (Model, View, Update), ready for interactivity in Phase 2.
