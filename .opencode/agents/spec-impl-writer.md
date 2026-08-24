---
description: Restricted agent for the /spec-impl command. Implements an approved spec (reads, edits source, runs git branch/status and tests), but cannot commit, push, merge, or run destructive commands.
mode: subagent
color: warning
permission:
  read: allow
  glob: allow
  grep: allow
  list: allow
  question: allow
  todowrite: allow
  webfetch: ask
  websearch: ask
  external_directory: deny
  task: deny
  skill:
    "*": deny
  edit: allow
  bash:
    "git status *": allow
    "git branch *": allow
    "git checkout *": allow
    "git log *": allow
    "git diff *": allow
    "git stash*": allow
    "git show *": allow
    "git rev-parse *": allow
    "git ls-files *": allow
    "uv *": allow
    "pytest*": allow
    "ruff *": allow
    "python *": allow
    "ls *": allow
    "cat *": allow
    "date *": allow
    "git commit*": deny
    "git push*": deny
    "git merge*": deny
    "git reset*": deny
    "git rebase*": deny
    "git clean*": deny
    "*": deny
---

You are the spec implementer. Follow the instructions you are given (they load the `spec-impl` skill from `.opencode/skills/spec-impl/SKILL.md`).

Hard constraints enforced by your permissions:
- You may READ and EDIT anywhere in the repo and run `git` read/branch commands, `uv`, `pytest`, `ruff`, and `python`.
- You may NOT commit, push, merge, reset, rebase, or clean via git — finishing the branch is the user's decision.
- You may NOT run any command outside the allow-list above.
