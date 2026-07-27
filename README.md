# Agent sandbox container

A sandboxed dev container for coding agents: Node/Python/Go/Foundry toolchain
plus the Claude Code CLI and rtk, ready to bind-mount a project directory into.

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
| **rtk**          | Installed via the official curl installer     |
| **Sudo**         | Passwordless for the `agent` user (UID 1001)  |

Handy aliases baked into the shell:
- `cmdy` (`command-code --yolo --no-onboarding`) and,
- `clauded` (`claude --dangerously-skip-permissions`).

## Quick start `ag-sbx` CLI

`ag-sbx` launches the Docker container for whatever directory you run
it from, with that directory bind-mounted at the *same path* inside the
container. One container per directory, keyed by a **hash of the path**,
so running it from different projects doesn't collide or tear down other
sandboxes.

By default it pulls the `shramee/agent-sandbox:latest` image from
Docker Hub. Pass `--build` to build the image locally from the
Dockerfile instead. Pass `--clean` to remove the existing container for
the current directory first, so it gets recreated fresh.

The image bundles a Node/Python/Go/Foundry toolchain plus the Claude Code
CLI and rtk (see `Dockerfile`).

```sh
# 1. Install
./install.sh  # Symlinks `ag-sbx` into a local bin directory or prints the `export` line you need.
# 2. Usage
cd ~/some/project
ag-sbx        # pull image from Docker Hub (or use local cache)
```

First run pulls (or builds with `--build`) the `shramee/agent-sandbox:latest` image and creates a container named
`ag-sbx-<hash of the directory>`, mounting the directory at its own path
inside the container, then drops you into a `zsh` shell there. Later runs
from the same directory reuse (starting if stopped) that same container.

Mounted in from the host, if present:

- `~/.claude` — Claude Code config/state
- `~/.claude.json` (read-only)
- `~/.commandcode`
- `~/.gitconfig` (read-only)

Claude Code on Linux (i.e. inside the container) has no OS keychain, so it
reads OAuth login credentials from `~/.claude/.credentials.json`. On macOS
those credentials live in the Keychain instead, not in that file. On every
`ag-sbx` run on macOS, the script syncs the Keychain secret into
`~/.claude/.credentials.json` on the host (prompting for confirmation the
first time it creates that file) so the login carries over into the
container via the `~/.claude` mount above.


## Quick start container

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
