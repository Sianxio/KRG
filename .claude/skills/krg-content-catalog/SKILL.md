---
name: krg-content-catalog
description: >
  Catalog of every content/configuration axis of the Korean Ramen Guide site and tested
  checklists for changing each. Load this skill when adding, editing, or removing product
  cards, categories, filter buttons, prices, badges, price ranges, product notes, FAQ items,
  CTAs, buy buttons, value lists, feature cards, preview items, trust badges, nav links,
  footer links, the Patreon link, the disclosure block, section titles, or any page copy on
  index.html or guide.html, or when changing the styles.css color palette. NOT for deploying
  or previewing (use krg-preview-and-deploy), debugging JS (use krg-architecture-and-conventions
  and krg-qa-and-diagnostics), affiliate-link format/tag questions (use
  krg-affiliate-monetization-reference), or compliance questions (use krg-change-control).
---

# KRG Content Catalog: every knob on the site and how to turn it

This is the master list of everything editable on the two-page Korean Ramen Guide site,
its current value, and a step-by-step checklist for each kind of change. All counts and
line numbers below were verified against the repo on 2026-07-06. **Line numbers drift as
content is added — always re-run the verification grep given with each table.**

## When to use / When NOT

**Use this skill when** you are changing site *content*: products, categories, prices,
badges, FAQ, CTAs, nav/footer, copy, or palette colors.

**Do NOT use this skill for** (use the sibling skill instead):

| Task | Sibling skill |
|---|---|
| How the HTML and script.js talk to each other; the "edit both pages" rule in depth | `krg-architecture-and-conventions` |
| Which edits need owner sign-off before shipping (price and legal copy = Class A) | `krg-change-control` |
| Affiliate URL format, Amazon tag, nofollow/compliance rules | `krg-affiliate-monetization-reference` |
| Post-edit audit scripts | `krg-qa-and-diagnostics` |
| Previewing locally or publishing | `krg-preview-and-deploy` |
| Marketing/launch tasks | `krg-launch-campaign` |
| Writing style, tone, wording rules | `krg-docs-and-writing` |

Jargon, defined once: a **product card** is one `<div class="product-card" data-category="…">`
block in index.html. A **badge** is the small `<div class="product-badge">` label on some cards.
A **CTA** ("call to action") is any button/link that pushes the visitor toward buying.
**Chrome** means the header/nav and footer shared by both pages.

---

## 1. The site in one glance

| File | Lines (2026-07-06) | Contents |
|---|---|---|
| `index.html` | 337 | Shopping list: 16 product cards in 3 categories, filter buttons, 2 guide CTAs, disclosure block |
| `guide.html` | 303 | $7.99 PDF sales page: hero, value list, feature cards, previews, FAQ, 3 Etsy buy buttons |
| `styles.css` | 835 | All styling; palette in `:root` at top |
| `script.js` | 76 | Category filtering + affiliate click logging (index.html only in practice) |

No build system. Edit the files, refresh the browser.

---

## 2. Catalog tables (current values)

### 2.1 Product cards — 16 total in index.html

Verify count: `grep -c 'class="product-card"' index.html` → **16**.
Per-category: `grep -o 'data-category="[^"]*"' index.html | sort | uniq -c` → 8 essential, 4 optional, 4 tools.

| # | ~Line | Product name | Category | Badge | Price shown | Note line |
|---|---|---|---|---|---|---|
| 1 | 61 | Korean Gochugaru (Fine Grind) | essential | Must Have | $8-15 | Try: Taekyung, Mother-In-Law's, or The Spice Way |
| 2 | 75 | Garlic Powder | essential | — | $3-10 | Try: McCormick or Simply Organic |
| 3 | 88 | Onion Powder | essential | — | $3-8 | Try: McCormick or Frontier Co-op |
| 4 | 101 | MSG (Ac'cent Flavor Enhancer) | essential | Popular | $4-8 | Safe and widely used in Asian cuisine |
| 5 | 115 | Soy Sauce Powder | essential | Hard to Find | $12-20 | Try: OliveNation or Raw Essentials |
| 6 | 129 | Beef Stock Powder | essential | — | $6-15 | Try: Better Than Bouillon or Knorr |
| 7 | 142 | Ginger Powder | essential | — | $3-9 | Try: McCormick or Simply Organic |
| 8 | 155 | Toasted Sesame Oil | essential | — | $6-15 | Try: Kadoya or La Tourangelle |
| 9 | 181 | Shiitake Mushroom Powder | optional | Premium | $12-25 | Try: FGO Organic or Terrasoul |
| 10 | 195 | Anchovy or Bonito Powder | optional | — | $8-18 | Adds authentic ramyun depth |
| 11 | 208 | Citric Acid | optional | — | $6-12 | Try: Milliard or Anthony's |
| 12 | 221 | Chili Oil (Lao Gan Ma) | optional | Trending | $6-12 | Cult favorite condiment |
| 13 | 240 | Glass Spice Jars (Set of 12) | tools | Essential | $12-25 | Try: Ball Mason or Nakpunar |
| 14 | 254 | Digital Kitchen Scale | tools | — | $10-25 | Try: Ozeri or Etekcity |
| 15 | 267 | Electric Spice Grinder | tools | Pro Tool | $15-35 | Try: KRUPS or Cuisinart |
| 16 | 281 | Silica Gel Desiccant Packs | tools | — | $8-15 | Food-safe moisture absorbers |

**Badges in use (7):** Must Have, Popular, Hard to Find, Premium, Trending, Essential, Pro Tool.
Verify: `grep -n 'product-badge' index.html` → 7 lines. Badges are free-text; reuse existing
wording rather than inventing near-duplicates ("Essential" vs "Must Have" already overlap).

**Known compliance issue — do not spread it:** every current card has a fabricated
star-rating line like `<div class="product-rating">⭐⭐⭐⭐⭐ (4.8)</div>` (16 of them:
`grep -c 'product-rating' index.html`). These ratings are made up, not from Amazon.
**Never copy this line into new cards**, and do not "fix" the existing ones without owner
sign-off — see `krg-change-control`.

**Affiliate links:** all 16 are placeholders:
`grep -c 'href="#" class="btn btn-primary btn-affiliate"' index.html` → **16**.
Real URL format, Amazon tag, and disclosure rules live in `krg-affiliate-monetization-reference`.

### 2.2 Filter axis — index.html lines 46-49

Verify: `grep -n 'data-filter' index.html`

| `data-filter` value | Button label | Cards matched |
|---|---|---|
| `all` | All Products | every card (special-cased in script.js line 22) |
| `essential` | Essential Ingredients | 8 |
| `optional` | Optional Enhancers | 4 |
| `tools` | Tools & Storage | 4 |

Section headings (`class="section-title"`, lines 57 / 177 / 236) are *visual only* — the
filter mechanism matches `data-filter` on buttons to `data-category` on cards, nothing else.
Full contract: `krg-architecture-and-conventions`.

### 2.3 guide.html axes

**PDF price $7.99 — 5 locations across BOTH files.** Changing the price is a **Class A
change** (owner approval required, see `krg-change-control`) and is **all-or-none**: update
every location in one edit session or the site contradicts itself.

```bash
grep -n '7\.99' index.html guide.html
```

| File:line | Context |
|---|---|
| index.html:172 | Mid-page CTA button "Get Full Guide - $7.99 →" |
| guide.html:8 | `<title>` tag (shows in browser tab and Google results) |
| guide.html:44 | Hero `price-amount` |
| guide.html:208 | Mid-page CTA heading "Get Instant Access for $7.99" |
| guide.html:264 | Final CTA `price-big` |

**Etsy buy buttons — 3, all pointing at the placeholder shop `YourShop`.**
Verify: `grep -n 'etsy' guide.html` → lines 48 (`btn-buy`), 210 (`btn-buy-large`),
267 (`btn-buy-huge`). All three must carry the same real shop/listing URL when it exists.

**Other guide.html content blocks** (verify command → expected count):

| Block | Where | Count | Verify |
|---|---|---|---|
| Value list (`value-item`) | hero, lines 34-39 | 6 | `grep -c 'value-item' guide.html` |
| Feature cards (`feature-card`) | "What's Inside", lines 80-119 | 8 | `grep -c 'feature-card' guide.html` |
| Preview items (`preview-item`) | "Sneak Peek", lines 130-157 | 4 | `grep -c 'preview-item' guide.html` |
| FAQ items (`<details class="faq-item">`) | lines 221-252 | 8 | `grep -c 'faq-item' guide.html` |
| Trust badges (3 `<span>`s in one `trust-badges` div) | lines 50-54 | 1 block | `grep -c 'trust-badges' guide.html` |
| Social-proof line ("Join hundreds of home cooks…") | line 262 | 1 | `grep -n 'hundreds' guide.html` |

The social-proof "hundreds of home cooks" and the "100% Money-back guarantee" badges are
**unsubstantiated claims** — an open compliance issue. Do not add more claims like these;
changes to them are Class A (`krg-change-control`).

### 2.4 Shared chrome (appears on BOTH pages — edit both, see krg-architecture-and-conventions)

**Nav (identical on both pages except which link has `class="… active"`):**
`index.html` → Shopping List (active), Get Full Guide. `guide.html` → same links, Get Full
Guide active. Verify: `grep -n 'nav-link' index.html guide.html`.

**Footer — 3 sections on each page.** Quick Links are identical on both:
`index.html` (Shopping List), `guide.html` (Buy Guide), and a **Patreon placeholder**
`<a href="#" target="_blank">Join on Patreon</a>` (index.html:324, guide.html:290 —
verify: `grep -n 'Patreon' index.html guide.html`). The **Legal section intentionally
differs**: index.html:328 carries the Amazon Associate line; guide.html:294 carries
"Refund Policy · Privacy Policy · Terms". After any footer edit, diff them:

```bash
diff <(sed -n '/<footer>/,/<\/footer>/p' index.html) \
     <(sed -n '/<footer>/,/<\/footer>/p' guide.html)
```

Expected output today is exactly one changed line (the Legal `<p class="small">` pair
above). Any other difference means a footer edit missed one page.

**Disclosure block — index.html ONLY** (lines 36-40, `class="disclosure"`, "As an Amazon
Associate, I earn…"). guide.html has no disclosure block because it has no Amazon links.
Verify: `grep -n 'class="disclosure"' index.html guide.html` → one hit, index.html:36.
Disclosure wording is legal copy → Class A (`krg-change-control`).

### 2.5 styles.css tunables — the `:root` palette (lines 13-21)

Verify: `sed -n '13,21p' styles.css`

| Variable | Value | Drives (main uses) |
|---|---|---|
| `--red` | `#D32F2F` | Brand color: logo, active nav, badges, all buy/CTA buttons, CTA gradient backgrounds (20 uses) |
| `--orange` | `#FF6F00` | "View on Amazon" buttons (`.btn-primary`), star-rating color, disclosure accent border, arrows (6 uses) |
| `--dark` | `#212121` | Body text (7 uses) |
| `--gray` | `#757575` | Secondary text: descriptions, notes, captions (18 uses) |
| `--light` | `#F5F5F5` | Section backgrounds, card borders (11 uses) |
| `--cream` | `#FFF8E1` | Disclosure banner and solution-box backgrounds (2 uses) |
| `--white` | `#FFFFFF` | Page/card backgrounds, button text (22 uses) |

Use counts: `for v in red orange dark gray light cream white; do echo "--$v $(grep -c "var(--$v)" styles.css)"; done`.
Change a color by editing the `:root` value once — never hard-code hex values in new rules.
Note two hard-coded gradient endpoints `#B71C1C` (darker red) exist at styles.css lines
255/438/464; if you change `--red`, review those too: `grep -n 'B71C1C' styles.css`.

---

## 3. Checklists

### 3.1 Add a product card

1. **Pick the section and category.** The card's `data-category` must be one of the
   existing filter values: `essential`, `optional`, `tools`. A new value needs a new
   filter button too — that is checklist 3.2, not this one.
2. **Copy this template** (derived from the real markup) inside the correct
   `<div class="product-grid">` in index.html, just before that grid's closing `</div>`:

   ```html
   <!-- Product Card 17 -->
   <div class="product-card" data-category="essential">   <!-- MUST match a data-filter value -->
       <div class="product-badge">Popular</div>            <!-- OPTIONAL: delete line, or reuse an existing badge word -->
       <div class="product-image">
           <div class="placeholder-img">🍜</div>           <!-- one emoji -->
       </div>
       <h4>Product Name Here</h4>
       <p class="product-desc">One-line benefit statement</p>
       <div class="product-price">$5-10</div>              <!-- price RANGE, with $ and hyphen -->
       <a href="REAL-AFFILIATE-URL" class="btn btn-primary btn-affiliate" target="_blank" rel="nofollow">View on Amazon →</a>
       <p class="product-note">Try: Brand One or Brand Two</p>
   </div>
   ```

   Deliberately **no** `product-rating` line — do not add one (fabricated ratings are an
   open compliance issue; see section 2.1).
3. **Set the real affiliate URL** with `rel="nofollow" target="_blank"` kept exactly as in
   the template. URL/tag format rules: `krg-affiliate-monetization-reference`.
4. **Cross-check** that every card's category has a filter button (empty output = OK):

   ```bash
   comm -23 <(grep -o 'data-category="[^"]*"' index.html | sed 's/data-category=//' | sort -u) \
            <(grep -o 'data-filter="[^"]*"' index.html | sed 's/data-filter=//' | sort -u)
   ```

5. **Re-count**: `grep -c 'class="product-card"' index.html` → old count + 1. Then update
   the counts in this skill's tables if you have time (section 5 has the commands).
6. **Preview** (`krg-preview-and-deploy`): click each filter button; the new card must
   appear under All Products and its own category, and hide under the others.
7. **Run audits** (`krg-qa-and-diagnostics`).

### 3.2 Add a new category

Three touch points, all in index.html, plus the JS contract check:

1. **Filter button** — add inside `<div class="filter-tabs">` (lines 45-50):
   `<button class="filter-btn" data-filter="sauces">Sauces & Pastes</button>`
   (lowercase single-word `data-filter` value; no `active` class — only the `all` button has it).
2. **Section title** — add after the last product grid, matching the existing pattern:
   `<h3 class="section-title">Sauces & Pastes</h3>`
3. **Product grid with at least one card** — `<div class="product-grid"> …cards… </div>`,
   each card `data-category="sauces"` (must equal the button's `data-filter` exactly;
   the match is case-sensitive string equality — script.js line 22).
4. No script.js or styles.css change is needed — filtering and grid styling are generic.
5. Run the cross-check from step 3.1.4 **and its inverse** (buttons with no cards):

   ```bash
   comm -13 <(grep -o 'data-category="[^"]*"' index.html | sed 's/data-category=//' | sort -u) \
            <(grep -o 'data-filter="[^"]*"' index.html | sed 's/data-filter=//' | sort -u)
   ```

   Only `"all"` may appear (it matches everything by design).
6. Preview: new button filters correctly; audits per `krg-qa-and-diagnostics`.

### 3.3 Change the PDF price (Class A — owner approval first)

1. **Get owner sign-off** per `krg-change-control` before editing anything.
2. List every current location (5 today — table in section 2.3):
   `grep -n '7\.99' index.html guide.html`
3. Replace **all** occurrences in one sitting — all-or-none. Example for $7.99 → $9.99:
   `sed -i 's/7\.99/9.99/g' index.html guide.html`
   (or edit the 5 spots by hand from the grep output).
4. Verify zero leftovers and the new count matches:
   `grep -n '7\.99' index.html guide.html` → no output;
   `grep -c '9\.99' index.html guide.html` → 1 and 4.
5. Confirm the **Etsy listing price** was changed to match before publishing — the site
   must never show a price different from checkout. Then update this skill's price table.

### 3.4 Edit shared chrome (nav / footer / logo)

1. Chrome exists **verbatim on both pages** — the both-pages rule
   (`krg-architecture-and-conventions` is the authority). Make the identical edit in
   index.html AND guide.html.
2. Verify with the footer diff from section 2.4 (expect only the one known Legal-line
   difference) and, for nav: `grep -n 'nav-link' index.html guide.html` — same hrefs/labels,
   only `active` placement differs.
3. Replacing the Patreon `href="#"` placeholder: 2 locations
   (`grep -n 'Patreon' index.html guide.html`), same URL in both, keep `target="_blank"`.
4. Footer legal text (Amazon Associate line, refund/privacy wording) is Class A —
   `krg-change-control`.

### 3.5 Add a FAQ item (guide.html)

1. Copy the exact existing pattern into `<div class="faq-container">` (before its closing
   `</div>`, currently around line 253):

   ```html
   <details class="faq-item">
       <summary>Question goes here?</summary>
       <p>Answer paragraph goes here.</p>
   </details>
   ```

2. No JS or CSS change needed — `<details>` opens/closes natively.
3. Verify: `grep -c 'faq-item' guide.html` → old count + 1 (8 today).
4. If the feature card "10 FAQs Answered" (guide.html:107) or the value list's
   "10 FAQ answered" (line 38) is meant to track the **PDF's** FAQ count, leave them alone —
   they describe the PDF, not this page. Copy wording rules: `krg-docs-and-writing`.

### 3.6 Remove a product

1. Delete the entire `<div class="product-card" …> … </div>` block **including** its
   leading `<!-- Product Card N -->` comment (a card spans from that comment to the
   matching closing `</div>` before the next comment or the grid's end).
2. Re-check structure: `grep -c 'class="product-card"' index.html` → old count − 1, and
   affiliate links must match: `grep -c 'btn-affiliate' index.html` → same number.
3. If it was the **last card in its category**, either remove the category's filter button
   and section title too (inverse of checklist 3.2) or leave an empty-looking section —
   run the step-3.2.5 inverse check to catch buttons with zero cards.
4. Preview each filter; run audits (`krg-qa-and-diagnostics`); update this skill's tables.

---

## 4. Rules of thumb

- One card = one `data-category`; the value must already exist as a `data-filter`.
- Same fact shown twice (price, Patreon URL, footer text) = update every copy in one edit.
- Never introduce a new star rating, review count, or "hundreds of customers" style claim.
- Prices on cards are ranges (`$8-15`), guide price is exact (`$7.99`) — keep those shapes.
- After ANY content edit: cross-check greps → preview → `krg-qa-and-diagnostics` audits.

---

## 5. Provenance & maintenance

Derived directly from the repo files on **2026-07-06** (index.html 337 lines, guide.html
303, styles.css 835, script.js 76). Every command above was run and its output checked on
that date. Line numbers are anchors, not gospel — re-verify each count before relying on it:

| Stated count | Re-verify with (run from /home/user/KRG) |
|---|---|
| 16 product cards | `grep -c 'class="product-card"' index.html` |
| 8 / 4 / 4 per category | `grep -o 'data-category="[^"]*"' index.html \| sort \| uniq -c` |
| 4 filter buttons (all/essential/optional/tools) | `grep -n 'data-filter' index.html` |
| 3 section titles | `grep -c 'section-title' index.html` |
| 7 badges, 7 distinct labels | `grep -n 'product-badge' index.html` |
| 16 placeholder affiliate links | `grep -c 'href="#" class="btn btn-primary btn-affiliate"' index.html` |
| 16 star-rating lines (compliance issue) | `grep -c 'product-rating' index.html` |
| 5 price locations (1 index + 4 guide) | `grep -n '7\.99' index.html guide.html` |
| 3 Etsy CTAs (YourShop placeholder) | `grep -n 'etsy' guide.html` |
| 6 value items / 8 feature cards / 4 preview items / 8 FAQ items | `for c in value-item feature-card preview-item faq-item; do echo "$c $(grep -c $c guide.html)"; done` |
| 1 trust-badges block (3 spans) | `grep -n -A3 'trust-badges' guide.html` |
| 2 Patreon placeholders | `grep -n 'Patreon' index.html guide.html` |
| Disclosure block in index.html only | `grep -n 'class="disclosure"' index.html guide.html` |
| 7 `:root` palette variables | `sed -n '13,21p' styles.css` |
| 3 hard-coded `#B71C1C` gradient stops | `grep -c 'B71C1C' styles.css` |

If any command's output disagrees with a table here, **trust the files** and update this
skill in the same change.
