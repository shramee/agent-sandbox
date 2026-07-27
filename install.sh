#!/usr/bin/env bash
# Symlinks ag-sbx into a local bin directory so it's runnable from anywhere.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$SCRIPT_DIR/ag-sbx"

# Pick the best local bin directory: prefer one already on PATH, falling back to
# ~/.local/bin (XDG standard).
pick_bin_dir() {
    local candidates=("$HOME/.local/bin" "$HOME/bin")
    for dir in "${candidates[@]}"; do
        [[ ":$PATH:" == *":$dir:"* ]] && { printf '%s' "$dir"; return; }
    done
    printf '%s' "$HOME/.local/bin"
}

BIN_DIR="$(pick_bin_dir)"
mkdir -p "$BIN_DIR"
ln -sf "$SCRIPT_DIR/ag-sbx" "$BIN_DIR/ag-sbx"

echo "Linked $BIN_DIR/ag-sbx -> $SCRIPT_DIR/ag-sbx"

case ":$PATH:" in
    *":$BIN_DIR:"*)
        echo "$BIN_DIR is already on PATH — you're good to go."
        ;;
    *)
        echo "$BIN_DIR is not on your PATH."
        echo "Add this to your shell rc (e.g. ~/.zshrc), then restart your shell:"
        echo "  export PATH=\"$BIN_DIR:\$PATH\""
        ;;
esac
