#!/usr/bin/env bash
# check_structure.sh - HTML structural sanity check using python3 stdlib only.
#   * flags mismatched / stray / unclosed tags (where html.parser can detect them)
#   * verifies every .product-card has a data-category that appears in the
#     page's filter buttons' data-filter values (parses BOTH attribute sets)
#   * verifies each page references styles.css and script.js
# Exit 0 = all checks pass. Exit 1 = findings. Exit 2 = missing files/python3.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

PY="$(command -v python3 || true)"
if [ -z "$PY" ]; then
  echo "ERROR: python3 not found on PATH." >&2
  exit 2
fi

"$PY" - "$REPO_ROOT" <<'PYEOF'
import sys, os
from html.parser import HTMLParser

repo = sys.argv[1]
VOID = {"area","base","br","col","embed","hr","img","input","link","meta",
        "param","source","track","wbr"}

class Checker(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []          # (tag, line-opened)
        self.errors = []
        self.cards = []          # (line, data-category or None)
        self.filters = []        # data-filter values in DOM order
        self.stylesheets = set() # <link rel=stylesheet href=...>
        self.scripts = set()     # <script src=...>

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        line = self.getpos()[0]
        if tag not in VOID:
            self.stack.append((tag, line))
        cls = (a.get("class") or "").split()
        if "product-card" in cls:
            self.cards.append((line, a.get("data-category")))
        if "filter-btn" in cls and a.get("data-filter"):
            self.filters.append(a["data-filter"])
        if tag == "link" and "stylesheet" in (a.get("rel") or ""):
            self.stylesheets.add(a.get("href"))
        if tag == "script" and a.get("src"):
            self.scripts.add(a["src"])

    def handle_startendtag(self, tag, attrs):  # <tag ... />
        self.handle_starttag(tag, attrs)
        if tag not in VOID and self.stack and self.stack[-1][0] == tag:
            self.stack.pop()

    def handle_endtag(self, tag):
        if tag in VOID:
            return
        line = self.getpos()[0]
        if self.stack and self.stack[-1][0] == tag:
            self.stack.pop()
        elif tag in [t for t, _ in self.stack]:
            while self.stack and self.stack[-1][0] != tag:
                t, l = self.stack.pop()
                self.errors.append(
                    f"line {line}: </{tag}> found while <{t}> "
                    f"(opened line {l}) is still open (unclosed <{t}>?)")
            if self.stack:
                self.stack.pop()
        else:
            self.errors.append(
                f"line {line}: stray </{tag}> with no matching open tag")

findings = 0
print("=== KRG HTML structure check (python3 html.parser) ===")

pages = [("index.html", True), ("guide.html", False)]
all_filters = {}

for name, expects_cards in pages:
    path = os.path.join(repo, name)
    if not os.path.isfile(path):
        print(f"ERROR: missing file: {path}")
        sys.exit(2)
    c = Checker()
    with open(path, encoding="utf-8") as fh:
        c.feed(fh.read())
    c.close()
    leftovers = [(t, l) for t, l in c.stack if t not in ("html", "body")]
    for t, l in leftovers:
        c.errors.append(f"<{t}> opened line {l} is never closed")

    print(f"\n--- {name} ---")
    if c.errors:
        print(f"[TAGS]     FAIL - {len(c.errors)} tag problem(s):")
        for e in c.errors:
            print(f"           {e}")
        findings += len(c.errors)
    else:
        print("[TAGS]     OK - no mismatched, stray, or unclosed tags detected.")

    css_ok = "styles.css" in c.stylesheets
    js_ok = "script.js" in c.scripts
    print(f"[ASSETS]   {'OK ' if css_ok else 'FAIL'} - stylesheet refs: {sorted(c.stylesheets)}"
          + ("" if css_ok else "  (styles.css NOT referenced)"))
    print(f"[ASSETS]   {'OK ' if js_ok else 'FAIL'} - script refs:     {sorted(c.scripts)}"
          + ("" if js_ok else "  (script.js NOT referenced)"))
    findings += (0 if css_ok else 1) + (0 if js_ok else 1)

    filt = [f for f in c.filters if f != "all"]
    all_filters[name] = filt
    if expects_cards:
        print(f"[FILTERS]  data-filter values (excluding 'all'): {filt}")
        print(f"[CARDS]    {len(c.cards)} .product-card element(s) found "
              f"(pre-launch baseline: 16)")
        bad = [(l, cat) for l, cat in c.cards if cat is None or cat not in filt]
        missing = [(l, cat) for l, cat in c.cards if cat is None]
        if not c.cards:
            print("[CARDS]    FAIL - expected product cards on this page, found none.")
            findings += 1
        elif bad:
            print(f"[CARDS]    FAIL - {len(bad)} card(s) with missing/unknown data-category:")
            for l, cat in bad:
                print(f"           line {l}: data-category={cat!r}")
            findings += len(bad)
        else:
            cats = sorted({cat for _, cat in c.cards})
            print(f"[CARDS]    OK - every card has a data-category within the "
                  f"filter set; categories used: {cats}")
    else:
        if c.cards:
            print(f"[CARDS]    NOTE - {len(c.cards)} product card(s) on {name}; "
                  f"unexpected for the sales page (baseline: 0).")
        else:
            print("[CARDS]    OK - no product cards expected here, none found.")

print()
if findings == 0:
    print("RESULT: PASS - structure checks all green.")
    sys.exit(0)
print(f"RESULT: FINDINGS - {findings} structural problem(s). "
      "See krg-debugging-playbook.")
sys.exit(1)
PYEOF
