{
  config,
  lib,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
in
{
  home = lib.mkIf (cfg.enable && cfg.shells.bash.enable) {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        if [ -n "$IN_NIX_SHELL" ]; then
          export PS1="[nix-shell] $PS1"
        fi

        if command -v starship >/dev/null 2>&1; then
          # Sync and apply Noctalia theme palette to Starship config
          PALETTE_FILE=""
          if [ -f "$HOME/.cache/noctalia/starship-palette.toml" ]; then
            PALETTE_FILE="$HOME/.cache/noctalia/starship-palette.toml"
          elif [ -f "$HOME/.config/noctalia/templates/starship.toml" ]; then
            PALETTE_FILE="$HOME/.config/noctalia/templates/starship.toml"
          fi

          if [ ! -f "$HOME/.cache/starship/starship.toml" ] || \
             [ "$HOME/.config/starship.toml" -nt "$HOME/.cache/starship/starship.toml" ] || \
             ( [ -n "$PALETTE_FILE" ] && [ "$PALETTE_FILE" -nt "$HOME/.cache/starship/starship.toml" ] ) || \
             ! grep -q "NOCTALIA STARSHIP PALETTE" "$HOME/.cache/starship/starship.toml" 2>/dev/null; then
            mkdir -p "$HOME/.cache/starship"
            cp "$HOME/.config/starship.toml" "$HOME/.cache/starship/starship.toml"
            if [ -n "$PALETTE_FILE" ]; then
              sed -i -E 's/^([[:space:]]*)palette([[:space:]]*)=.*/\1palette\2= "noctalia"/' "$HOME/.cache/starship/starship.toml" 2>/dev/null || sed -i '1i palette = "noctalia"' "$HOME/.cache/starship/starship.toml"
              echo -e "\n# >>> NOCTALIA STARSHIP PALETTE >>>" >> "$HOME/.cache/starship/starship.toml"
              cat "$PALETTE_FILE" >> "$HOME/.cache/starship/starship.toml"
              echo "# <<< NOCTALIA STARSHIP PALETTE <<<" >> "$HOME/.cache/starship/starship.toml"
            fi
          fi
          eval "$(starship init bash)"
        fi
      '';
    };
  };
}
