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

The project includes a Docker-based development environment with opencode, Python/uv, Node.js, and Playwright pre-installed. The container runs as a non-root user (`dev`) whose UID/GID match the host, so files written in the mounted workspace belong to your host user instead of `root`.

### Build & run

The image must be built with your host UID/GID so the container user matches the host:

```bash
# Build the image (UID/GID are injected from the host automatically)
docker compose build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)

# Enter the container
docker compose run --rm dev bash

# Inside the container
uv sync
git init
opencode
```

If you skip the `--build-arg` flags, the build fails (the `USER_ID`/`GROUP_ID` Dockerfile args are required).

### Environment variables

Create a `.env` file in the project root:

```bash
CONTEXT7_API_KEY=your_key_here
```

opencode will pick it up automatically inside the container.

## Spec-driven development (commands, skills & agents)

These are opencode commands wired in `opencode.json`, backed by skills under `.opencode/skills/` and restricted agents under `.opencode/agents/`. They were adapted from the JS project https://github.com/Klerith/open-daycare to this Python template.

| Command | Description | Argument |
| --- | --- | --- |
| `/spec` | Designs the spec by asking clarifying questions and saves it to `specs/NN-slug.md` | — |
| `/spec-impl` | Validates the spec is `Approved` and implements it step by step on a branch | `<NN-slug>` |
| `/verify-spec` | Verifies the acceptance criteria of a spec, fixes code, marks checkboxes | `<NN-slug>` |
| `/commit-msg` | Generates a copy-ready commit message from current changes (does NOT commit) | — |

Each command runs as a dedicated agent with locked-down permissions:

- `spec-writer` — may only read the repo and write spec files under `specs/` (no source edits, only `ls`/`cat`/`date` in the shell).
- `spec-impl-writer` — may edit source and run git branch/status plus `uv`/`pytest`/`ruff`, but cannot `commit`/`push`/`merge`.
- `spec-verifier` — may run `uv`/`pytest`/`ruff`/`python` to verify; no arbitrary shell commands.
- `commit-msg-writer` — read-only; produces a commit message but is denied `git commit`/`git push`/`git reset`, so it can never modify the repo.

---
## Spec Driven Development Workflow

1. **Describe the Problem:**
Use the `/spec {Describe what you want}` skill to create the SDD artifact (markdown specification).

2. **Review and Approval:**
Review the generated artifact and approve (in the specification markdown file) it if it meets the requirements.

3. **Implementation:**
Run `/spec-impl @specification.md` to begin the SDD-guided implementation.

4. **Step-by-Step Review:**
Verify each step of the implementation iteratively.

5. **Quick Adjustments:**
For minor changes or corrections, use one-shot prompts.

6. **Automatic Verification:**
Use the `@spec-verifier @specification.md` agent to validate the implementation.

7. **Mark as Implemented:**
Update the spec status to "implemented".

8. **Publish changes:**
Upload the branch to the GitHub repository and open a pull request. You can use /commit-msg command to autogenerate commit message.

9. **Merge and remote cleanup:**
*Merge* the branch on GitHub and delete the branch in the remote repository.

10. **Sync your local environment:**
Switch to the `main` branch, *pull* the changes, and delete the local branch if necessary.
---

## Usage

### Full feature cycle

```bash
# 1. Design the spec with clarifying questions
/spec levels-and-highscores

# The agent reads the project-memory file (CLAUDE.md, AGENTS.md, GEMINI.md, or README.md) and existing specs/, asks questions
# in blocks, develops the spec section by section,
# and finally saves it as specs/03-levels-and-highscores.md
# with status: Draft.

# 2. Re-read the spec outside the chat and approve it manually
# (open the file in the editor, change Status: Draft → Approved)

# 3. Implement the approved spec
/spec-impl 03-levels-and-highscores

# The agent validates the status is Approved, creates the branch
# spec-03-levels-and-highscores, switches to it, shows
# the spec summary, and starts the step-by-step implementation
# with pauses to review diffs.
```

### What each skill does

#### `/spec [short-topic]`

Designs the feature document. Goes through four phases:

1. **Context** — reads the project-memory file (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, or `README.md`, whichever exists first) and previous specs.
2. **Clarification** — asks questions in blocks of 3-5 until the feature is clearly defined.
3. **Section by section development** — generates and confirms each spec section before moving on.
4. **Save** — writes the file in `specs/NN-slug.md` with status `Draft`.

#### `/spec-impl <NN-name>`

Implements an approved spec. Goes through four phases:

1. **Identify** — locates the spec file.
2. **Validate** — verifies the status is `Approved`. If not, it stops.
3. **Create branch** — `git checkout -b spec-NN-slug` and switches to it.
4. **Implement** — step by step with pauses, showing the spec summary first.

> **Branch control:** Phase 3 reads the `AutoCreateBranch` flag from `specs/.spec-config.yml`. It defaults to `true` (creates the branch automatically). Set it to `false` to make `/spec-impl` ask `[y/N]` before creating any branch — useful if branch naming is part of your own Git workflow.
>
> ```yaml
> # specs/.spec-config.yml
> AutoCreateBranch: false
> ```

### Spec states

| State         | Meaning                                                                    |
| ------------- | -------------------------------------------------------------------------- |
| `Draft`       | The `/spec` skill generated it but the human hasn't re-read it.            |
| `In review`   | The human is reviewing or iterating with the agent.                        |
| `Approved`    | The human read and authorized it. `/spec-impl` only works with this state. |
| `Implemented` | The code exists and passes the acceptance criteria.                        |
| `Obsolete`    | Replaced by another spec. Not deleted — referenced.                        |

**Changing the status to `Approved` is a deliberate human act.** It's the only signature on the contract — the agent can't approve its own work.

> Status labels are language-agnostic. `/spec-impl` only requires the status to mean **Approved** — `Approved`, `Aprobado`, or the equivalent in any language all work. Same goes for the other states. Pick the labels your team prefers and stay consistent.

---

## Why the two skills work as a pair

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│   /spec     opencode asks and designs                     │
│             ↓                                             │
│             specs/NN-slug.md  (Status: Draft)             │
│                                                           │
│   ──────── human re-reads and approves ────────           │
│             ↓                                             │
│             specs/NN-slug.md  (Status: Approved)          │
│                                                           │
│   /spec-impl  opencode validates and implements           │
│             ↓                                             │
│             branch spec-NN-slug + code                    │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

The gap between the two skills — re-reading and changing the status by hand — is deliberate. It's the only moment where **only you can do something**. Without that gap, the method degrades to "the agent writes pretty documentation and then writes whatever code occurs to it anyway".

After implementation, run `/verify-spec <NN-slug>` to check the acceptance criteria against the code, fix any issues found, and mark the checkboxes directly in the spec.

---

## Releases

This project uses [release-please](https://github.com/googleapis/release-please) for automated releases. Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Effect |
| --- | --- |
| `feat:` | Bumps minor version |
| `fix:` | Bumps patch version |
| `feat!:` / `fix!:` | Bumps major version |
| `docs:`, `chore:`, `refactor:` | No version bump |

---