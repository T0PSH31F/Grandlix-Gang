# layers/70-agents/79-skills/todo-system.nix
# Option definition for the To-Do system (layers.layer-79.skills.todo-system).
# The full implementation (rofi + systemd units) lives in
#   layers/40-desktop/48-rofi/todo-system.nix
# This module exists so the option is defined on all hosts (including headless
# servers) without pulling in 40-desktop.
{
  lib,
  ...
}:
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "layers" "layer-20" "services" "todo-system" "enable" ]
      [ "layers" "layer-79" "skills" "todo-system" "enable" ]
    )
  ];

  options.layers.layer-79.skills.todo-system = {
    enable = lib.mkEnableOption "Rofi + Hermes To-Do system" // {
      default = true;
    };
  };
}
