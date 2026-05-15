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
        "media"
      ];
      deploy.targetHost = "root@100.95.168.90";
    };

    luffy = {
      tags = [
        "workstation"
        "desktop"
        "gaming"
        "server"
        "homelab"
        "cache-server"
        "ai-server"
        "development"
        "media"
      ];
      deploy.targetHost = "root@100.80.146.120";
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
      zerotier = {
        module = {
          name = "zerotier";
          input = "clan-core";
        };
        roles.peer.machines = {
          luffy = { };
          z0r0 = { };
        };
      };

      wireguard = {
        module = {
          name = "wireguard";
          input = "clan-core";
        };
        roles.peer.machines = {
          luffy = { };
          z0r0 = { };
        };
      };

      nix-cache = {
        module = {
          name = "nix-cache";
          input = "self";
        };
        roles.server.machines.luffy = { };
        roles.client.machines.z0r0 = { };
      };

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
      ]
      ++ mkMachineFromTags machinesInventory.z0r0.tags;
    };

    luffy = {
      imports = [
        ./machines/luffy/default.nix
      ]
      ++ mkMachineFromTags machinesInventory.luffy.tags;
      clan.services.ai.sillytavern.enable = true;
    };

  };
}
