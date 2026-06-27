# NixVim + Yazelix Integration

> **Yazelix** is the terminal workflow integrating **Ya**zi, **Zel**lij, and Ni**x**vim.
> Helix is retained as a fallback (`defaultEditor = false`).

## Quick Start

```bash
# Launch zellij with compact layout → nvim
yazelix

# Or launch specific zellij layout profiles:
z-dev    # nvim + lazygit split + yazi tab
z-git    # lazygit only
z-server # htop + journalctl
```

## NixVim Editor (Primary)

### Core Navigation

| Key | Action |
|-----|--------|
| `h/j/k/l` | Move cursor |
| `Ctrl+h/j/k/l` | Navigate windows |
| `H` / `L` | Line start / end |
| `s` | Flash jump to any visible character |
| `S` | Flash jump to treesitter node |

### File Management

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle Neo-tree sidebar |
| `<leader>y` | Toggle Yazi file manager in-editor |
| `<leader>ff` | Telescope find files |
| `<leader>fg` | Telescope live grep |
| `<leader>fb` | Telescope buffers |
| `<leader>fr` | Telescope recent files |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit |
| `]t` / `[t` | Next/previous TODO comment |

### Diagnostics

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle Trouble diagnostics |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `[d` / `]d` | Previous/next diagnostic |

### Multi-Cursor

| Key | Action |
|-----|--------|
| `<leader>m` | Start multi-cursor mode |
| `Ctrl+Shift+Up/Down` | Add cursor above/below |
| `Ctrl+Shift+Left/Right` | Skip/subtract cursor |
| `j/k` (in MC mode) | Add cursor below/above |

### AI Assistants

| Key | Action |
|-----|--------|
| `<leader>o` | OpenCode (Claude Code) |
| `:Ollama <prompt>` | Local LLM via Ollama |

### Editing

| Key | Action |
|-----|--------|
| `<leader>F` | Format buffer |
| `gc` | Toggle comment |
| `ys` / `cs` / `ds` | Surround add/change/delete |
| `J` / `K` (visual) | Move line down/up |
| `<C-e>` | Hide completion menu |
| `<C-Space>` | Force show completion |

### Effects

| Key | Action |
|-----|--------|
| `Ctrl+d/u` | Smooth scroll half-page |
| `gg` / `G` | Smooth scroll to top/bottom |
| `j/k` | Smooth scroll line-by-line |
| `Ctrl+y/e` | Smooth scroll without moving cursor |

Cursor has a trailing smear effect when moving quickly.

## Zellij Layouts

| Command | Layout | Panes |
|---------|--------|-------|
| `z-dev` | dev | nvim (left, 60%) + lazygit (right, 40%), yazi tab |
| `z-git` | git | lazygit fullscreen |
| `z-server` | server | htop (top) + journalctl -f (bottom) |
| `yazelix` | compact | nvim fullscreen |

### Zellij Keybindings

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Navigate panes |
| `Ctrl+q` | Quit session |
| `Ctrl+s` | Toggle pane resize mode |
| `Ctrl+d/u` | Scroll half-page up/down |
| `Ctrl+t` | Open new tab |
| `Ctrl+w` | Close current pane/tab |
| `Shift+Left/Right` | Switch tabs |

## Yazi File Manager

Yazi can be opened both in-editor (`<leader>y`) and standalone.
Files opened from Yazi open in Neovim.

## Theme

Noctalia Material You theme (wallpaper-generated colors) with tokyo-night
fallback. Applied system-wide: Hyprland, GTK, Neovim, Zellij, Yazi.

## Configuration

- **NixVim**: `layers/50-cli-tui-programs/52-editors/nixvim/default.nix`
- **Zellij**: `layers/50-cli-tui-programs/54-multiplexers/zellij.nix`
- **Yazi**: `layers/50-cli-tui-programs/56-file-managers/yazi.nix`
- **Yazelix**: `layers/50-cli-tui-programs/59-integrations/yazelix-style.nix`
