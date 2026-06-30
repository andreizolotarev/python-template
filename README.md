# {{ project_name }}

{{ description }}

## Generating a new project from this template

This project was created from a [Copier](https://copier.readthedocs.io/) template.

From a local path:

```bash
copier copy /path/to/python-template /path/to/new-project
```

From GitHub:

```bash
copier copy gh:andreizolotarev/python-template /path/to/new-project
```

After it within the created project run:
```
uv sync
git init
```

## Docker development environment

The project includes a Docker-based development environment with opencode, Python/uv, Node.js, and Playwright pre-installed.

### VS Code DevContainer (recommended)

1. Install the **Dev Containers** extension (`ms-vscode-remote.remote-containers`)
2. Open the project folder in VS Code
3. Run **"Dev Containers: Reopen in Container"** (`Ctrl+Shift+P`)

### Terminal-only

```bash
# Build the image
docker compose build

# Enter the container
docker compose run --rm dev bash

# Inside the container
uv sync
git init
opencode
```

### Environment variables

Create a `.env` file in the project root:

```bash
CONTEXT7_API_KEY=your_key_here
```

opencode will pick it up automatically inside the container.