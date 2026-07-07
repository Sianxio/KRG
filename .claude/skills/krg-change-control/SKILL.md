---
name: krg-change-control
description: >
  Load BEFORE making, reviewing, or approving ANY edit to the Korean Ramen Guide
  site (index.html, guide.html, styles.css, script.js, README.md). Defines the
  Class A/B/C change classification, the gates each class must pass, the
  non-negotiable rules (affiliate disclosure, price consistency, nofollow), the
  pre-deploy checklist, and the open-items ledger. Also load when asked "can I
  change X?", "is this safe to ship?", "what needs owner approval?", or when an
  AI session is about to touch price, guarantee, rating, or disclosure text.
  Do NOT load for how-to-deploy mechanics (krg-preview-and-deploy), debugging
  broken behavior (krg-debugging-playbook), or writing new marketing copy
  (krg-content-catalog / krg-docs-and-writing).
---

# KRG Change Control

How changes to this site are classified, gated, and reviewed. This is a
solo-owner project with **no CI, no tests, no build step** (CI = "continuous
integration", automated robots that check code before it ships — we don't have
any). The gate here is a disciplined self-review checklist, plus owner sign-off
rules for AI sessions. Ledger and rules start **2026-07-06**; there are **no
recorded incidents yet** — the rules below are grounded in a code audit and in
legal/program requirements, not in past outages.

## When to use / When NOT to use

| Situation | Use |
|---|---|
| About to edit any file, or deciding whether a change needs approval | **This skill** |
| What the site's invariants are, the both-pages rule in detail | `krg-architecture-and-conventions` |
| How to preview locally, deploy to Netlify, or roll back | `krg-preview-and-deploy` |
| Field-by-field checklists for editing product cards / copy | `krg-content-catalog` |
| Amazon Associates / FTC compliance details | `krg-affiliate-monetization-reference` |
| Running the full audit scripts | `krg-qa-and-diagnostics` |
| Fixing the placeholder links for launch | `krg-launch-campaign` |

**Terminal basics (owner note):** every command below is typed into a terminal
(the text-command window; Applications → Terminal on most systems) **from inside
the KRG project folder**. `cd <folder>` moves you into a folder; `grep` searches
text inside files and prints matching lines with `file:line-number:` prefixes.
Commands here only *read* files — none of them change anything.

## 1. Change classification

Classify every change BEFORE editing. When a change spans classes, the whole
change takes the **strictest** class it touches.

| Class | What it covers | Real examples in this repo | Gate |
|---|---|---|---|
| **A — business/legal copy** | Displayed price, guarantee/refund text, the Amazon disclosure block, revenue or social-proof claims, product star ratings | `$7.99` (5 places, see below); "100% Money-back guarantee" (guide.html:51, 270) and "100% Satisfaction Guaranteed" (guide.html:211); refund FAQ (guide.html:250-251); "Join hundreds of home cooks" (guide.html:262); disclosure block (index.html:36-40, footer index.html:328); `⭐` ratings on all 16 product cards | Explicit owner approval **before** editing + full pre-deploy checklist (§3). **AI sessions must never change Class A content unprompted** — propose a diff and wait. |
| **B — structural** | New pages, new/removed product cards, new categories, nav changes, any script.js change | Adding a 17th product card to index.html; adding a `data-category` value (script.js filters on it); changing the nav in either page's `<header>` | Full pre-deploy checklist (§3) + local preview + both-pages consistency check (rule home: `krg-architecture-and-conventions`) |
| **C — cosmetic** | Colors, spacing, typo fixes in non-legal copy | Editing a CSS custom property in styles.css (~835 lines); fixing a typo in a product description | Local preview + spot-check the changed element on both desktop and narrow width |

**Find every price location** (tested 2026-07-07; expect exactly **5** matches —
index.html:172, guide.html:8, 44, 208, 264):

```bash
grep -no '\$7\.99' index.html guide.html
```

**Canonical all-locations sweep** — the `$`-anchored grep above misses price copies
that carry no dollar sign (e.g. JSON-LD `"price": 7.99` or OG meta descriptions, if
those are ever added per krg-growth-frontier). This broader sweep is the authority:

```bash
grep -rn '7\.99' index.html guide.html    # expect exactly 5 matches today
```

**When any new copy of the price is added** (metadata, JSON-LD, a new page), register
it here — update the expected count of BOTH greps and the location list **in the same
change** that adds it. An unregistered price copy is a stale-price bug waiting for the
next price change.

## 2. Non-negotiables and strong defaults

The owner's stated policy is "use good judgment" — so most rules below are
**strong defaults with rationale**, overridable by the owner. The exceptions are
the legally-grounded ones, marked **(legal)**, which are genuinely non-negotiable.

1. **(legal) Keep the Amazon Associates disclosure visible on any page with
   affiliate links.** index.html has 16 Amazon affiliate links and carries the
   disclosure twice (banner at lines 36-40, footer at line 328). Removing or
   hiding it risks FTC trouble and Amazon Associates account termination —
   details and exact required wording live in `krg-affiliate-monetization-reference`.
   guide.html currently has no Amazon links, so it needs no Amazon disclosure;
   if you ever add one there, the disclosure must come with it.

2. **Keep `rel="nofollow"` and `target="_blank"` on every affiliate link.**
   `nofollow` tells search engines not to treat paid links as endorsements
   (a Google policy expectation); `_blank` opens the store in a new tab so the
   visitor doesn't lose your page. Verify no affiliate link is missing nofollow
   (tested; prints **0** when clean):

   ```bash
   grep -n 'btn-affiliate' index.html | grep -vc 'rel="nofollow"'
   ```

3. **Change the price in ALL 5 locations or none.** A visitor who sees $7.99 on
   index.html and a different price at guide.html's buy button will assume a
   scam and leave. Run BOTH greps in §1 (the `$`-anchored one and the canonical
   `grep -rn '7\.99'` sweep) before and after any price change; the count must
   be 0 for the old price and match the registered location count (5 today)
   for the new one. If metadata/JSON-LD price copies have been added, the
   registered count in §1 must already reflect them.

4. **Both-pages rule for shared chrome** (header, nav, footer, disclosure
   styles): index.html and guide.html are separate files with duplicated
   markup — an edit to one does NOT propagate. Full rule and element inventory:
   `krg-architecture-and-conventions` (that skill is the home; do not restate it
   here).

5. **Default to zero-build static** (strong default, owner may override): no
   package.json, no framework, no build step. Rationale: the owner deploys by
   dragging the folder into Netlify; anything requiring `npm install` breaks
   that workflow and adds failure modes with no revenue upside today.

6. **(honest sourcing) Do not add new ratings, testimonials, or guarantee
   claims without real backing.** The existing ones are already flagged as
   compliance risks in the ledger (§4) — do not compound the problem.

## 3. Pre-deploy checklist (run in order)

Run from inside the KRG project folder. Steps 1-3 are commands; 4-8 are eyes-on.

1. **Placeholder/link audit.** Run the maintained audit suite per
   `krg-qa-and-diagnostics` (script paths are its home):
   `bash .claude/skills/krg-qa-and-diagnostics/scripts/run_all.sh`.
   The inline greps below are the fallback if the scripts are missing.
   Current baseline counts are in §4 (baseline 2026-07-06 — authoritative
   source: run `bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh`):

   ```bash
   grep -n 'href="#"' index.html guide.html | wc -l     # placeholder links (baseline: 18)
   grep -rn 'YourShop' index.html guide.html | wc -l    # Etsy placeholders (baseline: 3)
   ```

   If a count went **up** since your change, you added a placeholder — fix it.

2. **Price consistency** (only if anything near prices changed):

   ```bash
   grep -no '\$7\.99' index.html guide.html             # must be exactly 5 lines
   ```

3. **Preview locally** (tested; serves both pages with HTTP 200):

   ```bash
   python3 -m http.server 8000
   ```

   Then open http://localhost:8000/index.html and
   http://localhost:8000/guide.html in a browser. Press Ctrl+C in the terminal
   to stop the server. Full preview options: `krg-preview-and-deploy`.

4. **Click every link you changed** in the preview. For category filters,
   click all four buttons (All / Essential / Optional / Tools) — script.js
   drives them.

5. **Check mobile width**: narrow the browser window to ~375px (or use the
   browser's device toolbar, usually F12 then the phone icon). Nothing should
   overflow horizontally.

6. **Class A only — confirm owner approval is on record** for the exact final
   text. No approval, no deploy.

7. **Deploy** per `krg-preview-and-deploy` (that skill owns deploy and
   rollback; do not improvise).

8. **Verify the LIVE site**: reload the production URL, re-check the changed
   element and the disclosure banner. Netlify occasionally serves a cached
   page — hard-refresh (Ctrl+Shift+R) before concluding something is wrong.

## 4. Open-items ledger

Started **2026-07-06**. No prior incident history exists — the five site files
have not changed since commit `b863b95` (2026-02-04, no reverts); later commits
touch only `.claude/skills/`. Seeded from the 2026-07-06 audit — real findings only.
Every evidence command below was run and its count verified on 2026-07-06.

| # | Item | Evidence (run from project folder) | Status | Fixed via |
|---|---|---|---|---|
| 1 | 16 affiliate "View on Amazon" links are `href="#"` placeholders (earn $0) | `grep -c 'btn-affiliate' index.html` → 16, all `href="#"` | open | `krg-launch-campaign` |
| 2 | 3 "Buy on Etsy" links point at placeholder shop `YourShop` (guide.html:48, 210, 267) | `grep -n 'YourShop' guide.html` → 3 lines | open | `krg-launch-campaign` |
| 3 | 2 Patreon footer links are `href="#"` (index.html:324, guide.html:290) | `grep -n 'Patreon' index.html guide.html` | open | `krg-launch-campaign` |
| 4 | Fabricated star ratings on all 16 product cards (e.g. "⭐⭐⭐⭐⭐ (4.8)") — **compliance risk**, not sourced from Amazon | `grep -c 'product-rating' index.html` → 16 | open | `krg-launch-campaign` (policy detail: `krg-affiliate-monetization-reference`) |
| 5 | Unsubstantiated claims in guide.html: "hundreds of home cooks" (line 262), guarantee claims (money-back: 51, 270; satisfaction: 211) and refund FAQ (250-251) with no product sold yet — **compliance risk** | `grep -ni 'hundreds\|guarantee\|refund' guide.html` | open | `krg-launch-campaign` |

Ledger maintenance: when an item is fixed, change its status to
`closed YYYY-MM-DD` and note the commit; when a new audit finding appears, add
a row with a tested evidence command. Never delete rows.

## 5. Rules for AI sessions

1. **Classify first.** State the class (A/B/C) in your plan before editing.
2. **Class A: propose, never apply.** Present the exact change as a diff
   (before/after text) and stop until the owner explicitly approves in the
   conversation. This includes "obvious improvements" to price, ratings,
   guarantees, disclosure, or social-proof text.
3. **Class B/C: apply directly, but always run the gates** in §3 appropriate
   to the class. "It's a small change" is not an exemption — there is no CI to
   catch you.
4. **Never route around this skill.** Do not batch a Class A edit inside a
   Class C commit, and do not skip the ledger check — if your change touches a
   ledger item, say so and update its row.
5. **Do not invent history.** This project has no incidents on record; if
   asked why a rule exists, cite its rationale in §2, not a made-up outage.
6. **When unsure of the class, treat it as one class stricter** and ask.

## Provenance & maintenance

Authored **2026-07-06** against commit `b863b95` (repo state: 5 site files, no
build system); reviewed & corrected 2026-07-07. All counts and commands above
were executed and verified. The five site files have not changed since commit
`b863b95` (2026-02-04); later commits touch only `.claude/skills/` — verify:
`git log --oneline -1 -- index.html guide.html styles.css script.js README.md`
(expect `b863b95`). Volatile facts and their one-line re-verification commands
(run from the project folder):

| Fact (as of 2026-07-06) | Re-verify with |
|---|---|
| Price $7.99 in exactly 5 places | `grep -no '\$7\.99' index.html guide.html \| wc -l` |
| Price digits `7.99` in exactly 5 places (all-locations sweep, catches $-less copies) | `grep -rn '7\.99' index.html guide.html \| wc -l` |
| 18 `href="#"` placeholders (16 affiliate + 2 Patreon) | `grep -n 'href="#"' index.html guide.html \| wc -l` |
| 3 `YourShop` Etsy placeholders | `grep -c 'YourShop' guide.html` |
| 16 product cards with fabricated ratings | `grep -c 'product-rating' index.html` |
| All affiliate links carry nofollow (0 = clean) | `grep -n 'btn-affiliate' index.html \| grep -vc 'rel="nofollow"'` |
| Still zero-build (no package.json) | `ls package.json` (should error: No such file) |

If any count above drifts, update this file and the ledger in the same change.
