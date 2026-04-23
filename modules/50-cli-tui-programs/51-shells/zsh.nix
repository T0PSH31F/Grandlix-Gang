# flake-parts/features/home/cli/shells/zsh.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cli-environment;

  motdPkg =
    pkgs.runCommand "nixos-motds"
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

        # Generate Nami MOTD
        chafa --size=35x16 ${../../../modules/00-cyberia/02-assets/png-ico/Nami2.png} > $out/nami.txt
        echo -ne "\033[16A" >> $out/nami.txt
        figlet -c -f isometric2 NAMI | lolcat -f | while IFS= read -r line; do
          echo -ne "\033[36C" >> $out/nami.txt
          echo "$line" >> $out/nami.txt
        done
        echo -ne "\033[2B" >> $out/nami.txt

        # Generate Z0r0 MOTD
        chafa --size=35x16 ${../../../modules/00-cyberia/02-assets/png-ico/roronoa-zoro.png} > $out/z0r0.txt
        echo -ne "\033[16A" >> $out/z0r0.txt
        figlet -c -f isometric2 ZORO | lolcat -f | while IFS= read -r line; do
          echo -ne "\033[36C" >> $out/z0r0.txt
          echo "$line" >> $out/z0r0.txt
        done
        echo -ne "\033[2B" >> $out/z0r0.txt

        # Generate Luffy MOTD
        # chafa --size=35x16 ${../../../modules/00-cyberia/02-assets/png-ico/Luffyrave.png} > $out/luffy.txt
        # echo -ne "\033[16A" >> $out/luffy.txt
        # figlet -c -f isometric2 LUFFY | lolcat -f | while IFS= read -r line; do
        #   echo -ne "\033[36C" >> $out/luffy.txt
        #   echo "$line" >> $out/luffy.txt
        # done
        # echo -ne "\033[2B" >> $out/luffy.txt
      '';
in
{
  config = lib.mkIf (cfg.enable && cfg.shells.zsh.enable) {
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableVteIntegration = true;
      autocd = true;
      enableCompletion = true;

      envExtra = lib.mkIf cfg.headless ''
        # Ensure Nix environment is sourced on Ubuntu/Headless
        if [ -e /etc/profile.d/nix.sh ]; then
          . /etc/profile.d/nix.sh
        elif [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
          . $HOME/.nix-profile/etc/profile.d/nix.sh
        fi
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
        searchUpKey = "^[[A"; # Up Arrow
        searchDownKey = "^[[B"; # Down Arrow
      };
      shellAliases = {
        zls = "zellij list-sessions";
        zd = "zellij delete-session";
        zk = "zellij kill-session";
      };

      initContent = ''
        any-nix-shell zsh --info-right | source /dev/stdin

        # Keybindings
        bindkey -v
        export KEYTIMEOUT=1
        bindkey '^Y' autosuggest-accept
        bindkey '^E' autosuggest-clear

        # Display MOTD
        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$STY" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
          if command -v fastfetch >/dev/null 2>&1; then
            fastfetch
          fi
        fi

        # Matugen FZF integration
        ${lib.optionalString cfg.theming.enable ''
          [ -f ~/.config/fzf/matugen.conf ] && source ~/.config/fzf/matugen.conf
        ''}

        # Starship prompt initialization
        if command -v starship >/dev/null 2>&1; then
          eval "$(starship init zsh)"
        fi

        # Auto-attach to Zellij automatically using the host name
        ${lib.optionalString (!cfg.headless) ''
          if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$TMUX" ]] && [[ -z "$STY" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ "$TERM_PROGRAM" != "WarpTerminal" ]] && [[ "$TERM_PROGRAM" != "Waveterm" ]] && [[ -z "$SSH_CONNECTION" ]]; then
              if command -v zellij >/dev/null 2>&1; then
                  zellij attach -c "$HOST"
              fi
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
    home.packages = [
      pkgs.revolver
      pkgs.zsh-command-time
      pkgs.zsh-completions
      pkgs.zsh-clipboard
      pkgs.zsh-f-sy-h
      pkgs.zsh-fzf-tab
      pkgs.zsh-you-should-use
      pkgs.zsh-nix-shell
      pkgs.nix-zsh-completions
      pkgs.any-nix-shell
      pkgs.z-lua
    ];
  };
}
