# emux

**🎮 video game settings — but for tmux**

Eli Dubizh's personal [tmux](https://github.com/tmux/tmux) config. Fast,
**prefix-free** keybindings for splitting, navigating, and resizing panes — copy
it and tmux starts to feel like a tiling window manager you drive with one hand.

Anyone is welcome to use it.

## Requirements

- tmux 3.x or newer
- **macOS Terminal / iTerm users:** turn on **"Use Option as Meta key"** in your
  terminal profile. Every binding below fires on the Option (`⌥`) key, so
  without this setting none of them work.

## Install

```sh
git clone https://github.com/edubizh/emux.git
cd emux
./install.sh
tmux source-file ~/.tmux.conf   # or just restart tmux
```

`install.sh` copies `.tmux.conf` to `~/.tmux.conf` and the helper scripts to
`~/.config/emux/`. Prefer to do it by hand? Just `cp .tmux.conf ~/.tmux.conf` —
everything works, except `⌥ Tab` falls back to tmux's plain next-pane instead of
the clockwise cycle until the helper is installed.

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
| `⌥ =` | Snap all panes back to an even 2×2 grid |

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

---

> **Note — coming soon:** emux will become an installable package, so anyone can
> run a single command and get my version of tmux. More of my keyboard and
> terminal configs will land here over time.
