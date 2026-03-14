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
        chafa --size=35x16 ${../../../../../assets/png-ico/Nami2.png} > $out/nami.txt
        echo -ne "\033[16A" >> $out/nami.txt
        figlet -c -f isometric2 NAMI | lolcat -f | while IFS= read -r line; do
          echo -ne "\033[36C" >> $out/nami.txt
          echo "$line" >> $out/nami.txt
        done
        echo -ne "\033[2B" >> $out/nami.txt

        # Generate Z0r0 MOTD
        chafa --size=35x16 ${../../../../../assets/png-ico/roronoa-zoro.png} > $out/z0r0.txt
        echo -ne "\033[16A" >> $out/z0r0.txt
        figlet -c -f isometric2 ZORO | lolcat -f | while IFS= read -r line; do
          echo -ne "\033[36C" >> $out/z0r0.txt
          echo "$line" >> $out/z0r0.txt
        done
        echo -ne "\033[2B" >> $out/z0r0.txt

        # Generate Luffy MOTD
        # chafa --size=35x16 ${../../../../../assets/png-ico/Luffyrave.png} > $out/luffy.txt
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
        searchUpKey = "^P";
        searchDownKey = "^N";
      };

      initContent = ''
        # Keybindings
        bindkey -v
        export KEYTIMEOUT=1
        bindkey '^Y' autosuggest-accept
        bindkey '^E' autosuggest-clear

        # Display MOTD
        if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -z "$STY" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
          if [[ "$HOST" == "nami" ]] && [[ -f "${motdPkg}/nami.txt" ]]; then
            cat "${motdPkg}/nami.txt"
          elif [[ "$HOST" == "z0r0" ]] && [[ -f "${motdPkg}/z0r0.txt" ]]; then
            cat "${motdPkg}/z0r0.txt"
          # elif [[ "$HOST" == "luffy" ]] && [[ -f "${motdPkg}/luffy.txt" ]]; then
          #   cat "${motdPkg}/luffy.txt"
          fi
        fi

        # Matugen FZF integration
        ${lib.optionalString cfg.theming.enable ''
          [ -f ~/.config/fzf/matugen.conf ] && source ~/.config/fzf/matugen.conf
        ''}

        # Auto-attach to Zellij
        if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$TMUX" ]] && [[ -z "$STY" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
            if command -v zellij >/dev/null 2>&1; then
                zellij attach -c
            fi
        fi

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
  };
}
