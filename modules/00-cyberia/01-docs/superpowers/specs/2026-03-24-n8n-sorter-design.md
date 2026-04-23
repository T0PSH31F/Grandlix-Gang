# Design Spec: n8n Workflow Sorting and Analysis System

## Overview
A high-volume data engineering and AI analysis pipeline designed to process ~30,000 n8n workflow JSON files. The system optimizes for token cost, handles rate limits via multi-provider juggling, and physical triage of malformed data.

## 1. Objectives
*   **Cleaning:** Strip bulky UI metadata from n8n JSONs to reduce token usage by ~90%.
*   **Analysis:** Categorize and score workflows based on complexity, value, and target audience.
*   **Resilience:** Failover between multiple AI providers (Gemini, Groq, OpenRouter, Ollama) to bypass rate limits.
*   **Triage:** Physically move malformed files to a skip folder for manual inspection.

## 2. Architecture

### Directory Structure
*   `workflows/`: Source directory (recursive search).
*   `cleaned_workflows/`: Stripped logic-only snapshots.
*   `skipped_workflows/`: Malformed or invalid source files.
*   `n8n_analysis.db`: SQLite database for results.

### Provider Rotation (The Juggler)
1.  **Gemini 1.5 Flash:** Primary (Fastest, High context).
2.  **Groq (Llama 3):** Secondary (Extremely fast free tier).
3.  **OpenRouter:** Tertiary (Broad model access).
4.  **Ollama (Local):** Final Fallback (No rate limits, hardware dependent).

## 3. Data Flow

### Phase 1: The Stripper (`clean.py`)
*   **Input:** Raw n8n JSON.
*   **Operations:** 
    *   Extract `name`.
    *   Iterate `nodes`, keeping only `name`, `type`, and `parameters`.
    *   Remove `id`, `position`, `typeVersion`, `credentials`, `meta`, and `connections`.
*   **Output:** Compact JSON in `cleaned_workflows/`.

### Phase 2: The Analyzer (`analyze.py`)
*   **Database Schema:**
    ```sql
    CREATE TABLE workflows (
        id INTEGER PRIMARY KEY,
        filename TEXT UNIQUE,
        name TEXT,
        summary TEXT,
        category TEXT,
        complexity INTEGER,
        value_score INTEGER,
        target_audience TEXT,
        provider TEXT
    );
    ```
*   **Logic:**
    *   Read from `cleaned_workflows/`.
    *   Skip if `filename` exists in DB.
    *   Request structured JSON output from current Provider.
    *   On 429 (Rate Limit): Switch provider and retry.
    *   Commit results immediately to ensure progress is saved.

## 4. Implementation Details
*   **Language:** Python 3.11+.
*   **Libraries:** `httpx` (async-ready requests), `tqdm` (progress tracking), `sqlite3`.
*   **Environment:** Managed via `devenv.nix` in `~/Projects/n8n-sorting-nix`.

## 5. Success Criteria
*   Zero system crashes during 30k file run.
*   Physical isolation of all non-parseable files.
*   Queryable database of "High Value" (Score > 8) workflows.
