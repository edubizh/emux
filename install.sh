#!/bin/sh
# emux installer — put the config and helper scripts in place.
set -e

PREFIX="$HOME/.config/emux"
SRC=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$PREFIX/bin"
cp "$SRC/bin/emux-pane-cycle" "$PREFIX/bin/emux-pane-cycle"
chmod +x "$PREFIX/bin/emux-pane-cycle"
cp "$SRC/.tmux.conf" "$HOME/.tmux.conf"

echo "emux installed:"
echo "  ~/.tmux.conf"
echo "  $PREFIX/bin/emux-pane-cycle"
echo
echo "Reload with:  tmux source-file ~/.tmux.conf   (or restart tmux)"
