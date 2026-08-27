{ mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "virtualization" ./virtualization.nix)
  ];
}
