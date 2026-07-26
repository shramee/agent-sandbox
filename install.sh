#!/usr/bin/env bash
# Symlinks ag-sbx onto ~/bin so it's runnable from any directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/bin"
chmod +x "$SCRIPT_DIR/ag-sbx"
ln -sf "$SCRIPT_DIR/ag-sbx" "$HOME/bin/ag-sbx"

echo "Linked $HOME/bin/ag-sbx -> $SCRIPT_DIR/ag-sbx"

case ":$PATH:" in
    *":$HOME/bin:"*)
        echo "~/bin is already on PATH — you're good to go."
        ;;
    *)
        echo "~/bin is not on your PATH."
        echo "Add this to your shell rc (e.g. ~/.zshrc), then restart your shell:"
        echo '  export PATH="$HOME/bin:$PATH"'
        ;;
esac
