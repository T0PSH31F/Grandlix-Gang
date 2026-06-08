package tui

import (
	"github.com/charmbracelet/lipgloss"
)

var (
	// Vaporwave Color Palette
	ColorCyan   = lipgloss.Color("#00FFFF")
	ColorPink   = lipgloss.Color("#FF00FF")
	ColorPurple = lipgloss.Color("#800080")
	ColorDark   = lipgloss.Color("#1A1A24")
	ColorGreen  = lipgloss.Color("#00FF00")
	ColorWhite  = lipgloss.Color("#FFFFFF")

	// Global Layout Styles
	AppStyle = lipgloss.NewStyle().
			Padding(1, 2).
			BorderStyle(lipgloss.DoubleBorder()).
			BorderForeground(ColorPink).
			Width(80).
			Height(24)

	TitleStyle = lipgloss.NewStyle().
			Foreground(ColorCyan).
			Bold(true).
			MarginBottom(1)

	BannerStyle = lipgloss.NewStyle().
			Foreground(ColorPink).
			Bold(true)

	AsciiStyle = lipgloss.NewStyle().
			Foreground(ColorPurple)

	InfoStyle = lipgloss.NewStyle().
			Foreground(ColorWhite)

	HighlightStyle = lipgloss.NewStyle().
			Foreground(ColorCyan).
			Bold(true)

	SuccessStyle = lipgloss.NewStyle().
			Foreground(ColorGreen)

	ErrorStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FF0000"))

	// List Styles
	ItemStyle = lipgloss.NewStyle().PaddingLeft(2).Foreground(ColorWhite)
	SelectedItemStyle = lipgloss.NewStyle().PaddingLeft(2).Foreground(ColorPink).Bold(true)
	
	// Checkbox Styles
	CheckedStyle = lipgloss.NewStyle().Foreground(ColorCyan).SetString("[x]")
	UncheckedStyle = lipgloss.NewStyle().Foreground(ColorWhite).SetString("[ ]")

	// Helper for footer instructions
	HelpStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#626262")).MarginTop(1)
)
