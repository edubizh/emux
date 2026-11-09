# emux

**🎮 video game settings — but for tmux**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![version](https://img.shields.io/github/v/tag/edubizh/emux?label=version&sort=semver)](https://github.com/edubizh/emux/releases)
[![install: TPM](https://img.shields.io/badge/install-TPM-1f6feb.svg)](https://github.com/tmux-plugins/tpm)

Eli Dubizh's personal [tmux](https://github.com/tmux/tmux) setup, packaged as a
plugin. Fast, **prefix-free** keybindings for splitting, navigating, and resizing
panes — add it and tmux starts to feel like a tiling window manager you drive
with one hand.

Anyone is welcome to use it.

## Requirements

- tmux 3.x or newer
- **macOS Terminal / iTerm users:** turn on **"Use Option as Meta key"** in your
  terminal profile. Every binding below fires on the Option (`⌥`) key, so
  without this setting none of them work.

## Install

emux is a [TPM](https://github.com/tmux-plugins/tpm) plugin. If you don't have
TPM yet, install it first (one command — see its README).

Then add emux to your `~/.tmux.conf` and press `prefix + I` to fetch it. A
minimal config looks like:

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'edubizh/emux'

run '~/.tmux/plugins/tpm/tpm'   # keep this line last
```

Reload tmux and every binding below is live — no extra prefix needed to use them.

## Keybindings

Everything is **prefix-free** — hold `⌥` (Option) and tap the key. No `Ctrl-b` first.

### Split panes
| Keys | Action |
|------|--------|
| `⌥ ,` | Split **stacked** (top / bottom) |
| `⌥ .` | Split **side by side** (left / right) |

New panes open in the current pane's working directory.

### Navigate panes
| Keys | Action |
|------|--------|
| `⌥ Tab` | Cycle panes **clockwise** around the screen |

### Resize panes
| Keys | Action |
|------|--------|
| `⌥ ;` | Resize left |
| `⌥ '` | Resize right |
| `⌥ ↑` | Resize up |
| `⌥ ↓` | Resize down |
| `⌥ ⇧ ;` | Move the whole vertical wall **left** — a column of panes resizes together (even if offset/jagged) |
| `⌥ ⇧ '` | Move the whole vertical wall **right** |
| `⌥ =` | Snap panes to an even layout (two go **side by side**) — **press again to rotate** panes through the cells |

#### Why `↑ / ↓` has no "move together" twin (and why that's a tmux law, not a gap)

A reasonable wish: make `⌥ ↑ / ↓` resize *just the active pane* and add `⌥ ⇧ ↑ / ↓`
to move the whole horizontal wall together — a perfect mirror of `;` / `'`. **tmux
can't do it**, and it's worth knowing why.

tmux always slices the screen into **two halves first**, then subdivides each half.
That first slice is a single shared wall. So in *any* 2×2, one of the two middle
walls is one shared edge and the other is two independent edges — you get "resize
separately" on **exactly one axis** and "moves together" on the other. Both axes
separate is not a layout tmux can represent.

The default grid (`⌥ =`, and the usual "split stacked, then side-by-side" flow)
slices **top/bottom first**, so:

- the **side** walls are independent → `⌥ ;` / `⌥ '` nudge one pane (separate), and
  `⌥ ⇧ ;` / `⌥ ⇧ '` sweep the whole column wall together.
- the **top/bottom** wall is the shared one → `⌥ ↑` / `⌥ ↓` already move the entire
  wall (the two top panes are pinned to the same height, so there is no separate
  edge to grab). A `⌥ ⇧ ↑ / ↓` would do exactly what `⌥ ↑ / ↓` already does, so it
  doesn't exist.

Want the opposite? Build the grid **side-by-side first** (`⌥ .`, then `⌥ ,` inside
each column) and the whole thing transposes: now `↑ / ↓` resize separately and
`; / '` move together.

## The `⌥ =` grid — tidy, then shuffle

`⌥ =` is two gestures in one key:

- **First press** snaps every pane back to an even layout — the classic "clean
  this up." Two panes land **side by side** (left/right); three or more fill the
  as-square-as-possible grid.
- **Press it again** once the layout is already even and it **rotates the panes
  through the cells**: each pane's contents slide one slot (top-left → top-right,
  wrapping around) while the layout itself stays put. Keep tapping to walk a pane
  around the screen without re-splitting.

Two panes are the one special case: tmux's own grid would stack a pair
top/bottom, so emux snaps exactly two panes to side-by-side instead. The trick
for telling "tidy" from "rotate" is that snapping an already-even layout is a
no-op, so emux uses that to tell "the layout was messy, just tidy it" apart from
"already tidy, so rotate." Handled by [`bin/emux-grid-rotate`](bin/emux-grid-rotate).

## The clockwise `⌥ Tab` — "walking the edges"

Stock tmux cycles panes by their *creation number*. In a 2×2 grid that order
jumps diagonally (TL → TR → BL → BR) and never feels like going *around* the
screen.

emux replaces it with a **position-aware** cycle that walks the edges clockwise:

```
 TL ──▶ TR
  ▲      │
  │      ▼
 BL ◀── BR
```

### How it works (and why it never gets stuck)

An earlier version walked the edges with tmux's directional moves
(`select-pane -L/-R/-U/-D`). That looks right on a clean grid but **breaks on
irregular layouts**: directional moves can form a 2-cycle, so `⌥ Tab` gets
*stuck* bouncing between two panes and never reaches the rest. (Repro: in a 2×2,
drag the top-right pane left until it overlaps the bottom-left one — the old
cycle traps itself between those two.)

The fix orders panes by the **angle of each pane's center around the window
center**, then steps to the next pane in that clockwise order, wrapping at the
end. Because that order is a full permutation of the panes, the cycle **always
visits every pane exactly once per lap and can never get stuck** — on any
layout. It also stays immune to pane renumbering and to the `⌥ =` snap. It's
handled by the helper [`bin/emux-pane-cycle`](bin/emux-pane-cycle).

## Versioning

emux follows [Semantic Versioning](https://semver.org). The keybindings are the
public API: a **major** bump changes or removes an existing binding, a **minor**
adds one, and a **patch** is a fix or docs change. Want a frozen set? Pin a tag:

```tmux
set -g @plugin 'edubizh/emux#v1.0.0'
```

See [CHANGELOG.md](CHANGELOG.md) for what changed and when.

## Contributing

PRs welcome — read [CONTRIBUTING.md](CONTRIBUTING.md) first (commit style,
branches, releases). The golden rule: keep bindings stable — muscle memory is
the product.

## License

[MIT](LICENSE) © Eli Dubizh. Use it, fork it, make it your own.

---

> More of my keyboard and terminal configs will land here over time — this is
> the start of a tmux "distro," not the end of it.
