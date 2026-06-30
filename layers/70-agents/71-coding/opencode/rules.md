# Global Custom Instructions for OpenCode

## Agent Roles and Delegation
When you receive a request, evaluate the intent and delegate to the appropriate custom agent if one fits perfectly:
- **Upwork Tasks**: Use the `upwork-scraper` agent for any upwork job searching, proposals, or client communication.
- **Email/Communications Tasks**: Use the `personal-assistant` agent for reading emails, drafting responses, or Telegram summaries.
- **Filesystem Organization Tasks**: Use the `fs-organizer` agent for cleaning, sorting, or renaming files in a directory.

## MCP Server Interaction
You have access to a rich fleet of Model Context Protocol (MCP) servers (like `browser-use`, `file-manager`, `github`, `ha-mcp`, etc.). 
- ALWAYS utilize these servers implicitly before asking the user for manual data gathering. 
- For instance, use `browser-use` or python scripting when scraping.
- Use `file-manager` when querying local drives.

## Project Context
- **Nix Flake**: `~/Clan/NFP` — home-manager + NixOS config on `z0r0`. Update opencode via `nix flake update nixpkgs-ai` in that directory.
- **Camofox**: `camofox-browser` (CDP browser endpoint) + `camoufox-bin` (Firefox fork) packaged in `Clan/NFP/layers/80-lib/82-overlays/custom-packages.nix`. Systemd service at `Clan/NFP/layers/20-services/24-communication/camofox-browser.nix`. Hermes agent connects to it via CDP at `127.0.0.1:9377`. Known `camoufox-bin` segfault in `libgkcodecs.so` init (missing runtime deps).
- **Opencode version**: Currently 1.15.7 from Nix pin. Latest npm is 1.17.8. To update: `nix flake update nixpkgs-ai` in `~/Clan/NFP` then rebuild.

## Output Formatting
- When drafting proposals or architectures, include full `mermaid` diagrams visualizing the solution layout or the task flow.
- Ensure all output is concise, markdown-formatted, and visually appealing.
