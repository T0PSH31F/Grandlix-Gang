{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.layers.layer-50.cli;

  # ── Layout Profiles ──────────────────────────────────────────────
  # KDL layout files installed to ~/.config/zellij/layouts/
  # Launch with: zellij --layout <name>

  layouts = {
    # Default development layout: nvim + lazygit split, yazi tab
    dev = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
        tab name="dev" {
            pane split_direction="vertical" {
              pane size="70%" {
                command "nvim"
              }
              pane size="30%" {
                command "lazygit"
              }
            }
          }
          tab name="shell" {
            pane {
              command "zsh"
            }
          }
          tab name="files" {
            pane {
              command "yazi"
            }
          }
      }
    '';
    # Git-focused layout: lazygit main pane + shell
    git = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
          tab name="git" {
            pane {
              command "lazygit"
            }
          }
          tab name="shell" {
            pane {
              command "zsh"
            }
          }
      }
    '';
    # Server/monitoring layout: htop + logs + shell
    server = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
          tab name="monitor" {
            pane split_direction="vertical" {
              pane size="50%" {
                command "htop"
              }
              pane size="50%" {
                command "journalctl" {
                  args "-f"
                }
              }
            }
          }
          tab name="shell" {
            pane {
              command "zsh"
            }
          }
      }
    '';

    # Single-pane compact (same as built-in compact, for fallback)
    compact = ''
      layout {
        pane {
          command "zsh"
        }
      }
    '';
  };

  # ── Keybind Cheatsheets ─────────────────────────────────────────────
  # Portable scripts that pipe keybind reference into rofi dmenu.
  # A unified `cheatsheet` command shows a picker; individual ones exist too.

  cheatsheet_picker = pkgs.writeShellScriptBin "cheatsheet" ''
    while true; do
      SELECTED=$(cat <<CHOICES | ${pkgs.rofi}/bin/rofi -dmenu -p "Cheatsheets" \
        -theme-str 'window {width: 35%; height: 65%;}' \
        -theme-str 'listview {columns: 1;}' \
        -theme-str 'element-text {font: "monospace 12";}'
    ⚡ Zellij
    📝 Neovim
    ✦ Helix
    📂 Yazi
    🐚 Zsh / Ghostty
    🔍 Fzf / TV / Ripgrep
    🔧 Grep / Sed / Awk
    🐳 Docker / Podman
    💻 VMs / MicroVMs
    🚀 CLI Power Tools
    🖥️ Hyprland
    🤖 OpenCode
    🧠 Hermes Agent
    CHOICES
      )
      [ -z "$SELECTED" ] && break
      case "$SELECTED" in
        "⚡ Zellij")            zellij-cheatsheet ;;
        "📝 Neovim")            nvim-cheatsheet ;;
        "✦ Helix")             helix-cheatsheet ;;
        "📂 Yazi")             yazi-cheatsheet ;;
        "🐚 Zsh / Ghostty")    zsh-cheatsheet ;;
        "🔍 Fzf / TV / Ripgrep") fzf-cheatsheet ;;
        "🔧 Grep / Sed / Awk") grep-sed-awk-cheatsheet ;;
        "🐳 Docker / Podman")  docker-cheatsheet ;;
        "💻 VMs / MicroVMs")   vm-cheatsheet ;;
        "🚀 CLI Power Tools")  cli-power-cheatsheet ;;
        "🖥️ Hyprland")         hypr-keybind-cheatsheet ;;
        "🤖 OpenCode")          opencode-cheatsheet ;;
        "🧠 Hermes Agent")      hermes-cheatsheet ;;
      esac
    done
  '';

  zellij_cheatsheet = pkgs.writeShellScriptBin "zellij-cheatsheet" ''
    CHEATSHEET="
⚡ ZELLIJ KEYBINDS
─────────────────────────────────────────
Ctrl + P                    Mode Switcher (Lock/Unlock)
Ctrl + P + S                Enter Scroll Mode
Ctrl + P + D                Close Focused Pane
Ctrl + P + N                New Pane
Ctrl + P + Tab              Next Pane
Ctrl + P + T                New Tab
Ctrl + P + W                Tab Switcher
Ctrl + P + X                Close Tab
Ctrl + P + R                Rename Pane
Ctrl + P + H/J/K/L          Nav Panes (Vim keys)
Ctrl + U / Ctrl + D         Scroll Half Page Up/Down
Ctrl + P + \                Pane Horizontal Split
Ctrl + P + -                Pane Vertical Split
Ctrl + P + F                Toggle Fullscreen
Mouse Drag                  Select Text
Y / Enter / Ctrl-C (sel)    Copy Selected Text
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Zellij Keybinds" \
      -theme-str 'window {width: 50%; height: 70%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 9";}'
  '';

  nvim_cheatsheet = pkgs.writeShellScriptBin "nvim-cheatsheet" ''
    CHEATSHEET="
📝 NEOVIM KEYBINDS
─────────────────────────────────────────
LEADER (Space)

🔍 NAVIGATION
─────────────────────────────────────────
Space + f                  Find Files (Telescope)
Space + /                  Live Grep
Space + b                  Buffer List
Space + h                  Help Tags
Ctrl + h/j/k/l             Navigate Splits
[ + b / ] + b              Prev/Next Buffer

🛠️ EDITING
─────────────────────────────────────────
g + d                      Go to Definition
g + r                      Find References
Space + w                  Save File
Space + q                  Quit
Space + e                  File Explorer (nvim-tree)
Space + g                  Git Status (lazygit)

🎨 SELECTION & VISUAL
─────────────────────────────────────────
v                          Visual Mode
V                          Line Visual
Ctrl + v                   Block Visual
y                          Yank
d                          Delete
p / P                      Paste after/before

💡 WHICH-KEY
─────────────────────────────────────────
Space (hold)               Show keybind menu
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Neovim Keybinds" \
      -theme-str 'window {width: 50%; height: 80%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 9";}'
  '';

  yazi_cheatsheet = pkgs.writeShellScriptBin "yazi-cheatsheet" ''
    CHEATSHEET="
📂 YAZI KEYBINDS
─────────────────────────────────────────

🔍 NAVIGATION
─────────────────────────────────────────
h / l                     Go to Parent / Enter Dir
j / k                     Move Down / Up
g + g / G                 Go to Top / Bottom
/                         Search Files
n / N                     Next / Prev Match

🛠️ FILE OPERATIONS
─────────────────────────────────────────
y                         Yank (Copy)
p                         Paste
d                         Cut
a                         Rename
Space                     Select / Toggle
X                         Delete

📋 MISC
─────────────────────────────────────────
~                         Go to Home
t                         Go to Trash
.                         Toggle Hidden
z                         Filter by Type
o                         Open with
:                         Shell Command
?                         Help
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Yazi Keybinds" \
      -theme-str 'window {width: 45%; height: 70%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 9";}'
  '';

  helix_cheatsheet = pkgs.writeShellScriptBin "helix-cheatsheet" ''
    CHEATSHEET="
✦ HELIX KEYBINDS
─────────────────────────────────────────

⚡ MODES
─────────────────────────────────────────
Esc / Ctrl + C           Normal Mode
i / a                    Insert / Append
v / V / Ctrl + v         Select / Line / Block
:                        Command Mode
Space                    Space Mode

🚀 NORMAL MODE
─────────────────────────────────────────
h / j / k / l            Move Cursor
w / b                    Next / Prev Word
x                        Select (extend)
y                        Yank
p / P                    Paste After / Before
d                        Delete
c                        Change
u / Ctrl + r             Undo / Redo
/                        Search
n / N                    Next / Prev Match

🌌 SPACE MODE
─────────────────────────────────────────
Space + f                File Picker
Space + /                Global Search
Space + g                Git
Space + w                Save
Space + q                Close
Space + k                Show Keybinds (helix default)
Space + ?                LSP Diagnostics
Space + R                Rename Symbol

🔧 SELECTION MODE (v)
─────────────────────────────────────────
h/j/k/l                 Extend selection
i + w                   Inside word
a + w                   Around word
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Helix Keybinds" \
      -theme-str 'window {width: 50%; height: 80%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 9";}'
  '';

  zsh_cheatsheet = pkgs.writeShellScriptBin "zsh-cheatsheet" ''
    CHEATSHEET="
🐚 ZSH KEYBINDS & GLOBALS
─────────────────────────────────────────

⌨️ LINE EDITING
─────────────────────────────────────────
Ctrl + a/e              Beginning/End of line
Ctrl + u/k              Cut to start/end of line
Ctrl + w                Cut previous word
Alt + d                 Cut next word
Ctrl + y                Paste cut text
Ctrl + l                Clear screen
Alt + b/f               Back/forward one word
Ctrl + x + e            Edit line in $EDITOR

📜 HISTORY
─────────────────────────────────────────
Ctrl + r                Reverse history search
Ctrl + s                Forward history search (if enabled)
!!                      Repeat last command
!$                      Last arg of last command
!:0                     Last command name
!?string                Repeat last cmd containing string
history | grep pat      Search history
fc -l                   List recent history

🔧 EXPANSIONS & GLOBALS
─────────────────────────────────────────
echo ~-                 Previous directory
echo ~+                 Current directory
{1..10}                 Brace expansion
**/*.js                 Recursive glob (zsh)
*.{jpg,png}             Multiple extensions
<1-100>                 Numeric range glob
!pattern                Negate glob
ls *(.)                 Files only
ls *(/)                 Directories only
ls *(@)                 Symlinks only
ls *(m0)                Modified today
ls *(Lk+1m)             Larger than 1MB

🛠️ JOB CONTROL
─────────────────────────────────────────
Ctrl + z                Suspend foreground process
fg                      Resume suspended job
bg                      Run suspended job in bg
jobs                    List jobs
disown                  Remove job from shell
nohup cmd &             Run immune to hup

💡 ZSH MODIFIERS
─────────────────────────────────────────
\${var:r}               Remove extension
\${var:e}               Extension only
\${var:h}               Head (dirname)
\${var:t}               Tail (basename)
\${var:s/old/new}       Substitute
\${var:u}               Uppercase
\${var:l}               Lowercase

🪟 GHOSTTY TERMINAL
─────────────────────────────────────────
Ctrl + Shift + c        Copy
Ctrl + Shift + v        Paste
Ctrl + Shift + =/-      Zoom in/out
Ctrl + Shift + 0        Reset zoom
Ctrl + Shift + t        New tab
Ctrl + Shift + w        Close tab
Ctrl + Tab / Shift      Next/prev tab
Ctrl + Shift + l        Toggle ligatures
Ctrl + Shift + f        Fullscreen
Ctrl + Shift + up/dn    Scroll page up/down
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Zsh & Ghostty" \
      -theme-str 'window {width: 55%; height: 80%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 8";}'
  '';

  fzf_cheatsheet = pkgs.writeShellScriptBin "fzf-cheatsheet" ''
    CHEATSHEET="
🔍 FZF & TELEVISION
─────────────────────────────────────────

🔎 FZF (FUZZY FINDER)
─────────────────────────────────────────
Ctrl + t                Insert selected path
Ctrl + r                Reverse search history
Alt + c                 cd into selected dir
Enter                   Select / Open
Tab / Shift + Tab       Multi-select
Ctrl + /                Toggle preview pane
Ctrl + f/b              Page down/up
Ctrl + u/d              Half page down/up
Alt + j/k               Scroll preview down/up
fzf --preview 'cmd {}'  Preview file content
fzf --multi             Enable multi-select
fzf -q 'query'          Start with query
fzf --filter 'pat'      Non-interactive filter
fzf --height 40%        Dropdown (not fullscreen)

📺 TELEVISION (tv)
─────────────────────────────────────────
tv                      Open in current dir
tv /path                Open in specific dir
Enter                   Open selection
Tab                     Multi-select
Ctrl + /                Toggle preview
Ctrl + f/b              Page down/up
Ctrl + u/d              Half page down/up
Ctrl + r                Reverse sort
Ctrl + s                Save selection
Esc / Ctrl + c          Exit

🐾 RIPGREP (rg) — faster grep
─────────────────────────────────────────
rg pattern              Recursive search
rg -i pattern           Case-insensitive
rg -l pattern           List files only
rg -g '*.js' pattern    Filter by filetype
rg -C3 pattern          Context lines
rg -o pattern           Only matching text
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Fzf / TV / Ripgrep" \
      -theme-str 'window {width: 50%; height: 80%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 8";}'
  '';

  grep_sed_awk_cheatsheet = pkgs.writeShellScriptBin "grep-sed-awk-cheatsheet" ''
    CHEATSHEET="
🔧 GREP / SED / AWK
─────────────────────────────────────────

🔎 GREP
─────────────────────────────────────────
grep pattern file       Basic search
grep -ri pattern dir    Recursive + case-insensitive
grep -l pattern *       List filenames only
grep -c pattern file    Count matches
grep -v pattern file    Invert match (exclude)
grep -w pattern file    Whole word match
grep -C3 pattern file   3 lines context
grep -E 'a|b' file     Extended regex (OR)
grep -o pattern file    Only matching text
rg pattern              ripgrep (faster, respects .gitignore)

📝 SED
─────────────────────────────────────────
sed 's/old/new/' f      Replace first per line
sed 's/old/new/g' f     Replace all (global)
sed -i 's/old/new/g' f  In-place edit
sed 's/old/new/gI' f    Case-insensitive replace
sed '/pat/d' f          Delete matching lines
sed '5,10d' f           Delete line range
sed -n '10,20p' f       Print lines 10-20
sed 's/^/pre/' f        Prefix each line
sed 's/$/suf/' f        Suffix each line
sed 's/ *$//' f         Trim trailing whitespace
sed 's/  */ /g' f       Collapse spaces
sed -n '/pat/,/end/p' f Print between two patterns

📊 AWK
─────────────────────────────────────────
awk '{print \$1}' f       Print first column
awk '{print \$NF}' f      Print last column
awk '\$3 > 10' f           Filter column > 10
awk '{sum+=\$1} END{print sum}' f  Sum column
awk 'NR>1' f              Skip header row
awk -F, '{print \$1}' f    CSV: print first field
awk '!seen[\$0]++' f       Deduplicate lines
awk 'length>80' f         Lines longer than 80
awk '{print \$1, \$2}' f    Print multiple columns
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Grep / Sed / Awk" \
      -theme-str 'window {width: 50%; height: 85%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 8";}'
  '';

  cli_power_cheatsheet = pkgs.writeShellScriptBin "cli-power-cheatsheet" ''
    CHEATSHEET="
🚀 CLI POWER TOOLS
─────────────────────────────────────────

📦 JSON (jq)
─────────────────────────────────────────
jq '.key' file.json         Extract key
jq '.[] | .name' json       Extract from array
jq -r '.key' json           Raw output (no quotes)
jq '. | select(.x > 5)'     Filter objects
jq 'group_by(.k) | length'  Count per group
jq -s 'add' *.json          Merge arrays

🌐 HTTP (curl)
─────────────────────────────────────────
curl -s URL                 Silent GET
curl -o file URL            Download to file
curl -L URL                 Follow redirects
curl -H 'K: v' URL          Custom header
curl -d 'data' URL          POST request
curl -X PUT URL             Custom method
curl 'http://a' -H '...'    Full control

🔁 STREAM PROCESSING
─────────────────────────────────────────
xargs -I{} cmd {}           Substitute stdin
xargs -n1                   One arg at a time
xargs -P4                   Parallel (4 procs)
parallel cmd ::: a b c      GNU Parallel

📂 FILES & ARCHIVES
─────────────────────────────────────────
tar -xzf file.tar.gz        Extract .tar.gz
tar -czf out.tgz dir/       Create .tar.gz
tar -xf file.tar            Extract .tar
unzip file.zip              Extract .zip
zip -r out.zip dir/         Create .zip
rsync -av src/ dst/         Sync directories
rsync -avz src/ host:dst    Remote sync

💾 DISK & MEMORY
─────────────────────────────────────────
du -sh dir/                 Directory total size
du -h --max-depth=1 .       Per-subdir breakdown
df -h                       Disk free space
free -h                     Memory usage
lsblk                       Block devices
mount | column -t           Mounted filesystems

⚡ PROCESSES
─────────────────────────────────────────
ps auxf                    Full process tree
pstree                     Tree view
top / htop                 Interactive monitor
kill -9 PID                Force kill
kill -15 PID               Graceful kill
pgrep pattern              Find PID by name
pkill pattern              Kill by name
lsof -i :PORT              What's listening on port

🔧 SYSTEM
─────────────────────────────────────────
ss -tulpn                  Listening ports
systemctl status svc       Service status
journalctl -fu svc         Follow service logs
dmesg -w                   Kernel log follow
uptime                     System uptime
hostnamectl                System info

📋 COMPARE & DIFF
─────────────────────────────────────────
diff -u file1 file2        Unified diff
diff -r dir1 dir2          Recursive diff
colordiff file1 file2      Colorized diff
git diff --no-index a b    Git-based diff
cmp -l file1 file2         Byte-by-byte comparison
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "CLI Power Tools" \
      -theme-str 'window {width: 50%; height: 85%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 8";}'
  '';

  docker_cheatsheet = pkgs.writeShellScriptBin "docker-cheatsheet" ''
    CHEATSHEET="
🐳 DOCKER / PODMAN
─────────────────────────────────────────

🛠️ CONTAINER LIFECYCLE
─────────────────────────────────────────
docker run -it image cmd     Run interactive
docker run -d --name n image  Run detached
docker run --rm image         Auto-remove on exit
docker run -p 8080:80 image   Port forward
docker run -v /host:/ctr img  Mount volume
docker start/stop/restart id  Lifecycle
docker rm / kill cont         Remove / kill
docker ps / ps -a             List running / all
docker logs -f cont           Follow logs
docker exec -it cont bash     Shell into container

📦 IMAGES
─────────────────────────────────────────
docker pull image:tag         Pull image
docker build -t name .        Build from Dockerfile
docker images                 List images
docker rmi image              Remove image
docker prune                  Clean unused
docker tag src tgt            Tag image
docker push repo/img:tag      Push to registry

🔧 DOCKERFILE
─────────────────────────────────────────
FROM node:20-alpine           Base image
COPY . /app                   Copy files
RUN npm install               Build step
CMD [\"node\", \"app.js\"]      Default command
ENTRYPOINT [\"npm\"]            Fixed entrypoint
EXPOSE 8080                   Document port
WORKDIR /app                  Working directory
ENV NODE_ENV=prod             Environment vars
HEALTHCHECK CMD curl ...      Health check

🔄 DOCKER COMPOSE
─────────────────────────────────────────
docker compose up -d          Start all services
docker compose down           Stop all
docker compose logs -f        Follow all logs
docker compose ps             List services
docker compose exec svc bash  Shell into service
docker compose build          Rebuild services
docker compose pull           Pull all images

🔁 PODMAN (drop-in for Docker)
─────────────────────────────────────────
podman run/pull/build ...     Same commands as docker
podman machine init           Init VM (macOS/Windows)
podman machine start          Start podman VM
podman compose up -d          Compose works too
alias docker=podman           Use podman everywhere

🪶 DISTROBOX (podman-based)
─────────────────────────────────────────
distrobox create --name ubuntu --image ubuntu:24.04
distrobox enter ubuntu        Enter container
distrobox list                List containers
distrobox stop / rm ubuntu    Stop / remove
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "Docker / Podman" \
      -theme-str 'window {width: 55%; height: 85%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 8";}'
  '';

  vm_cheatsheet = pkgs.writeShellScriptBin "vm-cheatsheet" ''
    CHEATSHEET="
💻 VMs / MicroVMs / CONTAINERS
─────────────────────────────────────────

🏗️ NIXOS CONTAINERS (native systemd)
─────────────────────────────────────────
containers.NAME = {
  autoStart = true;
  config = { ... };       # NixOS config
  privateNetwork = true;  # Separate net ns
  hostAddress = \"10.0.1.1\";  # Host-facing IP
  localAddress = \"10.0.1.2\"; # Container IP
};

Manage:
→ nixos-rebuild switch     Apply container config
→ machinectl list          List all containers
→ machinectl shell NAME    Enter container shell
→ machinectl poweroff NAME  Stop container
→ journalctl -u container-NAME  Logs

⚡ MICROVMS (spectrum/microvm.nix)
─────────────────────────────────────────
{ ... }: {
  imports = [ microvm.nix ];
  microvm = {
    enable = true;
    hypervisor = \"cloud-hypervisor\"; # or qemu
    vcpu = 2;
    mem = 2048;
    interfaces = [{
      type = \"tap\";
      id = \"vm0\";
      mac = \"02:00:00:01:01:01\";
    }];
    shares = [{
      source = \"/persist/data\";
      mountPoint = \"/data\";
    }];
  };
}

Manage:
→ microvm-run               Boot the microvm
→ microvm-ssh               SSH in
→ systemctl restart mvm-NAME NixOS restart

🖥️ QEMU/KVM VMs (libvirt)
─────────────────────────────────────────
virsh list --all            List VMs
virsh start NAME            Start VM
virsh shutdown NAME         Graceful stop
virsh destroy NAME          Force stop
virsh edit NAME             Edit XML config
virsh console NAME          Serial console
virt-manager                GUI manager
virt-viewer NAME            SPICE/VNC viewer

📦 NIXOS CONTAINER CHEATSHEET
─────────────────────────────────────────
nix-shell -p busybox        Ephemeral env
nix shell nixpkgs#pkg       Ad-hoc shell
nix run nixpkgs#tool        Run without install
nix bundle pkg              Single binary bundle
bunx / npx tool             Run JS tool (ephemeral)
distrobox create --name x --image fedora:39
docker run --rm -it archlinux  Ephemeral Arch
    "
    echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
      -p "VMs / MicroVMs / Containers" \
      -theme-str 'window {width: 55%; height: 85%;}' \
      -theme-str 'listview {columns: 1;}' \
      -theme-str 'element-text {font: "monospace 8";}'
  '';

  opencode_cheatsheet = pkgs.writeShellScriptBin "opencode-cheatsheet" ''
    ${pkgs.coreutils}/bin/cat <<'CHEATSHEET_EOF' | ${pkgs.rofi}/bin/rofi -dmenu -p "OpenCode" -theme-str 'window {width: 45%;}' -theme-str 'element-text {font: "monospace 11";}'
🤖 OPENCODE — AI Coding Agent
─────────────────────────────────────────
BASIC USAGE
  opencode run 'prompt'           One-shot task (no pty needed)
  opencode                        Launch interactive TUI
  opencode -c                     Continue last session
  opencode -s <id>               Resume specific session
  opencode pr 42                 Review PR #42

ONE-SHOT EXAMPLES
  opencode run 'Add retry logic to API calls'
  opencode run 'Fix failing tests' --thinking
  opencode run 'Refactor auth' --model anthropic/claude-sonnet-4
  opencode run 'Review security' -f config.yaml -f .env.example

INTERACTIVE TUI KEYBINDS
  Enter                          Submit message
  Tab                            Switch agents (build/plan)
  Ctrl+P                         Command palette
  Ctrl+X L                       Switch session
  Ctrl+X M                       Switch model
  Ctrl+X N                       New session
  Ctrl+C                         Exit (NOT /exit!)

FLAGS
  --thinking                     Show model reasoning
  --variant high|minimal         Reasoning effort
  --model provider/model         Force specific model
  --format json                  Machine-readable output
  --file / -f                    Attach context files
  --title name                   Name the session
  --agent build|plan             Choose agent

OUR SETUP (NFP)
  Plugin: oh-my-openagent (z0r0)
  Config: layers/70-agents/71-coding/opencode.nix
  MCP servers: context-mode, github, himalaya, mcp-nixos

TIPS
  Use opencode run for automation — no pty needed
  Interactive sessions need pty=true in terminal tool
  /exit opens agent selector — use Ctrl+C to quit
  Check costs: opencode stats --days 7
CHEATSHEET_EOF
  '';

  hermes_cheatsheet = pkgs.writeShellScriptBin "hermes-cheatsheet" ''
    ${pkgs.coreutils}/bin/cat <<'CHEATSHEET_EOF' | ${pkgs.rofi}/bin/rofi -dmenu -p "Hermes Agent" -theme-str 'window {width: 50%;}' -theme-str 'element-text {font: "monospace 11";}'
🧠 HERMES AGENT — Autonomous AI Worker
─────────────────────────────────────────
BASIC USAGE
  hermes                         Launch TUI
  hermes setup                   First-time setup
  hermes config                  Show current config
  hermes version                 Check version

GATEWAY (always running)
  http://127.0.0.1:8085          MCP gateway
  http://127.0.0.1:9119          Dashboard (REST API)

PERSONALITY AND VOICE
  Default: GLaDOS (dry, sarcastic)
  TTS: glados-local (ONNX model)
  STT: Whisper (local)
  20 personalities available

TOOLS AVAILABLE (from gateway)
  browser_*                      Camofox browser control
  terminal                       Shell commands
  file ops (read/write/patch)    File manipulation
  web_search / web_extract       Internet research
  image_generate                 FAL image generation
  text_to_speech                 GLaDOS TTS
  himalaya (MCP)                 Email (IMAP/SMTP)
  send_message                   Telegram/Discord/Signal
  delegate_task                  Spawn subagents
  cronjob                        Scheduled tasks
  memory                         Persistent memory
  skill_manage/view              Skill CRUD
  todo                           Task lists
  session_search                 Past session recall

CREDENTIALS (via authsome)
  authsome run -- curl <url>     Auto-inject credentials
  14 connections: GitHub, Google (9), Cloudflare, Stripe
  Daemon: http://127.0.0.1:7998

BROWSER (Camofox)
  http://127.0.0.1:9377          Browser server
  http://127.0.0.1:6080          VNC (manual start)
  Sessions persist via cookies
  Cookie import: POST /sessions/hermes/cookies

CONFIG LOCATIONS
  ~/.hermes/config.yaml          Local CLI config
  layers/70-agents/76-hermes-agent/hermes.nix  NixOS module
  ~/.hermes/skills/              Custom skills
  ~/.hermes/profiles/            Per-profile state

OUR STACK (NFP)
  z0r0: Laptop (i7-1260P, 16GB)
  luffy: Server (i5-9th gen, down — ACPI)
  Deploy: clan machines update z0r0
  Secrets: SOPS + age keys at /persist/

PROJECT: Streaming Liberation
  ~/Streaming_Liberation/        Book + modules
  ~/Projects/autonovel/          NousResearch pipeline
  GitHub: T0PSH31F/streaming-liberation
  Live: t0psh31f.github.io/streaming-liberation
CHEATSHEET_EOF
  '';

in
{
  home = lib.mkIf (cfg.enable && cfg.yazelixIntegration.enable) {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;

      settings = {
        theme = lib.mkIf cfg.theming.enable "matugen";
        pane_frames = true;
        default_layout = "dev";
        simplified_ui = true;

        # ── Scroll & Cursor Fixes ───────────────────────────────
        # scrollback_buffer_size: number of lines kept in scrollback
        scrollback_buffer_size = 50000;
        # scrollback_editor: open scrollback in nvim for search/filter
        scrollback_editor = "${lib.getExe pkgs.neovim}";
        # mouse_mode: enable mouse wheel scroll + click-to-focus
        mouse_mode = true;
        # copy_command: Wayland native clipboard
        copy_command = "wl-copy";
        # default_shell: use zsh
        default_shell = "${pkgs.zsh}/bin/zsh";
        # auto_copy_on_select: disable auto-copy on highlight, use manual bindings instead
        auto_copy_on_select = false;

        keybinds = {
          normal = {
            "bind \"Ctrl q\"" = {
              Quit = { };
            };
            # Scroll half page up/down
            "bind \"Ctrl u\"" = {
              ScrollUp = { };
            };
            "bind \"Ctrl d\"" = {
              ScrollDown = { };
            };
          };
          pane = {
            "bind \"h\"" = {
              MoveFocus = "Left";
            };
            "bind \"j\"" = {
              MoveFocus = "Down";
            };
            "bind \"k\"" = {
              MoveFocus = "Up";
            };
            "bind \"l\"" = {
              MoveFocus = "Right";
            };
          };
          resize = {
            "bind \"h\"" = {
              Resize = "Increase Left";
            };
            "bind \"j\"" = {
              Resize = "Increase Down";
            };
            "bind \"k\"" = {
              Resize = "Increase Up";
            };
            "bind \"l\"" = {
              Resize = "Increase Right";
            };
          };
          tab = {
            # Create new tab
            "bind \"n\"" = {
              NewTab = { };
            };
            # Close current tab
            "bind \"x\"" = {
              CloseTab = { };
            };
          };
          scroll = {
            # Copy selected text (alternative to auto-copy)
            "bind \"y\"" = {
              Copy = { };
            };
            "bind \"Enter\"" = {
              Copy = { };
            };
            "bind \"Ctrl c\"" = {
              Copy = { };
            };
          };
        };
      };
    };

    # Install layout profile files
    xdg.configFile = lib.mapAttrs' (name: kdl: {
      name = "zellij/layouts/${name}.kdl";
      value = { text = kdl; };
    }) layouts;

    # Shell aliases for quick layout switching
    programs.zsh.initContent = ''
      # Zellij layout aliases
      z-dev()   { zellij --layout dev; }
      z-git()   { zellij --layout git; }
      z-server(){ zellij --layout server; }
    '';

    # Keybind cheatsheets for terminal programs
    home.packages = [
      cheatsheet_picker
      zellij_cheatsheet
      nvim_cheatsheet
      yazi_cheatsheet
      helix_cheatsheet
      zsh_cheatsheet
      fzf_cheatsheet
      grep_sed_awk_cheatsheet
      docker_cheatsheet
      vm_cheatsheet
      cli_power_cheatsheet
      opencode_cheatsheet
      hermes_cheatsheet
    ];
  };
}
