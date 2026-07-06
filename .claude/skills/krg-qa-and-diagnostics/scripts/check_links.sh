#!/usr/bin/env bash
# check_links.sh - inventory all external http(s) links on both pages.
# Default (offline): list de-duplicated external URLs. Always exit 0.
# With --online: HEAD-request each URL (10s timeout) and print status codes.
#   Online exit 0 = no dead links; exit 1 = at least one dead link (000/4xx/5xx,
#   except 403/405 which are reported as WARN: bot-blocking, verify in a browser).
# Portable: bash + grep/sed + curl (curl ships with macOS and most Linux).
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
INDEX="$REPO_ROOT/index.html"
GUIDE="$REPO_ROOT/guide.html"
MODE="offline"
[ "${1:-}" = "--online" ] && MODE="online"

for f in "$INDEX" "$GUIDE"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: missing file: $f" >&2
    exit 2
  fi
done

URLS=$(grep -ohE 'href="https?://[^"]+"' "$INDEX" "$GUIDE" \
        | sed -E 's/^href="//; s/"$//' \
        | sort -u)

COUNT=0
[ -n "$URLS" ] && COUNT=$(printf '%s\n' "$URLS" | wc -l | tr -d ' ')

echo "=== KRG external link check ($MODE mode) ==="
echo "Unique external http(s) URLs found in index.html + guide.html: $COUNT"

if [ "$COUNT" -eq 0 ]; then
  echo "(none found - note: placeholder href=\"#\" links are NOT external; see audit_placeholders.sh)"
  exit 0
fi

if [ "$MODE" = "offline" ]; then
  printf '%s\n' "$URLS" | sed 's/^/  /'
  echo ""
  echo "RESULT: inventory only (offline). Re-run with --online to test each URL."
  exit 0
fi

# --- Online mode -------------------------------------------------------------
FAIL=0
echo ""
printf '%-8s %s\n' "STATUS" "URL"
while IFS= read -r url; do
  code=$(curl -sS -o /dev/null -I -L -m 10 -w '%{http_code}' "$url" 2>/dev/null || echo "000")
  case "$code" in
    2*|3*) verdict="OK" ;;
    403|405) verdict="WARN (server blocks scripted HEAD requests - verify in a browser)" ;;
    *) verdict="FAIL"; FAIL=$((FAIL + 1)) ;;
  esac
  printf '%-8s %s  %s\n' "$code" "$url" "[$verdict]"
done <<EOF
$URLS
EOF

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: PASS - no dead external links (WARNs need a manual browser check)."
  exit 0
else
  echo "RESULT: FINDINGS - $FAIL dead external link(s)."
  exit 1
fi
