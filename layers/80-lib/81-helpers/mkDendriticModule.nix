{
  lib,
  config,
  ...
}:
{
  /*
    Wrapper for dendritic multi-class modules.
    Given a module file that returns an attrset with:
      {
        options = { ... };
        nixos = { ... };
        home = { ... };
      }
    This evaluates it into a proper NixOS module that merges the `home` block
    into `home-manager.users.t0psh31f` (or equivalent target users).
  */
  mkDendriticModule =
    {
      name,
      module,
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }@args:
    let
      # Evaluate the raw module definition with the system arguments
      evaluated =
        if builtins.isFunction module then
          module args
        else
          module;

      # Extract sections (falling back to empty sets)
      opts = evaluated.options or { };
      nixosConf = evaluated.nixos or { };
      homeConf = evaluated.home or { };
      darwinConf = evaluated.darwin or { };

    in
    {
      options = opts;

      # Apply NixOS config directly to the root
      config = lib.mkMerge [
        nixosConf

        # Apply Home Manager config to the primary user
        # Note: In a fully multi-user setup, we'd iterate over users,
        # but for this repository we map to t0psh31f.
        (lib.mkIf (homeConf != { }) {
          home-manager.users.t0psh31f = homeConf;
        })
      ];
    };
}
