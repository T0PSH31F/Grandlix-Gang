# n8n Workflow Sorter Implementation Plan (Phase 1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean and triage ~30,000 n8n workflow JSON files into a structured SQLite database for future AI analysis.

**Architecture:** A two-stage pipeline. Stage 1 (Python) recursively finds all n8n JSONs, strips UI metadata, extracts hard metrics (node counts), and moves malformed files to a triage folder. Stage 2 (SQLite) stores the cleaned logic and extracted stats.

**Tech Stack:** Python 3.11, SQLite3, `httpx`, `tqdm`, `devenv`.

---

### Task 1: Environment & Directory Setup

**Files:**
- Modify: `~/Projects/n8n-sorting-nix/devenv.nix`
- Create: `~/Projects/n8n-sorting-nix/cleaned_workflows/.gitkeep`
- Create: `~/Projects/n8n-sorting-nix/skipped_workflows/.gitkeep`

- [ ] **Step 1: Update devenv.nix**
Ensure the environment has all necessary Python packages and tools.
```nix
{ pkgs, ... }: {
  languages.python = {
    enable = true;
    venv.enable = true;
    libraries = with pkgs.python311Packages; [ 
      httpx 
      tqdm 
      pydantic 
    ];
  };
  packages = [ pkgs.jq pkgs.sqlite ];
}
```

- [ ] **Step 2: Initialize directories**
```bash
cd ~/Projects/n8n-sorting-nix
mkdir -p cleaned_workflows skipped_workflows
touch cleaned_workflows/.gitkeep skipped_workflows/.gitkeep
```

- [ ] **Step 3: Activate environment**
Run `direnv allow` or `devenv shell`.

### Task 2: Database Schema Implementation

**Files:**
- Create: `~/Projects/n8n-sorting-nix/db.py`

- [ ] **Step 1: Write db.py**
```python
import sqlite3
import os

DB_PATH = "n8n_analysis.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    curr = conn.cursor()
    curr.execute('''
        CREATE TABLE IF NOT EXISTS workflows (
            id INTEGER PRIMARY KEY,
            filename TEXT UNIQUE,
            original_path TEXT,
            name TEXT,
            node_count INTEGER,
            trigger_count INTEGER,
            has_credentials BOOLEAN,
            node_types TEXT,
            cleaned_content TEXT,
            summary TEXT,
            category TEXT,
            complexity INTEGER,
            value_score INTEGER,
            target_audience TEXT,
            provider TEXT,
            processed_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    # Index for fast lookup during multi-provider analysis
    curr.execute('CREATE INDEX IF NOT EXISTS idx_filename ON workflows(filename)')
    conn.commit()
    conn.close()
    print(f"Database initialized at {DB_PATH}")

if __name__ == "__main__":
    init_db()
```

- [ ] **Step 2: Run db.py**
Run: `python db.py`
Expected: `n8n_analysis.db` created with correct schema.

### Task 3: Cleaning & Metrics Extraction Script

**Files:**
- Create: `~/Projects/n8n-sorting-nix/clean.py`

- [ ] **Step 1: Write clean.py**
Implement logic to strip coordinates, credentials, and IDs, while extracting metrics.
```python
import json
import os
import shutil
import sqlite3
from pathlib import Path
from tqdm import tqdm

SOURCE_DIR = Path("workflows")
CLEANED_DIR = Path("cleaned_workflows")
SKIPPED_DIR = Path("skipped_workflows")
DB_PATH = "n8n_analysis.db"

def clean_workflow(data):
    nodes = []
    node_types = set()
    trigger_count = 0
    has_creds = False

    for node in data.get('nodes', []):
        ntype = node.get("type", "unknown")
        node_types.add(ntype)
        
        # Check for triggers
        if "trigger" in ntype.lower() or node.get("webhookId"):
            trigger_count += 1
        
        # Check for credentials
        if node.get("credentials"):
            has_creds = True

        nodes.append({
            "name": node.get("name"),
            "type": ntype,
            "params": node.get("parameters", {})
        })
    
    cleaned = {
        "name": data.get("name", "Unnamed Workflow"),
        "nodes": nodes
    }
    
    metrics = {
        "node_count": len(nodes),
        "trigger_count": trigger_count,
        "has_credentials": has_creds,
        "node_types": ", ".join(sorted(list(node_types)))
    }
    
    return cleaned, metrics

def process():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    all_files = list(SOURCE_DIR.rglob("*.json"))
    print(f"Found {len(all_files)} workflows to process.")

    for p in tqdm(all_files):
        try:
            with open(p, 'r') as f:
                data = json.load(f)
            
            if not data.get('nodes'):
                shutil.move(str(p), SKIPPED_DIR / p.name)
                continue

            cleaned, metrics = clean_workflow(data)
            
            # Save cleaned JSON
            cleaned_file = CLEANED_DIR / p.name
            with open(cleaned_file, 'w') as f:
                json.dump(cleaned, f)

            # Insert into DB (Stage 1 data)
            cursor.execute('''
                INSERT OR IGNORE INTO workflows 
                (filename, original_path, name, node_count, trigger_count, has_credentials, node_types, cleaned_content)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (p.name, str(p), cleaned['name'], metrics['node_count'], 
                  metrics['trigger_count'], metrics['has_credentials'], 
                  metrics['node_types'], json.dumps(cleaned)))
            
        except Exception as e:
            # Physical triage of malformed files
            try:
                shutil.move(str(p), SKIPPED_DIR / p.name)
            except:
                pass
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    os.makedirs(CLEANED_DIR, exist_ok=True)
    os.makedirs(SKIPPED_DIR, exist_ok=True)
    process()
```

- [ ] **Step 2: Run a small test**
Point `SOURCE_DIR` to a test folder with 5-10 files.
Run: `python clean.py`
Verify `cleaned_workflows/` contains compact JSON and `n8n_analysis.db` has the metrics.

- [ ] **Step 3: Run full cleaning pass**
Run: `python clean.py`
Expected: Progress bar finishes, `skipped_workflows/` contains any bad files.

### Task 4: Committing Progress

- [ ] **Step 1: Commit scripts**
```bash
git add devenv.nix db.py clean.py
git commit -m "feat: implement n8n cleaning and db setup scripts"
```
