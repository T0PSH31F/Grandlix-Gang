package tui

import (
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/progress"
	tea "github.com/charmbracelet/bubbletea"
)

type tickMsg time.Time

func tickCmd() tea.Cmd {
	return tea.Tick(time.Millisecond*100, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

// ProgressModel implements the harmonica-based progress bar and banter ticker
type ProgressModel struct {
	progress progress.Model
	percent  float64
	done     bool
	banter   []string
	banterIdx int
	Title    string
}

func NewProgressModel(title string) ProgressModel {
	prog := progress.New(
		progress.WithDefaultGradient(),
		progress.WithWidth(60),
		progress.WithoutPercentage(),
	)

	return ProgressModel{
		progress: prog,
		Title:    title,
		banter: []string{
			"Reticulating splines...",
			"Evaluating Nix expressions...",
			"Bribing the Nix daemon...",
			"Compiling derivation graphs...",
			"Waiting for IFD (just kidding)...",
			"Staring at terminal aggressively...",
			"Injecting vaporwave aesthetics...",
			"Generating deterministic hashes...",
			"Syncing with Fleet Command...",
			"Almost there... maybe...",
		},
	}
}

func (m ProgressModel) Init() tea.Cmd {
	return tickCmd()
}

func (m ProgressModel) Update(msg tea.Msg) (ProgressModel, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tickMsg:
		if m.progress.Percent() == 1.0 {
			m.done = true
			return m, nil
		}

		// Simulate progress increment
		m.percent += 0.05
		if m.percent > 1.0 {
			m.percent = 1.0
		}

		// Cycle banter occasionally
		if int(m.percent*100)%20 == 0 {
			m.banterIdx = (m.banterIdx + 1) % len(m.banter)
		}

		cmd := m.progress.SetPercent(m.percent)
		return m, tea.Batch(tickCmd(), cmd)

	case progress.FrameMsg:
		progressModel, cmd := m.progress.Update(msg)
		m.progress = progressModel.(progress.Model)
		return m, cmd
	}

	return m, tea.Batch(cmds...)
}

func (m ProgressModel) View() string {
	b := strings.Builder{}

	b.WriteString(TitleStyle.Render(m.Title) + "\n\n")

	if m.done {
		b.WriteString(SuccessStyle.Render("✓ Done!") + "\n\n")
		b.WriteString(HelpStyle.Render("Press [Enter] to continue..."))
	} else {
		b.WriteString(InfoStyle.Render("  "+m.banter[m.banterIdx]) + "\n\n")
		b.WriteString("  " + m.progress.View() + "\n")
	}

	return b.String()
}

func (m *ProgressModel) Reset() {
	m.percent = 0.0
	m.done = false
	m.banterIdx = 0
}
