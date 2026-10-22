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
cp .tmux.conf ~/.tmux.conf
tmux source-file ~/.tmux.conf   # or just restart tmux
```

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

It decides where to go from *where the pane sits*, not from its number:

- on the **top** edge and not yet at the right → move **right**
- on the **right** edge and not yet at the bottom → move **down**
- on the **bottom** edge and not yet at the left → move **left**
- otherwise (on the **left** edge) → move **up**

Because it navigates by position, it's immune to pane renumbering and to the
`⌥ =` snap, so the cycle always feels the same. It's exact on a grid and walks
the edges sensibly on irregular layouts too.

---

> **Note — coming soon:** emux will become an installable package, so anyone can
> run a single command and get my version of tmux. More of my keyboard and
> terminal configs will land here over time.
