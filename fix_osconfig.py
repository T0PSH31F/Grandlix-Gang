import os
import re

directory = "layers/40-desktop"
for root, _, files in os.walk(directory):
    for file in files:
        if not file.endswith(".nix"):
            continue
        path = os.path.join(root, file)
        with open(path, "r") as f:
            content = f.read()
        
        # Only process if we find config.features.desktop
        if "config.features.desktop" not in content and "config.desktop" not in content:
            continue
            
        # We only need to fix if osConfig is not in the arguments
        if "osConfig" not in content:
            # Replace { config, lib, pkgs, ... }: with { config, lib, pkgs, osConfig ? config, ... }:
            # We'll just regex for { ... } at the top
            content = re.sub(r'(\{[\s\S]*?config,([\s\S]*?)\.\.\.\s*\}:)', r'{ config, \2 osConfig ? config, ... }:', content)
            
        # Replace config.features.desktop with osConfig.features.desktop
        content = content.replace("config.features.desktop", "osConfig.features.desktop")
        
        with open(path, "w") as f:
            f.write(content)
