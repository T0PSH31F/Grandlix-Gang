# n8n Workflow Analyzer Implementation Plan (Phase 2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the "Juggler" analyzer to categorize and score 21,358 workflows using a rotation of AI providers (Gemini, Groq, OpenRouter, Ollama).

**Architecture:** A Python script with a `ProviderManager` that cycles through API keys. It handles rate limits (429) by switching to the next available provider and retrying. Results are saved to the existing `n8n_analysis.db`.

**Tech Stack:** Python 3.11, `httpx`, `tqdm`, SQLite3.

---

### Task 1: Provider Manager Implementation

**Files:**
- Create: `analyzer_utils.py`

- [ ] **Step 1: Define Provider classes**
Create base classes for different providers (Gemini, Groq, OpenRouter, Ollama) to handle their specific API formats.

- [ ] **Step 2: Implement Juggler Logic**
Create a `ProviderManager` that maintains the rotation and cooldown states.

### Task 2: Analyzer Script Implementation

**Files:**
- Create: `analyze.py`

- [ ] **Step 1: Write the main analyzer loop**
Implement the loop that reads from the DB (workflows where `processed_at` is null or analysis is missing), calls the `ProviderManager`, and updates the record.

- [ ] **Step 2: Define the AI Prompt**
Include the specific scoring rubric: Security, Plug & Play, Marketability, and Value Score.

### Task 3: Testing & Scaling

- [ ] **Step 1: Run a test batch of 10**
Verify that it can switch from Gemini to Groq/OpenRouter on failure.

- [ ] **Step 2: Implement Multi-processing (Optional)**
If speed is too slow, wrap the loop in `concurrent.futures.ThreadPoolExecutor`.

### Task 4: Committing Progress

- [ ] **Step 1: Commit Phase 2 scripts**
```bash
git add analyzer_utils.py analyze.py
git commit -m "feat: implement multi-provider AI analyzer"
```
