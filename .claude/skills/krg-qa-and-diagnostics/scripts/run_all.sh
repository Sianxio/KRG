#!/usr/bin/env bash
# run_all.sh - run every KRG QA check in order and print a pass/fail summary.
# Pass --online to also HEAD-test external links (needs internet).
# Exit 0 = every check passed. Exit = number of failing checks otherwise.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINK_FLAG="${1:-}"

FAILED=0
SUMMARY=""

run_check() { # <script> [arg]
  local name="$1"; shift
  echo ""
  echo "############################################################"
  echo "## $name $*"
  echo "############################################################"
  if bash "$SCRIPT_DIR/$name" "$@"; then
    SUMMARY="$SUMMARY
  PASS      $name $*"
  else
    SUMMARY="$SUMMARY
  FINDINGS  $name $*"
    FAILED=$((FAILED + 1))
  fi
}

run_check audit_placeholders.sh
if [ "$LINK_FLAG" = "--online" ]; then
  run_check check_links.sh --online
else
  run_check check_links.sh
fi
run_check check_consistency.sh
run_check check_structure.sh

echo ""
echo "############################################################"
echo "## KRG QA SUMMARY ($(date '+%Y-%m-%d %H:%M %Z'))"
echo "############################################################"
echo "$SUMMARY"
echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "OVERALL: PASS - all checks green."
else
  echo "OVERALL: $FAILED check(s) with findings. Fix via sibling skills"
  echo "(krg-launch-campaign for placeholders, krg-debugging-playbook for"
  echo "structure/consistency), then re-run this script until it prints PASS."
fi
exit "$FAILED"
