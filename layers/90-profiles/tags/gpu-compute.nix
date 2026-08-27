# gpu-compute — GPU compute workloads
# Tags-as-data: all config gated by tag membership.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "gpu-compute" config.machine.tags) {
    # GPU-specific compute config (CUDA/ROCm) applied here when needed
  };
}
