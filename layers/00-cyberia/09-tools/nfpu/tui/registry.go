package tui

import (
	"fmt"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type RegistryModel struct {
	Options []struct {
		Name        string
		Enabled     bool
		IsHeader    bool
		Description string
	}
	Cursor int
}

func NewRegistryModel(options []struct{Name string; Enabled bool; IsHeader bool; Description string}) RegistryModel {
	return RegistryModel{
		Options: options,
		Cursor:  0,
	}
}

func (m RegistryModel) Init() tea.Cmd {
	return nil
}

func (m RegistryModel) Update(msg tea.Msg) (RegistryModel, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "up", "k":
			if m.Cursor > 0 {
				m.Cursor--
				// Skip headers going up
				for m.Cursor > 0 && m.Options[m.Cursor].IsHeader {
					m.Cursor--
				}
			}
		case "down", "j":
			if m.Cursor < len(m.Options)-1 {
				m.Cursor++
				// Skip headers going down
				for m.Cursor < len(m.Options)-1 && m.Options[m.Cursor].IsHeader {
					m.Cursor++
				}
			}
		case " ":
			// Toggle (headers can't be toggled)
			if !m.Options[m.Cursor].IsHeader {
				m.Options[m.Cursor].Enabled = !m.Options[m.Cursor].Enabled
			}
		}
	}
	return m, nil
}

func (m RegistryModel) View() string {
	b := strings.Builder{}
	b.WriteString(TitleStyle.Render("STEP 2: CONFIGURATION REGISTRY") + "\n\n")

	if len(m.Options) == 0 {
		b.WriteString(InfoStyle.Render("No options found. Did the eval fail?"))
	}

	// We only show a limited number to fit the 24 lines height
	start := 0
	end := len(m.Options)
	if m.Cursor > 10 {
		start = m.Cursor - 10
	}
	if end > start+15 {
		end = start + 15
	}

	for i := start; i < end; i++ {
		opt := m.Options[i]
		
		if opt.IsHeader {
			// Map layer names to nice headers
			headerTitle := strings.ToUpper(opt.Name)
			switch opt.Name {
			case "layer-10": headerTitle = "LAYER-10: SYSTEM"
			case "layer-20": headerTitle = "LAYER-20: SERVICES"
			case "layer-30": headerTitle = "LAYER-30: THEMING"
			case "layer-40": headerTitle = "LAYER-40: DESKTOP"
			case "layer-50": headerTitle = "LAYER-50: CLI/TUI"
			case "layer-60": headerTitle = "LAYER-60: GUI"
			case "layer-70": headerTitle = "LAYER-70: AGENTS"
			}
			
			// Center the text in a line
			totalWidth := 80
			padLen := (totalWidth - len(headerTitle) - 2) / 2
			if padLen < 0 {
				padLen = 0
			}
			padding := strings.Repeat("─", padLen)
			headerText := fmt.Sprintf("\n%s %s %s", padding, headerTitle, padding)
			
			b.WriteString(lipgloss.NewStyle().Foreground(ColorPink).Bold(true).Render(headerText) + "\n")
			continue
		}

		cursor := "  "
		if i == m.Cursor {
			cursor = HighlightStyle.Render("> ")
		}

		checkbox := UncheckedStyle.String()
		if opt.Enabled {
			checkbox = CheckedStyle.String()
		}

		descStr := ""
		if opt.Description != "" {
			// truncate description if it's too long
			desc := opt.Description
			if len(desc) > 60 {
				desc = desc[:57] + "..."
			}
			descStr = " - " + lipgloss.NewStyle().Foreground(ColorCyan).Render(desc)
		}

		line := fmt.Sprintf("%s%s %s%s", cursor, checkbox, opt.Name, descStr)
		if i == m.Cursor {
			b.WriteString(SelectedItemStyle.Render(line) + "\n")
		} else {
			b.WriteString(ItemStyle.Render(line) + "\n")
		}
	}

	b.WriteString("\n" + HelpStyle.Render("↑/k: up • ↓/j: down • space: toggle • enter/esc: back to machines"))
	return b.String()
}
