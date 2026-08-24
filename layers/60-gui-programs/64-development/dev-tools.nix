{
  pkgs,
  lib,
  config,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
  cfg = config.layers.layer-60.gui.dev-tools;
in
{
  options.layers.layer-60.gui.dev-tools = {
    enable = lib.mkEnableOption "GUI development tools" // {
      default = builtins.elem "development" clanTags || builtins.elem "dev" clanTags;
    };
  };

  nixos = { };

  home = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      postman
      httpie
      curlie
      yq
      vhs

      # Database GUI Managers
      beekeeper-studio
      pgadmin4-desktopmode
    ];

    home.activation.setupSshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.ssh
      chmod 700 $HOME/.ssh
      if [ ! -f $HOME/.ssh/config ] || [ -L $HOME/.ssh/config ]; then
        rm -f $HOME/.ssh/config
        cat > $HOME/.ssh/config << 'EOF'
        AddKeysToAgent yes

        Host z0r0.local
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null
            LogLevel ERROR

        Host github.com
            HostName github.com
            User git
            IdentityFile ~/.ssh/id_ed25519
EOF
        chmod 600 $HOME/.ssh/config
      fi
    '';
  };
}
