# emux-ticker — design (v1 prototype)

- **Date:** 2026-11-11
- **Status:** approved for implementation
- **Branch:** `feat/emux-ticker`

## Goal

The first prototype of emux's "finance template" direction: a single script,
`emux-ticker <PAIR>`, that turns one tmux pane into a **live, streaming**
dashboard for one crypto asset. Because each pane runs its own instance,
splitting panes gives a multi-asset view for free — that is the whole point of
hosting this in tmux.

This spec covers **only** that one script. Everything else (launcher, popup
search, charts, stocks, prediction markets) is explicitly deferred (see
Non-goals).

## Why crypto first (not stocks)

Hard constraints: **no money, no API keys.** Under those, *free + no-key +
real-time streaming* exists only for **crypto**: crypto exchanges give market
data away free, while stock exchanges (NYSE/Nasdaq) license their real-time
feeds. There is no free, no-key stock websocket — free stock data is HTTP
polling only (e.g. Yahoo). So the roadmap is **crypto-first, streaming-first**.
Vendor: the **Gemini** exchange (chosen over Coinbase), whose public market-data
websocket and REST endpoints need no auth.

## Scope (v1)

`emux-ticker <PAIR> [poll_seconds]` — e.g. `emux-ticker btcusd`.

Runs in the foreground inside a pane and shows one asset, with two data cadences:

- **Price — streamed live** over a persistent Gemini websocket (pushes, no
  polling).
- **24h % change and 24h volume — polled** on a short interval (default 20s)
  from Gemini REST, because a raw trade stream carries price only and those
  values move slowly.

### Output layout (illustrative)

The banner is `figlet` with its default font, full size, left-aligned as a
header; the stats sit underneath it:

```
  ____    _____    ____          <- figlet of the BASE asset (e.g. "BTC"),
 | __ )  |_   _|  / ___|            tinted green when 24h change >= 0, else red
 |  _ \    | |   | |
 | |_) |   | |   | |___
 |____/    |_|    \____|

  $74,035.80   ▲ +0.81%          <- price = live (streamed); % = polled
  Vol  154.46 BTC                <- 24h volume (polled)        ⟳ live
```

## Data sources (all Gemini, no key, verified 2026-11-11)

1. **Live price — websocket:** `wss://api.gemini.com/v1/marketdata/<pair>`
   (pair lowercased, e.g. `btcusd`). The feed streams messages whose `events[]`
   include `{"type":"trade","price":"…"}`; we take the `price` of each `trade`.
2. **24h % change — REST:** `https://api.gemini.com/v1/pricefeed` returns an
   array of `{pair, price, percentChange24h}`; we select our pair (uppercased,
   e.g. `BTCUSD`) and read `percentChange24h` (a decimal fraction — `0.0081`
   means +0.81%).
3. **24h volume — REST:** `https://api.gemini.com/v1/pubticker/<pair>` returns
   `.volume`, an object keyed by the uppercased base asset (e.g. `.volume.BTC`)
   plus the quote and a timestamp.

All requests send a browser `User-Agent` and `--max-time 10`.

## Architecture (the persistent pipeline)

One long-lived shell process per pane; **no per-tick process spawns** for the
price path:

```
  websocat <wss>  |  jq --unbuffered -r '<trade price>'  |  while read price; do render; done
        \                                                          ^
         persistent                                                | reads
                                                                   state file
  poller (background): every N s  curl pricefeed + pubticker  -->  writes "pct vol"
```

- `websocat` and `jq` stay open for the life of the pane; `figlet` runs **once**
  and its banner is cached. The only short-lived processes are the poller's
  `curl`s, every ~20s.
- The **poller** is a background loop writing the latest `pct` and `vol` to a
  small temp state file; `render` reads that file each redraw, so the two
  cadences stay decoupled.
- `render` clears the pane (`tput clear`) and prints the cached banner (colored
  by the sign of the last polled `pct`) + formatted price, % and volume.

### Process model (for reference)

```
tmux server
└─ sh emux-ticker btcusd          (hosted by tmux; the persistent "app")
   ├─ websocat                    (persistent: holds the live stream)
   ├─ jq --unbuffered             (persistent: parses each message)
   └─ poller (background subshell)(persistent: every ~20s …)
        └─ curl                   (short-lived grandchild, ~every 20s)
```

## Behavior & robustness

- **Args:** `PAIR` required (case-insensitive; lowercased for URLs, base asset
  uppercased for the banner). `poll_seconds` optional, default `20`.
- **Base asset for the banner:** strip a known quote suffix
  (`usdc usdt gusd usd dai eur gbp sgd btc eth`) from the pair; fall back to the
  whole symbol if none matches. `btcusd → BTC`, `ethusdc → ETH`.
- **Reconnect:** if the websocket drops, `websocat` exits → an outer `while`
  loop shows `reconnecting…` and retries after a short sleep. The poller keeps
  running across reconnects.
- **Startup:** before the first trade streams in, seed the price from the first
  poll so the pane isn't blank.
- **Cleanup:** a `trap` on EXIT/INT/TERM kills the poller and removes the temp
  state file.
- **Missing `figlet`:** fall back to printing the plain uppercased base asset so
  the script still runs; print the install hint once.

## Dependencies

- `curl` — preinstalled on macOS.
- `jq` — already installed (1.8.1).
- `websocat` — **`brew install websocat`** (a single no-key binary; the
  websocket client).
- `figlet` — **`brew install figlet`** (optional; graceful fallback if absent).

## Testing

emux convention: scripts are POSIX `sh`, shellcheck-clean, and testable without
a live tmux via env-var hooks. For `emux-ticker`:

- **Test hooks** (harmless in normal use):
  - `EMUX_ONCE=1` — render exactly one frame and exit (no stream, no loop).
  - `EMUX_PRICE=<n>` — the price to render in once-mode.
  - `EMUX_STATE="<pct> <vol>"` — inject polled values (skips the poller/curl) so
    a render is deterministic.
  - `EMUX_WS_FIXTURE=<file>` — read websocket lines from a file instead of
    connecting, to test price extraction + continuous render offline.
  - `EMUX_NO_COLOR=1` — disable ANSI color for stable test output.
- A `tests/emux-ticker.sh` runner asserts: base-asset derivation; `trade` price
  extraction from a sample Gemini message; green vs red by the sign of `pct`;
  price/%/volume formatting; `figlet`-absent fallback.
- `bin/emux-ticker` passes `shellcheck` (the CI gate runs `shellcheck bin/*`).

## Where it lives / repo rules

- New file: `bin/emux-ticker` (sibling of the existing `bin/` helpers), plus
  `tests/emux-ticker.sh`.
- This adds a **new** capability and changes **no** existing keybinding, so it is
  not breaking and needs **no version bump**; it lands under `[Unreleased]` in
  the changelog as a `feat`.
- Ship via branch → PR → squash-merge (`feat/emux-ticker`); PR title is a
  Conventional Commit (`feat: …`).

## Non-goals (deferred to later phases)

1. `emux-finance` launcher that opens a preset grid of tickers.
2. A `display-popup` "center search bar" to spawn a ticker pane by typing a
   symbol, bound to an `⌥` key.
3. Charts (sparkline, then full ASCII graph).
4. **Stocks** (would need Yahoo polling or a free-keyed stream) and
   **prediction markets** (a wanted later direction — the reason streaming infra
   is worth building now). The same script generalizes; only the data adapter
   changes.
