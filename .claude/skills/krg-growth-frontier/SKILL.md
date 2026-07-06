---
name: krg-growth-frontier
description: >
  The KRG growth research frontier: ranked open problems for growing traffic and
  revenue on this two-page Korean Ramen Guide affiliate site. Load when asked how
  to grow traffic or revenue, what to build next, SEO improvements, adding a
  sitemap/robots/favicon/meta tags, social sharing previews, structured data /
  schema.org, email list or newsletter capture, new content pages for long-tail
  search, or conversion-rate experiment ideas. Do NOT load for replacing
  placeholder affiliate/Etsy links or launch tasks (use krg-launch-campaign), nor
  for how to measure results or run an experiment (use
  krg-measurement-and-experiments).
---

# KRG Growth Frontier

Ranked open problems where this site can grow. Every item below is a **candidate** —
nothing here is proven for this site yet. Predicted benefits are hypotheses based on
general SEO/marketing knowledge **as of author's knowledge 2026-07; verify current
guidance** before acting. Verify every "missing X" claim with the command given —
the repo may have changed since this was written.

## When to use / When NOT

| Use this skill when… | Do NOT use it for… |
|---|---|
| Asked "what should we build next?" or "how do we grow traffic/revenue?" | Replacing placeholder Amazon/Etsy links, go-live tasks → **krg-launch-campaign** |
| Planning SEO, social previews, structured data, email capture, new pages | Deciding how to measure an outcome or run an A/B test → **krg-measurement-and-experiments** |
| Generating conversion-experiment hypotheses | Executing a structural HTML change (that is Class B → **krg-change-control**) |
| Prioritizing among growth options | Mechanics of adding a page/card → **krg-content-catalog**; copy style → **krg-docs-and-writing** |

**Hard prerequisite:** the site is pre-launch — all monetization links are placeholders.
Frontier work compounds only after launch. Complete **krg-launch-campaign** first, or in
parallel; never instead.

## Jargon (defined once)

| Term | Meaning |
|---|---|
| SEO | Search Engine Optimization — making pages easier for search engines to find, understand, and rank |
| SERP | Search Engine Results Page — the list of results a query returns |
| OG tags | Open Graph `<meta>` tags controlling how a link previews on social/chat platforms |
| Structured data | Machine-readable page description (schema.org vocabulary, usually JSON-LD in a `<script>` tag) that can enable enhanced "rich" SERP results |
| CTR | Click-Through Rate — clicks ÷ impressions |
| Conversion rate | Fraction of visitors completing a goal (affiliate click, PDF purchase, email signup) |
| Long-tail keyword | Specific low-volume, low-competition search phrase (e.g. "gochugaru substitute for ramen") |

## Ranking rationale (pre-launch affiliate site)

Order below = recommended attack order. Reasoning: items 1–3 are cheap one-time HTML/file
edits that must exist *before* launch traffic arrives (crawlers and social shares hit the
site from day one); 4–5 are ongoing compounding investments that need the foundation
first; 6 needs real traffic to test against; 7 is owner-deprioritized.

---

## Frontier 1 — SEO technical foundation (sitemap, robots.txt, favicon, canonical) — candidate

**(a) Shortfall.** No sitemap, no robots.txt, no favicon file or `<link rel="icon">`,
no canonical URLs. Search engines can still crawl two pages, but there is no crawl
guidance, no icon in tabs/SERPs, and no canonical signal if the Netlify URL and a
custom domain both serve the site (duplicate-content risk — hypothesis, common knowledge).
Verify: `ls /home/user/KRG/sitemap.xml /home/user/KRG/robots.txt /home/user/KRG/favicon.ico`
(all three: No such file) and
`grep -in 'canonical\|rel="icon"' /home/user/KRG/index.html /home/user/KRG/guide.html` (no matches).

**(b) Leverage.** README.md already contains a ready sitemap.xml template (lines ~170–184)
— adapt, don't invent. Two-page site = five-minute sitemap. Zero-build repo means these
are plain files at the web root, no tooling.

**(c) First three steps.**
1. Create `/home/user/KRG/sitemap.xml` from the README template (README.md lines 170–184), replacing `https://yoursite.com/` with the real production URL (from krg-launch-campaign).
2. Create `/home/user/KRG/robots.txt` with `User-agent: *`, `Allow: /`, and a `Sitemap:` line pointing at the sitemap URL.
3. Add `<link rel="icon" href="favicon.ico">` and `<link rel="canonical" href="…">` inside `<head>` of both index.html and guide.html (both heads currently span lines 3–10; insert before `</head>` at line 10). Supply a real favicon.ico at the repo root. Structural head edits = Class B per **krg-change-control**.

**(d) Milestone.** Result when Google Search Console reports the submitted sitemap as
"Success" with **2 pages discovered** (data source: Search Console → Sitemaps report).

**(e) Effort/priority.** ~1 hour; **do first**. Depends on: final production URL
(krg-launch-campaign). Measurement discipline: krg-measurement-and-experiments.

---

## Frontier 2 — Social sharing readiness (OG + Twitter meta tags) — candidate

**(a) Shortfall.** Neither page has any Open Graph or Twitter Card tags, so shared links
render as bare URLs or auto-scraped fragments — plausibly lowering share CTR (hypothesis).
Verify: `grep -in 'og:\|twitter:' /home/user/KRG/index.html /home/user/KRG/guide.html` (no matches).

**(b) Leverage.** README.md lines ~158–168 already contain OG + Twitter snippet drafts
(`og:title`, `og:description`, `og:image`, `twitter:card`). Food content is visually
shareable; Pinterest/Instagram is named as a target channel in README's own strategy notes.

**(c) First three steps.**
1. Add the README's OG/Twitter block (README.md lines 158–168) into `<head>` of index.html (before `</head>`, line 10), rewriting content per page — index gets shopping-list copy, per **krg-docs-and-writing**.
2. Repeat for guide.html `<head>` (before `</head>`, line 10) with PDF-guide copy including the $7.99 offer.
3. Create a real 1200×630 `og:image` (e.g. `/home/user/KRG/preview.jpg`) — the README snippet references a placeholder image URL that does not exist; an OG block pointing at a 404 image fails validators.

**(d) Milestone.** Result when a card validator (e.g. opengraph.xyz or the platform's own
sharing debugger — verify current tooling, 2026-07 knowledge) renders **both pages** with
correct title, description, and image: **2/2 pages pass**, 0 warnings on required tags
(data source: validator output screenshot).

**(e) Effort/priority.** ~1–2 hours incl. image; **second**. Depends on: Frontier 1 canonical
URL decision. Class B head edits per krg-change-control.

---

## Frontier 3 — Structured data (JSON-LD: FAQ, Product, ItemList) — candidate

**(a) Shortfall.** No schema.org markup anywhere, so the site is ineligible for any rich
SERP treatment. Verify:
`grep -in 'application/ld+json\|schema.org' /home/user/KRG/index.html /home/user/KRG/guide.html` (no matches).

**(b) Leverage.** guide.html already has a real FAQ section: **8 `<details>` items** at
lines 221–252 (verify: `grep -c '<details' /home/user/KRG/guide.html` → 8) — FAQPage
JSON-LD can be generated 1:1 from existing copy. index.html has 16 product cards suited
to ItemList; guide.html's $7.99 PDF suits Product/Offer. **Rich-result eligibility is a
candidate outcome only** — search engines restrict which sites/types get rich display
(as of author's knowledge 2026-07, FAQ rich results are heavily restricted; verify current
guidance before promising anything).

**(c) First three steps.**
1. Add a `<script type="application/ld+json">` FAQPage block to guide.html `<head>` (before `</head>`, line 10), with mainEntity built from the exact 8 question/answer pairs at lines 221–252 — text must match visible content.
2. Add a Product + Offer block (name, `price: 7.99`, `priceCurrency: USD`) to guide.html head, sourcing copy from the price container at lines 42–48.
3. Add an ItemList block to index.html head enumerating the 16 product-card names in page order (cards use `product-price` divs; see krg-content-catalog for card anatomy).

**(d) Milestone.** Result when Google's Rich Results Test / Schema.org validator reports
**0 errors across all 3 blocks** (data source: validator output). SERP rich display is a
separate, non-guaranteed follow-on — track impressions per krg-measurement-and-experiments.

**(e) Effort/priority.** ~2 hours; **third**. Depends on: none (can precede launch).
Must stay in sync with FAQ copy — note this in any FAQ edit (krg-change-control Class B).

---

## Frontier 4 — Content expansion for long-tail search — open

**(a) Shortfall.** One content page per revenue stream: index.html feeds affiliate clicks,
guide.html sells the PDF, and nothing else can rank. Verify:
`ls /home/user/KRG/*.html` → only index.html and guide.html. Two pages give search engines
almost no long-tail surface area (hypothesis, common knowledge).

**(b) Leverage.** The 16-product shopping list is a natural link target: every new article
("gochugaru substitutes", "gochujang vs gochugaru", "Korean ramen on a budget") can funnel
readers into existing monetized pages. Zero-build static HTML means a new page = one file
copied from existing conventions (per **krg-architecture-and-conventions** — do not add a
static-site generator casually; that is a separate, explicit decision).

**(c) First three steps.**
1. Pick one long-tail topic with clear purchase intent (candidate: "gochugaru substitutes") and draft per **krg-docs-and-writing**.
2. Create `/home/user/KRG/gochugaru-substitutes.html` by copying guide.html's skeleton (head lines 1–10, header/nav lines 12–24, footer) and following page-addition mechanics in **krg-content-catalog**; include head tags from Frontiers 1–3.
3. Cross-link: add the new page to sitemap.xml, link to it from an index.html section, and link from the article body back to relevant index.html product cards and the guide.html CTA.

**(d) Milestone.** Result when the new page records its **first organic impression, then
first click** in Google Search Console (data source: Search Console → Performance → Pages
filter). No impressions within ~8 weeks post-index = falsified for that topic; pick again.

**(e) Effort/priority.** ~3–4 hours/page, ongoing; **fourth — start only after launch +
Frontiers 1–3**. Depends on: launch (krg-launch-campaign), Search Console access. New page
= structural change, Class B per krg-change-control.

---

## Frontier 5 — Email capture — open

**(a) Shortfall.** No email form, signup, or mailto anywhere, so every visitor who doesn't
buy today is lost permanently. Verify:
`grep -ci '<form\|mailto\|subscribe' /home/user/KRG/index.html /home/user/KRG/guide.html` → 0 and 0.

**(b) Leverage.** A natural lead magnet already exists: a free excerpt or "top 5 ingredients"
mini-list from the paid guide. Email owns the audience independent of SERP volatility
(hypothesis, common knowledge).

**Options ranked for a zero-build static Netlify site** (all: verify current pricing/terms, 2026-07 knowledge):

| Rank | Option | Why | Caveat |
|---|---|---|---|
| 1 | Netlify Forms (`data-netlify="true"` attribute on a plain `<form>`) | Zero JS, zero external service, works with existing deploy | **Verify current free-tier limits and whether Forms is still offered on the current plan** |
| 2 | Buttondown embed form | Simple HTML form POST, newsletter sending included | External dependency; free tier is small — verify |
| 3 | ConvertKit (Kit) embed | Mature automation | Embed script = external JS; heavier than needed now |

**(c) First three steps.**
1. Add a plain HTML `<form>` (name, email, submit) above the footer of index.html (footer region after the final CTA box at lines 169–173 / end of cards) using Netlify Forms attributes — no JS required.
2. Add the same form to guide.html near the after-purchase note (line 273) framed as "not ready to buy? get the free mini-list".
3. Wire the thank-you: a `/home/user/KRG/thanks.html` page (added to sitemap) or Netlify's default success screen; deliver the lead magnet from it.

**(d) Milestone.** Result at the **first real subscriber** (n=1, excluding your own test
entries; data source: Netlify Forms submissions dashboard or provider list). Then judge
signup rate per **krg-measurement-and-experiments**.

**(e) Effort/priority.** ~2–3 hours; **fifth — needs traffic to matter, but cheap enough to
ship at launch**. Depends on: Netlify Forms availability check; lead-magnet asset. Class B.

---

## Frontier 6 — Conversion optimization — open (hypotheses only)

**(a) Shortfall.** All conversion copy/layout choices are untested defaults; there is no
analytics beyond a `console.log` on affiliate clicks (verify:
`grep -n 'console.log' /home/user/KRG/script.js` → line 56), so no current basis for
optimizing anything.

**(b) Leverage.** The site already has distinct testable elements: mid-page CTA box
(index.html lines 169–173), three Buy buttons on guide.html (lines 48, 210, 267), price
presentation ($7.99 blocks at guide.html lines 42–48 and 263–267), FAQ ordering, and
product-card copy honesty.

**(c) First three steps — every hypothesis MUST route through krg-measurement-and-experiments
before adoption; do not "just change it".**
1. Write a hypothesis backlog file inside an experiment doc (per that skill's format). Seed candidates: (i) CTA position — mid-list CTA box (index.html 169–173) vs end-of-page; (ii) price anchoring — show "restaurant bowl costs $15+" near the $7.99 block; (iii) review honesty — plain-spoken product-card blurbs vs superlatives (see krg-docs-and-writing).
2. Get real click measurement in place first (replace the console.log at script.js line 56 with actual analytics — instrumentation choice belongs to krg-measurement-and-experiments).
3. Run ONE experiment at a time on the highest-traffic element, per that skill's discipline.

**(d) Milestone format.** A result = a **measured CTR delta with a stated baseline**, e.g.
"affiliate-link CTR moved from X% to Y% over N sessions" (data source: the analytics
instrument chosen via krg-measurement-and-experiments). No measurement = no result.

**(e) Effort/priority.** Ongoing; **sixth — meaningless before organic traffic exists**.
Depends on: launch, analytics, Frontiers 1–4 traffic. Any layout change = Class B.

---

## Frontier 7 — Template-ization / site network — PARKED

Owner has deprioritized this. Candidate idea: extract the two-page pattern into a template
and stamp out sibling niche sites. Honestly labeled: **do not start** until this site has
demonstrated repeatable revenue — cloning an unproven funnel multiplies zero. Revisit only
with owner sign-off and evidence from krg-measurement-and-experiments.

---

## NOT the frontier (attractive but wrong-path now)

| Temptation | One-line reason to refuse |
|---|---|
| Adding a JS framework / SSG / build step | Violates the zero-build default (krg-architecture-and-conventions); two pages don't need tooling |
| Paid ads before organic validation | Spends money to test an unproven funnel with placeholder links; validate organically first |
| Scraping Amazon data for prices/reviews | Likely violates Amazon Associates terms and breaks silently; use the affiliate program's sanctioned tools (krg-affiliate-monetization-reference) |
| Blog platform / CMS migration | Content need is a handful of static pages (Frontier 4), not a platform |
| Chasing rich results as a guarantee | Eligibility is search-engine-controlled and shifting; treat as candidate upside only (Frontier 3) |

## Provenance & maintenance

Authored 2026-07-06 against the repo state below. Before acting on ANY frontier, re-verify
its gap claim — one command each:

| Claim | Re-verify with |
|---|---|
| No sitemap.xml | `ls /home/user/KRG/sitemap.xml` |
| No robots.txt | `ls /home/user/KRG/robots.txt` |
| No favicon file | `ls /home/user/KRG/favicon.ico` (and `grep -in 'rel="icon"' /home/user/KRG/*.html`) |
| No OG/Twitter/canonical tags | `grep -in 'og:\|twitter:\|canonical' /home/user/KRG/index.html /home/user/KRG/guide.html` |
| No structured data | `grep -in 'application/ld+json' /home/user/KRG/*.html` |
| No email form | `grep -ci '<form\|mailto\|subscribe' /home/user/KRG/index.html /home/user/KRG/guide.html` |
| Analytics = console.log only | `grep -n 'console.log\|gtag\|plausible' /home/user/KRG/script.js` |
| README OG snippet / sitemap template | `grep -n 'og:title\|sitemap' /home/user/KRG/README.md` (lines ~160 / ~170) |
| 8 FAQ `<details>` items | `grep -c '<details' /home/user/KRG/guide.html` |
| 16 product cards | `grep -c 'product-card\|class="card"' /home/user/KRG/index.html` |
| Only two HTML pages | `ls /home/user/KRG/*.html` |

Line numbers cited (index.html `</head>` line 10; guide.html FAQ 221–252, Buy buttons
48/210/267, price 42–48/263–267; index.html CTA 169–173; script.js 56; README 158–184)
were verified 2026-07-06 — re-check with `grep -n` before editing, and update this file
when they drift. External SEO/marketing claims: as of author's knowledge 2026-07; verify
current guidance.
