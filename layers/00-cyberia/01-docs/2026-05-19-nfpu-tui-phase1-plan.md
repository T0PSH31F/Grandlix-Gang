# NFP TUI (Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a hybrid Go/Nix tool that evaluates the NFP dendritic architecture to produce a machine-readable JSON registry of all configuration options and their enabled states across the fleet.

**Architecture:** A Nix expression (`eval-registry.nix`) will evaluate the system configurations to output a JSON map. A Go Bubbletea application will execute this Nix command, parse the JSON into strongly-typed structs, and present a categorized, read-only UI.

**Tech Stack:** Nix, Go 1.22+, Bubbletea, Lipgloss

---

### Task 1: Scaffolding the Workspace

**Files:**
- Create: `layers/00-cyberia/09-tools/nfpu/eval-registry.nix`
- Create: `layers/00-cyberia/09-tools/nfpu/main.go`
- Create: `layers/00-cyberia/09-tools/nfpu/go.mod`

- [ ] **Step 1: Create directory and Go module**
Run: 
```bash
mkdir -p layers/00-cyberia/09-tools/nfpu
cd layers/00-cyberia/09-tools/nfpu
go mod init nfpu
go get github.com/charmbracelet/bubbletea
go get github.com/charmbracelet/lipgloss
```

- [ ] **Step 2: Create a basic empty main.go**
```go
// layers/00-cyberia/09-tools/nfpu/main.go
package main

import "fmt"

func main() {
    fmt.Println("NFPU Init")
}
```

- [ ] **Step 3: Run Go build to test**
Run: `go build -o nfpu-bin main.go && ./nfpu-bin`
Expected: Outputs "NFPU Init"

- [ ] **Step 4: Commit Scaffolding**
```bash
git add layers/00-cyberia/09-tools/nfpu
git commit -m "chore(nfpu): init go project and module"
```

---

### Task 2: Implement Nix Introspection Script

**Files:**
- Modify: `layers/00-cyberia/09-tools/nfpu/eval-registry.nix`

- [ ] **Step 1: Write the Nix evaluation script**
```nix
# layers/00-cyberia/09-tools/nfpu/eval-registry.nix
{ pkgs ? import <nixpkgs> {} }:
let
  # Path to the root of the NFP flake
  flake = builtins.getFlake (toString ../../../..);
  
  # Function to extract services.config and layers from a machine
  extractMachineConfig = name: machine: 
    let
      cfg = machine.config;
    in {
      # Extracting layer-20 services config state
      services = cfg.layers.layer-20.services.config or {};
      
      # We can expand this later to capture other layers
      layer10 = cfg.layers.layer-10.system or {};
    };

  # Map over all machines defined in the flake
  machines = builtins.mapAttrs extractMachineConfig flake.nixosConfigurations;
in
  machines
```

- [ ] **Step 2: Test the Nix evaluation**
Run: `nix eval --json -f layers/00-cyberia/09-tools/nfpu/eval-registry.nix | jq .`
Expected: Outputs a structured JSON representing the boolean state of services per machine (e.g., `adguard.enable: true`).

- [ ] **Step 3: Commit Nix Introspection**
```bash
git add layers/00-cyberia/09-tools/nfpu/eval-registry.nix
git commit -m "feat(nfpu): add nix evaluation script for registry"
```

---

### Task 3: Build Go Data Models & Parser

**Files:**
- Create: `layers/00-cyberia/09-tools/nfpu/registry/parser.go`

- [ ] **Step 1: Write Data Structures**
```go
// layers/00-cyberia/09-tools/nfpu/registry/parser.go
package registry

import (
	"encoding/json"
	"fmt"
	"os/exec"
)

// Raw representation of the Nix output
type RawMachineConfig struct {
	Services map[string]interface{} `json:"services"`
}

type Registry map[string]RawMachineConfig

// ExecuteNixEval runs the nix eval command and returns the parsed Registry
func ExecuteNixEval(nixFilePath string) (Registry, error) {
	cmd := exec.Command("nix", "eval", "--json", "-f", nixFilePath)
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("nix eval failed: %v", err)
	}

	var reg Registry
	if err := json.Unmarshal(output, &reg); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %v", err)
	}

	return reg, nil
}
```

- [ ] **Step 2: Modify main.go to test parsing**
```go
// layers/00-cyberia/09-tools/nfpu/main.go
package main

import (
	"fmt"
	"log"
	"nfpu/registry"
)

func main() {
	reg, err := registry.ExecuteNixEval("eval-registry.nix")
	if err != nil {
		log.Fatalf("Error: %v", err)
	}
	fmt.Printf("Successfully loaded registry for %d machines.\n", len(reg))
}
```

- [ ] **Step 3: Test execution**
Run: `cd layers/00-cyberia/09-tools/nfpu && go run main.go`
Expected: Outputs "Successfully loaded registry for X machines."

- [ ] **Step 4: Commit Models**
```bash
git add layers/00-cyberia/09-tools/nfpu
git commit -m "feat(nfpu): implement go json parser for nix registry"
```

---

### Task 4: Build Initial Bubbletea UI

**Files:**
- Create: `layers/00-cyberia/09-tools/nfpu/tui/model.go`
- Modify: `layers/00-cyberia/09-tools/nfpu/main.go`

- [ ] **Step 1: Write Bubbletea Model**
```go
// layers/00-cyberia/09-tools/nfpu/tui/model.go
package tui

import (
	"fmt"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"nfpu/registry"
)

type errMsg error

type model struct {
	registry registry.Registry
	err      error
	loading  bool
}

// InitModel initializes the TUI state
func InitModel() model {
	return model{
		loading: true,
	}
}

// LoadRegistry is a tea.Cmd that loads the data in the background
func LoadRegistry() tea.Msg {
	reg, err := registry.ExecuteNixEval("eval-registry.nix")
	if err != nil {
		return errMsg(err)
	}
	return reg
}

func (m model) Init() tea.Cmd {
	return LoadRegistry
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		if msg.String() == "q" || msg.String() == "ctrl+c" {
			return m, tea.Quit
		}
	case registry.Registry:
		m.registry = msg
		m.loading = false
	case errMsg:
		m.err = msg
		m.loading = false
	}
	return m, nil
}

func (m model) View() string {
	if m.err != nil {
		return fmt.Sprintf("Error loading registry: %v\n", m.err)
	}
	if m.loading {
		return "Loading Nix configuration...\n"
	}

	var sb strings.Builder
	titleStyle := lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("205")).MarginBottom(1)
	sb.WriteString(titleStyle.Render("NFP Option Registry (Read-Only)"))
	sb.WriteString("\n\n")

	for machineName, config := range m.registry {
		sb.WriteString(fmt.Sprintf("🖥️  %s\n", lipgloss.NewStyle().Bold(true).Render(machineName)))
		// Very simple dump for now
		sb.WriteString(fmt.Sprintf("   Found %d services\n\n", len(config.Services)))
	}

	sb.WriteString("\nPress 'q' to quit.\n")
	return sb.String()
}
```

- [ ] **Step 2: Update main.go to run TUI**
```go
// layers/00-cyberia/09-tools/nfpu/main.go
package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"nfpu/tui"
)

func main() {
	p := tea.NewProgram(tui.InitModel())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
```

- [ ] **Step 3: Run the TUI**
Run: `cd layers/00-cyberia/09-tools/nfpu && go run .`
Expected: TUI launches, shows "Loading...", then displays the parsed machines before quitting cleanly with 'q'.

- [ ] **Step 4: Commit Basic TUI**
```bash
git add layers/00-cyberia/09-tools/nfpu
git commit -m "feat(nfpu): add basic bubbletea TUI for registry view"
```

---

### Task 5: Move Legacy Scripts

**Files:**
- Create: `layers/00-cyberia/09-tools/nfpu/legacy`
- Modify: Repositories existing scripts

- [ ] **Step 1: Move files**
Run: 
```bash
mkdir -p layers/00-cyberia/09-tools/nfpu/legacy
git mv tools/nfpu/nfpu.sh layers/00-cyberia/09-tools/nfpu/legacy/
git mv tools/nfpu/lib layers/00-cyberia/09-tools/nfpu/legacy/
```

- [ ] **Step 2: Commit Migration**
```bash
git commit -m "refactor: move legacy nfpu scripts to new tool directory"
```
