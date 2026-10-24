---
name: feature-patch
description: Use when the user reports a bug in, or wants to fix/tweak, an EXISTING emux keybinding or helper and ship the fix end to end — e.g. they type "/feature-patch <what's broken>". emux-specific; sibling of the feature skill.
---

# /feature-patch — fix an emux feature end to end

Take a bug report or tweak for existing emux behavior and carry it through the
whole pipeline. Sibling of the `feature` skill. **Read emux's `AGENTS.md` first** —
it is the source of truth; this skill is the procedure.

Working copy: `~/emux` · installed plugin: `~/.tmux/plugins/emux`

## Prime rule
A bugfix makes a binding behave as it was *meant* to — the keys stay the same, so
it's a `fix` (patch), not a version-breaking change. If the "fix" would actually
change what an existing key *does* (break muscle memory), STOP: that's a MAJOR
change — flag it, don't sneak it in. Never commit to `main`; everything via a PR.

## Pipeline

1. **Reproduce first (RED).** Don't fix what you haven't watched fail. In a
   DETACHED scratch window (`tmux new-window -d -n emux-dev`) build the exact
   layout/case that triggers the bug and confirm the broken behavior via
   `tmux list-panes -F ...` / `tmux list-keys`. Can't reproduce it? Ask for the
   exact layout/keys — don't guess.
2. **Root cause, not symptom.** Find *why* it breaks (e.g. "grouped by exact edge,
   so jagged layouts drop panes"). Fix the cause; resist band-aids.
3. **Branch.** `git -C ~/emux checkout main && git pull`, then
   `git checkout -b fix/<slug>`.
4. **Minimal fix.** Change the smallest thing that fixes the root cause. Keep the
   keybinding and any helper's interface the same unless the request says otherwise.
5. **Prove it (GREEN + regression).** Re-run the failing case and confirm it now
   works; then re-run the cases that already worked (clean/default) so you didn't
   break them. Use the helper's test hooks for unit coverage and a live
   scratch-window run *by pane-id* for the real thing.
6. **Docs.** `CHANGELOG.md`: a `### Fixed` note under `## [Unreleased]` (or refine
   the feature's `### Added` entry if it was never released). Update the README if
   the described behavior changed.
7. **Commit.** `fix(<scope>): …` Conventional Commit(s) — one per genuinely
   separate cause. `chmod +x` any touched script.
8. **PR → CI → merge.** Push, `gh pr create` (fill the template), watch
   `gh pr checks <n> --watch`, and only when green:
   `gh pr merge <n> --squash --delete-branch`. Then sync `main`.
9. **Go live.** `git -C ~/.tmux/plugins/emux pull` + `tmux source-file ~/.tmux.conf`,
   then re-confirm the fix from the installed path.

## Done means
Merged to `main`, CI green, the bug reproduced-then-verified-fixed in a live tmux
session with no regressions, docs updated. Report the PR number and what changed.
