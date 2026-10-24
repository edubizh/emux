#!/usr/bin/env bash
#
# emux.tmux — Tmux Plugin Manager (TPM) entry point.
#
# TPM runs this file after cloning the repo. It installs every emux keybinding
# against the running tmux server. The clockwise-cycle binding points straight
# at this plugin's own bundled helper, so there is nothing to install by hand.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CYCLE="$CURRENT_DIR/bin/emux-pane-cycle"

# --- Split panes (no prefix) ---
tmux bind-key -n M-. split-window -h -c "#{pane_current_path}"   # side by side
tmux bind-key -n M-, split-window -v -c "#{pane_current_path}"   # stacked

# --- Navigate: Option+Tab = next pane CLOCKWISE (see bin/emux-pane-cycle) ---
tmux bind-key -n M-Tab run-shell "$CYCLE"

# --- Resize panes (no prefix) ---
tmux bind-key -n "M-;" resize-pane -L 5
tmux bind-key -n "M-'" resize-pane -R 5
tmux bind-key -n M-Up   resize-pane -U 5
tmux bind-key -n M-Down resize-pane -D 5

# --- Resize a whole vertical wall together, keeping a grid aligned ---
# Option+Shift+; / Option+Shift+'  (i.e. M-: / M-") move every pane sharing the
# wall, so e.g. both right-column panes of a 2x2 slide together. See
# bin/emux-resize-wall.
tmux bind-key -n "M-:" run-shell "$CURRENT_DIR/bin/emux-resize-wall L"
tmux bind-key -n 'M-"' run-shell "$CURRENT_DIR/bin/emux-resize-wall R"

# --- Snap panes back to an even 2x2 grid ---
tmux bind-key -n M-= select-layout tiled
