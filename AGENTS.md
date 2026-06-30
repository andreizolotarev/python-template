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
