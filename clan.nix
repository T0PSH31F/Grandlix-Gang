let
  machinesInventory = {
    z0r0 = {
      tags = [
        "workstation"
        "desktop"
        "development"
        "gaming"
        "ai-server"
        "homelab"
        "cache-server"
        "media-server"
        "laptop"
        "dev"
      ];
      deploy.targetHost = "root@z0r0.local";
    };
    nami = {
      tags = [
        "workstation"
        "laptop"
        "desktop"
        "media"
        "media-server"
        "homelab"
      ];
      deploy.targetHost = "root@nami.local";
    };
    luffy = {
      tags = [
        "workstation"
        "desktop"
        "gaming"
      ];
      # deploy.targetHost = "root@luffy.local";
    };
    gaming-desktop = {
      tags = [
        "desktop"
        "gaming"
      ];
      deploy.targetHost = "root@gaming-desktop.local";
    };
  };
  mkMachineFromTags = tags: map (tag: ./layers/90-profiles/tags/${tag}.nix) tags;
in
{
  imports = [
    # ./clan-service-layers/default.nix # Removed due to class mismatch (clan.service vs clan)
  ];

  meta.name = "NFP";

  inventory = {
    machines = machinesInventory;
    instances = {
      /*
        zerotier = {
          module = {
            name = "zerotier";
            input = "clan-core";
          };
          # roles.controller.machines.luffy = { };
          # roles.moon.machines."luffy".settings.stableEndpoints = [
          #   "93.188.162.110"
          #   "93.188.162.110/9993"
          # ];
          roles.peer.machines = {
            z0r0 = { };
            nami = { };

          };
        };
      */

      # nix-cache = {
      #   module = {
      #     name = "nix-cache";
      #     input = "self";
      #   };

      #   roles.client.machines = {
      #     z0r0 = { };
      #     nami = { };

      #   };
      # };

      sillytavern = {
        module = {
          name = "ai";
          input = "self";
        };
        roles.sillytavern.machines = {
          z0r0 = { };

        };
      };
    };
  };

  machines = {
    z0r0 = {
      imports = [
        ./machines/z0r0/default.nix
      ] ++ mkMachineFromTags machinesInventory.z0r0.tags;
      clan.services.ai.sillytavern.enable = true;
    };
    nami = {
      imports = [
        ./machines/nami/default.nix
      ] ++ mkMachineFromTags machinesInventory.nami.tags;
    };
    luffy = {
      imports = [
        ./machines/luffy/default.nix
      ] ++ mkMachineFromTags machinesInventory.luffy.tags;
    };
    gaming-desktop = {
      imports = [
        ./machines/gaming-desktop/default.nix
      ] ++ mkMachineFromTags machinesInventory.gaming-desktop.tags;
    };
  };
}
