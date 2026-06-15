{
  description = "Nix Flake Pirates (NFP) Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
      "https://cache.numtide.com"
      "https://numtide.cachix.org"
      "https://vicinae.cachix.org"
      "https://hyprland.cachix.org"
      "https://niri.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "numtide.cachix.org-1:vSxzZPSh9OCpqJc572Mk9BdbrGMNSbR4F5O4/jVtHK8="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.sops-nix.follows = "sops-nix";
      inputs.disko.follows = "disko";
      inputs.systems.follows = "systems";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
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

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.inputs.treefmt-nix.follows = "clan-core/treefmt-nix";
      inputs.noctalia-qs.inputs.systems.follows = "systems";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wakatime-lsp = {
      url = "github:mrnossiom/wakatime-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.gitignore.follows = "hyprland/pre-commit-hooks/gitignore";
    };
    antigravity = {
      url = "github:Jacopone/Antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    hermes-workspace = {
      url = "path:/tmp/hermes-workspace";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    # Utility inputs defined at top-level to allow follows
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    inputs@{
      clan-core,
      flake-parts,
      home-manager,
      llm-agents,
      niri,
      noctalia,
      spicetify-nix,

      vicinae,
      vicinae-extensions,
      nixai,
      yazelix-hm,
      disko,
      wakatime-lsp,
      antigravity,
      nix-cachyos-kernel,
      hermes-workspace,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        inputs,
        ...
      }:
      {
        imports = [
          clan-core.flakeModules.default
          home-manager.flakeModules.home-manager
          ./layers/00-cyberia/07-clan/clan-inventory.nix
          ./layers/00-cyberia/07-clan/devshell.nix
        ];

        clan = {
          imports = [ ./clan.nix ];
          specialArgs = {
            inherit inputs;
          };
          # Configure nixpkgs to allow unfree packages
          pkgsForSystem =
            system:
            import inputs.nixpkgs {
              localSystem = system;
              config.allowUnfree = true;
              overlays = [
                (import ./layers/80-lib/82-overlays/custom-packages.nix)
                inputs.hermes-workspace.overlays.default
              ];
            };
        };

        # Register clan services
        flake.clan = {
          modules = {
            # Binary cache
            nix-cache = ./layers/20-services/28-clan-services/nix-cache/default.nix;
            # Matrix Synapse
            matrix-synapse = ./layers/20-services/28-clan-services/matrix-synapse/module.nix;
          };
        };

        flake.nfpuRegistry =
          let
            extractMachineConfig =
              name: machine:
              let
                cfg = machine.config;
                layer20Services = cfg.layers.layer-20.services.config or { };
                services = builtins.mapAttrs (sName: sCfg: {
                  enable = sCfg.enable or false;
                }) layer20Services;
              in
              {
                services = services;
                layer10 = cfg.layers.layer-10.system or { };
              };
          in
          builtins.mapAttrs extractMachineConfig inputs.self.nixosConfigurations;

        systems = [ "x86_64-linux" ];

        # flake.homeConfigurations = {
        #   "root@vps" = inputs.home-manager.lib.homeManagerConfiguration {
        #     pkgs = import inputs.nixpkgs {
        #       system = "x86_64-linux";
        #       config.allowUnfree = true;
        #       overlays = [
        #         (import ./layers/80-lib/82-overlays/custom-packages.nix)
                inputs.hermes-workspace.overlays.default
        #       ];
        #     };
        #     extraSpecialArgs = { inherit inputs; };
        #     modules = [
        #       ./layers/50-cli-tui-programs/50-entry/cli-tui.nix
        #       {
        #         home.username = "root";
        #         home.homeDirectory = "/root";
        #         # Standard age key location for NFP users
        #         sops.age.keyFile = "/root/.config/sops/age/keys.txt";
        #         # Enable Yazelix on VPS
        #         programs.cli-environment.headless = true;
        #         programs.cli-environment.theming.theme = "Tokyo Night Moon";
        #         features.home.cli.yazelix.enable = true;
        #       }
        #     ];
        #   };
        # };

        perSystem =
          {
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              localSystem = system;
              config.allowUnfree = true;
              overlays = [
              ];
            };
            packages.iso =
              (inputs.nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs; };
                modules = [
                  ./layers/00-cyberia/04-templates/iso/default.nix
                ];
              }).config.system.build.isoImage;

            formatter = pkgs.nixfmt-tree;

            checks =
              let
                theme-tests = import ./layers/00-cyberia/05-tests/themes.nix {
                  inherit pkgs;
                  lib = pkgs.lib;
                };
              in
              {
                inherit (theme-tests) plymouth-theme-builds sddm-theme-builds all-themes;

                services-test = pkgs.testers.nixosTest (import ./layers/00-cyberia/05-tests/services.nix);
                n8n-test = pkgs.testers.nixosTest (import ./layers/00-cyberia/05-tests/n8n.nix);
              };
          };
      }
    );
}
