---
name: krg-debugging-playbook
description: >
  Symptom-triage playbook for the Korean Ramen Guide site. Load when something
  looks broken, doesn't update, doesn't filter, or looks wrong — e.g. "filter
  buttons do nothing", "my new product card vanished", "page looks unstyled",
  "I edited the footer but only one page changed", "clicking a product button
  jumps to the top", "the live site doesn't show my change", "it looks broken
  on my phone". NOT for adding content (krg-content-catalog), deploying or
  rolling back (krg-preview-and-deploy), or replacing placeholder links
  (krg-launch-campaign).
---

# KRG Debugging Playbook

Symptom → cause → experiment → fix, for a 5-file static site with no build step.
Anything you see in the browser comes straight from `index.html`, `guide.html`,
`styles.css`, and `script.js` — so every bug is in one of those four files, or
in what got deployed.

**When to use:** something is visibly wrong or mysteriously unchanged, locally or on the live site.
**When NOT (use sibling):** adding/editing products → `krg-content-catalog` · previewing locally, deploying, or rolling back a bad deploy → `krg-preview-and-deploy` · replacing `href="#"` placeholders with real affiliate links → `krg-launch-campaign` · running the full audit scripts → `krg-qa-and-diagnostics` · how the HTML↔JS contract works → `krg-architecture-and-conventions`.

All commands below are copy-pasteable and were run against this repo on 2026-07-06. Run them **from inside the website folder** (the folder containing `index.html`) — in a terminal, type `cd` followed by a space, drag the folder onto the terminal window, press Enter.

## Jargon (defined once, used everywhere below)

| Term | Meaning |
|---|---|
| **Devtools console** | A hidden panel in your browser that shows errors from the page. Open it: press `F12` (or right-click the page → "Inspect"), then click the **Console** tab. Red text = an error. |
| **Cache** | Your browser saves copies of files so pages load faster. Sometimes it shows you a *stale* (old) copy after you've changed the file. |
| **Hard refresh** | Reload the page while skipping the cache: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac). Always try this before assuming a change "didn't work". |
| **Local vs live** | *Local* = the files on your computer, opened directly or via a preview server. *Live* = the site Netlify serves to the world. They can differ if you haven't deployed. |

## Universal 5-step triage ladder (start here every time)

1. **Open the devtools console** (`F12` → Console) on the broken page. Copy any red error text word-for-word — it usually names the file and line number.
2. **Hard refresh** (`Ctrl+Shift+R` / `Cmd+Shift+R`). If the problem vanishes, it was cache. Done.
3. **Compare local vs live.** Open the file from your own computer in the browser. Works locally but not live? It's a deploy problem → Symptom 6. Broken in both? It's in the files.
4. **Isolate by undoing your last edit.** Whatever you touched most recently is the prime suspect. Undo it (Ctrl+Z in your editor, save, hard refresh). Problem gone? The bug is inside that edit — redo it in smaller pieces. Change-tracking discipline lives in `krg-change-control`.
5. **Ask for help with the exact error text** — paste the console message, the page (index or guide), and what you last changed. "It's broken" is undebuggable; a quoted error is a 2-minute fix.

## Symptom triage table

| Symptom | Likely cause(s) | Discriminating experiment | Fix / route |
|---|---|---|---|
| Filter buttons do nothing | script.js not loaded; JS error earlier in file; button missing `data-filter` | Console shows 404 for script.js? red error? `node --check script.js` | §1 |
| Card doesn't filter / vanishes | bad or missing `data-category`; broken card markup | grep category values; count `<div>` vs `</div>` | §2 |
| Page unstyled / styles wrong | stylesheet path typo; stale cache; broken CSS edit | Console 404 for styles.css; hard refresh; devtools struck-through rule | §3 |
| Header/footer changed on one page only | both-pages duplication trap | diff the two pages' footer blocks | §4 |
| Product button jumps to page top | `href` still `"#"` placeholder | grep for `href="#"` | §5 → `krg-launch-campaign` |
| Live site missing my change | never deployed; wrong folder dragged; not pushed; Netlify built older commit | `curl` live URL and grep for the change; check Netlify deploy log | §6 → rollback: `krg-preview-and-deploy` |
| Broken on phone | 768px/480px breakpoints in styles.css | devtools device toolbar | §7 |

## §1 Filter buttons do nothing

The filter logic (`script.js` lines 9–32) attaches a click handler to every `.filter-btn`, reads its `data-filter`, and shows/hides each `.product-card` by comparing against its `data-category`. Three ways this dies:

**a) script.js isn't loading.** Both pages load it as the last tag in `<body>`. Verify the tag exists and is spelled right:

```bash
grep -n '<script src=' index.html guide.html
```

Expected (verified): `index.html:319` and `guide.html:301`, both `<script src="script.js"></script>`. Discriminator: devtools console shows a red **404** for script.js, or the Network tab (next to Console) lists script.js in red. Fix: correct the filename/path in the tag.

**b) A JS error earlier in the file kills everything.** One syntax error anywhere in script.js stops the whole file — filters, smooth scroll, click logging, and the injected fadeIn style all die together (see Latent traps). Discriminator: console shows a red error naming `script.js` and a line number. Machine check:

```bash
node --check script.js
```

Verified output on the current file: `syntax OK` (node prints nothing on success; the `&& echo` pattern in Provenance shows it). Fix: undo the last script.js edit, or fix the named line.

**c) One specific button is dead but others work.** That button is missing its `data-filter` attribute (handler reads `null`, matches nothing). Discriminator: list the buttons —

```bash
grep -o 'data-filter="[^"]*"' index.html
```

Verified output: exactly `all`, `essential`, `optional`, `tools` — one per button (index.html lines 46–49). Any button in the HTML without a line here is the broken one.

## §2 New/edited product card doesn't filter correctly or vanishes

Every card needs `data-category` set to exactly one of **essential / optional / tools** (lowercase — the comparison at script.js line 22 is exact, `category === filter`). A missing value means the card shows under "All Products" (`filter === 'all'` short-circuits) but disappears under every specific filter. A misspelled value (`"Essential"`, `"tool"`) behaves the same.

**The one grep to run** — list every category value and its count, then compare by eye against the four filter values from §1c:

```bash
grep -o 'data-category="[^"]*"' index.html | sort | uniq -c
```

Verified baseline: `8 essential`, `4 optional`, `4 tools` (16 cards total). Any value not in the filter set, or a count that doesn't match how many cards you expect, is your bug.

**Card markup broken (unclosed div swallows siblings).** A `<div class="product-card">` missing its closing `</div>` makes the browser nest the *next* cards inside it — filtering the parent then hides all its accidental children, so several cards "vanish" at once. Discriminator: count tags —

```bash
grep -o '<div' index.html | wc -l; grep -o '</div>' index.html | wc -l
```

Verified baseline: **106 and 106** (guide.html: 86 and 86). Unequal counts = unclosed div; the culprit is almost always the card you last edited. Card-authoring rules live in `krg-content-catalog`; the HTML↔JS contract itself is documented in `krg-architecture-and-conventions`.

## §3 Styles look wrong / page unstyled

Three causes, in order of likelihood:

1. **Stale cache.** Hard refresh first. This fixes the majority of "my CSS change didn't apply" reports.
2. **Stylesheet path typo.** Both pages link the stylesheet at line 9: `<link rel="stylesheet" href="styles.css">`. Verify:

   ```bash
   grep -n 'stylesheet' index.html guide.html
   ```

   Verified: line 9 in both files. Discriminator for a typo: the page renders as plain black-on-white text and the console/Network tab shows a 404 for the CSS file.
3. **A broken CSS edit.** A missing `}` or a typo'd property makes the browser silently skip rules *from the error onward* — no console error for CSS. How to spot it: right-click the wrongly-styled element → Inspect → in the **Styles** panel, your rule is either absent or shown with a yellow warning / struck through. Fix: undo the last styles.css edit and reapply in smaller pieces. Site-wide color/spacing tokens are the `:root` custom properties at the top of styles.css.

## §4 I changed the header/footer but only one page shows it

`index.html` and `guide.html` each carry their **own full copy** of the header and footer — there is no shared template. Editing one page never touches the other. (Full both-pages rule: `krg-architecture-and-conventions`.)

Compare the two footers directly:

```bash
diff <(sed -n '/<footer>/,/<\/footer>/p' index.html) <(sed -n '/<footer>/,/<\/footer>/p' guide.html)
```

Verified baseline output — exactly one *intentional* difference (the Legal line):

```
16c16
<                     <p class="small">As an Amazon Associate I earn from qualifying purchases.</p>
---
>                     <p class="small">Refund Policy · Privacy Policy · Terms</p>
```

Same trick for headers (swap `footer` → `header`); verified baseline difference there is only which nav link has `class="nav-link active"`. Any *other* line in the diff is your missed edit — apply it to the lagging page.

## §5 Clicking a product button jumps to the top of the page

This is the **signature symptom of un-replaced affiliate links**, not a bug in the code. Trace: every "View on Amazon" button is `<a href="#" class="btn btn-primary btn-affiliate" ...>` (e.g. index.html line 70). The smooth-scroll handler in script.js (lines 35–49) intercepts clicks on `a[href^="#"]` but explicitly checks `if (href !== '#')` at line 38 — a **bare `#` falls through** to default browser behavior, which is "navigate to the top of the current page". So: click → jump to top → no store, no commission.

Count the remaining placeholders:

```bash
grep -c 'href="#"' index.html guide.html
```

Verified baseline: **index.html: 17** (16 Amazon buttons + 1 footer Patreon link), **guide.html: 1** (footer Patreon link) (baseline 2026-07-06 — authoritative source: run `bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh`). The Etsy buttons in guide.html are a separate placeholder (`https://www.etsy.com/shop/YourShop`, lines 48/210/267) — they *do* navigate, just to nowhere useful. Replacing all of these with real links is the launch-blocking task: → `krg-launch-campaign` (process) and `krg-affiliate-monetization-reference` (link formats).

## §6 Live site doesn't show my change

Local file is right, live site is wrong. Four causes: you never deployed; you dragged the wrong folder into Netlify; you edited locally but never pushed to GitHub (auto-deploy builds what's on GitHub, not on your disk); or Netlify is showing an older deploy.

**Discriminating experiments:**

1. **Ask the live site what it's serving.** Pick a phrase that exists only in your new edit and grep the live page for it (replace the URL with your real Netlify URL):

   ```bash
   curl -s https://YOUR-SITE.netlify.app/index.html | grep -c 'phrase from your edit'
   ```

   `0` = live site doesn't have it → deploy problem confirmed. (Pattern verified against a local server: `curl -s http://localhost:8123/index.html | grep -c 'Gochugaru'` → `1`.) A `curl -s -o /dev/null -w '%{http_code}\n' https://YOUR-SITE.netlify.app/script.js` returning anything but `200` means the file itself is missing from the deploy.
2. **Check the Netlify deploy log timestamp.** Netlify dashboard → your site → **Deploys**. Is the newest deploy *after* your edit? If auto-deploying from GitHub, does its commit message match your latest push (`git log -1 --oneline` locally vs. the deploy's commit)? An older commit = you didn't push, or the build ran before your push.
3. **Rule out cache last.** Hard refresh the live URL; if curl already showed the change, the only remaining gap was your browser.

Fixes — redeploy, push, or roll back to a known-good deploy — live in `krg-preview-and-deploy`.

## §7 Looks broken on phone

styles.css has exactly two responsive breakpoints (verified): `@media (max-width: 768px)` at **line 785** and `@media (max-width: 480px)` at **line 823**. Anything you add outside those blocks applies to phones too unless overridden inside them.

Reproduce without a phone: devtools → click the **device toolbar** icon (a phone/tablet outline, top-left of the devtools panel, or `Ctrl+Shift+M` / `Cmd+Shift+M`) → pick "iPhone" or drag the viewport width across 768px and 480px and watch where the layout snaps. If it breaks only below one of those widths, the bug is inside that media query block (or a missing override in it). Then inspect the broken element (§3, cause 3) to see which rule wins.

## Latent traps — identified by static audit 2026-07-06, no incident yet

None of these has ever bitten (the site files saw no functional change between commit `b863b95`, 2026-02-04, and the copy-only ratings/claims cleanup of 2026-07-07; no reverts — verify: `git log --oneline -- index.html guide.html styles.css script.js README.md`). They are wired into the current code and *will* produce confusing symptoms someday:

1. **fadeIn lives inside script.js.** The `@keyframes fadeIn` CSS is injected at runtime by script.js lines 63–76 (`document.createElement('style')`). If script.js fails to load or has a syntax error, the animation definition vanishes *along with* the filters — one root cause, two symptoms. Don't chase them separately; run §1b first.
2. **Inline `display` styles can override future CSS.** Filtering sets `card.style.display = 'block'` / `'none'` directly on each card (script.js lines 23/27). Inline styles beat stylesheet rules, so if you later restyle `.product-card` with `display: flex` or `grid` in styles.css, cards will look right on page load but **snap back to `block`** the first time anyone clicks a filter. If a card's layout "breaks only after filtering", this is why.
3. **Smooth scroll intercepts ALL `#` anchors.** The handler binds to every `a[href^="#"]` on the page (script.js line 35). Any future in-page nav (e.g. `href="#tools"` jump links) gets `preventDefault()` + `scrollIntoView` — and if the target id doesn't exist, the click **silently does nothing** (line 41's `if (target)` guard). A "dead" in-page link usually means the `id` is missing or misspelled, not that the link is broken.
4. **console.log is not analytics.** The "click tracking" on `.btn-affiliate` (script.js lines 52–59) only prints `Affiliate click: <name>` to the visitor's own devtools console. Nothing is recorded, sent, or countable. Do not report "tracking is set up" — for real measurement, → `krg-measurement-and-experiments`.

## Provenance & maintenance

Verified against the working tree on **2026-07-06**; reviewed & corrected 2026-07-07; line anchors re-derived after the 2026-07-07 ratings/claims cleanup (index.html 321 lines, guide.html 303, styles.css 835, script.js 76). Re-verify the load-bearing facts in one pass from the site folder:

```bash
grep -o 'data-category="[^"]*"' index.html | sort | uniq -c            # expect 8 essential / 4 optional / 4 tools
grep -o 'data-filter="[^"]*"' index.html                               # expect all, essential, optional, tools
grep -c 'href="#"' index.html guide.html                               # expect 17 and 1 until links are replaced
grep -n '<script src=' index.html guide.html                           # expect last tag in each body
grep -n '@media' styles.css                                            # expect lines ~785 and ~823
node --check script.js && echo "syntax OK"                             # expect syntax OK
```

If any expectation fails, the site changed — update the matching section (and its baseline numbers) before trusting this playbook.
