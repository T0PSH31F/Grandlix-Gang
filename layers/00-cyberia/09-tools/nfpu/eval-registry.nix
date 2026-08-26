let
  # Path to the root of the NFP flake
  flake = builtins.getFlake (toString ../../../..);
  lib = flake.inputs.nixpkgs.lib;

  # Recursively extract only the `enable` values from an options tree
  extractEnables =
    prefix: opts:
    lib.concatMapAttrs (
      name: val:
      if name == "enable" && lib.isOption val then
        # Use builtins.tryEval to avoid evaluation errors crashing the whole script
        let
          evalRes = builtins.tryEval val.value;
          desc =
            if val ? description then
              (if builtins.isString val.description then val.description else val.description.text or "")
            else
              "";
        in
        {
          "${prefix}.enable" = {
            value = if evalRes.success then evalRes.value else false;
            description = desc;
          };
        }
      else if
        builtins.isAttrs val && !(lib.isOption val) && !(lib.isDerivation val) && name != "_module"
      then
        extractEnables (if prefix == "" then name else "${prefix}.${name}") val
      else
        { }
    ) opts;

  extractMachineConfig = _name: machine: {
    options = extractEnables "" (machine.options.layers or { });
  };

  machines = builtins.mapAttrs extractMachineConfig flake.nixosConfigurations;
in
machines
