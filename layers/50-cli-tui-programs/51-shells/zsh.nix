{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
  hostName = config.networking.hostName or "nix";

  # ── Per-machine MOTD assets ──
  # Each machine gets its own chafa image + figlet banner.
  # Place your preferred PNG at the referenced path — chafa renders it in-terminal.
  motdAssets = {
    z0r0 = {
      image = ../../../layers/00-cyberia/02-assets/png-ico/roronoa-zoro-monkey-d-luffy-one-piece-vinsmoke-sanji-one-piece-f28baea931e3d454307ef781771688d6.png;
      label = "Z0R0";
    };
    luffy = {
      image = ../../../layers/00-cyberia/02-assets/png-ico/Luffyrave.png;
      label = "LUFFY";
    };
  };

  # Fall back to Nami for unknown hosts
  currentAsset =
    motdAssets.${hostName} or {
      image = ../../../layers/00-cyberia/02-assets/png-ico/Nami2.png;
      label = "NFP";
    };

  motdPkg =
    pkgs.runCommand "nixos-motd-${hostName}"
      {
        buildInputs = [
          pkgs.chafa
          pkgs.figlet
          pkgs.lolcat
          pkgs.coreutils
        ];
      }
      ''
        mkdir -p $out
        # Render image as crisp ASCII art
        # Render image as crisp ASCII art (fg-only avoids color-noise on dark terminals)
        chafa --symbols=block+border+space --fg-only --size=34x20 ${currentAsset.image} > $out/motd.txt
        # Move cursor back up to overlay figlet label beside the image
        echo -ne "\033[20A" >> $out/motd.txt
        # Left-justified figlet (no -c) so offset isn't doubled from figlet centering
        figlet -f isometric2 ${currentAsset.label} | lolcat -f | while IFS= read -r line; do
          # Offset: image is 34 cols wide, give 2-col gap → text at col 36
          echo -ne "\033[36C" >> $out/motd.txt
          echo "$line" >> $out/motd.txt
        done
        echo -ne "\033[2B" >> $out/motd.txt
      '';
in
{
  home = lib.mkIf (cfg.enable && cfg.shells.zsh.enable) {
    programs.zsh = {
      enable = true;
      dotDir = "${config.users.users.${config.layers.meta.primaryUser}.home}/.config/zsh";
      enableVteIntegration = true;
      autocd = true;
      enableCompletion = true;
      envExtra = lib.mkIf cfg.headless ''
        if [ -e /etc/profile.d/nix.sh ]; then . /etc/profile.d/nix.sh; elif [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
      '';
      autosuggestion = {
        enable = true;
        highlight = "fg=#6c7086";
      };
      syntaxHighlighting.enable = true;
      history = {
        append = true;
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        saveNoDups = true;
        ignoreDups = true;
        findNoDups = true;
        ignoreSpace = true;
        extended = true;
        share = true;
        path = "$ZDOTDIR/.zsh_history";
      };
      historySubstringSearch = {
        enable = true;
        searchUpKey = "^[[A";
        searchDownKey = "^[[B";
      };
      shellAliases = {
        zls = "zellij list-sessions";
        zd = "zellij delete-session";
        zk = "zellij kill-session";
      };
      initContent = ''
        any-nix-shell zsh --info-right | source /dev/stdin
        bindkey '^Y' autosuggest-accept
        bindkey '^E' autosuggest-clear
        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$STY" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
          # Machine-specific MOTD greeting
          cat ${motdPkg}/motd.txt
        fi
        ${lib.optionalString cfg.theming.enable "[ -f ~/.config/fzf/matugen.conf ] && source ~/.config/fzf/matugen.conf"}
        if command -v starship >/dev/null 2>&1; then
          # Sync and apply Noctalia theme palette to Starship config
          local PALETTE_FILE=""
          if [ -f "$HOME/.cache/noctalia/starship-palette.toml" ]; then
            PALETTE_FILE="$HOME/.cache/noctalia/starship-palette.toml"
          elif [ -f "$HOME/.config/noctalia/templates/starship.toml" ]; then
            PALETTE_FILE="$HOME/.config/noctalia/templates/starship.toml"
          fi

          if [ ! -f "$HOME/.cache/starship/starship.toml" ] || [ "$HOME/.config/starship.toml" -nt "$HOME/.cache/starship/starship.toml" ]; then
            mkdir -p "$HOME/.cache/starship"
            cp "$HOME/.config/starship.toml" "$HOME/.cache/starship/starship.toml"
            if [ -n "$PALETTE_FILE" ]; then
              sed -i -E 's/^([[:space:]]*)palette([[:space:]]*)=.*/\1palette\2= "noctalia"/' "$HOME/.cache/starship/starship.toml" 2>/dev/null || sed -i '1i palette = "noctalia"' "$HOME/.cache/starship/starship.toml"
              echo -e "\n# >>> NOCTALIA STARSHIP PALETTE >>>" >> "$HOME/.cache/starship/starship.toml"
              cat "$PALETTE_FILE" >> "$HOME/.cache/starship/starship.toml"
              echo "# <<< NOCTALIA STARSHIP PALETTE <<<" >> "$HOME/.cache/starship/starship.toml"
            fi
          fi
          eval "$(starship init zsh)"
        fi

        ${lib.optionalString (!cfg.headless) ''
          if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$TMUX" ]] && [[ -z "$STY" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ "$TERM_PROGRAM" != "WarpTerminal" ]] && [[ "$TERM_PROGRAM" != "Waveterm" ]] && [[ -z "$SSH_CONNECTION" ]]; then
              if command -v zellij >/dev/null 2>&1; then zellij attach -c "$HOST"; fi
          fi
        ''}
      '';
      antidote = {
        enable = true;
        useFriendlyNames = true;
        plugins = [
          "getantidote/use-omz"
          "ohmyzsh/ohmyzsh path:lib"
          "ohmyzsh/ohmyzsh path:plugins/git"
          "ohmyzsh/ohmyzsh path:plugins/docker"
          "ohmyzsh/ohmyzsh path:plugins/docker-compose"
          "ohmyzsh/ohmyzsh path:plugins/gradle"
        ];
      };
    };
    home.packages = with pkgs; [
      revolver
      zsh-command-time
      zsh-completions
      zsh-clipboard
      zsh-f-sy-h
      zsh-fzf-tab
      zsh-you-should-use
      zsh-nix-shell
      nix-zsh-completions
      any-nix-shell
      z-lua
    ];
  };
}
