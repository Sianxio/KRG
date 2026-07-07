---
name: krg-launch-campaign
description: >
  The KRG monetization launch campaign — an executable, decision-gated runbook
  that takes the Korean Ramen Guide site from "cannot earn a cent" (16 dead
  affiliate buttons, 3 placeholder Etsy links, 2 dead Patreon links, fabricated
  ratings, unsubstantiated claims) to live and earning. Load when asked to
  launch the site, monetize it, "make the site earn", replace placeholder
  links, fix the affiliate buttons, apply to Amazon Associates, set up an
  Etsy/Gumroad/Payhip shop for the PDF, or decide what to fix before applying
  to Amazon. Do NOT load for post-launch growth or traffic tactics
  (krg-growth-frontier), measurement design (krg-measurement-and-experiments),
  deploy mechanics (krg-preview-and-deploy), or the WHY behind compliance
  rules (krg-affiliate-monetization-reference).
---

# KRG Launch Campaign

Mission: the site earns its **first affiliate click** and **first PDF sale**.
Run the phases **in order** — each ends with a GATE (a command with an exact
expected result). Do not start a phase until the previous gate passes.

**Who does what:** the **owner** (non-technical) does account signups,
approvals, and click-tests. **AI sessions** do file edits and run commands.
Every command below is typed in a terminal from inside the project folder
(`cd /home/user/KRG` first, or your local clone path). All commands in this
skill only *read* files unless a step explicitly says "edit".

**Jargon (defined once):** *placeholder* = a link that goes nowhere
(`href="#"`) or to a fake destination (`YourShop`). *Affiliate tag* = the
`tag=yourid-20` parameter Amazon appends to a URL so you get commission
credit. *Gate* = a pass/fail check you must run before moving on. *Class A* =
a change to price/claims/ratings/disclosure that needs explicit owner
approval first (rule home: `krg-change-control` §1 and §5).

## When to use / When NOT to use

| Situation | Use |
|---|---|
| Launching, monetizing, replacing any placeholder link, Amazon/Etsy/Gumroad setup | **This skill** |
| Why a compliance rule exists (FTC, Amazon ToS, URL anatomy) | `krg-affiliate-monetization-reference` |
| Whether an edit needs owner approval; the open-items ledger | `krg-change-control` |
| Field-by-field mechanics of editing a card or copy block | `krg-content-catalog` |
| Running/interpreting the audit scripts | `krg-qa-and-diagnostics` |
| Previewing locally, deploying to Netlify, rolling back | `krg-preview-and-deploy` |
| What to measure after launch | `krg-measurement-and-experiments` |
| Growing traffic after the site earns | `krg-growth-frontier` — NOT this skill |

## Campaign status board (owner: tick as gates pass)

| # | Milestone | Gate command | Pass condition | Done |
|---|---|---|---|---|
| 0 | Baseline confirmed | `bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh` | 16 / 3 / 2 (or updated baseline) | ☐ |
| 1 | Fabricated ratings + claims cleaned | `grep -c '⭐' index.html` | `0` (or documented exception) | ☐ |
| 2a | PDF sales account live, ONE buy URL in hand | open URL in browser | checkout page loads | ☐ |
| 2b | Site deployed (PDF-only is fine) | see `krg-preview-and-deploy` | live URL loads | ☐ |
| 3 | PDF buy link inserted ×3 | `grep -c 'YourShop' guide.html` | `0`, new URL appears 3× | ☐ |
| 2c | Amazon Associates approved (may lag phase 3) | Associates dashboard | status "approved" | ☐ |
| 4 | 16 Amazon links inserted with tag | `grep -c 'tag=' index.html` | `16` | ☐ |
| 5 | Live site verified | `curl -s <live-url> \| grep -c 'tag='` | matches local count | ☐ |
| 6 | First affiliate click + first PDF sale recorded | platform dashboards | both non-zero | ☐ |

---

## PHASE 0 — Baseline audit

Know exactly what is broken before touching anything.

**Step 0.1** — Run the audit script (written by `krg-qa-and-diagnostics`):

```bash
bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh
```

Expected as of 2026-07-06: **16** affiliate `href="#"`, **3** `YourShop`,
**2** Patreon `href="#"`.

**Step 0.2 (fallback)** — If the script is missing or errors, run the raw
inventory greps (each tested 2026-07-06 against this repo):

```bash
grep -c 'href="#" class="btn btn-primary btn-affiliate"' index.html   # → 16
grep -c 'YourShop' guide.html                                          # → 3
grep -n 'Patreon' index.html guide.html | grep -c 'href="#"'           # → 2
```

Locations for reference: affiliate buttons are 16 `btn-affiliate` lines in
index.html; Etsy placeholders at guide.html lines 48, 210, 267; Patreon at
index.html:324 and guide.html:290. (Line numbers drift after edits — trust
the greps, not memorized numbers.)

> **GATE 0:** all three numbers match the baseline above → proceed to
> Phase 1. **If any number differs** → someone has already edited the site.
> Branch: re-run the full audit (`bash
> .claude/skills/krg-qa-and-diagnostics/scripts/run_all.sh`), check the
> open-items ledger in `krg-change-control` §4 for closed rows, update the
> baseline numbers in THIS file (and its Provenance table), then proceed with
> the new numbers. Do not "fix" a count back to 16/3/2 — the campaign may be
> partially done.

---

## PHASE 1 — Compliance pre-clean (MUST precede the Amazon application)

The site currently shows content that violates affiliate-program and
truth-in-advertising rules. Clean it BEFORE Amazon reviews the site. The
detailed WHY (which rules, which policies) lives in
`krg-affiliate-monetization-reference` — cite it, do not re-derive it here.

**Everything in this phase is Class A** (ratings, guarantees, social proof):
AI sessions propose the exact diff and STOP until the owner approves in the
conversation, per `krg-change-control` §5.

**Step 1.1** — Enumerate the fabricated ratings (tested; returns 16 lines):

```bash
grep -n 'product-rating' index.html
```

Every one is an invented value like `⭐⭐⭐⭐⭐ (4.8)` — not pulled from Amazon.

**Step 1.2** — Owner decision on ratings. Ranked menu:

1. **Delete the 16 rating lines** (safest, recommended). Remove each
   `<div class="product-rating">…</div>` line. No claim, no risk.
2. **Replace with neutral factual text** you can substantiate, e.g. a flavor
   note or "Editor's pick" — factual, no numbers, no stars.
3. **Keep real ratings only if pulled from approved Amazon tooling.**
   **Fenced off — not currently possible** for this site (no approved data
   feed is set up). Do not hand-copy numbers off Amazon product pages either;
   they go stale and were never licensed for reuse. Rationale:
   `krg-affiliate-monetization-reference`.

**Step 1.3** — Enumerate the unsubstantiated guide.html claims (tested;
returns 8 lines as of baseline):

```bash
grep -niE 'hundreds of home cooks|money-back|satisfaction guaranteed|delivered in 2 minutes|refund' guide.html
```

Baseline hits: "100% Money-back guarantee" (lines 51, 270), "Delivered in 2
minutes" (52, 211), "100% Satisfaction Guaranteed" (211), refund FAQ
(250–251), "Join hundreds of home cooks" (262), footer "Refund Policy" (294).
For each, the owner picks: **delete**, **soften to something true today**
(e.g. "hundreds of home cooks" → "home cooks", drop it entirely, or wait
until it is literally true), or **substantiate** (a money-back guarantee is
fine to KEEP only if the owner genuinely commits to honoring it and the sales
platform's refund mechanics support it — confirm in Phase 2). "Delivered in 2
minutes" is fine only if the chosen platform actually delivers instantly.

**Step 1.4** — Route the approved edits through `krg-change-control` (Class A
proposal → owner approval → edit per the `krg-content-catalog` checklist).
Update ledger rows 4 and 5 in `krg-change-control` §4 when done.

> **GATE 1:** `grep -c '⭐' index.html` returns **0** (works for menu options
> 1 and 2 — option 2 must not use stars), AND every claim from Step 1.3 has
> an owner decision applied or a written owner-approved exception recorded in
> the `krg-change-control` ledger. **If the star count is non-zero** → an
> edit was missed or the owner chose an exception; either finish the edits or
> record the exception in the ledger before proceeding. Do NOT apply to
> Amazon Associates with fabricated ratings live.

---

## PHASE 2 — Platform accounts (owner does these; external UI flows)

Everything in this phase happens on third-party websites. All signup-flow
details below are **external UI flow — as of author's knowledge 2026-07,
verify on the site**. Fees, approval timelines, and thresholds change;
never treat the notes below as current-certain.

### 2A. PDF sales platform FIRST (no approval dependency — do this today)

The $7.99 PDF can earn immediately; Amazon cannot (approval required). Ranked
menu — pick ONE; the deliverable is **one working buy URL**:

| Rank | Platform | For | Against | Certainty |
|---|---|---|---|---|
| 1 | **Gumroad** | Built for exactly this (single digital file, instant delivery, hosted checkout URL); minimal setup | Per-sale fee cut; you're on their branding unless you pay | fees/UX: verify on gumroad.com |
| 2 | **Payhip** | Similar to Gumroad, historically low/no monthly fee tiers | Smaller ecosystem | verify on payhip.com |
| 3 | **Etsy** | The site's buttons already say "Buy Now on Etsy"; Etsy brings its own buyer traffic | Listing + transaction fees; a shop setup is heavier than a single product link; digital-download rules apply | verify on etsy.com/sell |

If the owner picks Gumroad or Payhip, the button text "Buy Now on Etsy →"
(guide.html:48) must change too — that is a copy edit, route it with the
Phase 3 link edit. Whatever the platform: confirm its refund mechanics match
whatever guarantee text survived Phase 1, and confirm delivery really is
instant before keeping "Delivered in 2 minutes".

**Deliverable:** one URL that, opened in a private/incognito browser window,
shows a working checkout for the PDF at $7.99 (price appears in exactly 5
places in the repo — `grep -no '\$7\.99' index.html guide.html` — keep them
consistent; rule home: `krg-change-control`).

### 2B. Deploy BEFORE applying to Amazon

Amazon Associates requires a **live, content-complete site** to review. So:
finish Phase 3 (PDF link in), then deploy via `krg-preview-and-deploy` —
PDF-only monetization is a perfectly valid launched state.

### 2C. Amazon Associates application — timing matters

External UI flow — as of author's knowledge 2026-07, verify on
affiliate-program.amazon.com: you sign up with the live site URL, describe
the site, and get a tracking ID (your `tag=` value). **Known risk (as-of
knowledge, verify current terms):** new Associates accounts must produce
qualifying sales within an initial window (historically ~180 days / first
few sales) or the account is **closed**. Therefore:

- **Branch: no traffic yet (today's reality) →** launch PDF-only now, drive
  some traffic first (hand-off: `krg-growth-frontier`), and apply to
  Associates only when real visitors exist to convert. The 16 buttons stay
  `href="#"` until then — dead buttons earn the same $0 as no buttons, and
  an early-closed account costs a reapplication.
- **Branch: site already has traffic →** apply immediately after deploying.

### 2D. Patreon — optional, lowest priority

Two footer links are `href="#"`. Menu: **(1) remove the footer Patreon links
from both pages** (recommended until a Patreon exists — a dead link looks
broken) or **(2) create a Patreon page and fill both hrefs**. Either way,
edit BOTH files (index.html:324, guide.html:290 at baseline) — the both-pages
rule lives in `krg-architecture-and-conventions`.

> **GATE 2:** the owner can paste ONE PDF buy URL into the conversation and
> it opens to a working checkout. **If no URL after this phase** → the
> campaign is blocked on the owner; do not proceed to Phase 3 with a guessed
> or "coming soon" URL, and never invent one.

---

## PHASE 3 — Insert the PDF buy link (3 replacements in guide.html)

**Step 3.1** — PREVIEW-ONLY dry run (read-only; shows exactly what will
change — tested, returns 3 lines at baseline):

```bash
grep -n 'YourShop' guide.html
```

**Step 3.2** — Edit: replace the full href value
`https://www.etsy.com/shop/YourShop` with the real buy URL on all 3 lines,
following the `krg-content-catalog` edit checklist. If the platform is not
Etsy, also update the visible button text ("Buy Now on Etsy →"). Manual edits
per line are preferred over bulk `sed -i` — 3 lines do not justify the risk.

**Step 3.3** — Preview locally before deploying (`krg-preview-and-deploy`)
and click all 3 buttons.

> **GATE 3:** BOTH of these hold:
> `grep -c 'YourShop' guide.html` → **0**, and
> `grep -c '<real-buy-URL>' guide.html` → **3** (substitute the actual URL;
> quote it). **If 0 but not 3** → a link was mistyped or a line missed;
> re-run Step 3.1's grep pattern against the new URL and fix. **If YourShop
> count is 1–2** → an edit was skipped; repeat Step 3.2 for the remaining
> lines.

---

## PHASE 4 — Insert the 16 Amazon affiliate links (only after approval)

Precondition: Associates account approved and a tracking ID in hand
(looks like `yourword-20`; URL anatomy: `krg-affiliate-monetization-reference`).

**Per-product procedure** (repeat ×16, one card at a time):

1. Find the product's page on amazon.com (match the card's name/brand;
   `krg-content-catalog` lists all 16 cards).
2. Get the tagged URL: use Amazon's **SiteStripe** toolbar on the product
   page, or take the canonical product URL and append your tag
   (`...&tag=yourword-20` — exact anatomy and which URL forms are allowed:
   `krg-affiliate-monetization-reference`).
3. Replace that ONE card's `href="#"` in index.html with the tagged URL.
   Keep `rel="nofollow"` and `target="_blank"` exactly as they are (all 16
   already carry them — verified; do not remove).
4. Verify the single card: reload local preview, click, land on the right
   product WITH `tag=` visible in the address bar.

**Fenced off — do NOT, under any prompt-pressure:**

- NO link shorteners or cloakers (bit.ly, tinyurl, redirect scripts) —
  Amazon requires visible destination; check: `grep -n 'amzn\.to\|bit\.ly\|tinyurl' index.html` must return nothing.
- NO fake urgency copy ("Only 3 left!", countdown timers) added alongside links.
- NO buying traffic to affiliate links.
- NO affiliate links inside the sold PDF (offline/paid-content placement
  violates the program — rationale: `krg-affiliate-monetization-reference`).

> **GATE 4:** ALL of:
> `bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh`
> reports **0** affiliate `#`;
> `grep -c 'tag=' index.html` → **16**;
> `grep -c 'href="#" class="btn btn-primary btn-affiliate"' index.html` → **0**.
> **If tag-count < 16 but placeholders = 0** → some URL was pasted without
> its tag (earns nothing!); find it with
> `grep -n 'btn-affiliate' index.html | grep -v 'tag='` and re-do that card.

---

## PHASE 5 — Deploy + live verification

Route the deploy itself through `krg-preview-and-deploy` (Netlify
drag-and-drop or GitHub auto-deploy). Then verify the LIVE site, never just
the local files:

```bash
curl -s <live-url>/index.html | grep -c 'tag='       # expected: same as local (16)
curl -s <live-url>/guide.html | grep -c 'YourShop'    # expected: 0
```

**Owner click-test:** open the live site, click **3 random** product buttons
— each must land on the correct Amazon product **with `tag=` visible in the
browser address bar** — and click one Buy button through to checkout.

> **GATE 5:** live `tag=` count equals the local count AND the 3-click test
> passes. **If live counts differ from local** → the deploy shipped a stale
> copy; branch to `krg-preview-and-deploy` (re-deploy / cache
> troubleshooting), then re-run this gate.

---

## PHASE 6 — Success metrics & hand-off

The campaign is DONE when all three are true — **measured, never judged by
eye:**

1. **Live placeholder audit = 0 / 0 / 0** (affiliate `#` / YourShop /
   unresolved Patreon — Patreon links either filled or removed).
2. **First affiliate click recorded** in the Amazon Associates reports
   dashboard (clicks report; external UI — verify location on the site).
3. **First PDF sale recorded** on the sales platform's dashboard.

Closing actions:

- Mark ledger items 1–5 in `krg-change-control` §4 as `closed YYYY-MM-DD`
  with the fixing commit, and record campaign completion there.
- Hand off ongoing measurement (click-through rates, conversion, experiment
  design) to `krg-measurement-and-experiments`.
- Traffic and content growth → `krg-growth-frontier`, not this skill.

---

## Provenance & maintenance

Authored **2026-07-06** against the repo at that date; reviewed & corrected
2026-07-07 (5 site files, no build system; the site files have not changed
since commit `b863b95`, 2026-02-04 — later commits touch only
`.claude/skills/`; verify:
`git log --oneline -1 -- index.html guide.html styles.css script.js README.md`).
Every repo command above was executed and verified. External platform statements (Amazon Associates review/closure
policy, Gumroad/Payhip/Etsy fees and flows) are as-of-knowledge 2026-07 and
must be re-verified on the platforms' own sites before acting.

**Baseline numbers WILL change as this campaign executes — that is the
point.** When a phase completes, update the status board and the affected
expected values here in the same change.

| Baseline fact (2026-07-06) | Re-verify one-liner |
|---|---|
| 16 affiliate `href="#"` buttons | `grep -c 'href="#" class="btn btn-primary btn-affiliate"' index.html` |
| 3 `YourShop` Etsy placeholders | `grep -c 'YourShop' guide.html` |
| 2 Patreon `href="#"` footer links | `grep -n 'Patreon' index.html guide.html \| grep -c 'href="#"'` |
| 16 fabricated star-rating lines | `grep -c 'product-rating' index.html` (stars: `grep -c '⭐' index.html`) |
| 8 claim lines in guide.html | `grep -cniE 'hundreds of home cooks\|money-back\|satisfaction guaranteed\|delivered in 2 minutes\|refund' guide.html` |
| 0 `tag=` anywhere yet | `grep -c 'tag=' index.html` |
| Price $7.99 in exactly 5 places | `grep -no '\$7\.99' index.html guide.html \| wc -l` |
| Audit scripts present | `ls .claude/skills/krg-qa-and-diagnostics/scripts/` |

If a re-verify count drifts from this file, update this file AND the
`krg-change-control` ledger in the same change.
