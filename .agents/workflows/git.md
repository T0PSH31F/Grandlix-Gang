---
description: Run git add, commit, pull, and push to sync with remote main branch.
---

// turbo-all

# Git Sync Workflow

When the user invokes this workflow via the `/git` command, you must execute the following steps in order to stage, commit, and sync the local repository to the remote `main` branch. 

Since this workflow has the `// turbo-all` annotation, you MUST auto-run all commands by setting `SafeToAutoRun: true` in your `run_command` tool calls.

## Step 1: Check Status and Stage Changes
First, check the status of the repository to understand what has changed, and then stage all changes. You can run these together.
Command: `git status && git add .`

## Step 2: Commit Changes
Determine a concise and descriptive commit message. If the user provided a commit message along with the command (e.g., `/git added the new matrix configuration`), use it. If not, generate a suitable commit message based on the recent changes you made or the context of the conversation.
Command: `git commit -m "<your_commit_message>"`

## Step 3: Sync and Push to Remote
Pull the latest changes from the remote `main` branch using rebase to prevent merge conflicts and keep a clean history. Then, push the local changes to the remote repository.
Command: `git pull --rebase origin main && git push origin main`

## Step 4: Report
Let the user know that the repository has been successfully committed and pushed to `main`, summarizing the commit message used.
