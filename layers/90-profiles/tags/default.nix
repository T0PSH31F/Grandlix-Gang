# Tag Profile Registry — Tags as Pure Data
#
# All tag profiles are always imported. Each profile gates its config
# with lib.mkIf (builtins.elem "tag" config.machine.tags).
# Tags are pure data — they don't control whether options exist.
#
# Invalid tags fail eval with a readable assertion error.
{
  config,
  lib,
  mkDendriticModule,
  ...
}:
let
  validTags = [
    "ai-agent"
    "ai-server"
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
    "server"
    "workstation"
  ];

  machineTags = config.machine.tags or [ ];
  invalidTags = builtins.filter (tag: !(builtins.elem tag validTags)) machineTags;
in
{
  imports = [
    (mkDendriticModule "ai-agent" ./ai-agent.nix)
    (mkDendriticModule "ai-server" ./ai-server.nix)
    (mkDendriticModule "cache-server" ./cache-server.nix)
    (mkDendriticModule "desktop" ./desktop.nix)
    (mkDendriticModule "development" ./development.nix)
    (mkDendriticModule "gaming" ./gaming.nix)
    (mkDendriticModule "gpu-compute" ./gpu-compute.nix)
    (mkDendriticModule "homelab" ./homelab.nix)
    (mkDendriticModule "intel-12th-gen" ./intel-12th-gen.nix)
    (mkDendriticModule "intel-9th-gen" ./intel-9th-gen.nix)
    (mkDendriticModule "laptop" ./laptop.nix)
    (mkDendriticModule "media" ./media.nix)
    (mkDendriticModule "server" ./server.nix)
    (mkDendriticModule "workstation" ./workstation.nix)
  ];

  config = {
    assertions = [
      {
        assertion = invalidTags == [ ];
        message = "Invalid machine tag(s): ${builtins.concatStringsSep ", " invalidTags}. Valid tags: ${builtins.concatStringsSep ", " validTags}";
      }
    ];
  };
}
