# Changelog

All notable changes to emux are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and emux adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `bin/emux-ticker <PAIR>` — a live crypto price dashboard for a single pane: a
  big figlet banner of the asset (green up / red down), the price, the `24h`-labelled
  % change, and 24h volume in USD. The price is the **median of three exchange websocket feeds**
  (Gemini, Coinbase, Kraken), so it keeps working if one vendor drops — a health
  line shows how many are live (`3/3`). 24h %/volume come from Gemini REST. Free,
  no API keys. Run it in several split panes to watch multiple assets at once.
  Requires `websocat`, `jq`, `figlet`. The first piece of emux's "finance
  template" direction (crypto first; stocks and prediction markets later).
- `⌥ Shift ;` / `⌥ Shift '` — move a whole vertical wall together: the active pane
  and its stacked column companions resize as one, so a column (e.g. both right
  panes of a 2×2) moves in sync. Works even when panes are offset or the grid is
  jagged — not just a clean 2×2. Powered by `bin/emux-resize-wall`.

### Changed
- `⌥ =` now **rotates panes through the grid** on repeat presses. The first
  press snaps to an even layout — **two panes go side by side** (left/right,
  rather than tmux's default top/bottom stack), three or more fill the grid —
  and once the layout is already even, each further press slides every pane one
  cell (top-left → top-right, wrapping around) while keeping the layout, so you
  can shuffle which pane sits where without re-splitting. Powered by
  `bin/emux-grid-rotate`.

### Fixed
- `⌥ ;` (resize left) now actually works. The binding was silently dropped
  because `;` is tmux's command separator: the unescaped key ended the
  `bind-key` command early (`unknown key: M-`), so only `⌥ '` (resize right)
  ever installed. Escaping it (`M-\;`) registers the binding.

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
