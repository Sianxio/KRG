---
name: krg-measurement-and-experiments
description: >
  Load when adding analytics to the Korean Ramen Guide site, evaluating whether
  a change actually helped, designing an experiment or A/B test, interpreting
  traffic/CTR/conversion numbers, choosing between GA4 / Netlify Analytics /
  click-event tracking / UTM tagging, or whenever anyone (owner or AI session)
  claims a change "worked" — this skill defines the evidence bar that claim
  must clear. Also load before promising any metric improvement in a plan.
  Do NOT load for repo-state QA or "is the site broken?" checks
  (krg-qa-and-diagnostics), or for deciding WHAT to try next
  (krg-growth-frontier owns the idea backlog).
---

# KRG Measurement & Experiments

How this project turns "I think moving the CTA up will help" into an accepted,
numbers-backed change — or an honestly retired one. Nothing here has been run
against live traffic yet: the site is pre-launch, links are placeholders, and
**zero analytics are installed** (verified below).

## When to use / When NOT

| Use this skill when… | Do NOT use it for… |
|---|---|
| Installing or upgrading analytics | Checking repo health / broken links → `krg-qa-and-diagnostics` |
| Someone claims a change "worked" or "helped" | Picking which growth idea to try → `krg-growth-frontier` |
| Designing an experiment or predicting a number | Approving/classifying the edit itself → `krg-change-control` |
| Reading Amazon/PDF/GA4 dashboards | Deploy mechanics → `krg-preview-and-deploy` |
| Deciding if weekly numbers are signal or noise | Getting the first traffic at all → `krg-launch-campaign` |

## Vocabulary (defined once, used throughout)

| Term | Meaning here |
|---|---|
| **Baseline** | The metric's value measured BEFORE a change, over a stated window. No baseline = no experiment. |
| **CTR** (click-through rate) | Clicks on a link ÷ visitors who saw the page, as a %. E.g. 40 Amazon clicks from 100 visitors = 40% CTR. |
| **Conversion rate** | Purchases ÷ visitors, as a %. For the guide page: PDF sales ÷ guide-page visitors. |
| **A/B test** | Comparing version A vs version B of a page to see which performs better on one metric. |
| **Statistical noise** | Random wobble in small numbers. 3 clicks one week, 5 the next is noise, not a trend. |
| **UTM parameter** | Extra text on a URL (`?utm_source=pinterest`) that tells analytics where a visitor came from. |
| **Novelty effect** | A temporary bump because a change is NEW, not because it is BETTER. Fades in 1–2 weeks. |

---

## 1. The evidence bar (project doctrine)

A change is **adopted** only when ALL four hold:

1. **Predicted number first.** A hypothesis stated a specific number BEFORE the
   change went live ("guide-CTA CTR will rise from X% to at least Y%").
   Predicting after seeing the data is not predicting.
2. **One mechanism explains everything.** The proposed reason for the win must
   also explain any negative or null observations (e.g. "more people saw the
   CTA" must square with guide-page conversion NOT dropping).
3. **It survived an honest attempt to explain it away.** Before celebrating,
   actively try to attribute the result to: traffic-mix shift (did a Pinterest
   pin spike during window B?), seasonality (holiday week? payday week?), or
   novelty effect. Only if the result survives these does it count.
4. **It passed `krg-change-control`.** A winning experiment is still a site
   change; it routes through change control like any other edit. Winning a
   test is evidence FOR adoption, not adoption itself.

Anything that fails this bar is **retired WITH a written note** — one line in
the change-control open-items ledger (see `krg-change-control`) or the README:
what was tried, the numbers, why it was retired. Silent reverts destroy the
project's memory and guarantee the same idea gets re-tried blind.

## 2. Current instrumentation truth (verified 2026-07-06)

`script.js` lines 51–59 (loaded by BOTH pages — `index.html:335`,
`guide.html:301`):

```js
// Add click tracking for affiliate links (optional - for analytics)
const affiliateLinks = document.querySelectorAll('.btn-affiliate');
affiliateLinks.forEach(link => {
    link.addEventListener('click', function() {
        const productName = this.closest('.product-card').querySelector('h4').textContent;
        console.log('Affiliate click:', productName);
        // You can add Google Analytics or other tracking here
    });
});
```

**This is not analytics.** `console.log` prints to the VISITOR'S own browser
console. The data never leaves their machine; the owner never sees it. Current
data collected by this site: **none**.

Once launched, the only revenue ground truth will be:
- **Amazon Associates reports** — clicks, ordered items, commissions.
- **The PDF platform's sales report** — `guide.html` currently points its "Buy
  Now" buttons at a placeholder Etsy shop URL (`guide.html:48` and `:210`), so
  Etsy's stats would be the source if that platform is kept.

Everything else (page views, CTR, traffic sources) needs installing.

## 3. Instrumentation menu (ranked for a zero-build static site)

| Rank | Option | Code change? | Cost | Certainty |
|---|---|---|---|---|
| 1 | GA4 via README's gtag snippet | Paste snippet in 2 files | Free | Snippet verified in repo; GA4 behavior as of author's knowledge 2026-07 — verify at source |
| 2 | Netlify Analytics | None (server-side) | Paid add-on | As of author's knowledge 2026-07 — verify pricing/availability at netlify.com |
| 3 | Upgrade `.btn-affiliate` handler to GA4 events | Edit `script.js` | Free (needs #1 first) | CANDIDATE — untested on live |
| 4 | UTM parameters on inbound links | None (edit shared URLs) | Free | Standard practice; GA4 reads them automatically as of author's knowledge 2026-07 |

**(a) GA4.** The README (lines 115–127) already contains the snippet: add it
before `</head>` in **both** `index.html` and `guide.html`, replacing
`YOUR-GA-ID` (both occurrences) with a real measurement ID from a GA4 property
the owner creates at analytics.google.com. Gives page views, traffic sources,
and page-to-page flow. Privacy note: analytics cookies may require a consent
banner depending on visitor jurisdiction (GDPR/ePrivacy) — verify current
requirements at source before launch; this is a legal question, not a code one.

**(b) Netlify Analytics.** Server-side, so no code change, no cookies, and it
counts visitors who block scripts. It does NOT capture in-page events like
button clicks. Paid per-site add-on; capabilities and price as of author's
knowledge 2026-07 — verify in the Netlify dashboard.

**(c) Upgrade the click handler.** CANDIDATE code — untested on live, requires
(a) installed first. Replace `script.js` line 56's `console.log` with:

```js
if (typeof gtag === 'function') {
    gtag('event', 'affiliate_click', { product_name: productName });
}
console.log('Affiliate click:', productName); // keep for local debugging
```

A matching CANDIDATE for the guide CTA (the `.btn-cta` box, `index.html:169`)
and the guide page's buy buttons would use events like `guide_cta_click` and
`buy_click`. Route the edit through `krg-change-control`; verify events arrive
in GA4's realtime view after deploy (`krg-preview-and-deploy`).

**(d) UTM parameters.** Tag every link you post elsewhere so GA4 can attribute
the visit. Example for a Pinterest pin pointing at the shopping list:

```
https://YOUR-SITE.netlify.app/index.html?utm_source=pinterest&utm_medium=social&utm_campaign=launch
```

UTMs change nothing on the site itself — they only label inbound traffic.
`krg-launch-campaign` is where these tagged links actually get posted.

## 4. The idea lifecycle

| State | Lives in | Exit condition |
|---|---|---|
| 1. Idea | `krg-growth-frontier` backlog | Someone commits to testing it |
| 2. Hypothesis | Written down with a **predicted number** | Number and metric stated before any edit |
| 3. Baseline | Analytics dashboard | Metric measured over N days of stable traffic |
| 4. Change deployed | Via `krg-change-control` + `krg-preview-and-deploy` | Live, deploy date recorded |
| 5. Measurement window | Analytics dashboard | Same N days (same weekdays) as baseline |
| 6. Verdict | This skill's evidence bar (section 1) | **Adopt** (keep, note in README) or **retire-with-note** (revert, note in ledger) |

**Minimum-data honesty.** With tiny traffic, weekly numbers are noise. Rules of
thumb — these are heuristics, not statistics:

- **Under ~100 visitors per window:** don't run experiments at all; any
  "result" is noise. Spend the time on `krg-launch-campaign` instead.
- **~100–500 visitors per window:** only trust differences bigger than about
  ±10 percentage points on a rate metric.
- **Clicks under ~30 per window:** the rate built on them is unstable;
  lengthen the window.
- Always compare **whole weeks to whole weeks** (weekend traffic differs from
  weekday traffic).

## 5. Worked example — moving the mid-page CTA box

**All numbers below are ILLUSTRATIVE (hypothetical), invented to show the
method.** Repo facts are real and verified.

Real elements: `index.html:169` has `<div class="cta-box">` — "Want the
Complete Recipe Guide?" with button text **"Get Full Guide - $7.99 →"**
(`index.html:172`) linking to `guide.html`. It sits AFTER the 8 "Essential
Ingredients" cards (Korean Gochugaru (Fine Grind) through Toasted Sesame Oil)
and BEFORE the "Optional Enhancers" grid.

1. **Idea** (from `krg-growth-frontier`): "Move the cta-box above the product
   grid so visitors see it before scrolling through 8 cards."
2. **Hypothesis with number:** "Guide-CTA CTR (clicks on `.btn-cta` ÷
   index.html visitors) will rise from the baseline to at least 1.5× baseline,
   without guide-page conversion dropping." *Hypothetical concretely:* baseline
   6% → predict ≥9%.
3. **Baseline:** requires instrumentation (a) + a `guide_cta_click` event from
   (c). *Hypothetical:* 14 days, 420 visitors, 25 CTA clicks → **6.0% CTR**.
4. **Deploy:** move the `cta-box` div; Class per `krg-change-control` (layout
   change, no price/claim text touched); deploy via `krg-preview-and-deploy`.
5. **Measurement window:** the NEXT 14 days (same weekday mix). *Hypothetical:*
   445 visitors, 44 clicks → **9.9% CTR**.
6. **Verdict — two possible outcomes:**
   - **Adopt** requires: 9.9% ≥ the predicted 9%; mechanism ("earlier
     visibility") also explains side effects — check guide-page conversion did
     NOT fall (more, colder clicks could dilute it); explain-away check passes
     (no traffic spike from a new pin during window B, no holiday, and ideally
     the lift persists into week 3–4, ruling out novelty). Then route final
     adoption through `krg-change-control` and note the result in the README.
   - **Retire-with-note** if any leg fails — e.g. *hypothetical* 7.1% (under
     prediction), or 9.9% but window B coincided with a viral Pinterest pin
     (traffic-mix shift). Revert the layout, and write one line in the
     change-control open-items ledger: "Moved cta-box above grid, CTR 6.0%→7.1%
     vs predicted 9%; below bar; reverted 2026-XX-XX."

Note the honesty in outcome two: 7.1% is still "up," but it did not clear the
pre-stated bar and small numbers wobble. Adopting every up-tick is how noise
gets enshrined as strategy.

## 6. A/B testing options on static Netlify

| Method | How | Honest caveats |
|---|---|---|
| **Manual sequential test** (recommended) | Measure version A for 2 weeks, deploy B, measure 2 weeks | Time itself is a confound: seasonality, traffic-mix changes, and novelty all land on one version. Mitigate with whole-week windows, the explain-away check, and by extending windows when traffic is thin. |
| **Netlify split testing** | Serve two git branches to split traffic simultaneously | True A/B (same time period, so time confounds vanish), but feature availability, plan requirements, and analytics integration as of author's knowledge 2026-07 — **verify at source** in the Netlify dashboard before planning around it. Needs enough traffic to split. |

**Recommendation for this site:** sequential testing. At pre-launch-to-early
traffic levels, splitting visitors in half doubles the time to reach even the
section-4 heuristic minimums. Revisit split testing if the site sustains
roughly 1,000+ visitors/month (heuristic).

## 7. Reading the revenue dashboards (as of author's knowledge 2026-07 — verify at source)

- **Amazon Associates reports:** show **clicks** (people who followed your
  tagged links), **ordered items**, **shipped/returned items**, and
  **conversion** (ordered ÷ clicks). Clicks here are Amazon's count — expect it
  to differ from your GA4 `affiliate_click` count (ad blockers, bots,
  double-clicks); treat Amazon's number as ground truth for money, GA4's as
  ground truth for on-page behavior.
- **PDF platform sales report:** whichever platform the placeholder Etsy links
  are replaced with (see `krg-launch-campaign`) will report units sold and
  revenue. Sales ÷ guide-page visitors (from GA4) = guide conversion rate.

The README's "📊 Analytics to Track" list (README lines 206–212), restated as a
measurement plan. The README's goals (30–50% Amazon CTR at line 191, 10–20%
guide conversion at line 196) are **aspirations, not measurements** — treat as
unvalidated until real data exists.

| # | Metric (from README) | Source | Cadence | Current value |
|---|---|---|---|---|
| 1 | Traffic sources | GA4 (+ UTM tags) | Weekly | unknown — pre-launch |
| 2 | Page views (shopping list vs guide) | GA4 or Netlify Analytics | Weekly | unknown — pre-launch |
| 3 | Amazon click-through rate | GA4 `affiliate_click` ÷ visitors; cross-check Amazon clicks | Weekly | unknown — pre-launch |
| 4 | Guide page conversion rate | PDF platform sales ÷ GA4 guide-page visitors | Weekly | unknown — pre-launch |
| 5 | Average order value (Amazon) | Amazon Associates report | Monthly | unknown — pre-launch |

First fill of this table happens after `krg-launch-campaign` replaces the
placeholder links and produces real traffic.

## Provenance & maintenance

Written 2026-07-06 against the repo as of that date. Re-verify before trusting:

- Click handler still console-only: `grep -n "console.log" /home/user/KRG/script.js` (expect line ~56 inside the `.btn-affiliate` listener; if it now calls `gtag`, section 2 is stale).
- No analytics installed: `grep -in "gtag\|googletagmanager\|analytics" /home/user/KRG/index.html /home/user/KRG/guide.html` (any hit = section 2/3 stale, update "Current value" column).
- CTA box location: `grep -n "cta-box\|btn-cta" /home/user/KRG/index.html` (expect cta-box at ~line 169, after the essential grid; if moved, the worked example's premise changed).
- README metric claims: `grep -n "30-50\|10-20\|Analytics to Track" /home/user/KRG/README.md`.
- Placeholder buy links: `grep -n "YourShop" /home/user/KRG/guide.html` (no hits = launch happened; update "pre-launch" rows).
- External facts (GA4 setup/consent rules, Netlify Analytics pricing, Netlify split testing, Amazon Associates report fields): all labeled "as of author's knowledge 2026-07" — verify at the vendor's own docs/dashboards before acting.
