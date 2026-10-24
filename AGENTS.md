# AGENTS.md — working on emux

emux is a tmux plugin: prefix-free Option-key bindings, installed via TPM.
**The keybindings are the public API. Muscle memory is the product.**

## Must-nots
- NEVER change or remove an existing binding without a MAJOR version bump.
- NEVER commit directly to `main`. Branch → PR → squash-merge only.
- Don't bump the version per change — only at a deliberate release.

## Before any change
- PR title must be a Conventional Commit (`feat` / `fix` / `docs` / `chore` / …).
- Bindings must be tested in a LIVE tmux session.
- The cycle helper has test hooks: `EMUX_PANES`, `EMUX_CUR`, `EMUX_PRINT=1`
  (verify it visits every pane and never gets stuck, without needing tmux).
- Keep scripts shellcheck-clean (`emux.tmux` = bash, `bin/emux-pane-cycle` = POSIX sh).

## Layout
- `emux.tmux` — TPM entry point; installs all keybindings.
- `bin/emux-pane-cycle` — clockwise pane cycle (angle-sorted; always complete).
- `bin/emux-resize-wall` — move a vertical wall as a unit (a column resizes together).

## Full rules
See [CONTRIBUTING.md](CONTRIBUTING.md) (policy) and [CHANGELOG.md](CHANGELOG.md) (history).
