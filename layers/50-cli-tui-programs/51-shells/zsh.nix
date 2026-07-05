{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
  hostName = config.networking.hostName or "nix";

  # ── Per-machine MOTD using fastfetch ──
  # Fastfetch renders the PNG logo natively (kitty/sixel/iterm2/chafa) with
  # far better quality than viu's raw escape codes, and shows system info.
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

  # chafa's runtime closure depends on `util-linux-minimal`'s `libmount.so.1`
  # (and a handful of other transitive libraries like `libselinux.so.1`).
  # nixpkgs-unstable's `pkgs.util-linux` no longer ships libmount in its main
  # output; only `util-linux-minimal` does. We resolve the full set of chafa's
  # closure paths and feed them into `LD_LIBRARY_PATH` so the build sandbox
  # can run the binary during the derivation.
  motdPkg =
    let
      # Compute the proper library path from chafa's runtime closure.
      runtimePath = lib.makeLibraryPath (with pkgs; [
        util-linux
        libselinux
        pcre2
        fontconfig
        glib
        cairo
        librsvg
        gdk-pixbuf
        libjpeg_turbo
        libtiff
        libjxl
        libavif
        freetype
        bzip2
        libpng
        brotli
      ]);
    in
    pkgs.runCommand "nixos-motd-${hostName}"
      {
        buildInputs = [
          pkgs.chafa
          pkgs.figlet
          pkgs.lolcat
          pkgs.coreutils
        ];
      } ''
        mkdir -p $out
        # Make all of chafa's runtime libraries resolvable in the build sandbox.
        export LD_LIBRARY_PATH="${runtimePath}''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
        # Render PNG via chafa — supports kitty/sixel/iterm2/ascii, way better than viu
        chafa --size=40x20 -f symbols ${currentAsset.image} > $out/motd.txt
        echo "" >> $out/motd.txt
        figlet -c -f isometric2 ${currentAsset.label} | lolcat -f >> $out/motd.txt
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
