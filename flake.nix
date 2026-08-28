{
  description = "Nix Flake Pirates (NFP) Configuration";

  inputs = {
    # ── Core Flake Tools & Clan ──────────────────────────────────
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.sops-nix.follows = "sops-nix";
      inputs.disko.follows = "disko";
      inputs.systems.follows = "systems";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix.follows = "clan-core/treefmt-nix";

    # ── Desktop & UI Runtimes ───────────────────────────────────
    dsh-nix = {
      url = "github:Samuka007/dsh-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.vicinae.follows = "vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "hyprland/pre-commit-hooks/flake-compat";
      inputs.systems.follows = "systems";
    };
    yazelix-cursors = {
      url = "github:luccahuguet/yazelix-cursors";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelix-hm = {
      url = "github:luccahuguet/yazelix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.beads.inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixgl.inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixgl.inputs.flake-utils.follows = "flake-utils";
      inputs.zjstatus.inputs.flake-utils.follows = "flake-utils";
      inputs.zjstatus.inputs.rust-overlay.follows = "wakatime-lsp/rust-overlay";
      inputs.yazelixZellijPaneOrchestrator.inputs.flake-utils.follows = "flake-utils";
      inputs.yazelixZellijPopup.inputs.flake-utils.follows = "flake-utils";
    };
    yazelix-screen = {
      url = "github:luccahuguet/yazelix-screen";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── AI & Agents ────────────────────────────────────────────
    antigravity = {
      url = "github:Jacopone/Antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    camoufox-nix = {
      url = "github:maximoffua/camoufox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-webui = {
      url = "github:nesquena/hermes-webui/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "clan-core/treefmt-nix";
      inputs.systems.follows = "systems";
    };
    nixai = {
      url = "github:olafkfreund/nix-ai-help";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixpkgs-ai.url = "github:NixOS/nixpkgs/9c4c05a947a91dc14625265fab505fb695e93218";
    polyfloor = {
      url = "github:T0PSH31F/Polyfloor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };

    # ── Services & Utilities ───────────────────────────────────
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wakatime-lsp = {
      url = "github:mrnossiom/wakatime-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.gitignore.follows = "hyprland/pre-commit-hooks/gitignore";
    };
  };

  outputs =
    inputs@{
      clan-core,
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          clan-core.flakeModules.default
          home-manager.flakeModules.home-manager
          inputs.treefmt-nix.flakeModule
          ./flake/formatter.nix
          ./flake/checks.nix
          ./flake/packages.nix
          ./layers/00-cyberia/07-clan/clan-inventory.nix
          ./layers/00-cyberia/07-clan/devshell.nix
          ./layers/00-cyberia/07-clan/git-hooks.nix
        ];

        clan = {
          imports = [ ./clan.nix ];
          specialArgs = {
            inherit inputs;
            inherit (import ./layers/80-lib/81-helpers/mkDendriticModule.nix { inherit (inputs.nixpkgs) lib; })
              mkDendriticModule
              ;
            inherit (import ./layers/80-lib/81-helpers/mkDendriticTree.nix { inherit (inputs.nixpkgs) lib; })
              mkDendriticTree
              ;
          };
          pkgsForSystem =
            system:
            import inputs.nixpkgs {
              localSystem = system;
              config.allowUnfree = true;
            };
        };

        flake.clan = {
          modules = {
            nix-cache = ./layers/20-services/28-clan-services/nix-cache/default.nix;
            matrix-synapse = ./layers/20-services/28-clan-services/matrix-synapse/module.nix;
          };
        };

        flake.nfpuRegistry =
          let
            extractMachineConfig =
              _name: machine:
              let
                cfg = machine.config;
                layer20Services = cfg.layers.layer-20.services.config or { };
                services = builtins.mapAttrs (_sName: sCfg: {
                  enable = sCfg.enable or false;
                }) layer20Services;
              in
              {
                inherit services;
                layer10 = cfg.layers.layer-10.system or { };
              };
          in
          builtins.mapAttrs extractMachineConfig inputs.self.nixosConfigurations;

        systems = [ "x86_64-linux" ];
      }
    );
}
