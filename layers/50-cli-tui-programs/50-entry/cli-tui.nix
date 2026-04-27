{
  config,
  inputs,
  ...
}:
{
  imports = [
    ../default.nix
    ../../80-lib/81-helpers/hm-bridge.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

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

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
  };

  home.stateVersion = "25.05";
}
