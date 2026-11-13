#!/bin/sh
# tests/emux-ticker.sh — offline checks for bin/emux-ticker.
#
# Drives the script through its env-var hooks so nothing here touches the
# network or a websocket. Run it from anywhere:  sh tests/emux-ticker.sh
set -u

here=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
T="$here/bin/emux-ticker"

pass=0
fail=0

# check <description> <expected-substring> <actual-output>
check() {
	if printf '%s' "$3" | grep -qF -- "$2"; then
		pass=$((pass + 1))
		printf 'ok   - %s\n' "$1"
	else
		fail=$((fail + 1))
		printf 'FAIL - %s\n       want substring: [%s]\n       got: [%s]\n' "$1" "$2" "$3"
	fi
}

# absent <description> <substring-that-must-not-appear> <actual-output>
absent() {
	if printf '%s' "$3" | grep -qF -- "$2"; then
		fail=$((fail + 1))
		printf 'FAIL - %s\n       unexpected substring: [%s]\n       got: [%s]\n' "$1" "$2" "$3"
	else
		pass=$((pass + 1))
		printf 'ok   - %s\n' "$1"
	fi
}

# --- base-asset derivation (banner text) ---
check "base btcusd -> BTC"   "BTC"  "$(EMUX_PRINT_BASE=1 "$T" btcusd)"
check "base ethusdc -> ETH"  "ETH"  "$(EMUX_PRINT_BASE=1 "$T" ethusdc)"
check "base DOGEUSD -> DOGE" "DOGE" "$(EMUX_PRINT_BASE=1 "$T" DOGEUSD)"

# --- render: positive 24h change ---
up=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_PRICE=74035.8 \
	EMUX_STATE="0.0081 154.45948915" "$T" btcusd)
check "price comma-formatted"   '$74,035.80' "$up"
check "pct positive formatted"  '+0.81%'      "$up"
check "pct labelled 24h"        '24h'         "$up"
check "volume shown in USD"     '$154.46'     "$up"

# --- render: negative 24h change + millions volume ---
down=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_PRICE=74035.8 \
	EMUX_STATE="-0.0123 2000000" "$T" btcusd)
check "pct negative formatted" '-1.23%'  "$down"
check "volume USD abbreviated" '$2.00M'  "$down"

# --- figlet-absent fallback still shows the ticker ---
plain=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_NO_FIGLET=1 EMUX_PRICE=100 \
	EMUX_STATE="0 1" "$T" btcusd)
check "figlet fallback shows base" 'BTC' "$plain"

# --- median of price sources ---
check "median of 3 (odd)"      "2"        "$(EMUX_PRINT_MEDIAN='3 1 2' "$T" btc)"
check "median of 2 (even avg)" "15"       "$(EMUX_PRINT_MEDIAN='10 20' "$T" btc)"
check "median ignores outlier" "73619.63" "$(EMUX_PRINT_MEDIAN='73625.47 73619.63 73614.0' "$T" btc)"

# --- aggregation: replay vendor prices, assert the median is rendered ---
aggf=$(mktemp "${TMPDIR:-/tmp}/emux-agg.XXXXXX")
printf 'gemini\t73625.47\ncoinbase\t73619.63\nkraken\t73614.0\n' >"$aggf"
agg=$(EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_STATE="0.0081 154.46" \
	EMUX_AGG_FIXTURE="$aggf" "$T" btcusd)
rm -f "$aggf"
check "median of 3 vendors rendered" '$73,619.63' "$agg"
check "aggregation keeps polled pct" '+0.81%'      "$agg"
check "health line shows live count" '3/3 live'    "$agg"

# --- richer stats: 24h high/low + range bar + bid/ask spread ---
# EMUX_STATE extended to "pct vol hi lo bid ask" (price sits near the low).
rich=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_PRICE=68115.41 \
	EMUX_STATE="-0.0418 27650000 71433.73 67777 68115.40 68115.42" "$T" btcusd)
check "stats shows 24h high"   '$71,433.73' "$rich"
check "stats shows 24h low"    '$67,777.00' "$rich"
check "range bar has a marker" '●'          "$rich"
check "spread shown in bps"    'spread'     "$rich"

# --- old 2-field EMUX_STATE still renders identically (regression guard) ---
compat=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_PRICE=74035.8 \
	EMUX_STATE="0.0081 154.45948915" "$T" btcusd)
check  "2-field state still formats pct" '+0.81%'  "$compat"
check  "2-field state still formats vol" '$154.46' "$compat"
absent "no range bar without hi/lo"      '●'       "$compat"

# --- non-USD quote (ethbtc) drops the $ prefix (agnostic pricing) ---
nonusd=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_PRICE=0.028 \
	EMUX_STATE="0.01 1234" "$T" ethbtc)
check  "non-USD shows bare price" '0.03'  "$nonusd"
absent "non-USD omits dollar sign" '$0.03' "$nonusd"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
