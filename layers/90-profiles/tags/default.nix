# Tag Profile Registry — Tags as Pure Data
{
  config,
  lib,
  mkDendriticModule,
  mkDendriticTree,
  ...
}:
let
  validTags = [
    "ai-agent"
    "ai-router"
    "ai-server"
    "agent-orchestrator"
    "cache-server"
    "desktop"
    "development"
    "gaming"
    "gpu-compute"
    "homelab"
    "intel-12th-gen"
    "intel-9th-gen"
    "laptop"
    "media"
    "network-router"
    "pkb-node"
    "server"
    "workstation"
  ];

  machineTags = config.machine.tags or [ ];
  invalidTags = builtins.filter (tag: !(builtins.elem tag validTags)) machineTags;
in
{
  imports = mkDendriticTree mkDendriticModule ./.;

  config = {
    assertions = [
      {
        assertion = invalidTags == [ ];
        message = "Invalid machine tag(s): ${builtins.concatStringsSep ", " invalidTags}. Valid tags: ${builtins.concatStringsSep ", " validTags}";
      }
    ];
  };
}
