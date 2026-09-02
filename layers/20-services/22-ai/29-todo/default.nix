# layers/20-services/22-ai/29-todo/default.nix
# Stub option definition for the To-Do system (layers.layer-20.services.todo-system).
# The full implementation (rofi + systemd units) lives in
#   layers/40-desktop/48-rofi/todo-system.nix
# This module exists so the option is defined on all hosts (including headless
# servers) without pulling in 40-desktop.
{
  lib,
  ...
}:
{
  # Default=true matches the original definition in todo-system.nix.
  # Set to false on servers (e.g. in machines/<host>/default.nix) to suppress.
  options.layers.layer-20.services.todo-system = {
    enable = lib.mkEnableOption "Rofi + Hermes To-Do system" // {
      default = true;
    };
  };
}
