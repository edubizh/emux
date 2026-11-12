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

# --- base-asset derivation (banner text) ---
check "base btcusd -> BTC"   "BTC"  "$(EMUX_PRINT_BASE=1 "$T" btcusd)"
check "base ethusdc -> ETH"  "ETH"  "$(EMUX_PRINT_BASE=1 "$T" ethusdc)"
check "base DOGEUSD -> DOGE" "DOGE" "$(EMUX_PRINT_BASE=1 "$T" DOGEUSD)"

# --- render: positive 24h change ---
up=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_PRICE=74035.8 \
	EMUX_STATE="0.0081 154.45948915" "$T" btcusd)
check "price comma-formatted"   '$74,035.80' "$up"
check "pct positive formatted"  '+0.81%'      "$up"
check "volume abbreviated+base" '154.46 BTC'  "$up"

# --- render: negative 24h change + millions volume ---
down=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_PRICE=74035.8 \
	EMUX_STATE="-0.0123 2000000" "$T" btcusd)
check "pct negative formatted" '-1.23%' "$down"
check "volume abbreviated (M)" '2.00M'  "$down"

# --- figlet-absent fallback still shows the ticker ---
plain=$(EMUX_ONCE=1 EMUX_NO_COLOR=1 EMUX_NO_CLEAR=1 EMUX_NO_FIGLET=1 EMUX_PRICE=100 \
	EMUX_STATE="0 1" "$T" btcusd)
check "figlet fallback shows base" 'BTC' "$plain"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
