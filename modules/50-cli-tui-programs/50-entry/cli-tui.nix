# flake-parts/features/home/cli-tui.nix
{
  config,
  inputs,
  ...
}:
{
  imports = [
    ../default.nix
    ../../70-agents/default.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  # ==========================================================
  # CLI ENVIRONMENT TOGGLES
  # ==========================================================
  programs.cli-environment = {
    enable = true;
    theming.enable = true;
    shells.zsh.enable = true;
    modernTools.enable = true;
    nixTools.enable = true;
    yazelixIntegration.enable = true;
  };

  # ==========================================================
  # GIT IDENTITY (Via SOPS)
  # ==========================================================
  sops.secrets.git_name = {
    sopsFile = ../../../modules/00-cyberia/03-treasure/secrets/git.yaml;
    format = "yaml";
  };
  sops.secrets.git_email = {
    sopsFile = ../../../modules/00-cyberia/03-treasure/secrets/git.yaml;
    format = "yaml";
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "hx";
      include.path = "${config.sops.templates."git-config".path}";
    };
  };

  sops.templates."git-config".content = ''
    [user]
      name = ${config.sops.secrets.git_name.path}
      email = ${config.sops.secrets.git_email.path}
  '';

  # ==========================================================
  # AI AGENTS
  # ==========================================================
  features.home.agent.opencode.enable = true;
  features.home.agent.mcp.enable = true;
  features.home.agent.gemini-cli.enable = true;

  # ==========================================================
  # OLLAMA (User-level service via Home Manager)
  # ==========================================================
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
  };

  # Home Manager requirements
  home.stateVersion = "25.05";
}
