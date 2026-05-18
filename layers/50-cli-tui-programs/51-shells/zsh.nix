{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
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
        chafa --size=35x16 ${../../../layers/00-cyberia/02-assets/png-ico/Nami2.png} > $out/nami.txt
        echo -ne "\033[16A" >> $out/nami.txt
        figlet -c -f isometric2 NAMI | lolcat -f | while IFS= read -r line; do
          echo -ne "\033[36C" >> $out/nami.txt
          echo "$line" >> $out/nami.txt
        done
        echo -ne "\033[2B" >> $out/nami.txt
        chafa --size=35x16 ${../../../layers/00-cyberia/02-assets/png-ico/roronoa-zoro.png} > $out/z0r0.txt
        echo -ne "\033[16A" >> $out/z0r0.txt
        figlet -c -f isometric2 ZORO | lolcat -f | while IFS= read -r line; do
          echo -ne "\033[36C" >> $out/z0r0.txt
          echo "$line" >> $out/z0r0.txt
        done
        echo -ne "\033[2B" >> $out/z0r0.txt
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
        bindkey -v
        export KEYTIMEOUT=1
        bindkey '^Y' autosuggest-accept
        bindkey '^E' autosuggest-clear
        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$STY" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
          # Display machine-specific MOTD or default to nami
          if [ "$HOST" = "z0r0" ]; then
            cat ${motdPkg}/z0r0.txt
          else
            cat ${motdPkg}/nami.txt
          fi
          if command -v fastfetch >/dev/null 2>&1; then fastfetch; fi
        fi
        ${lib.optionalString cfg.theming.enable "[ -f ~/.config/fzf/matugen.conf ] && source ~/.config/fzf/matugen.conf"}
        if command -v starship >/dev/null 2>&1; then eval "$(starship init zsh)"; fi
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
