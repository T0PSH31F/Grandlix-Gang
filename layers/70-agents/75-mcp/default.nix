{ lib, mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "mcp-catalog" ./server-catalog.nix)
  ];
}
