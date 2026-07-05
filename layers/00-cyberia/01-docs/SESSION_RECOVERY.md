# Session Recovery and State Persistence

This document describes how to persist and recover the state of our AI-assisted workflow within the NFP flake.

## 1. Session State File

We use `~/Clan/NFP/session-state.json` as the canonical session state file.

## 2. State Structure

```json
{
  "taskId": null,
  "backgroundJobs": [],
  "currentContext": [],
  "lastModified": null
}
```

## 3. State Management Protocol

### 3.1. Creating/Updating State
- When starting a new task, record the `taskId` and relevant context in `currentContext`.
- When launching background jobs, add them to `backgroundJobs`.
- When completing a task, update `lastModified` to the current timestamp.

### 3.2. Loading State
- At the start of a session, the user should provide the content of `session-state.json` to the AI.
- The AI should parse this file and resume work accordingly.

### 3.3. Persistence Through Flake
- The `session-state.json` file is managed by the user's workflow.
- It can be added to Home Manager configuration for automatic backup/restore.
- It can be included in git tracking for version history.

## 4. Integration with NFP Flake

### 4.1. Documentation
- Add this document to `layers/00-cyberia/01-docs/SESSION_RECOVERY.md`.
- Update `AGENT_ONBOARDING.md` to reference this document.

### 4.2. Home Manager Integration (Optional)
- Create a Home Manager module to manage this file as a managedHomeFile.
- This would allow the file to be backed up and restored automatically.

## 5. Usage Example

```bash
# To save state
echo '{
  "taskId": "current-task-123",
  "backgroundJobs": [],
  "currentContext": ["file1.txt", "task.md"],
  "lastModified": "2026-07-01T12:00:00Z"
}' > session-state.json

# To load state
cat session-state.json
```

## 6. Recovery Workflow

1. Read `session-state.json` to understand current task IDs and context.
2. Resume work based on the saved state.
3. Update the state file after each significant operation.