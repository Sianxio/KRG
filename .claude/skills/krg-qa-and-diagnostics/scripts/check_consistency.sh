#!/usr/bin/env bash
# check_consistency.sh - detect drift in the duplicated header/footer chrome
# between index.html and guide.html (there is no template system; edits must be
# mirrored by hand, so drift is a standing risk).
#
# What it compares:
#   1. The <nav>...</nav> block (with the per-page "active" class stripped,
#      since which link is active legitimately differs per page).
#   2. The <footer>...</footer> block, against a RECORDED ACCEPTABLE BASELINE:
#      as of 2026-07-06 the pages intentionally differ in exactly ONE line of
#      the Legal section (index.html = Amazon Associates disclosure,
#      guide.html = "Refund Policy · Privacy Policy · Terms").
#
# Exit 0 = nav identical AND footer diff exactly matches the recorded baseline.
# Exit 1 = drift (any other difference). Exit 2 = missing files.
# Portable: bash + awk/sed/diff. Leading whitespace is normalized before diffing.
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

TMPDIR_LOCAL="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_LOCAL"' EXIT

extract() { # extract <start-pattern> <end-pattern> <file> -> stdout, whitespace-normalized
  awk "/$1/,/$2/" "$3" | sed -E 's/^[[:space:]]+//'
}

DRIFT=0
echo "=== KRG chrome consistency check (index.html vs guide.html) ==="

# --- 1. Nav ------------------------------------------------------------------
extract '<nav ' '<\/nav>' "$INDEX" | sed -E 's/ active//' > "$TMPDIR_LOCAL/nav_index"
extract '<nav ' '<\/nav>' "$GUIDE" | sed -E 's/ active//' > "$TMPDIR_LOCAL/nav_guide"

if [ ! -s "$TMPDIR_LOCAL/nav_index" ] || [ ! -s "$TMPDIR_LOCAL/nav_guide" ]; then
  echo "[NAV]    FAIL - could not extract a <nav> block from one of the pages."
  DRIFT=1
elif diff "$TMPDIR_LOCAL/nav_index" "$TMPDIR_LOCAL/nav_guide" > "$TMPDIR_LOCAL/nav_diff"; then
  echo "[NAV]    OK - nav blocks identical (ignoring the per-page 'active' class)."
else
  echo "[NAV]    DRIFT - nav blocks differ (< = index.html, > = guide.html):"
  sed 's/^/         /' "$TMPDIR_LOCAL/nav_diff"
  DRIFT=1
fi

# --- 2. Footer ---------------------------------------------------------------
extract '<footer>' '<\/footer>' "$INDEX" > "$TMPDIR_LOCAL/foot_index"
extract '<footer>' '<\/footer>' "$GUIDE" > "$TMPDIR_LOCAL/foot_guide"

# Recorded acceptable footer differences as of 2026-07-06 (see SKILL.md).
# Only the change lines (< / >) are compared; line numbers may shift harmlessly.
cat > "$TMPDIR_LOCAL/foot_expected" <<'BASELINE'
< <p class="small">As an Amazon Associate I earn from qualifying purchases.</p>
> <p class="small">Refund Policy · Privacy Policy · Terms</p>
BASELINE

if [ ! -s "$TMPDIR_LOCAL/foot_index" ] || [ ! -s "$TMPDIR_LOCAL/foot_guide" ]; then
  echo "[FOOTER] FAIL - could not extract a <footer> block from one of the pages."
  DRIFT=1
else
  diff "$TMPDIR_LOCAL/foot_index" "$TMPDIR_LOCAL/foot_guide" \
    | grep -E '^[<>]' > "$TMPDIR_LOCAL/foot_actual" || true
  if [ ! -s "$TMPDIR_LOCAL/foot_actual" ]; then
    echo "[FOOTER] OK - footer blocks are now IDENTICAL."
    echo "         Note: baseline expected one known Legal-line difference;"
    echo "         if this convergence was intentional, update the BASELINE"
    echo "         heredoc in this script and the table in SKILL.md."
  elif diff -q "$TMPDIR_LOCAL/foot_actual" "$TMPDIR_LOCAL/foot_expected" >/dev/null; then
    echo "[FOOTER] OK - footers differ only in the recorded, known-acceptable way"
    echo "         (Legal line: Associates disclosure vs Refund/Privacy/Terms):"
    sed 's/^/         /' "$TMPDIR_LOCAL/foot_actual"
  else
    echo "[FOOTER] DRIFT - footer difference does NOT match the recorded baseline."
    echo "         Actual differing lines (< = index.html, > = guide.html):"
    sed 's/^/         /' "$TMPDIR_LOCAL/foot_actual"
    echo "         Recorded acceptable baseline (2026-07-06):"
    sed 's/^/         /' "$TMPDIR_LOCAL/foot_expected"
    DRIFT=1
  fi
fi

echo ""
if [ "$DRIFT" -eq 0 ]; then
  echo "RESULT: PASS - no unexpected chrome drift between the two pages."
  exit 0
else
  echo "RESULT: FINDINGS - chrome drift detected. See krg-debugging-playbook."
  exit 1
fi
