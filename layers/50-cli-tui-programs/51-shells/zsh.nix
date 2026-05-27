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
  currentAsset = motdAssets.${hostName} or {
    image = ../../../layers/00-cyberia/02-assets/png-ico/Nami2.png;
    label = "NFP";
  };

  motdPkg = pkgs.runCommand "nixos-motd-${hostName}"
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
      chafa --size=35x16 ${currentAsset.image} > $out/motd.txt
      echo -ne "\033[16A" >> $out/motd.txt
      figlet -c -f isometric2 ${currentAsset.label} | lolcat -f | while IFS= read -r line; do
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
      shellInit = ''
        # Load Nix profile for Zsh sessions
        if [ -e /etc/profile.d/nix.sh ]; then
          . /etc/profile.d/nix.sh
        elif [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
          . $HOME/.nix-profile/etc/profile.d/nix.sh
        fi
      '';
      shellAliases = {
        zls = "zellij list-sessions";
        zd = "zellij delete-session";
        zk = "zellij kill-session";
      };
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
