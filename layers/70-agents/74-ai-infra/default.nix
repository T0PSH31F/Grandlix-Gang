{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-70.agent.ai-agent-stack;

  # Python agent dependencies wrapper:
  agentDeps = pkgs.python3.withPackages (
    ps: with ps; [
      pip
      requests
      httpx
      pyyaml
      click
      pydantic
      rich
    ]
  );

  # Mock bin wrappers for pip-based CLI tools to be installed manually or handled via pipx inside the shell
  # This provides the raw environment needed for zeroclaw, openclaw, hermes, vectorcode
  agentEnv = pkgs.buildEnv {
    name = "ai-agent-stack-env";
    paths = [
      agentDeps
      pkgs.pipx
      # OpenCode and Beads are in nixpkgs/overlays
      # pkgs.opencode (handled via config.layers.layer-70.home.agent.opencode)
      pkgs.beads
    ];
  };

in
{
  imports = [
    ./agent-sandbox.nix
    ../../20-services/22-ai
    ../../20-services/25-data/langfuse.nix
  ];

  options.layers.layer-70.agent.ai-agent-stack = {
    enable = lib.mkEnableOption "Turn-key Universal PKB and Agent Stack";
  };

  config = lib.mkIf cfg.enable {
    # 1. Enable Core Data & Services
    services.ai-services = {
      enable = true;
      postgresql.enable = true;
      brain-service.enable = true;
      voice.enable = true;
    };

    services.infrastructure.langfuse.enable = true;

    # 2. Add System Packages & Tools
    environment.systemPackages = [ agentEnv ];

    # 3. Agent Home Features (OpenCode auto-integration if home-manager is active)
    # We set these up to propagate to all users or the main user
    # If the user has features.home... it will activate.
    # Note: Using mkDefault here allows overrides.
    # We don't forcefully override per-user, instead we just provide the system tools.
  };
}
