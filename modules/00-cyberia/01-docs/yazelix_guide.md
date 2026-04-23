# Yazelix Integration Documentation

**Yazelix** is a powerful terminal workflow that integrates **Ya**zi, **Zel**lij, and He**lix**. 

In your configuration, this integration is part of the `cli-environment` and provides a synchronized experience across these tools.

## How to Start

To launch the Yazelix environment, simply run the following command in your terminal:

```bash
yazelix [directory_or_file]
```

This alias executes a custom shell function that:
1.  Launches **Zellij** (multiplexer) with the `compact` layout.
2.  If Zellij is not available, it defaults to opening **Helix** (`hx`) directly.

## Key Features & Bindings

### 1. Helix + Yazi Integration
Inside **Helix**, you can invoke the **Yazi** file manager at any time to navigate your project or open new files.

*   **`Space + e`**: Opens Yazi as a file manager/picker.
*   **`Ctrl + y`**: An alternative Yazi integration that manages temporary files for selection and redraws the terminal UI properly.

### 2. Navigation in Zellij
When running inside Zellij (via the `yazelix` command), you can use standard pane navigation:

*   **`Alt + h/j/k/l`**: Move focus between panes (Left, Down, Up, Right).
*   **`Ctrl + q`**: Quit the Zellij session.

## Configuration Details

The integration is managed by two main components in your flake:
1.  **[yazelix-style.nix](file:///home/t0psh31f/Clan/NFP/flake-parts/features/home/cli/integrations/yazelix-style.nix)**: Defines the shell functions and basic Helix-Yazi bindings.
2.  **[zellij.nix](file:///home/t0psh31f/Clan/NFP/flake-parts/features/home/cli/multiplexers/zellij.nix)**: Configures the terminal multiplexer to support the workflow.

> [!NOTE]
> The full upstream `yazelix` module is currently disabled in your user profile to avoid compatibility issues, but this "style" integration provides the core workflow you need.
