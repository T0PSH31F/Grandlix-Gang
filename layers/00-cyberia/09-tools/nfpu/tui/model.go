package tui

import (
	"fmt"
	"sort"
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
		spinnerStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("205"))
		return fmt.Sprintf("\n  %s Loading Nix configuration...\n", spinnerStyle.Render("⏳"))
	}

	var sb strings.Builder
	
	// Styles
	titleStyle := lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("205")).MarginLeft(2).MarginBottom(1).MarginTop(1)
	machineStyle := lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("39")).MarginLeft(2)
	enabledStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
	disabledStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("240"))
	optionStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("252"))

	sb.WriteString(titleStyle.Render("NFP Option Registry (Read-Only)"))
	sb.WriteString("\n\n")

	// To keep things deterministic, we should sort the machine names and services
	var machines []string
	for k := range m.registry {
		machines = append(machines, k)
	}
	sort.Strings(machines)

	for _, machineName := range machines {
		config := m.registry[machineName]
		sb.WriteString(fmt.Sprintf("%s\n", machineStyle.Render(fmt.Sprintf("🖥️  %s", machineName))))
		
		var services []string
		for k := range config.Services {
			services = append(services, k)
		}
		sort.Strings(services)

		if len(services) == 0 {
			sb.WriteString(disabledStyle.Render("     No services found.\n"))
		}

		for _, svc := range services {
			val := config.Services[svc]
			isEnabled, ok := val.(bool)
			
			// Format the name slightly nicer by stripping "services."
			displayName := strings.TrimPrefix(svc, "services.")

			if ok && isEnabled {
				sb.WriteString(fmt.Sprintf("     %s %s\n", enabledStyle.Render("[✓]"), optionStyle.Render(displayName)))
			} else {
				sb.WriteString(fmt.Sprintf("     %s %s\n", disabledStyle.Render("[ ]"), disabledStyle.Render(displayName)))
			}
		}
		sb.WriteString("\n")
	}

	helpStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("241")).MarginLeft(2)
	sb.WriteString(helpStyle.Render("Press 'q' to quit."))
	sb.WriteString("\n")
	
	return sb.String()
}
