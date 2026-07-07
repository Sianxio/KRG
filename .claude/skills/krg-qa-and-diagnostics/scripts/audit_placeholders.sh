#!/usr/bin/env bash
# audit_placeholders.sh - count every placeholder link that must be replaced before launch.
# Exit 0 = zero placeholders remain (launch-ready). Exit 1 = placeholders found.
# Portable: bash + grep/sed/awk only. Works on macOS and Linux, from any directory.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
INDEX="$REPO_ROOT/index.html"
GUIDE="$REPO_ROOT/guide.html"

for f in "$INDEX" "$GUIDE"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: missing file: $f" >&2
    exit 2
  fi
done

# --- Counts -----------------------------------------------------------------
# Affiliate buttons in index.html that still point at "#"
AFFILIATE_PH=$(grep 'btn-affiliate' "$INDEX" | grep -c 'href="#"' || true)

# Placeholder Etsy shop name in guide.html
YOURSHOP=$(grep -o 'YourShop' "$GUIDE" | wc -l | tr -d ' ')

# Patreon links still "#" (both pages)
PATREON_IDX=$(grep 'Patreon' "$INDEX" | grep -c 'href="#"' || true)
PATREON_GDE=$(grep 'Patreon' "$GUIDE" | grep -c 'href="#"' || true)
PATREON_PH=$((PATREON_IDX + PATREON_GDE))

# Every href="#" on each page (one per line in this codebase; -o counts all)
HASH_IDX=$(grep -o 'href="#"' "$INDEX" | wc -l | tr -d ' ')
HASH_GDE=$(grep -o 'href="#"' "$GUIDE" | wc -l | tr -d ' ')
OTHER_HASH=$((HASH_IDX + HASH_GDE - AFFILIATE_PH - PATREON_PH))

TOTAL=$((AFFILIATE_PH + YOURSHOP + PATREON_PH + OTHER_HASH))

# --- Report -----------------------------------------------------------------
echo "=== KRG placeholder audit ==="
printf '%-45s %5s  %s\n' "CHECK" "COUNT" "LAUNCH TARGET"
printf '%-45s %5s  %s\n' "Affiliate links still href=\"#\" (index.html)" "$AFFILIATE_PH" "0"
printf '%-45s %5s  %s\n' "Etsy 'YourShop' placeholders (guide.html)" "$YOURSHOP" "0"
printf '%-45s %5s  %s\n' "Patreon href=\"#\" links (both pages)" "$PATREON_PH" "0"
printf '%-45s %5s  %s\n' "Other href=\"#\" links (both pages)" "$OTHER_HASH" "0"
printf '%-45s %5s  %s\n' "TOTAL placeholders" "$TOTAL" "0"

if [ "$AFFILIATE_PH" -gt 0 ]; then
  echo ""
  echo "--- Affiliate placeholder locations (index.html) ---"
  grep -n 'btn-affiliate' "$INDEX" | grep 'href="#"' | sed -E 's/^([0-9]+):.*/  index.html:\1/'
fi
if [ "$YOURSHOP" -gt 0 ]; then
  echo ""
  echo "--- 'YourShop' locations (guide.html) ---"
  grep -n 'YourShop' "$GUIDE" | sed -E 's/^([0-9]+):.*/  guide.html:\1/'
fi
if [ "$PATREON_PH" -gt 0 ]; then
  echo ""
  echo "--- Patreon placeholder locations ---"
  grep -n 'Patreon' "$INDEX" | grep 'href="#"' | sed -E 's/^([0-9]+):.*/  index.html:\1/'
  grep -n 'Patreon' "$GUIDE" | grep 'href="#"' | sed -E 's/^([0-9]+):.*/  guide.html:\1/'
fi
if [ "$OTHER_HASH" -gt 0 ]; then
  echo ""
  echo "--- Other href=\"#\" locations (excluding affiliate/Patreon lines) ---"
  grep -n 'href="#"' "$INDEX" | grep -v 'btn-affiliate' | grep -v 'Patreon' | sed -E 's/^([0-9]+):.*/  index.html:\1/'
  grep -n 'href="#"' "$GUIDE" | grep -v 'btn-affiliate' | grep -v 'Patreon' | sed -E 's/^([0-9]+):.*/  guide.html:\1/'
fi

echo ""
if [ "$TOTAL" -eq 0 ]; then
  echo "RESULT: PASS - no placeholders remain. Links are launch-ready."
  exit 0
else
  echo "RESULT: FINDINGS - $TOTAL placeholder link(s) remain. Site is NOT launch-ready."
  exit 1
fi
