---
name: krg-architecture-and-conventions
description: >
  Load this skill whenever you are about to READ, EDIT, or REASON ABOUT the structure of the
  Korean Ramen Guide (KRG) site — index.html, guide.html, styles.css, or script.js. It explains
  how the 4 site files fit together, the "both-pages rule" for copy-pasted header/footer chrome,
  the HTML-attribute contract that script.js depends on (data-filter / data-category /
  .btn-affiliate), the CSS color palette and breakpoints, the invariants every change must
  preserve, and the known weak points. Load it BEFORE any structural HTML/CSS/JS edit or
  when answering "how does this site work?". Do NOT load it for:
  deciding whether a change is allowed (krg-change-control), diagnosing a broken page symptom
  (krg-debugging-playbook), previewing or deploying (krg-preview-and-deploy), product/copy
  content details (krg-content-catalog), Amazon/Etsy/FTC rules (krg-affiliate-monetization-reference),
  or README/copy style (krg-docs-and-writing).
---

# KRG Architecture & Conventions

This skill is the map of how the Korean Ramen Guide site is built and the rules that keep it
working. Every fact below was verified against the repo on 2026-07-06 (see "Provenance &
maintenance" at the end for one-line re-check commands).

**How to run the commands in this file:** open a terminal, go to the KRG folder
(`cd /home/user/KRG` — `cd` means "change directory", i.e. move into that folder), then
copy-paste the command. All commands are read-only; none of them change any file.

## When to use this skill

- Before editing `index.html`, `guide.html`, `styles.css`, or `script.js` for any reason.
- Before adding, removing, or re-categorizing a product card.
- Before touching the header, footer, or any button/link that appears on both pages.
- When a zero-context AI session needs to understand the site layout fast.

## When NOT to use it (use a sibling instead)

| Your question | Go to |
|---|---|
| "Am I allowed to make this change? What checks gate it?" | `krg-change-control` |
| "The page looks broken / a button stopped working" | `krg-debugging-playbook` |
| "How do I preview locally or deploy to Netlify?" | `krg-preview-and-deploy` |
| "What products/copy exist? How do I add a product correctly?" | `krg-content-catalog` |
| "How do I add a new HTML page?" | `krg-content-catalog` §3.7 (Add a new HTML page) |
| "Amazon Associates / Etsy / FTC disclosure rules" | `krg-affiliate-monetization-reference` |
| "How do I prove a change works? Audit scripts?" | `krg-qa-and-diagnostics` |
| "What should we build next for revenue?" | `krg-growth-frontier` |

## 1. The architecture in one picture

```
index.html  (shopping list: 16 product cards)──┐
                                               ├── styles.css  (one shared stylesheet, 835 lines)
guide.html  (sales page for the $7.99 PDF)  ───┤
                                               └── script.js   (one shared script, 76 lines)
README.md   (deploy manual + business plan — not loaded by the site)
```

- **Static site**: plain HTML/CSS/JS files. There is no build step, no `package.json`, no
  framework, no server code. What is in the files is exactly what visitors' browsers receive.
- **No templating engine** (a templating engine is a tool that generates repeated HTML — like
  headers — from one shared source; this site has none). Consequence: the shared "chrome"
  (header navigation and footer) is **copy-pasted** into both HTML files.

### The both-pages rule

**Any change to the header or footer must be made in BOTH `index.html` AND `guide.html`,
or the two pages will silently drift apart.**

The duplicated blocks (line numbers verified 2026-07-06):

| Block | index.html | guide.html | Intentional difference |
|---|---|---|---|
| Header `<header>…</header>` | lines 13–23 | lines 13–23 | which nav link has `class="nav-link active"` (highlights the current page) |
| Footer `<footer>…</footer>` | lines 297–317 | lines 279–299 | one line in the "Legal" column: index says "As an Amazon Associate I earn from qualifying purchases."; guide says "Refund Policy · Privacy Policy · Terms" |

The mid-page and final CTA boxes ("CTA" = call to action, the big red buy boxes) are **not**
verbatim copies — each page has its own (index: `.cta-box` and `.final-cta`; guide:
`.cta-box-large` and `.final-cta-box`) — but they share CSS classes in `styles.css`, so a
style change to one can affect the other page. Check both pages after styling changes.

**Verify the pages haven't drifted** (these diffs find the blocks by tag, so they keep working
even if line numbers move; expected output is ONLY the intentional differences listed above):

```bash
diff <(sed -n '/<header>/,/<\/header>/p' index.html) <(sed -n '/<header>/,/<\/header>/p' guide.html)
diff <(sed -n '/<footer>/,/<\/footer>/p' index.html) <(sed -n '/<footer>/,/<\/footer>/p' guide.html)
```

Any output beyond the two intentional differences means drift — fix it in both files.
The same baseline is also encoded in `check_consistency.sh` (`krg-qa-and-diagnostics`);
if the intentional differences ever change deliberately, update that script AND this
section in the same change. Note: the script compares only index.html vs guide.html
today — extend it when a third page is added (see `krg-content-catalog` §3.7).

## 2. The HTML↔JS contract

`script.js` runs on both pages and finds elements by class names and "data attributes"
(custom HTML attributes starting with `data-`, used to pass information to JavaScript).
If the HTML stops matching these exact names, features break with no error message.

**Contract rules:**

1. **Filter buttons** carry `data-filter` with exactly one of: `all`, `essential`, `optional`,
   `tools`. All four exist on index.html lines 46–49.
2. **Every product card** (`class="product-card"`) carries `data-category` matching one of the
   non-`all` filter values. Current tally (verified): 8 `essential` + 4 `optional` + 4 `tools`
   = 16 cards. The matching logic (script.js lines 19–29):

   ```js
   productCards.forEach(card => {
       const category = card.getAttribute('data-category');

       if (filter === 'all' || category === filter) {
           card.style.display = 'block';
           // Add fade-in animation
           card.style.animation = 'fadeIn 0.5s';
       } else {
           card.style.display = 'none';
       }
   });
   ```

   A card with a typo'd or missing `data-category` shows under "All Products" but vanishes
   under every specific filter.
3. **`.btn-affiliate` is the click-logging hook.** script.js lines 52–59 attach a listener to
   every element with that class and log the product name to the browser console:

   ```js
   const affiliateLinks = document.querySelectorAll('.btn-affiliate');
   affiliateLinks.forEach(link => {
       link.addEventListener('click', function() {
           const productName = this.closest('.product-card').querySelector('h4').textContent;
           console.log('Affiliate click:', productName);
   ```

   Two hidden requirements inside that snippet: a `.btn-affiliate` must live **inside a
   `.product-card`**, and that card must contain an **`<h4>`** (the product title) — otherwise
   clicking throws a JavaScript error. Keep the class if you want click logging; this is the
   place where real analytics would plug in later.
4. **Smooth scroll** intercepts only links whose `href` starts with `#` and is not the bare
   `"#"` (script.js lines 35–49):

   ```js
   document.querySelectorAll('a[href^="#"]').forEach(anchor => {
       anchor.addEventListener('click', function (e) {
           const href = this.getAttribute('href');
           if (href !== '#') {
               e.preventDefault();
   ```

   Side effect worth knowing: all 16 Amazon buttons and both Patreon footer links currently
   have `href="#"` (placeholders — see krg-launch-campaign), so today they fall into the
   `href === '#'` branch and do a default jump-to-top. Once real URLs replace `#`, this code
   ignores them entirely (they don't start with `#`), which is correct.

## 3. The CSS system

### Palette — CSS custom properties

A "CSS custom property" is a named, reusable value declared once and referenced with
`var(--name)`. The entire palette lives in `:root` (styles.css lines 12–20). **Always use
`var(--…)` instead of retyping hex codes**, so a future rebrand is a 7-line change:

| Property | Value | Used for |
|---|---|---|
| `--red` | `#D32F2F` | primary brand color: active nav, CTAs, buy buttons, prices |
| `--orange` | `#FF6F00` | secondary accent: `.btn-primary` (Amazon buttons), disclosure border (the `.product-rating` rule still references it but has been unused since the 2026-07-07 rating removal) |
| `--dark` | `#212121` | body text, footer background |
| `--gray` | `#757575` | secondary text |
| `--light` | `#F5F5F5` | light backgrounds, borders |
| `--cream` | `#FFF8E1` | disclosure banner, solution boxes |
| `--white` | `#FFFFFF` | page background, text on dark |

Known exceptions (hard-coded hexes that bypass the variables, all verified): `#E65100`
(`.btn-primary:hover`, line 100) and `#B71C1C` (dark-red gradient end in `.pdf-cover`,
`.cta-box`, `.cta-box-large`, lines 255/438/464). Treat these as the darker hover/gradient
shades of `--orange` and `--red`.

### Naming conventions

- **Buttons**: everything starts from base class `.btn`, then adds a variant:
  `.btn-primary` (orange, Amazon), `.btn-secondary` (outlined red), `.btn-cta`,
  `.btn-cta-large`, `.btn-buy`, `.btn-buy-large`, `.btn-buy-huge` (red buy buttons, ascending
  size), plus behavior class `.btn-affiliate` (JS hook, full-width; see section 2). New
  buttons: reuse a variant; if you must invent one, follow `.btn-<purpose>`.
- **Page sections**: one class per section, named after content, styled in same-named CSS
  comment blocks: `.hero`, `.guide-hero`, `.disclosure`, `.filters`, `.products`,
  `.whats-included`, `.preview-section`, `.problem-solution`, `.cta-mid`, `.faq`,
  `.final-cta`, `.final-cta-section`, `footer`.
- **Layout**: `.container` = centered 1200px-max wrapper with 20px side padding; every
  section wraps its content in one.

### Sticky header

`header` (styles.css lines 36–42) uses `position: sticky; top: 0; z-index: 100`.
"Sticky" means the header scrolls with the page until it hits the top edge, then stays
pinned. "z-index" is the stacking order — higher numbers draw on top; 100 keeps the header
above page content. **If you add any overlay (modal, popup, banner), give it a z-index above
100 or the header will cover it.**

### Responsive breakpoints

A "breakpoint" is a screen width where the layout changes, via `@media (max-width: …)` rules.

| Breakpoint | Line | What changes |
|---|---|---|
| `768px` (tablets/phones) | 785 | hero headings shrink to 2rem; guide hero 2-column grid → 1 column; product grid → 1 column; problem/solution rows → 1 column with the arrow rotated 90°; nav gap tightens; filter tabs left-align; big buy buttons shrink |
| `480px` (small phones) | 823 | container padding 20px → 15px; logo 1.5rem → 1.2rem; index hero heading → 1.75rem |

Rule of thumb: any new multi-column layout needs a 768px rule collapsing it to one column.

## 4. Invariants — must hold after every change

| # | Invariant | Why |
|---|---|---|
| 1 | Every affiliate link keeps `rel="nofollow"` and `target="_blank"` | `rel="nofollow"` tells search engines not to treat it as an endorsement (expected for paid/affiliate links); `target="_blank"` opens in a new tab so the visitor doesn't lose your site. Currently 16/16 Amazon buttons have both. |
| 2 | The Amazon disclosure banner (`.disclosure`, index.html lines 36–40) stays on index.html, above the products | Amazon Associates and FTC rules require disclosure near affiliate links (rules detailed in `krg-affiliate-monetization-reference`). Removing it risks the affiliate account. |
| 3 | Every `data-category` value matches an existing `data-filter` button value (`essential`, `optional`, `tools`) | Otherwise the card disappears under filtering (section 2). Adding a new category means adding BOTH a filter button and cards — checklist in `krg-content-catalog`. |
| 4 | Both pages load the shared assets by relative path: `<link rel="stylesheet" href="styles.css">` (line 9 in both) and `<script src="script.js"></script>` (index line 319, guide line 301) | Relative paths (no leading `/` or domain) are what make drag-and-drop Netlify deploys and local double-click previews both work. Renaming/moving either file breaks both pages. |
| 5 | The both-pages rule (section 1): header/footer edits land in both HTML files | No templating engine to do it for you. |

Fast invariant check (expected numbers in comments):

```bash
grep -c 'rel="nofollow"' index.html            # 16
grep -c 'class="product-card"' index.html      # 16
grep -o 'data-category="[^"]*"' index.html | sort | uniq -c   # 8 essential, 4 optional, 4 tools
grep -n 'Amazon Associate' index.html          # lines 38 (banner) and 312 (footer)
grep -n 'stylesheet\|script src' index.html guide.html        # 2 hits per file
```

## 5. Known weak points (open, not accepted-as-fine)

1. **No templating → drift risk.** The header/footer are hand-copied. Nothing detects drift
   except the diff commands in section 1. Every shared-chrome edit is a chance to update only
   one page.
2. **Fabricated star ratings — RESOLVED 2026-07-07.** All 16 cards formerly showed
   invented `.product-rating` lines; they and guide.html's unsubstantiated claims
   ("Join hundreds of home cooks", money-back/satisfaction guarantees, "Delivered in
   2 minutes") were removed or replaced with verifiable copy in the owner-approved
   2026-07-07 cleanup (status home: `krg-change-control` §4 ledger items 4–5; full
   inventory: `krg-affiliate-monetization-reference` §7). The `.product-rating` CSS
   rule remains in styles.css but is unused. Do not reintroduce this pattern in new
   cards or pages — that is Class A. Compliance details live in
   `krg-affiliate-monetization-reference`.
3. **script.js injects a `<style>` element at runtime** (lines 63–76) to define the `fadeIn`
   animation. That keyframe is invisible in styles.css — if you search the stylesheet for
   `fadeIn` you'll find nothing and might wrongly conclude it's unused. Candidate cleanup:
   move the keyframes into styles.css; until then, don't define a conflicting `fadeIn` there.
4. **Inline display toggling fights future CSS.** Filtering sets `card.style.display =
   'block'`/`'none'` directly on the element (script.js lines 23/27). Inline styles override
   the stylesheet, so if you ever change product cards to `display: flex` or `grid` in CSS,
   the first filter click snaps them back to `block` and breaks the card's internal layout.
   Keep card-internal layout on child elements, or fix the JS first.
5. **Monetization placeholders.** 16 Amazon buttons and 2 Patreon links are `href="#"`;
   3 Etsy links point at `https://www.etsy.com/shop/YourShop` (baseline 2026-07-06 —
   authoritative source: run
   `bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh`).
   The site cannot earn until
   these are real (the campaign to fix this lives in `krg-launch-campaign`). Listed here so
   nobody "fixes" a `#` link by deleting it.

## 6. Design decisions and why

These rationales are **inference** — the repo has no design docs, and the site files carry
only three commits (all 2026-02-04; later commits touch only `.claude/skills/`), so intent
is read from the artifacts (and matches the README's deploy manual):

- **Zero-build static site** (inference, strongly supported by the README): keeps deployment
  literally drag-and-drop into Netlify, which a non-technical owner can do without a terminal.
  Any proposal that adds a build step (npm, bundlers, site generators) trades away the
  owner's ability to deploy unassisted — treat that as a major cost.
- **System font stack** (`body` font-family, styles.css line 23: `-apple-system, …, Arial,
  sans-serif`): uses fonts already installed on the visitor's device, so pages load with zero
  external font requests (inference: performance/simplicity; there are no external requests of
  any kind in the site files).
- **One stylesheet + one script shared by both pages** (inference): two pages are few enough
  that a single file of each is simpler than per-page assets, and the browser caches them
  across the two pages.
- **Emoji as imagery** (`.placeholder-img` divs, page icons): no image files exist in the
  repo at all — nothing to optimize, host, or attribute (and named "placeholder", so real
  product images are presumably intended later — candidate improvement, see
  `krg-growth-frontier`).

## Provenance & maintenance

Verified against `/home/user/KRG` on **2026-07-06**; reviewed & corrected 2026-07-07;
line anchors re-derived after the 2026-07-07 ratings/claims cleanup (the first site-file
change since `b863b95`, 2026-02-04; index.html is now 321 lines).
No abandoned work branches; the `claude/*` branch carries
only the skill library. Every command below was actually run from inside the KRG folder
and produced the stated results. If any re-check disagrees with this file, trust the
repo and update this file.

| Fact | Re-verify with (run inside the KRG folder) |
|---|---|
| File set & line counts (index 321, guide 303, css 835, js 76) | `wc -l index.html guide.html styles.css script.js` |
| Header duplication + only-active-class difference | `diff <(sed -n '/<header>/,/<\/header>/p' index.html) <(sed -n '/<header>/,/<\/header>/p' guide.html)` |
| Footer duplication + only-Legal-line difference | `diff <(sed -n '/<footer>/,/<\/footer>/p' index.html) <(sed -n '/<footer>/,/<\/footer>/p' guide.html)` |
| 4 filter values | `grep -o 'data-filter="[^"]*"' index.html` |
| 16 cards: 8/4/4 split | `grep -o 'data-category="[^"]*"' index.html \| sort \| uniq -c` |
| 16 nofollow affiliate buttons, all `href="#"` | `grep -c 'href="#" class="btn btn-primary btn-affiliate"' index.html` |
| Etsy placeholder ×3, Patreon `#` ×2 | `grep -n 'YourShop' guide.html; grep -n 'Patreon' index.html guide.html` |
| Palette values | `sed -n '12,20p' styles.css` |
| Sticky header + z-index 100 | `grep -n 'position: sticky\|z-index' styles.css` |
| Breakpoints at lines 785 & 823 | `grep -n '@media' styles.css` |
| Shared assets linked from both pages | `grep -n 'stylesheet\|script src' index.html guide.html` |
| Runtime style injection & inline display toggling | `grep -n "createElement('style')\|style.display" script.js` |
| 0 rating lines / 0 claim lines (removed 2026-07-07) | `grep -c 'product-rating' index.html; grep -c 'Join hundreds\|Money-back\|money-back' guide.html` → 0 and 0 |
| Disclosure banner on index only | `grep -n 'Amazon Associate' index.html guide.html` |
| Last site-file change = the 2026-07-07 claims-cleanup commit | `git log --oneline -1 -- index.html guide.html styles.css script.js README.md` |
