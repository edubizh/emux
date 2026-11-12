# emux-ticker — design (v1 prototype)

- **Date:** 2026-11-11
- **Status:** approved for planning
- **Branch:** `feat/emux-ticker`

## Goal

The first prototype of emux's "finance template" direction: a single script,
`emux-ticker <SYMBOL>`, that turns one tmux pane into a live dashboard for one
asset. Because each pane runs its own instance, splitting panes gives a
multi-asset view for free — that is the whole point of hosting this in tmux.

This spec covers **only** that one script. Everything else (launcher, popup
search, charts, crypto) is explicitly deferred (see Non-goals).

## Scope (v1)

`emux-ticker <SYMBOL> [interval]`

Runs in the foreground inside a pane and loops forever:

1. `curl` the free Yahoo Finance endpoint for `<SYMBOL>`.
2. `jq` out: symbol, current price, previous close, latest volume.
3. Compute the day's change: `price - prevClose`, and `%` of prevClose.
4. Redraw the pane:
   - a **big ASCII-art banner** of the ticker (`figlet`, **default "standard"
     font at its natural size** — no condensed fonts, no width squeezing),
     **left-aligned at the top of the pane as its header**, tinted **green**
     when the day's change ≥ 0, **red** when < 0;
   - the **price**, the **± change and %** (same color), and **volume**;
   - a small refresh indicator (the interval).
5. Sleep `interval` seconds (default 15) and repeat.

### Output layout (illustrative)

The banner is `figlet` with its default font, full size, left-aligned as a
header; the stats sit underneath it. This is the exact sizing to match — not a
condensed/squished variant:

```
    _        _    ____  _          <- figlet "$SYMBOL" (default font, green/red)
   / \      / \  |  _ \| |
  / _ \    / _ \ | |_) | |
 / ___ \  / ___ \|  __/| |___
/_/   \_\/_/   \_\_|   |_____|

  $355.63   ▲ +6.12 (+1.75%)
  Vol  34.0M                       ⟳ 15s
```

## Data source

Yahoo Finance public chart endpoint — **no API key, no account, no payment**:

```
https://query1.finance.yahoo.com/v8/finance/chart/<SYMBOL>?range=1d&interval=1d
```

Fields used (verified returning live data on 2026-11-11):

- `.chart.result[0].meta.symbol`
- `.chart.result[0].meta.regularMarketPrice` — current price
- `.chart.result[0].meta.chartPreviousClose` — previous close (for change/%)
- `.chart.result[0].meta.currency`
- latest non-null of `.chart.result[0].indicators.quote[0].volume`

Caveats (acceptable for a personal prototype): the endpoint is unofficial and
may rate-limit or change; free data can be delayed; outside market hours the
price is the last close. The script must degrade gracefully, not crash.

## Interface & behavior

- **Args:** `SYMBOL` (required, case-insensitive — upcased before use).
  `interval` (optional, default `15`, seconds).
- **Request:** `curl -s --max-time 10` with a browser `User-Agent` header
  (Yahoo rejects some default agents).
- **Redraw:** clear the screen each frame (e.g. `tput clear`) so the pane shows
  one current snapshot, not a scrolling log.
- **Exit:** `Ctrl-C` stops it; it is just a normal foreground program in a pane.

## Error handling

- **Bad / unknown symbol:** endpoint returns an error object or null price →
  render the banner plus a clear `symbol not found` line; keep looping (the user
  may have mistyped and can `Ctrl-C`).
- **Network failure / timeout:** keep the last good frame on screen and show an
  `offline — retrying` marker; never exit the loop on a transient failure.
- **Missing volume (null):** show `Vol —`.

## Dependencies

- `curl` — preinstalled on macOS.
- `jq` — already installed on this machine.
- `figlet` — **one-time `brew install figlet`** (not yet installed). `toilet` is
  a nicer optional upgrade (color filters) but `figlet` is the baseline.

If `figlet` is missing, fall back to printing the plain upcased symbol so the
script still runs; note the install hint once.

## Testing

Follow emux's existing convention (scripts are testable without a live tmux and
are shellcheck-clean):

- `bin/emux-ticker` is **POSIX `sh`**, shellcheck-clean.
- **Test hooks** (harmless in normal use):
  - `EMUX_FIXTURE=<path>` — read the API JSON from a file instead of `curl`, so
    parsing/formatting can be tested offline with canned responses (valid quote,
    unknown symbol, null volume).
  - `EMUX_ONCE=1` — render exactly one frame and exit (no loop / no sleep), so a
    test can assert the rendered output.
- Checks to cover: price/change/% computed correctly from a fixture; green vs
  red chosen by sign; `symbol not found` path; null-volume path.

## Where it lives / repo rules

- New file: `bin/emux-ticker` (sibling of the existing `bin/` helpers).
- This adds a **new** capability and changes **no** existing keybinding, so it is
  not a breaking change and needs **no version bump** (per AGENTS.md).
- Ship via branch → PR → squash-merge (`feat/emux-ticker`); PR title is a
  Conventional Commit (`feat: ...`).

## Non-goals (deferred to later phases)

1. `emux-finance` launcher that opens a preset grid of tickers.
2. A `display-popup` "center search bar" to spawn a new ticker pane by typing a
   symbol, bound to an `⌥` key.
3. Charts (sparkline, then full ASCII graph).
4. Crypto and other asset classes (the same script generalizes; the banner being
   the plain symbol keeps it uniform across asset types).
