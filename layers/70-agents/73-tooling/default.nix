{ mkDendriticModule, mkDendriticTree, ... }:
{
  imports = mkDendriticTree mkDendriticModule ./.;
}
