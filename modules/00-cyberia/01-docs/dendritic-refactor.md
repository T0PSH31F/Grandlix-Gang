To achieve the Layered Dendritic pattern while maintaining the flexibility of 5-6 system states (Headless to Desktop) and keeping CLI config consistent, you should adopt a Unified Feature Pattern.
In this pattern, you don't separate NixOS and Home Manager by folder. Instead, you group them by intent. A "feature" module contains both the system-level settings and the user-level settings for that specific capability.
1. The Unified Dendritic Structure
.
├── flake.nix
├── parts/                 # flake-parts logic (clan-core integration)
├── core/                  # Layer 1: The "Root" (Mandatory)
│   ├── nix-settings.nix   # Flake registry, gc, nix-path
│   └── shell/             # Shared CLI (Fish/Zsh, Starship, Direnv)
│       └── default.nix    # Combined NixOS + HM logic for CLI
├── profiles/              # Layer 2: The "Trunks" (System States)
│   ├── headless-server.nix
│   ├── headless-vm.nix
│   ├── minimal-gui-vm.nix # Basic Hyprland, no fluff
│   ├── edge-device.nix
│   ├── desktop.nix        # Full Noctalia-Shell + Apps
│   └── laptop.nix         # Desktop + Power Management
├── features/              # Layer 3: The "Branches" (Toggles)
│   ├── gaming.nix         # Steam, Gamemode, MangoHud
│   ├── creative/          # CAD, Image Editing (Blender, Gimp)
│   ├── media-prod/        # Screen recording (OBS, Pipewire config)
│   └── security/          # Pentest tools (linked to your dev-flake)
├── services/              # Layer 4: The "Infrastructure"
│   ├── networking/        # Tailscale, Firewall
│   ├── virtualization/    # Docker, extra-container, Podman
│   └── web/               # Nginx, Arion
└── hosts/                 # Layer 5: The "Leaves" (Clan-core / Hardware)
    └── workstation/       # Imports Profile:Desktop + Feature:Gaming

2. The "Unified Module" Pattern
To avoid the "System vs. HM" split, write your modules like this. This ensures that when you import features/gaming.nix, it configures both the kernel and the user's desktop icons.
# features/gaming.nix
{ pkgs, config, lib, ... }:
{
  # --- NixOS Level ---
  programs.steam.enable = true;
  hardware.xone.enable = true; # Xbox Controller support

  # --- Home Manager Level (Integrated) ---
  # Note: Replace "t0psh31f" with your explicit username, or define a custom 
  # config.user.name option to make this dynamic across different users.
  home-manager.users.t0psh31f = {
    home.packages = [ pkgs.mangohud pkgs.lutris ];
    xdg.configFile."mangohud/mangohud.conf".text = "fps_limit=144";
  };
}

3. Organizing Services
Services should be categorized by Domain. In a dendritic pattern, services often depend on specific "Trunks."
System Services (SSH, Tailscale, Docker) go in services/.
User Services (Waybar, Mako, Pipewire-applets) should live within the profiles/desktop.nix or features/ modules because they require a graphical session.

4. Handling the "Dev/Pentest" Flake
Since you want to keep evaluation costs low, use direnv with nix shell or devenv references rather than importing them into your system closure.
In your main flake:
# Use flake-parts to define a "dev" shell that pulls from your external pentest flake
devShells.default = inputs.pentest-flake.devShells.${system}.tools;
This way, the tools are never evaluated unless you enter a specific directory or run a nix shell command.

5. Clan-Core Integration (Toggles & Tags)
Use clan-core tags to identify which "Trunk" a machine belongs to. In your hosts/ directory, you can use logic like:
# hosts/my-laptop/default.nix
{
  imports = [
    ../../profiles/laptop.nix      # The Trunk
    ../../features/gaming.nix      # A Branch
    ../../features/creative.nix    # A Branch
  ];
  
  clan.tags = [ "graphical" "mobile" "workstation" ];
}
Summary of Benefits:
CLI Consistency: Since core/shell is imported by every single Profile (Trunk), your shell experience is identical on a Headless Server and a Desktop.
State Management: If you need a "Minimal Graphical VM," you just create a profile that imports profiles/headless-vm.nix + features/hyprland-minimal.nix.
Low Eval Cost: By keeping Pentest/Dev tools in devenv and a separate flake, your nixos-rebuild remains fast.
Noctalia-Shell: You can relegate the heavy Matugen/Theming logic strictly to the profiles/desktop.nix layer so it doesn't pollute your edge-device or server configs.