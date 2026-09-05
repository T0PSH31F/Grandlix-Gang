# Desktop Experiences — selector + experience adapters
# Direct imports (not via mkDendriticTree) because the selector defines
# options.layers.desktop.* which sits outside the layer-XX namespace.
{
  imports = [
    ./43.0-selector.nix
    ./43.1-noctalia-hyprland/default.nix
  ];
}
