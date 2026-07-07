---
name: krg-affiliate-monetization-reference
description: >
  Domain reference for how this site is supposed to make money and stay compliant.
  Load when a question involves Amazon Associates (applying, associate tags, ASINs,
  affiliate URLs, prohibited practices), affiliate links or link attributes
  (nofollow/sponsored), FTC disclosure requirements, fabricated ratings or claims
  compliance ("hundreds of home cooks", money-back guarantee), selling the PDF via
  Etsy/Gumroad/Payhip, or the Patreon link. NOT for executing the launch checklist
  (use krg-launch-campaign) and NOT for the mechanics of editing product cards or
  links in the HTML (use krg-content-catalog).
---

# KRG Affiliate & Monetization Reference

Domain knowledge for the Korean Ramen Guide's three revenue channels: Amazon
Associates commissions, a $7.99 PDF, and Patreon. This skill explains WHY things
must be a certain way. The HOW (launch steps, edits) lives in sibling skills.

## When to use / When NOT

| Situation | Skill |
|---|---|
| "How do Amazon affiliate links work?", "What is a tag/ASIN/cookie?" | THIS skill |
| "Are the star ratings a problem?", "Is our disclosure legal?" | THIS skill |
| "Etsy vs Gumroad?", "What is Patreon for?" | THIS skill |
| "Do the launch" / replace placeholders end-to-end | krg-launch-campaign |
| Add/edit a product card, change a link's href | krg-content-catalog |
| Any change to disclosure or legal copy (Class A change) | krg-change-control |
| Wording/claims discipline when writing new copy | krg-docs-and-writing |
| New revenue ideas beyond the current three | krg-growth-frontier |

## Certainty labels used below

- **[REPO]** — verified against this repository on 2026-07-06 (grep given).
- **[EXTERNAL]** — about Amazon/FTC/Etsy/Google policy. Cannot be verified from
  the repo. Stated as of author's knowledge (2026-07); verify at the named
  official source before relying on it. Never treat these as current fact.

## 1. Affiliate marketing in 10 lines

1. A merchant (Amazon) runs an affiliate program.
2. You join and receive an **associate tag** — a unique ID like `yourname-20`.
3. You link to products with your tag embedded in the URL.
4. A visitor clicks; Amazon sets a **cookie** (a small browser marker crediting you).
5. The **cookie window** is how long that credit lasts — for Amazon, short
   (roughly 24 hours) [EXTERNAL — verify at Amazon Associates Program Policies,
   https://affiliate-program.amazon.com].
6. If the visitor buys within the window, that is a **conversion**.
7. You earn a commission — a percentage that varies by product category and
   changes over time. Never assume a specific rate [EXTERNAL — verify at the
   Amazon Associates commission income statement on the same site].
8. No tag in the URL = no credit = **zero earnings**, even if the visitor buys.
9. Disclosure to visitors is legally required (see section 6).
10. The program has rules; breaking them gets the account closed (see section 3).

## 2. Amazon Associates as it applies to THIS site

### Anatomy of a real affiliate URL

```
https://www.amazon.com/dp/B01N5PWDSO/?tag=yourtag-20
                          └──ASIN──┘      └─the money─┘
```

- **ASIN** — Amazon Standard Identification Number, a 10-character product ID.
  Every Amazon product page URL contains one (after `/dp/`).
- **`tag=yourtag-20`** — your associate tag. This parameter is the money. A
  link without it earns nothing.
- Current state [REPO]: all 16 product links are `href="#"` placeholders.
  Verify: `grep -c 'btn-affiliate' index.html` → 16 anchors, all `href="#"`
  (index.html lines 69–273; baseline 2026-07-06 — authoritative source: run
  `bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh`).
  Not one real URL exists yet.

### The disclosure sentence (already present)

[REPO] index.html line 38 carries the standard sentence in a banner directly
below the hero, above the product grid:

> "Disclosure: As an Amazon Associate, I earn from qualifying purchases."

A shorter repeat sits in the footer (index.html line 312). Verify both:
`grep -n "Amazon Associate" index.html`. Do not reword either without going
through krg-change-control (legal copy = Class A).

### Application reality check

[EXTERNAL — verify at Amazon Associates Program Policies,
https://affiliate-program.amazon.com/help/operating/policies]
As of author's knowledge (2026-07):

- You apply with a **live, content-bearing site** — deploy first, apply second.
- New accounts must generally produce a few qualifying sales within an initial
  window (historically ~180 days / 3 sales) or the account is closed. Treat the
  exact numbers as unverified; the consequence (deadline pressure) is the point.
- Links created before approval, or with a wrong/missing tag, do not pay.

### Prohibited practices mapped to THIS repo

Each row: a program rule as of author's knowledge (2026-07) — all [EXTERNAL],
verify at Amazon Associates Program Policies — mapped to a current repo fact.

| Rule (conservative reading) | Repo fact today | Status |
|---|---|---|
| Do not display star ratings / review counts unless pulled from Amazon's approved tooling (e.g. their API or SiteStripe output) | Site formerly fabricated 16 rating lines (`⭐⭐⭐⭐⭐ (4.8)`); all deleted 2026-07-07. Confirm clean: `grep -c "product-rating" index.html` → 0 | **FIXED 2026-07-07 — never reintroduce without an approved data source** |
| Do not state exact prices that go stale (price display has strict conditions) | Site shows RANGES like `$8-15` (`grep -n "product-price" index.html`), which avoids the stale-exact-price problem. Whether ranges fully satisfy policy is a nuance to verify at the source | Design mitigation; nuance unverified |
| Do not cloak or shorten affiliate links (bit.ly etc.) — the tag must be visible in the destination URL | No shorteners in repo today; keep it that way when real links land | OK — guard |
| Do not incentivize clicks ("click my link to support me" tied to rewards) | Disclosure says clicks "help support the free content" — thank-you framing, generally fine; do not escalate to paid incentives | OK — guard |
| Do not place affiliate links in email, PDFs, or other offline/closed content | Owner sells a PDF (guide.html). Temptation: put Amazon links inside the PDF. **Do not** — the PDF must link back to the website instead | Guard — relevant because of the PDF product |

The ratings fix (launch-campaign Phase 1, menu option 1: delete) was executed
2026-07-07, before any Associates application — as this skill requires.
Reintroducing ratings requires a real approved data source and routes through
krg-change-control (Class A).

## 3. rel="nofollow" vs rel="sponsored"

- **nofollow** — tells search engines "do not pass ranking credit through this
  link". Historic catch-all for paid/untrusted links.
- **sponsored** — newer value specifically for paid/affiliate links.

[REPO] All 16 affiliate anchors currently use `rel="nofollow"` only. Verify:
`grep -c 'rel="nofollow"' index.html` → 16.

[EXTERNAL — verify at Google Search Central, "Qualify your outbound links",
https://developers.google.com/search/docs/crawling-indexing/qualify-outbound-links]
As of author's knowledge (2026-07), Google prefers `rel="sponsored"` for paid
and affiliate links; `nofollow` is still accepted and there is no stated penalty
for using it.

**Candidate recommendation (unresolved):** switch to `rel="nofollow sponsored"`
— valid to combine, satisfies both old and new guidance, no known downside.
Decision and rollout belong to krg-launch-campaign; the sitewide edit to
krg-content-catalog.

## 4. Selling the PDF: Etsy vs Gumroad vs Payhip

[REPO] guide.html has three buy buttons, all pointing at the placeholder
`https://www.etsy.com/shop/YourShop` (lines 48, 210, 267). Verify:
`grep -n "YourShop" guide.html`. README.md (lines 76–79) already names Gumroad
and Payhip as alternatives. Whatever is chosen, the site needs exactly one
thing from it: **a working buy URL to replace YourShop ×3**.

All fee/feature claims below are [EXTERNAL], as of author's knowledge (2026-07)
— verify at each platform's official pricing page before deciding. Do not quote
these as current numbers.

| | Etsy | Gumroad | Payhip |
|---|---|---|---|
| Model | Marketplace with its own buyer traffic | Direct checkout link, no marketplace traffic | Direct checkout link, no marketplace traffic |
| Fees | Per-listing fee PLUS transaction + payment-processing percentages; structure changes — verify at etsy.com/legal/fees | Flat percentage per sale on the free tier — verify at gumroad.com/pricing | Percentage per sale on the free tier, lower paid tiers — verify at payhip.com |
| Digital delivery | Automatic file delivery on purchase | Automatic | Automatic |
| Setup friction | Highest (shop, listing, possibly onboarding fee) | Lowest | Low |
| Fit for KRG | Extra discovery traffic; brand match with "handmade/craft" | Fastest path to a working buy link | Similar to Gumroad; compare current fees |

**Open decision** — no platform is chosen yet. The choice, account creation,
and URL replacement are krg-launch-campaign work. (guide.html's former
"Delivered in 2 minutes" and money-back-guarantee promises were removed
2026-07-07 precisely because they depended on this unchosen platform — see
section 7; reintroduce only after the chosen platform verifiably honors them.)

## 5. Patreon in one paragraph

Patreon is a recurring-membership platform: fans pledge a monthly amount in
exchange for extras (bonus recipes, early access). It is the smallest and most
speculative of the three channels — it needs an audience first, so it earns
nothing at launch. [REPO] The footer link is a dead placeholder: `href="#"` on
"Join on Patreon" in index.html line 308 and guide.html line 290. Verify:
`grep -n "Join on Patreon" *.html`. Either wire it to a real
`patreon.com/username` page or remove it until one exists — a dead "Join"
link erodes trust. (Decision: open; execution: krg-launch-campaign.)

## 6. FTC disclosure basics as applied here

**FTC** — the U.S. Federal Trade Commission, which requires that material
connections (you earn money from these links) be disclosed **clearly and
conspicuously, near the endorsement/links themselves** — a footer-only mention
is generally considered insufficient. [EXTERNAL — verify at FTC Endorsement
Guides, https://www.ftc.gov/business-guidance/resources/ftcs-endorsement-guides-what-people-are-asking]

Honest assessment of THIS site today [REPO]:

| Page | State | Verdict |
|---|---|---|
| index.html | Disclosure banner at line 38, directly below the hero and ABOVE all 16 affiliate links, plus a footer repeat at line 312 | Good — placement is before the links, not footer-only |
| guide.html | Contains NO affiliate links (`grep -c 'btn-affiliate' guide.html` → 0 and `grep -c 'href="https://www.amazon' guide.html` → 0). One editorial Amazon *mention* at line 227 — FAQ text "…we provide a complete Amazon shopping list for easy ordering." — which is not a link and triggers no disclosure requirement | No affiliate disclosure needed on this page |

Keep it this way: if affiliate links are ever added to guide.html or any new
page, that page needs its own near-the-links disclosure. Any edit to disclosure
text is Class A under krg-change-control.

## 7. Claims hygiene: current copy vs reality

Why it matters: FTC rules cover deceptive claims generally, not just missing
disclosures [EXTERNAL — same FTC source as section 6], and fabricated social
proof also risks the Amazon account (section 2). One home per fact: the FIX
procedure for every row lives in krg-launch-campaign; this table defines WHY
each item is a problem. All repo locations verified 2026-07-06.

(Baseline 2026-07-06; live status of each row is tracked in the
`krg-change-control` §4 open-items ledger.)

| Claim in copy | Where [REPO] | Why it's a problem | Status |
|---|---|---|---|
| `⭐⭐⭐⭐⭐ (4.8)` etc., ×16 | Was in every index.html product card; all 16 lines deleted 2026-07-07 (`grep -c "product-rating" index.html` → 0) | Fabricated — not from Amazon; violated Associates rules AND was deceptive social proof | **FIXED 2026-07-07** — never reintroduce without a real data source |
| "Join hundreds of home cooks" | Was guide.html line 262; replaced 2026-07-07 with "Make authentic … in your own kitchen" | Unsubstantiated audience claim — the site had zero customers | **FIXED 2026-07-07** — publish real counts only when they exist |
| "100% Money-back guarantee" / "100% Satisfaction Guaranteed" | Were guide.html lines 51, 211, 270; replaced 2026-07-07 with "Digital PDF download" / "One-time purchase" badges; the refund FAQ now defers to the sales platform's policy | Only truthful if the owner and the chosen platform demonstrably honor refunds | **FIXED 2026-07-07** — reintroduce only with platform-verified refund mechanics (Class A) |
| "Delivered in 2 minutes" | Were guide.html lines 52, 211; removed 2026-07-07 | Delivery timing is the platform's behavior, not the owner's | **FIXED 2026-07-07** — reintroduce only after verifying instant delivery on the chosen platform |
| Price ranges "$8-15" etc. | index.html product cards | Safer than exact prices (go stale) but policy nuance unverified — see section 2 | Mitigated; nuance to verify |
| README revenue math ("~$200-240/month") | README.md lines 194–204 | Internal projection only — never surface commission-rate math in public copy; rates are unverified | Guard — keep out of site copy |

## Provenance & maintenance

- Authored 2026-07-06 against repo state at that date; reviewed & corrected
  2026-07-07 (all [REPO] line numbers from that snapshot; re-run the greps
  rather than trusting line numbers).
- Re-verify repo facts with:
  - `grep -c 'btn-affiliate' index.html` (16 affiliate anchors, all `href="#"`)
  - `grep -c "product-rating" index.html` (0 — fabricated ratings removed 2026-07-07)
  - `grep -n "Amazon Associate" index.html` (disclosure at ~line 38 + footer)
  - `grep -c 'rel="nofollow"' index.html` (16; no `sponsored` yet)
  - `grep -n "YourShop" guide.html` (3 Etsy placeholders)
  - `grep -n "Join on Patreon" *.html` (2 `href="#"` placeholders)
  - `grep -c 'btn-affiliate' guide.html` → 0 and
    `grep -c 'href="https://www.amazon' guide.html` → 0 (guide.html must stay
    free of affiliate links; the harmless text mention of Amazon at line 227
    is expected)
- Re-verify external claims (all labeled [EXTERNAL], knowledge as of 2026-07):
  - Re-check Amazon Associates Program Policies + Operating Agreement at
    https://affiliate-program.amazon.com (cookie window, new-account sales
    window, ratings/price/PDF/cloaking rules, commission rates).
  - Re-check FTC Endorsement Guides at https://www.ftc.gov (disclosure
    placement, deceptive-claims standards).
  - Re-check Google link-qualification guidance at
    https://developers.google.com/search (nofollow vs sponsored).
  - Re-check current fees at etsy.com/legal/fees, gumroad.com/pricing,
    payhip.com before the platform decision.
- Siblings: krg-launch-campaign (executes), krg-change-control (Class A gate on
  legal copy), krg-content-catalog (link/card mechanics), krg-docs-and-writing
  (copy claims discipline), krg-growth-frontier (new channels).
