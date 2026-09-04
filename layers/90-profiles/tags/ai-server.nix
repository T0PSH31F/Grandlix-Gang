# ai-server — DEPRECATED: use ai-router + pkb-node + agent-orchestrator instead.
# Retained for backward compatibility during tag migration.
# Machines should migrate to the granular tags above.
# This tag enables minimal shared dependencies only.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "ai-server" config.machine.tags) {
    services.ai-services.postgresql.enable = lib.mkDefault true;
  };
}
