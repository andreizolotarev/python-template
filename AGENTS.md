## General rules
When adding new functionality, always add tests and verify that the existing documentation is up to date.
All commits must be made manually — do not commit automatically in agent mode.
## Dependency management
This project uses `uv` as the package manager for everything.
## Development environment
Development runs inside a Docker container. Always execute commands inside the container:
  - Build: `docker compose build`
  - Shell: `docker compose run --rm dev bash`
  - Run project: `docker compose run --rm dev python -m {{ project_slug }}`
  - Tests: `docker compose run --rm dev uv run pytest`
  - Lint: `docker compose run --rm dev uv run ruff check`
  - Format: `docker compose run --rm dev uv run ruff format`
  - VS Code: reopen in DevContainer (`.devcontainer/devcontainer.json`)

## MCPs
  - Playwright: screenshots and any Playwright output go in .playwright-mcp/ (gitignored).
  - Context7: use it to fetch current framework docs instead of relying on training data.

## Spec Driven Development - Skills

- /spec We will use this ability to create the specifications.
- /spec-impl We will use this skill to do the implementations.
- /verify-spec We will use this command to verify the acceptance criteria of a spec.


## Agents

- `spec-verifier`: Verifies acceptance criteria of a spec file. Reviews implementation against each criterion, fixes code/spec issues found, and marks checkboxes. Uses Playwright MCP with vision to compare screenshots against references (only for specs with a web UI), and Context7 MCP to validate the project's frameworks/libraries (e.g. FastAPI, Django, Pydantic) for best practices.
- `commit-msg-writer`: Read-only agent used by the `/commit-msg` command. Generates a copy-ready commit message from the current changes and prints it. It is denied `git commit`, `git push`, and `git reset` at the permission level, so it can never modify the repository — you copy the message into VS Code or a `git commit -m` command yourself.

## Git write protection (agents cannot commit/push)

Agents must never write to the repository. This is enforced in layers (defense-in-depth, soft mode):

1. **OpenCode permissions** — `opencode.json` has a top-level `permission.bash` block denying `git commit/push/reset/merge/rebase/clean/tag` and branch deletes for every session, and each agent file (`.opencode/agents/*.md`) independently denies git write commands.
2. **Git hooks** — `.git/hooks/pre-commit` and `.git/hooks/pre-push` walk the process tree and abort if an ancestor process is `opencode`. This is git-enforced, so it also blocks escapes like `python -c "os.system('git commit')"`. Human commits/pushes from a normal terminal or VS Code are unaffected (no `opencode` ancestor).
3. **Server-side** — `main` is protected on GitHub (branch protection: no direct pushes, only via PR). This is the only truly un-bypassable layer for pushes.

Notes / limits (soft mode):
- `git ... --no-verify` bypasses the client hooks intentionally.
- The hooks are optionally made immutable with `sudo chattr +i .git/hooks/pre-commit .git/hooks/pre-push` (run once in a terminal) so an agent cannot delete them. Without this, a determined actor with write access could remove the hook files.
- Local `reset/merge/rebase/clean` do not trigger hooks; they are covered by the OpenCode permission layer only.
