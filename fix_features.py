import os
import re

mapping = {
    'features.system': 'layers.layer-10.system',
    'features.services': 'layers.layer-20.services',
    'features.identity': 'layers.layer-30.identity',
    'features.desktop': 'layers.layer-40.desktop',
    'features.cli': 'layers.layer-50.cli',
    'features.home.cli': 'layers.layer-50.home.cli',
    'features.gui': 'layers.layer-60.gui',
    'features.agent': 'layers.layer-70.agent',
    'features.home.agent': 'layers.layer-70.home.agent',
}

def replace_in_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content
    for old, new in mapping.items():
        # Match 'features.XXX' but also 'config.features.XXX' and 'options.features.XXX'
        content = re.sub(r'\b' + re.escape(old) + r'\b', new, content)

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

def main():
    for root, dirs, files in os.walk('layers'):
        for file in files:
            if file.endswith('.nix') or file.endswith('.md'):
                replace_in_file(os.path.join(root, file))
    
    for root, dirs, files in os.walk('machines'):
        for file in files:
            if file.endswith('.nix') or file.endswith('.md'):
                replace_in_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
