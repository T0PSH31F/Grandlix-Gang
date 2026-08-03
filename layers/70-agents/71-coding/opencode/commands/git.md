# Git Ship Command

Full git workflow: stage, commit, push, and merge to main.

Usage: /git [optional commit message]

Steps:
1. `git status` and `git diff` — review what changed
2. `git add -A` — stage all changes (or add specific files if the user named them)
3. Write a concise, conventional commit message (type: subject) from the diff — use the user's message if they provided one
4. `git commit` with that message
5. `git push` to the current branch
6. If not on `main`: switch to `main`, `git merge` the feature branch, `git push origin main`, then switch back

Rules:
- NEVER commit secrets, .env files, or sops-encrypted content paths
- If merge conflicts arise, stop and report them — do not force
- Keep the commit message under 72 chars for the subject line
- Report the final state: branch, commit hash, and whether main was updated
