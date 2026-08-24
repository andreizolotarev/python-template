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
