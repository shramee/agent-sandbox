# Agent sandbox container

A sandboxed dev container for coding agents: Node/Python/Go/Foundry toolchain
plus the Claude Code CLI, ready to bind-mount a project directory into.

Source & Dockerfile: https://github.com/shramee/agent-sandbox

## What's inside

| Tool / Runtime   | Details                                       |
| ---------------- | --------------------------------------------- |
| **OS & Shell**   | Debian, `zsh` 🎉 with oh-my-zsh                |
| **Node.js**      | v26 with `corepack` (pnpm enabled)            |
| **Python**       | 3.14                                          |
| **Go**           | 1.26 (`/usr/local/go`)                        |
| **Foundry**      | Solidity toolchain (`forge`, `cast`, `anvil`) |
| **Claude Code**  | Installed via the official curl installer     |
| **Command Code** | Installed globally via pnpm (`command-code`)  |
| **Sudo**         | Passwordless for the `agent` user (UID 1001)  |

Handy aliases baked into the shell:
- `cmdy` (`command-code --yolo --no-onboarding`) and,
- `clauded` (`claude --dangerously-skip-permissions`).

## Quick start

Bind-mount your project at the same path inside the container and drop into
a shell:

```sh
docker run -it --rm \
  --mount type=bind,src="$(pwd)",target="$(pwd)" \
  -w "$(pwd)" \
  shramee/agent-sandbox:latest zsh
```

Anything the container writes under that mount shows up on your host
immediately, and vice versa — it's a live passthrough, not a copy.

### Persisting Claude Code / Command Code config across runs

```sh
docker run -it --rm \
  --mount type=bind,src="$(pwd)",target="$(pwd)" \
  --mount type=bind,src="$HOME/.claude",target=/home/agent/.claude \
  --mount type=bind,src="$HOME/.commandcode",target=/home/agent/.commandcode \
  --mount type=bind,src="$HOME/.claude.json",target=/home/agent/.claude.json,readonly \
  --mount type=bind,src="$HOME/.gitconfig",target=/home/agent/.gitconfig,readonly \
  -w "$(pwd)" \
  shramee/agent-sandbox:latest zsh
```

## `ag-sbx` CLI

`ag-sbx` launches the Docker container for whatever directory you run
it from, with that directory bind-mounted at the *same path* inside the
container. One container per directory, keyed by a **hash of the path**,
so running it from different projects doesn't collide or tear down other
sandboxes.

The image bundles a Node/Python/Go/Foundry toolchain plus the Claude Code
CLI (see `Dockerfile`).

### Install

```sh
./install.sh
```

Symlinks `ag-sbx` into a local bin directory — prefers `~/.local/bin` or
`~/bin` if already on `PATH`, falling back to `~/.local/bin`. If the chosen
directory isn't on your `PATH`, the script prints the `export` line you need.

### Usage

From any project directory:

```sh
cd ~/some/project
ag-sbx
```

First run builds the `ag-sbx:latest` image and creates a container named
`ag-sbx-<hash of the directory>`, mounting the directory at its own path
inside the container, then drops you into a `zsh` shell there. Later runs
from the same directory reuse (starting if stopped) that same container.

Mounted in from the host, if present:

- `~/.claude` — Claude Code config/state
- `~/.claude.json` (read-only)
- `~/.commandcode`
- `~/.gitconfig` (read-only)
