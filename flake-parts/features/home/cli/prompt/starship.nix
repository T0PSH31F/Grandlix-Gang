# flake-parts/features/home/cli/prompt/starship.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cli-environment;
in
{
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;

      settings = {
        add_newline = true;

        # =========================
        # LEFT PROMPT (Line 1 & 2)
        # =========================
        format = ''
          [](black)$os[](bg:purple fg:black)$localip[](bg:cyan fg:purple)$directory[](bg:black fg:cyan)$env_var[ ](fg:black)
          $sudo$character$fill$cmd_duration$time
        '';

        # =========================
        # RIGHT PROMPT (Line 1)
        # =========================
        right_format = ''
          [ ](fg:black)[](bg:black fg:purple)$git_branch$git_status[](bg:purple fg:cyan)$rust$nodejs$python[](cyan)
        '';

        # =========================
        # STRUCTURAL & CHARACTER
        # =========================
        fill = {
          symbol = " ";
          disabled = false;
        };

        character = {
          # Google Space Invader (Normal vs Error with red background)
          success_symbol = "👾 ";
          error_symbol = "[👾 ](bg:red) ";
        };

        # =========================
        # TOP-LEFT MODULES
        # =========================
        os = {
          disabled = false;
          format = "[ $symbol](bg:black)";
          symbols = {
            Ubuntu = "🐧";
            NixOS = "[  ](bold cyan)"; # The authentic NixOS lambda! (Simplified for text representation)
          };
        };

        localip = {
          ssh_only = true;
          format = "[ 🌐 $localipv4 ](bg:purple fg:black bold)";
          disabled = false;
        };

        directory = {
          format = "[ 📂 $path ](bg:cyan fg:black bold)";
          truncation_length = 3;
          truncate_to_repo = false;
        };

        env_var = {
          USER = {
            format = "[ 👤 $env_value ](bg:black fg:cyan)";
            disabled = false;
          };
        };

        # =========================
        # TOP-RIGHT MODULES
        # =========================
        git_branch = {
          format = "[ 🌿 $branch ](bg:purple fg:black bold)";
        };

        git_status = {
          format = "[$all_status$ahead_behind ](bg:purple fg:black)";
          conflicted = "🥊 ";
          up_to_date = "✅ ";
          untracked = "🌱 ";
          modified = "📝 ";
        };

        rust = {
          format = "[ 🦀 ](bg:cyan)";
        };
        nodejs = {
          format = "[ 📦 ](bg:cyan)";
        };
        python = {
          format = "[ 🐍 ](bg:cyan)";
        };

        # =========================
        # BOTTOM MODULES (Line 2)
        # =========================
        sudo = {
          disabled = false;
          symbol = "🧙 ";
          format = "[$symbol]($style)";
          style = "bold purple";
        };

        cmd_duration = {
          min_time = 500;
          format = "[](fg:purple)[ ⏳ $duration ](bg:purple fg:black)";
        };

        time = {
          disabled = false;
          use_12hr = true;
          format = "[](bg:purple fg:cyan)[ ⌚ $time ](bg:cyan fg:black)[](cyan)";
        };

        transient_prompt = {
          enabled = true;
        };
      };
    };

    home.sessionVariables = lib.mkIf cfg.theming.enable {
      # Use matugen generated starship config if enabled
      # This is tricky because we might already have a starship.toml
      # Starship doesn't have an easy "include" for the whole config
      # However, we can use the STARSHIP_CONFIG environment variable
      # STARSHIP_CONFIG = "~/.config/starship-matugen.toml";
    };

    # Alternative: Use zsh hook to source it or merge in nix
  };
}
