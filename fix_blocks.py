import os

files = [
    'machines/nami/default.nix',
    'machines/z0r0/default.nix',
    'layers/90-profiles/tags/workstation.nix',
    'layers/90-profiles/tags/development.nix',
    'layers/90-profiles/tags/desktop.nix',
    'layers/80-lib/84-templates/machine/default.nix'
]

mapping = {
    'system': 'layer-10.system',
    'services': 'layer-20.services',
    'identity': 'layer-30.identity',
    'desktop': 'layer-40.desktop',
    'cli': 'layer-50.cli',
    'gui': 'layer-60.gui',
    'agent': 'layer-70.agent'
}

for file in files:
    if not os.path.exists(file):
        continue
    with open(file, 'r') as f:
        content = f.read()
    
    # Simple replacement if it's "features = {" -> "layers = {"
    # AND replacing the top-level keys inside the block
    content = content.replace("features = {", "layers = {")
    for k, v in mapping.items():
        # Replace top level `  system = {` with `  layer-10.system = {`
        # But handle indentation. usually 4 spaces if features was 2.
        # So "    system =" -> "    layer-10.system ="
        content = content.replace(f"    {k} =", f"    {v} =")
        content = content.replace(f"    {k}.enable", f"    {v}.enable")
        # For nested dot notation like `desktop.frameworks`
        content = content.replace(f"    {k}.", f"    {v}.")
        content = content.replace(f"  {k} =", f"  {v} =")
        
    with open(file, 'w') as f:
        f.write(content)
    print(f"Updated {file}")
