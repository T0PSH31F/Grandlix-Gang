package tui

import (
	"fmt"
	"sort"
	"strings"

	"github.com/charmbracelet/bubbles/progress"
	tea "github.com/charmbracelet/bubbletea"
	"nfpu/registry"
)

type errMsg error

// RouterModel manages the different views of the TUI
type RouterModel struct {
	step             int
	welcome          WelcomeModel
	machineSelector  MachineSelectorModel
	registryView     RegistryModel
	progressView     ProgressModel
	
	// Data
	registryData     registry.Registry
	selectedMachine  string
	err              error
	loading          bool
}

// InitModel initializes the TUI state and the router
func InitModel() RouterModel {
	return RouterModel{
		step:         0,
		welcome:      NewWelcomeModel(),
		progressView: NewProgressModel("STEP 3: FORECAST & DEPLOYMENT"),
		// We'll init others once data is loaded
		loading:      true,
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

func (m RouterModel) Init() tea.Cmd {
	// Start loading the registry data immediately in the background
	// And initialize the welcome screen animation
	return tea.Batch(LoadRegistry, m.welcome.Init())
}

func (m RouterModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		// Global quit
		if msg.String() == "q" || msg.String() == "ctrl+c" {
			return m, tea.Quit
		}

		// Navigation handling based on step
		if m.step == 0 {
			if msg.String() == "enter" || msg.String() == "1" {
				m.step = 1
			}
		} else if m.step == 1 {
			// Pass keys to machine selector if initialized
			if !m.loading && m.err == nil {
				newSel, cmd, selected := m.machineSelector.Update(msg)
				m.machineSelector = newSel
				cmds = append(cmds, cmd)

				if selected != "" {
					if selected == "🚀 PROCEED TO DEPLOYMENT" {
						m.step = 3
						cmds = append(cmds, m.progressView.Init())
					} else {
						m.selectedMachine = selected
						m.loadRegistryForMachine(selected)
						m.step = 2
					}
				}
			}
		} else if m.step == 2 {
			if msg.String() == "3" {
				m.step = 3
				cmds = append(cmds, m.progressView.Init())
			} else if msg.String() == "esc" || msg.String() == "enter" {
				m.step = 1 // Go back
			}
			// Pass keys to registry
			newReg, cmd := m.registryView.Update(msg)
			m.registryView = newReg
			cmds = append(cmds, cmd)
		} else if m.step == 3 {
			if msg.String() == "enter" && m.progressView.done {
				m.step = 0 // loop back or do something else
			}
			newProg, cmd := m.progressView.Update(msg)
			m.progressView = newProg
			cmds = append(cmds, cmd)
		}

	case tickMsg, progress.FrameMsg:
		if m.step == 3 {
			newProg, cmd := m.progressView.Update(msg)
			m.progressView = newProg
			cmds = append(cmds, cmd)
		}

	case welcomeTickMsg:
		if m.step == 0 {
			newWel, cmd := m.welcome.Update(msg)
			m.welcome = newWel
			cmds = append(cmds, cmd)
		}

	case registry.Registry:
		m.registryData = msg
		m.loading = false
		
		var machines []string
		for k := range msg {
			machines = append(machines, k)
		}
		sort.Strings(machines)
		machines = append(machines, "🚀 PROCEED TO DEPLOYMENT")
		m.machineSelector = NewMachineSelectorModel(machines)

	case errMsg:
		m.err = msg
		m.loading = false
	}

	return m, tea.Batch(cmds...)
}

func (m *RouterModel) loadRegistryForMachine(machineName string) {
	config := m.registryData[machineName]
	
	var options []struct{Name string; Enabled bool; IsHeader bool; Description string}
	var optionKeys []string
	for k := range config.Options {
		optionKeys = append(optionKeys, k)
	}
	sort.Strings(optionKeys)

	currentLayer := ""

	for _, optKey := range optionKeys {
		val := config.Options[optKey]
		
		optMap, ok := val.(map[string]interface{})
		if !ok {
			continue
		}

		isEnabled, _ := optMap["value"].(bool)
		desc, _ := optMap["description"].(string)

		parts := strings.Split(optKey, ".")
		layer := ""
		if len(parts) > 0 {
			layer = parts[0]
		}
		
		if layer != "" && layer != currentLayer {
			currentLayer = layer
			options = append(options, struct{Name string; Enabled bool; IsHeader bool; Description string}{
				Name:        currentLayer,
				Enabled:     false,
				IsHeader:    true,
				Description: "",
			})
		}
		
		// Simplify name by taking the last part before '.enable', or the last 2 parts
		simpleName := optKey
		if len(parts) > 2 {
			// e.g. layer-10.system.mobile.android.enable -> "android"
			// Actually, let's take the second-to-last part if the last is "enable"
			if parts[len(parts)-1] == "enable" {
				simpleName = parts[len(parts)-2]
			} else {
				simpleName = parts[len(parts)-1]
			}
		}
		
		// Capitalize the simple name for better display
		if len(simpleName) > 0 {
			simpleName = strings.ToUpper(simpleName[:1]) + simpleName[1:]
		}

		options = append(options, struct{Name string; Enabled bool; IsHeader bool; Description string}{
			Name:        simpleName,
			Enabled:     isEnabled,
			IsHeader:    false,
			Description: desc,
		})
	}
	m.registryView = NewRegistryModel(options)
}

func (m RouterModel) View() string {
	var content string

	if m.step == 0 {
		content = m.welcome.View()
	} else if m.step == 1 {
		if m.err != nil {
			content = ErrorStyle.Render(fmt.Sprintf("Error loading registry: %v\n", m.err))
		} else if m.loading {
			content = HighlightStyle.Render("\n  ⏳ Loading Nix configuration...\n")
		} else {
			content = m.machineSelector.View()
		}
	} else if m.step == 2 {
		content = m.registryView.View()
	} else if m.step == 3 {
		content = m.progressView.View()
	}

	// Apply the global layout (Vaporwave double border, fixed width/height)
	return AppStyle.Render(content)
}
