# flake-parts/features/home/cli/prompt/starship.nix
{
  config,
  lib,
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
          [ ](black)$os[](bg:purple fg:black)$localip[](bg:cyan fg:purple)$directory[](bg:black fg:cyan)$env_var[ ](black)$fill[ ](purple)$git_branch$git_status[](bg:purple fg:cyan)$rust$nodejs$python$c$cpp$docker_context[ ](fg:cyan)
          [](black)$sudo$character$fill[ ](purple)$cmd_duration[](bg:purple fg:cyan)$time[](cyan)
        '';

        # =========================
        # RIGHT PROMPT (Line 1)
        # =========================
        right_format = "";

        # =========================
        # STRUCTURAL & CHARACTER
        # =========================
        fill = {
          symbol = " ";
          disabled = false;
        };

        character = {
          # Slanted bubble matching top row; slant included in symbol for prompt positioning
          success_symbol = "[ 󰯉 ](bg:black fg:green)[](fg:black) ";
          error_symbol = "[ 👾 ](bg:red fg:white)[](fg:red) ";
        };

        # =========================
        # TOP-LEFT MODULES
        # =========================
        os = {
          disabled = false;
          format = "[$symbol](bg:black)";
          symbols = {
            Ubuntu = "🐧󰕈";
            NixOS = "[](bold cyan)"; # The authentic NixOS lambda! (Simplified for text representation)
            Windows = "󰍲";
            SUSE = "";
            Raspbian = "󰐿";
            Mint = "󰣭";
            Macos = "󰀵";
            Manjaro = "";
            Linux = "󰌽";
            Gentoo = "󰣨";
            Fedora = "󰣛";
            Alpine = "";
            Amazon = "";
            Android = "";
            AOSC = "";
            Arch = "󰣇";
            Artix = "󰣇";
            EndeavourOS = "";
            CentOS = "";
            Debian = "󰣚";
            Redhat = "󱄛";
            RedHatEnterprise = "󱄛";
            Pop = "";
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
          substitutions = {
            #"" = " ";
            "Documents" = " ";
            "Downloads" = "󱃩 ";
            "Music" = " ";
            "Notes" = " ";
            "Pictures" = "   ";
            "Projects" = "  ";
            "Videos" = " ";
            "Agents" = " ";
            "Games" = "  ";
            "Clan" = " ";
            ".config" = " ";
            ".local" = " ";
            ".nix" = "󱄅 ";
            ".ssh" = "󰣀 ";
            ".gemini" = "󰪁 ";
            ".mozilla" = " ";
            ".npm" = " ";
            ".pnpm" = " ";
            ".yarn" = " ";
            ".rustup" = "󱘗 ";
            ".cargo" = "󱣘 ";
            ".git" = " ";
          };
        };

        env_var = {
          USER = {
            format = "[   $env_value  ](bg:black fg:cyan)";
            disabled = false;
            ## other favs                              
          };
        };

        # =========================
        # TOP-RIGHT MODULES
        # =========================
        git_branch = {
          format = "[  $branch ](bg:purple fg:black bold)";
        };

        git_status = {
          format = "[$all_status$ahead_behind ](bg:purple fg:black)";
          conflicted = "🥊 ";
          up_to_date = "✅ ";
          untracked = " ";
          modified = " ";
        };

        # =========================
        # TOP-RIGHT MODULES
        # =========================
        golang = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };
        c = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };
        cpp = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };
        python = {
          symbol = "🐍";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
        };
        docker_context = {
          symbol = "  ";
          style = "bg:color_bg3";
          format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
        };

        # =========================
        # BOTTOM MODULES (Line 2)
        # =========================
        sudo = {
          disabled = false;
          symbol = "  ";
          format = "[$symbol]($style)";
          style = "bold yellow";
        };

        cmd_duration = {
          min_time = 500;
          format = "[⏳ $duration ](bg:purple fg:black)";
        };

        time = {
          disabled = false;
          use_12hr = true;
          format = "[   $time ](bg:cyan fg:black)";
        };

        # transient_prompt requires Starship ≥1.17 and a format string
        transient_prompt = {
          enabled = true;
          format = "[󰯉 ](bold green)";
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
