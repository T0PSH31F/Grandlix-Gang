# Desktop Experiences — pure aggregator for the dendritic tree.
# mkDendriticTree wraps each entry via mkDendriticModule, which
# correctly handles multi-class modules (nixos + home).
{ mkDendriticModule, mkDendriticTree, ... }:
{
  imports = mkDendriticTree mkDendriticModule ./.;
}
