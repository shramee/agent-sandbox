# agent-sandbox

`ag-sbx` launches a sandboxed Docker container for whatever directory you run
it from, with that directory bind-mounted at the *same path* inside the
container. One container per directory, keyed by a hash of the path, so
running it from different projects doesn't collide or tear down other
sandboxes.

The image bundles a Node/Python/Go/Foundry toolchain plus the Claude Code
CLI (see `Dockerfile`).

## What's inside the container

| Tool / Runtime | Details |
|---|---|
| **OS & Shell** | Debian, `zsh` with oh-my-zsh (`robbyrussell` theme, git plugin) |
| **Node.js** | v26 with `corepack` (pnpm enabled) |
| **Python** | 3.14 |
| **Go** | 1.26 (`/usr/local/go`) |
| **Foundry** | Solidity toolchain (`forge`, `cast`, `anvil`) |
| **Claude Code CLI** | Installed via the official curl installer |
| **Command Code** | Installed globally via pnpm (`command-code`) |
| **Sudo** | Passwordless for the `agent` user (UID 1001) |

## Install

```sh
./install.sh
```

Symlinks `ag-sbx` to `~/bin/ag-sbx`. If `~/bin` isn't already on your
`PATH`, add this to your shell rc (e.g. `~/.zshrc`) and restart your shell:

```sh
export PATH="$HOME/bin:$PATH"
```

## Usage

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
