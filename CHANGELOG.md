# Changelog

All notable changes to emux are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and emux adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `⌥ Shift ;` / `⌥ Shift '` — move a whole vertical wall together, so a column of
  panes (e.g. both right panes of a 2×2) resizes in sync and the grid stays
  aligned instead of going jagged. Powered by `bin/emux-resize-wall`.

## [1.0.0] - 2026-10-22

First stable release. The binding set below is now a public contract — changing
any of it requires a major bump.

### Added
- Prefix-free pane **splitting**: `⌥ ,` (stacked) and `⌥ .` (side by side),
  opening in the current pane's working directory.
- Prefix-free pane **resizing**: `⌥ ;` / `⌥ '` (left/right) and `⌥ ↑` / `⌥ ↓`
  (up/down), 5 cells per press.
- `⌥ =` to **snap** panes back to an even 2×2 grid.
- `⌥ Tab` to cycle panes **clockwise**, powered by `bin/emux-pane-cycle`: panes
  are ordered by the angle of their center around the window center, so the
  cycle always visits every pane once per lap and can never get stuck on
  irregular or overlapping layouts.
- Packaged as a **TPM plugin** via `emux.tmux`; the clockwise helper is bundled,
  so there is nothing to install by hand.
- Project docs: `README`, `CONTRIBUTING`, this changelog, PR template, and an
  MIT `LICENSE`.

[Unreleased]: https://github.com/edubizh/emux/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/edubizh/emux/releases/tag/v1.0.0
