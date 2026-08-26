# layers/20-services/22-ai/25-harness-control/memory-governance.nix
# Memory Governance Plane for agent access control and memory scope segregation.

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.memory-governance;

  govScript = pkgs.writeShellApplication {
    name = "memory-gov-check";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      findutils
      jq
    ];
    text = ''
      set -euo pipefail

      echo "=== Memory Governance Plane Audit ==="
      echo "Shared Vault: ${cfg.sharedVaultPath}"
      if [ -d "${cfg.sharedVaultPath}" ]; then
        echo "[OK] Shared Vault exists"
      else
        echo "[WARN] Shared Vault directory missing"
      fi

      echo "Scope Enforcement: ${if cfg.enforceScopes then "ENABLED" else "DISABLED"}"
      echo "Default Agent Scope: ${cfg.defaultScope}"
      echo "Registered Private Stores:"
      ${concatStringsSep "\n" (
        mapAttrsToList (
          agent: path:
          "echo \"  - ${agent}: ${path} ($(if [ -d \"${path}\" ]; then echo \"EXISTS\"; else echo \"MISSING\"; fi))\""
        ) cfg.privateStores
      )}
      echo "====================================="
    '';
  };
in
{
  options.layers.layer-20.services.memory-governance = {
    enable = mkEnableOption "Memory Governance Plane";

    sharedVaultPath = mkOption {
      type = types.str;
      default = "/var/lib/memory/vault";
      description = "Canonical shared markdown memory vault path";
    };

    privateStores = mkOption {
      type = types.attrsOf types.str;
      default = {
        hermes = "/var/lib/hermes";
        opencode = "/var/lib/opencode";
        polyfloor = "/var/lib/polyfloor";
      };
      description = "Map of agent identities to their private state directories";
    };

    enforceScopes = mkOption {
      type = types.bool;
      default = true;
      description = "Enforce ACL scopes via ContextForge & EverOS gatekeeper";
    };

    defaultScope = mkOption {
      type = types.enum [
        "shared-only"
        "shared-and-private"
      ];
      default = "shared-only";
      description = "Default scope policy assigned to sandboxed/untrusted agent runtimes";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      govScript
    ];

    # Enable dependency services if governance is enabled
    layers.layer-20.services.memory-vault.enable = mkDefault true;
    layers.layer-20.services.everos.enable = mkDefault true;
    layers.layer-20.services.context-forge.enable = mkDefault true;
  };
}
