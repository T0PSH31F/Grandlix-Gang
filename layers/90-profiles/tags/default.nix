# Tag Profile Registry and Machine Tag Resolver
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

  mkMachineFromTags =
    tags:
    map (
      tag:
      if builtins.elem tag validTags then
        ./${tag}.nix
      else
        throw "Invalid machine tag '${tag}'! Must be one of: ${builtins.concatStringsSep ", " validTags}"
    ) tags;
in
{
  inherit validTags mkMachineFromTags;
}
