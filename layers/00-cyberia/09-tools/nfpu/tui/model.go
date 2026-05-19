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
