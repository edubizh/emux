---
name: feature
description: Use when the user wants to add or change an emux tmux keybinding/feature and ship it end to end — e.g. they type "/feature <what they want>". emux-specific workflow.
---

# /feature — ship an emux feature end to end

Take a free-form request for [emux](https://github.com/edubizh/emux) and carry it
through the whole pipeline. **Read emux's `AGENTS.md` first** — it is the source of
truth; this skill is the operating procedure.

Working copy: `~/emux` · installed plugin: `~/.tmux/plugins/emux`

## Prime rule
The keybindings are the public API. **Never change or remove an existing binding
without a MAJOR version bump** (muscle memory is the product). A new binding is a
`feat` (minor). Never commit to `main` — everything goes through a PR. Don't bump
the version per PR.

## Pipeline

1. **Understand.** Restate the request; pin down the exact key(s) and behavior.
   - Keys arrive via Option-as-Meta: `Option+<k>` → `M-<k>`, and a *shifted* key
     sends the shifted char (`Option+Shift+;` → `M-:`). Avoid `[` / `]` — `ESC-[`
     and `ESC-]` are CSI/OSC introducers and misparse.
   - Confirm the target key is currently free (`tmux list-keys -T root`) and that
     it actually reaches tmux (Option-as-Meta must be on). Flag conflicts.
2. **Measure, don't guess.** For anything about layout/resize/pane geometry,
   experiment in a DETACHED scratch window so the user's view is untouched:
   `tmux new-window -d -n emux-dev`, build the case, read `tmux list-panes -F ...`,
   confirm the exact commands, then `tmux kill-window -t emux-dev`.
3. **Branch.** `git -C ~/emux checkout main && git pull`, then
   `git checkout -b <type>/<slug>` (`feat` / `fix` / `docs` / `chore`).
4. **Implement.** Add the binding in `emux.tmux`. If the logic is more than one
   tmux command, add a `bin/emux-*` helper (POSIX sh + awk) with **test hooks**
   (env-var overrides for its input + a print-only mode), and bind it with an
   absolute path via `$CURRENT_DIR`.
5. **Test live (required).** Unit-test the helper logic through its env-var hooks;
   then drive the REAL helper against a detached scratch window *by pane-id* and
   read the geometry back to prove the behavior. Restore/kill the scratch window.
6. **Docs.** `CHANGELOG.md` under `## [Unreleased]`; the README keybinding table;
   the `AGENTS.md` layout list if you added a file.
7. **Commit.** Conventional Commit(s) — one per genuinely separate task, else one.
   `chmod +x` any new script so the executable bit is tracked.
8. **PR → CI → merge.** Push, `gh pr create` (fill the PR template), watch
   `gh pr checks <n> --watch`, and only when green:
   `gh pr merge <n> --squash --delete-branch`. Then sync `main`.
9. **Go live.** `git -C ~/.tmux/plugins/emux pull` + `tmux source-file ~/.tmux.conf`,
   then confirm with `tmux list-keys -T root | grep ...`.

## Done means
Merged to `main`, CI green, the binding verified in a live tmux session, docs
updated. Report the PR number and which keys to press.
