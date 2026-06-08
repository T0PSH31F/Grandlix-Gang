package tui

import (
	"fmt"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
)

type MachineSelectorModel struct {
	Machines []string
	Cursor   int
}

func NewMachineSelectorModel(machines []string) MachineSelectorModel {
	return MachineSelectorModel{
		Machines: machines,
		Cursor:   0,
	}
}

func (m MachineSelectorModel) Init() tea.Cmd {
	return nil
}

func (m MachineSelectorModel) Update(msg tea.Msg) (MachineSelectorModel, tea.Cmd, string) {
	selectedMachine := ""
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "up", "k":
			if m.Cursor > 0 {
				m.Cursor--
			}
		case "down", "j":
			if m.Cursor < len(m.Machines)-1 {
				m.Cursor++
			}
		case "enter", " ":
			if len(m.Machines) > 0 {
				selectedMachine = m.Machines[m.Cursor]
			}
		}
	}
	return m, nil, selectedMachine
}

func (m MachineSelectorModel) View() string {
	b := strings.Builder{}
	b.WriteString(TitleStyle.Render("STEP 1: SELECT MACHINE") + "\n\n")

	if len(m.Machines) == 0 {
		b.WriteString(InfoStyle.Render("No machines found. Did the eval fail?"))
	}

	for i, machine := range m.Machines {
		cursor := "  "
		if i == m.Cursor {
			cursor = HighlightStyle.Render("> ")
		}

		// A little visual flair
		icon := "🖥️ "
		
		line := fmt.Sprintf("%s%s %s", cursor, icon, machine)
		
		if i == m.Cursor {
			b.WriteString(SelectedItemStyle.Render(line) + "\n")
		} else {
			b.WriteString(ItemStyle.Render(line) + "\n")
		}
	}

	b.WriteString("\n" + HelpStyle.Render("↑/k: up • ↓/j: down • enter: select machine"))
	return b.String()
}
