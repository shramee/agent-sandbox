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
| **Claude Code**  | Installed via the official installer (stable) |
| **Command Code** | Installed globally via pnpm (`command-code@latest`) |
| **GoModel**      | AI gateway serving Anthropic-compatible API (see `claude-gomodel`) |
| **rtk**          | Installed via the official curl installer     |
| **Sudo**         | Passwordless for the `agent` user (UID 1001)  |

Handy aliases baked into the shell:
- `cmdy` (`command-code --yolo --no-onboarding`),
- `clauded` (`claude --dangerously-skip-permissions`) and,
- `claudem` (`claude-gomodel --dangerously-skip-permissions`).

### `claudem` — Claude Code via the Command Code API

`claude-gomodel` starts a local [GoModel](https://github.com/ENTERPILOT/GOModel)
gateway that serves an Anthropic-compatible API backed by Command Code's
OpenAI-compatible provider endpoint
(`https://api.commandcode.ai/provider/v1`), using your Command Code API key
from `~/.commandcode/auth.json`, then launches Claude Code pointed at it.
The gateway keeps running for reuse; logs land in `/tmp/gomodel.log`.

Model tiers are mapped onto Command Code models by default
(`HAIKU`→`xiaomi/mimo-v2.5`, `SONNET`→`z-ai/glm-5.3-flash`, `OPUS`→`zai-org/GLM-5.3`)
and can be overridden per tier in `~/.config/claude-gomodel.conf`
(see [`claude-gomodel.conf`](claude-gomodel.conf)).

## Quick start `ag-sbx` CLI

`ag-sbx` launches the Docker container for whatever directory you run
it from, with that directory bind-mounted at the *same path* inside the
container. One container per directory, keyed by a **hash of the path**,
so running it from different projects doesn't collide or tear down other
sandboxes.

By default it uses the `shramee/agent-sandbox:latest` image, pulling it from
Docker Hub when it's not on the machine yet. It takes an optional command
(`--` prefixed flags work too):

- `ag-sbx build` — build the image locally from the Dockerfile and recreate
  this directory's container on the fresh build.
- `ag-sbx deploy` — build + push the image to Docker Hub, then recreate this
  directory's container on it.
- `ag-sbx update` — pull the latest image from Docker Hub and recreate this
  directory's container on it. Useful after a deploy elsewhere: a plain run
  only pulls when the image is missing locally.
- `ag-sbx clean` — remove this directory's container so it's recreated fresh.

So shipping a new image is:

```sh
ag-sbx deploy   # on the machine with the changes: build + push
ag-sbx update   # everywhere else: pull the new image, recreate the container
```

The image bundles a Node/Python/Go/Foundry toolchain plus the Claude Code
CLI and rtk (see `Dockerfile`).

```sh
# 1. Install
./install.sh  # Symlinks `ag-sbx` into a local bin directory or prints the `export` line you need.
# 2. Usage
cd ~/some/project
ag-sbx        # pull image from Docker Hub (or use local cache)
```

First run pulls (or builds with `build`) the `shramee/agent-sandbox:latest` image and creates a container named
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
