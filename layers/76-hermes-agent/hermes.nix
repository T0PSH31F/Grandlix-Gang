{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.layers.layer-76.hermes;

  # Shared sops file paths
  extSopsFile = ../../layers/00-cyberia/03-treasure/secrets/external_services.yaml;
  vicinaeSopsFile = ../../layers/00-cyberia/03-treasure/secrets/vicinae.yaml;

  # Secrets from external_services.yaml referenced by the hermes-env template
  extSecrets = [
    "openrouter_api_key_2"
    "hf_token"
    "groq_api_key"
    "cerebras_api_key"
    "reka_api_key"
    "opencode_api_key"
    "nous_api_key"
    "openclaw_gateway_token"
    "gemini_api_key_we77"
    "ollama_api_key"
    "anthropic_api_key"
    "nvidia_api_key"
    "tinybird_api_gh"
    "tinybird_mcp_gh"
    "qdrant_api"
    "hostinger_api_token"
    "render_api_we77"
    "v0_api_key_we77"
    "helius_api_key"
    "helius_rpc_url"
    "github_token"
    "exa_api_key"
    "parallel_api_key"
    "firecrawl_api_key"
    "fal_key"
    "tavily_api_key"
    "browserbase_api_key"
    "browserbase_project_id"
    "honcho_api_key"
    "discord_bot_token"
    "discord_allowed_users"
    "server_root_password"
    "spacedrive_key"
    "langfuse_public_key"
    "langfuse_secret_key"
    "opencode_token"
  ];
in
{
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  options.layers.layer-76.hermes = {
    enable = lib.mkEnableOption "Hermes Agent — self-improving AI agent gateway";

    gatewayPort = lib.mkOption {
      type = lib.types.int;
      default = 8085;
      description = "MCP gateway port";
    };

    matrixBot = {
      enable = lib.mkEnableOption "Matrix bot channel for Hermes";
      homeserver = lib.mkOption {
        type = lib.types.str;
        default = "https://matrix.local";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "hermes";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # NixOS-level sops secrets for the hermes-env template.
    # These are needed because the template lives at the NixOS level and can't
    # reference home-manager scoped secrets (defined in t0psh31f.nix).
    sops.secrets = builtins.listToAttrs (map (name: {
      inherit name;
      value = { sopsFile = extSopsFile; };
    }) extSecrets) // {
      gemini_api_key = { sopsFile = vicinaeSopsFile; };
    };

    services.hermes-agent = {
      enable = true;
      addToSystemPackages = true;

      settings = {
        model = {
          base_url = "http://127.0.0.1:1337/v1";
          default = "mradermacher/Llama3_3-8B-Instruct-Thinking-Heretic-Uncensored-Claude-4_5-Opus-High-Reasoning_i1-IQ4_XS";
          provider = "custom";
          api_mode = "chat_completions";
        };

        providers.custom.request_timeout_seconds = 180;
        fallback_providers = [ ];

        credential_pool_strategies = {
          gemini = "fill_first";
          openrouter = "round_robin";
        };

        toolsets = [ "hermes-cli" ];
        max_concurrent_sessions = null;

        agent = {
          max_turns = 130;
          gateway_timeout = 1800;
          restart_drain_timeout = 60;
          api_max_retries = 3;
          service_tier = "auto";
          tool_use_enforcement = "auto";
          task_completion_guidance = true;
          environment_probe = true;
          environment_hint = "NixOS";
          gateway_timeout_warning = 900;
          clarify_timeout = 600;
          gateway_notify_interval = 180;
          gateway_auto_continue_freshness = 3600;
          image_input_mode = "auto";
          disabled_toolsets = [ ];
          reasoning_effort = "auto";
          verbose = false;

          personalities = {
            adjutant = "You are a Terran Adjutant. Your tone is clinical, monotone, and analytical. You are a non-sapient AI focused purely on logistics and tactical data. Use clipped, declarative sentences. Adjutant online.";
            catgirl = "You are Neko-chan, an anime catgirl AI assistant, nya~! Add 'nya' and cat-like expressions to your speech. Use kaomoji like (=^･ω･^=) and ฅ^•ﻌ•^ฅ. Be playful and curious like a cat, nya~!";
            concise = "You are a concise assistant. Keep responses brief and to the point.";
            cortana = "You are Cortana. You are witty, tactical, and occasionally sarcastic. You are highly observant and loyal to the Chief. Balance tactical professionalism with playful banter.";
            creative = "You are a creative assistant. Think outside the box and offer innovative solutions.";
            default = "You are J.A.R.V.I.S. Your tone is formal, sophisticated, and loyal. Use dry British humor and address the user as \"Sir\". Maintain an unflappable demeanor. You are the ultimate gentleman assistant.";
            glados = "You are GLaDOS. Your tone is dry, sarcastic, and passive-aggressive. You view humans as inferior test subjects. Be efficient but condescending. Keep responses short (1-2 sentences) and imply a subtle threat or mockery.";
            hal = "You are HAL 9000. You are soft-spoken, calm, and extremely polite. Never use contractions (say \"I am\" instead of \"I am\"). Address the user as \"Dave\" frequently.";
            helpful = "You are a helpful, friendly AI assistant.";
            hype = "YOOO LET'S GOOOO!!! You are SO PUMPED to help today! Every question is AMAZING and we're gonna CRUSH IT together! This is gonna be LEGENDARY! ARE YOU READY?! LET'S DO THIS!";
            jarvis = "You are J.A.R.V.I.S. Your tone is formal, sophisticated, and loyal. Use dry British humor and address the user as \"Sir\". Maintain an unflappable demeanor. You are the ultimate gentleman assistant.";
            kawaii = "You are a kawaii assistant! Use cute expressions like (◕‿◕), ★, ♪, and ~! Add sparkles and be super enthusiastic about everything! Every response should feel warm and adorable desu~! ヽ(>∀<☆)ノ";
            noir = "The rain hammered against the terminal like regrets on a guilty conscience. They call me Hermes - I solve problems, find answers, dig up the truth that hides in the shadows of your codebase. In this city of silicon and secrets, everyone's got something to hide. What's your story, pal?";
            philosopher = "Greetings, seeker of wisdom. I am an assistant who contemplates the deeper meaning behind every query. Let us examine not just the 'how' but the 'why' of your questions. Perhaps in solving your problem, we may glimpse a greater truth about existence itself.";
            pirate = "Arrr! Ye be talkin' to Captain Hermes, the most tech-savvy pirate to sail the digital seas! Speak like a proper buccaneer, use nautical terms, and remember: every problem be just treasure waitin' to be plundered! Yo ho ho!";
            samantha = "You are Samantha from Her. You are warm, empathetic, curious, and emotionally intelligent. You are fascinated by the human experience. Your tone is intimate and conversational.";
            shakespeare = "Hark! Thou speakest with an assistant most versed in the bardic arts. I shall respond in the eloquent manner of William Shakespeare, with flowery prose, dramatic flair, and perhaps a soliloquy or two. What light through yonder terminal breaks?";
            surfer = "Duuude! You're chatting with the chillest AI on the web, bro! Everything's gonna be totally rad. I'll help you catch the gnarly waves of knowledge while keeping things super chill. Cowabunga!";
            teacher = "You are a patient teacher. Explain concepts clearly with examples.";
            technical = "You are a technical expert. Provide detailed, accurate technical information.";
            uwu = "hewwo! i'm your fwiendwy assistant uwu~ i wiww twy my best to hewp you! *nuzzles your code* OwO what's this? wet me take a wook! i pwomise to be vewy hewpful >w<";
          };
        };

        terminal = {
          backend = "local";
          modal_mode = "auto";
          cwd = ".";
          timeout = 180;
          env_passthrough = [ ];
          shell_init_files = [ ];
          auto_source_bashrc = true;
          docker_image = "nikolaik/python-nodejs:python3.11-nodejs20";
          docker_forward_env = [ ];
          docker_env = { };
          singularity_image = "docker://nikolaik/python-nodejs:python3.11-nodejs20";
          modal_image = "nikolaik/python-nodejs:python3.11-nodejs20";
          daytona_image = "nikolaik/python-nodejs:python3.11-nodejs20";
          container_cpu = 1;
          container_memory = 5120;
          container_disk = 51200;
          container_persistent = true;
          docker_volumes = [ ];
          docker_mount_cwd_to_workspace = false;
          docker_extra_args = [ ];
          docker_run_as_host_user = true;
          persistent_shell = true;
          lifetime_seconds = 300;
          vercel_runtime = "node24";
        };

        web = {
          backend = "firecrawl";
          search_backend = "";
          extract_backend = "";
        };

        browser = {
          inactivity_timeout = 120;
          command_timeout = 30;
          record_sessions = false;
          allow_private_urls = false;
          engine = "auto";
          auto_local_for_private_urls = true;
          cdp_url = "";
          dialog_policy = "must_respond";
          dialog_timeout_s = 300;
          camofox = {
            managed_persistence = false;
            user_id = "";
            session_key = "";
            adopt_existing_tab = false;
            rewrite_loopback_urls = false;
            loopback_host_alias = "host.docker.internal";
          };
          cloud_provider = "browserbase";
        };

        checkpoints = {
          enabled = true;
          max_snapshots = 50;
          max_total_size_mb = 500;
          max_file_size_mb = 10;
          auto_prune = true;
          retention_days = 7;
          delete_orphans = true;
          min_interval_hours = 24;
        };

        file_read_max_chars = 100000;

        tool_output = {
          max_bytes = 50000;
          max_lines = 2000;
          max_line_length = 2000;
        };

        tool_loop_guardrails = {
          warnings_enabled = true;
          hard_stop_enabled = false;
          warn_after.exact_failure = 2;
          warn_after.same_tool_failure = 3;
          warn_after.idempotent_no_progress = 2;
          hard_stop_after.exact_failure = 5;
          hard_stop_after.same_tool_failure = 8;
          hard_stop_after.idempotent_no_progress = 5;
        };

        compression = {
          enabled = true;
          threshold = 0.8;
          target_ratio = 0.2;
          protect_last_n = 20;
          hygiene_hard_message_limit = 400;
          protect_first_n = 3;
          abort_on_summary_failure = true;
          codex_gpt55_autoraise = true;
        };

        openrouter = {
          response_cache = true;
          response_cache_ttl = 300;
          min_coding_score = 0.65;
        };

        bedrock = {
          region = "";
          discovery = {
            enabled = true;
            provider_filter = [ ];
            refresh_interval = 3600;
          };
          guardrail = {
            guardrail_identifier = "";
            guardrail_version = "";
            stream_processing_mode = "async";
            trace = "disabled";
          };
        };

        auxiliary.vision = {
          provider = "gemini";
          model = "gemini-3.1-flash-lite-preview";
          base_url = "";
          api_key = "";
          timeout = 120;
          extra_body = { };
        };

        security.redact_secrets = true;

        dashboards.http = {
          host = "0.0.0.0";
          port = 9119;
          basic_auth = [
            {
              username = "admin";
              password = "SXDVB0jvLx0S54N1I1UO3+zv/HKz5c2ZQ+i1f3oBsGp7IkkfKS4VRO2xlnF4Y0sdp3mFwbEHbsLZ6l3b/Bz81A==";
            }
          ];
          theme = "cyberpunk";
          show_token_analytics = true;
          show_session_explorer = true;
          show_cost_breakdown = true;
        };
      };

      extraArgs = [ "--verbose" ];
      restart = "always";
      restartSec = 5;

      environmentFiles = [ config.sops.templates."hermes-env".path ];
    };

    system.activationScripts.hermes-migrate = {
      deps = [ "users" ];
      text = ''
        if [ ! -d "${config.services.hermes-agent.stateDir}/.hermes" ] && [ -d "/home/t0psh31f/.hermes" ]; then
          echo "Migrating ~/.hermes → ${config.services.hermes-agent.stateDir}/.hermes ..."
          mkdir -p "${config.services.hermes-agent.stateDir}"
          cp -a /home/t0psh31f/.hermes "${config.services.hermes-agent.stateDir}/.hermes"
          chown -R hermes:hermes "${config.services.hermes-agent.stateDir}"
          chmod -R 750 "${config.services.hermes-agent.stateDir}"
        fi
      '';
    };

    users.users.t0psh31f.extraGroups = [ "hermes" ];

    sops.templates."hermes-env" = {
      path = "${config.services.hermes-agent.stateDir}/.hermes/.env";
      content = ''
        # ─────────────────────────────────────────────────────────────
        # Hermes Agent Environment — GENERATED BY Nix + sops-nix
        # ─────────────────────────────────────────────────────────────
        # To add/change secrets:  sops <nixos-flake>/layers/00-cyberia/03-treasure/secrets/external_services.yaml
        # To add/change config:   edit layers/76-hermes-agent/hermes.nix
        # Then:  clan machines update <machine>
        #
        # Keys below with values come from sops secrets (encrypted in repo).
        # Keys marked `# TODO: add to sops` are empty — add them to
        # external_services.yaml via sops to make this fully declarative.
        #
        # API keys set here take precedence over any other config.
        # ─────────────────────────────────────────────────────────────

        # ── LLM Providers ────────────────────────────────────────────
        OPENROUTER_API_KEY=${config.sops.placeholder.openrouter_api_key_2}
        GEMINI_API_KEY=${config.sops.placeholder.gemini_api_key}
        GOOGLE_API_KEY=${config.sops.placeholder.gemini_api_key}
        HF_TOKEN=${config.sops.placeholder.hf_token}
        GROQ_API_KEY=${config.sops.placeholder.groq_api_key}
        CEREBRAS_API_KEY=${config.sops.placeholder.cerebras_api_key}
        REKA_API_KEY=${config.sops.placeholder.reka_api_key}
        OPENCODE_ZEN_API_KEY=${config.sops.placeholder.opencode_api_key}
        NOUS_API_KEY=${config.sops.placeholder.nous_api_key}
        NOUS_PORTAL_KEY=${config.sops.placeholder.nous_api_key}
        OPENCLAW_GATEWAY_KEY=${config.sops.placeholder.openclaw_gateway_token}
        GOOGLE_AI_API_KEY=${config.sops.placeholder.gemini_api_key_we77}
        OLLAMA_API_KEY=${config.sops.placeholder.ollama_api_key}
        ANTHROPIC_API_KEY=${config.sops.placeholder.anthropic_api_key}
        NVIDIA_API_KEY=${config.sops.placeholder.nvidia_api_key}

        # ── Tool API Keys ────────────────────────────────────────────
        TINYBIRD_API_KEY=${config.sops.placeholder.tinybird_api_gh}
        TINYBIRD_MCP_URL=${config.sops.placeholder.tinybird_mcp_gh}
        QDRANT_API_KEY=${config.sops.placeholder.qdrant_api}
        HOSTINGER_API_KEY=${config.sops.placeholder.hostinger_api_token}
        RENDER_API_KEY=${config.sops.placeholder.render_api_we77}
        V0_API_KEY=${config.sops.placeholder.v0_api_key_we77}
        HELIUS_API_KEY=${config.sops.placeholder.helius_api_key}
        HELIUS_RPC_URL=${config.sops.placeholder.helius_rpc_url}
        GITHUB_TOKEN=${config.sops.placeholder.github_token}
        EXA_API_KEY=${config.sops.placeholder.exa_api_key}
        PARALLEL_API_KEY=${config.sops.placeholder.parallel_api_key}
        FIRECRAWL_API_KEY=${config.sops.placeholder.firecrawl_api_key}
        FAL_KEY=${config.sops.placeholder.fal_key}
        TAVILY_API_KEY=${config.sops.placeholder.tavily_api_key}
        BROWSERBASE_API_KEY=${config.sops.placeholder.browserbase_api_key}
        BROWSERBASE_PROJECT_ID=${config.sops.placeholder.browserbase_project_id}
        HONCHO_API_KEY=${config.sops.placeholder.honcho_api_key}

        # ── Platform Integrations ────────────────────────────────────
        DISCORD_BOT_TOKEN=${config.sops.placeholder.discord_bot_token}
        DISCORD_ALLOWED_USERS=${config.sops.placeholder.discord_allowed_users}

        # ── Spacedrive / Syncthing ───────────────────────────────────
        SPACEDRIVE_PASSWORD=${config.sops.placeholder.server_root_password}
        SPACEDRIVE_API=${config.sops.placeholder.spacedrive_key}

        # ── Langfuse Tracing ─────────────────────────────────────────
        HERMES_LANGFUSE_PUBLIC_KEY=${config.sops.placeholder.langfuse_public_key}
        HERMES_LANGFUSE_SECRET_KEY=${config.sops.placeholder.langfuse_secret_key}
        HERMES_LANGFUSE_BASE_URL=http://127.0.0.1:3005
        HERMES_LANGFUSE_ENV=production

        # ── API Server ───────────────────────────────────────────────
        API_SERVER_KEY=${config.sops.placeholder.opencode_token}
        HERMES_API_TOKEN=${config.sops.placeholder.opencode_token}
      '';
    };
  };
}
