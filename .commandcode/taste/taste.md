- Prefers `zsh` as the interactive shell when exec-ing into Docker containers (not bash). Confidence: 0.7
- Prefers commits to include the assistant as a co-author via `Co-authored-by: CommandCodeBot <noreply@commandcode.ai>`. Confidence: 0.8
- When uncertain about a tool's CLI flags or features, prefers the assistant to consult its documentation rather than assume the functionality doesn't exist. Confidence: 0.85
- Prefers oh-my-zsh custom aliases to be placed in `$ZSH_CUSTOM/aliases.zsh` (i.e., `~/.oh-my-zsh/custom/aliases.zsh`) rather than inline in `.zshrc` or written dynamically at runtime. Confidence: 0.85

- Prefers CLI tools and sandbox environments to be self-documenting — when adding new features (aliases, commands), also update the welcome banner or help text so they're discoverable. Confidence: 0.8
- Prefers box-drawing characters (e.g., ┌─┐│└─┘├┤) for formatting tables and structured information in CLI welcome banners and terminal output. Confidence: 0.7
