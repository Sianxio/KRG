---
name: krg-docs-and-writing
description: >
  Load when WRITING or EDITING any prose for the Korean Ramen Guide project:
  README.md sections, page copy in index.html or guide.html, product
  descriptions, FAQ entries, hero/CTA text, meta descriptions, copy for NEW
  pages, or any public/external claim (guarantees, ratings, social proof,
  income figures). Also load when maintaining the skill library itself
  (.claude/skills/) — adding, updating, or reconciling skills. Covers the
  docs-of-record inventory, the house copy style guide, claims discipline,
  fill-in templates, and skill-maintenance rules. Do NOT load for content
  mechanics (where copy lives in the DOM, counts, selectors — that is
  krg-content-catalog) or for affiliate-program compliance law (FTC/Amazon
  rules — that is krg-affiliate-monetization-reference).
---

# KRG Docs & Writing

The single skill for HOW to write anything in this project: repo docs, site
copy, and public claims. WHERE copy lives is krg-content-catalog. WHY claims
rules exist legally is krg-affiliate-monetization-reference. WHO must approve
copy that touches money/claims is krg-change-control (Class A gate).

**When to use:** editing README.md; writing or rewriting any visible sentence
on the site; drafting copy for new pages (growth work per krg-growth-frontier);
writing anything a stranger or a platform reviewer will read; touching any
file in `.claude/skills/`.

**When NOT to use:** looking up which DOM node holds a piece of copy or how
many product cards exist (krg-content-catalog); deciding whether a disclosure
is legally required (krg-affiliate-monetization-reference); pure CSS/JS work
with no prose change (krg-architecture-and-conventions).

---

## 1. Docs of record

### 1a. README.md — the only project document

README.md is deploy manual, config checklist, customization guide, SEO tips,
monetization model, analytics plan, and pre-launch checklist in one file.
Its actual section map (verify: `grep '^##' README.md`):

| Heading | Governs |
|---|---|
| `## 📁 Files Included` | File inventory (must match repo contents) |
| `## 🚀 Deploy to Netlify` | Deploy procedure (see krg-preview-and-deploy) |
| `## ⚙️ Configuration Needed` | Placeholder replacement: affiliate links, Etsy URL, Patreon |
| `## 🔧 Customization Options` | Colors, site name, Google Analytics snippet |
| `## 📱 Custom Domain Setup` | DNS instructions |
| `## ✅ Pre-Launch Checklist` | Launch gate (mirrors krg-launch-campaign) |
| `## 🎯 SEO Tips` | Meta tags, sitemap.xml |
| `## 💰 Monetization Strategy` | Revenue MODEL — projections, not results |
| `## 📊 Analytics to Track` | Metric list (see krg-measurement-and-experiments) |
| `## 🆘 Support` / `## 📝 License` | Misc |

### 1b. The staleness rule

README is written in pre-launch voice ("Replace all `#` placeholders…").
Once krg-launch-campaign completes those steps, that text becomes FALSE
documentation. Rule: **README must always describe the CURRENT state of the
site.** When a setup step is completed:

1. Do not delete the section (it documents how the config works).
2. Convert imperative to done-note at the top of the section, e.g.
   `> ✅ Done 2026-07-XX: all 16 affiliate links point to tag \`yourtag-20\`.`
3. Check the corresponding `## ✅ Pre-Launch Checklist` box (`- [x]`).
4. Record the doc update in the krg-change-control ledger with the same
   change that completed the step — never as a separate "later" task.

A README that still says "Replace the Etsy placeholder" after launch is a
Class B defect: file it and fix it.

### 1c. `.claude/skills/` — the second doc set

Eleven `krg-*` skills form the AI-facing documentation. Maintenance covenant
in §5. Skills must never contradict README; README wins on site facts, the
skill wins on process it owns (e.g. change classes live in krg-change-control).

---

## 2. House copy style guide

Every rule below is derived from the shipped files. Quote-check before
inventing style; the corpus is the authority.

| Rule | Real example (file:line) |
|---|---|
| Emoji-led README H2s: emoji + space + title | `## 🚀 Deploy to Netlify` (README.md:13) |
| ✓ checkmark value lists for benefits | `✓ Exact recipe with precise measurements` (guide.html:34) |
| ✓ items joined with ` · ` when inline | `✓ Curated Amazon links · ✓ Trusted brands · ✓ Best prices` (index.html:30) |
| Benefit first, mechanism after a spaced hyphen | `The umami secret weapon - optional but highly recommended` (index.html:107) |
| Product descs: one line, no period, ~6–10 words | `Essential aromatic base for depth and complexity` (index.html:80) |
| Brand suggestions as a "Try:" note, 2–3 brands, Oxford "or" | `Try: Taekyung, Mother-In-Law's, or The Spice Way` (index.html:71) |
| Price RANGES, never exact prices, `$lo-hi` no spaces | `$8-15` (index.html:68); exception: the PDF's own fixed price `$7.99` |
| FAQ: question as `<summary>`, friendly second person, opens with a direct answer word | `Absolutely! If you can measure spices and stir ingredients together, you can make this seasoning blend.` (guide.html:223) |
| Headings are outcome-phrased, often questions/imperatives | `Ready to Make Your Own Korean Ramen Blend?` (index.html:300) |
| Sentence length: 1–2 sentences per paragraph; FAQ answers 2–3 short sentences max | guide.html:227 is two sentences totaling 19 words |
| CTA buttons: verb + object + ` →` | `View on Amazon →` (index.html:70), `Download Complete Recipe Guide →` (index.html:31) |

Jargon defined once: **CTA** = call-to-action, the button/link asking the
reader to act. **Meta description** = the `<meta name="description">` snippet
search engines show under the page title.

### Anti-patterns — present in the corpus, do NOT propagate

These exist in shipped files as open defects (see krg-change-control ledger).
Match the good patterns above; never copy these into new writing:

| Anti-pattern | Where it lives today | Why banned |
|---|---|---|
| Fake specificity: invented star ratings | `⭐⭐⭐⭐⭐ (4.8)` (index.html:69) — no data source exists | Fabricated numbers destroy trust and violate claims discipline (§3) |
| Unverifiable social proof | `Join hundreds of home cooks` (guide.html:262) — no customer count exists | Only real counts may be published (§3) |
| Platform-dependent promises stated as house guarantees | `✓ 100% Money-back guarantee` / `✓ Delivered in 2 minutes` (guide.html:51-52) | Depends on the (not yet chosen) sales platform; Class A |

---

## 3. Claims discipline

A **claim** is any statement a reader could test and find false. Before
publishing one, meet its requirement. Anything in the "Class A" rows also
needs owner approval per krg-change-control; the legal WHY is in
krg-affiliate-monetization-reference.

| Claim type | Required before publishing | Class |
|---|---|---|
| Performance/income ("earn $X/month") | Never publish projections as results. README's `~$200-240/month` (README.md:204) is a hypothetical model built on assumed rates; any public reuse must be labeled "illustrative example, not typical results" | A |
| Social proof ("hundreds of home cooks", review counts) | A real, current count from an owned data source. No source → no number. "X% of readers…" requires data per krg-measurement-and-experiments | A |
| Guarantees ("money-back", "delivered in 2 minutes") | The chosen sales platform (or the owner personally) demonstrably honors it, with terms written down. The existing 30-day refund FAQ (guide.html:251) must match whatever the platform actually does | A |
| Ratings/scores | Only from a real rating system with real submissions. The current `(4.8)` values are fabricated — remove or replace, never extend | A |
| Product claims ("authentic", "tested variations") | "Tested" only if the owner actually made and tasted it; "authentic" only for genuinely Korean products — hedge as "Korean-style" otherwise (the site already does: index.html:29) | B |
| Superlatives ("best prices", "secret weapon") | Budget: at most one per section, and only puffery a reasonable reader won't fact-check. "Best prices" (index.html:30) is at the edge — do not add "cheapest", "#1", "guaranteed lowest" | B |
| Factual product info (shelf life, MSG safety) | A checkable source; keep ranges honest (`3-4 months`, guide.html:243) | C |

Default when unsure: write the weaker, true sentence. "Loved by home cooks"
with zero customers is a lie; "Made for home cooks" is not.

---

## 4. Templates (derived from shipped markup)

Fill every `{…}`; delete nothing structural. Ratings intentionally absent
from the product-card template (§2 anti-patterns).

### New product card (index.html pattern, cards at index.html:60-291; e.g. cards 1–4 at 60–112)

```html
<div class="product-card" data-category="{essential|optional|tools}">
    <div class="product-image">
        <div class="placeholder-img">{emoji}</div>
    </div>
    <h4>{Product Name}</h4>
    <p class="product-desc">{Benefit first - mechanism or caveat after hyphen}</p>
    <div class="product-price">${lo}-{hi}</div>
    <a href="{affiliate-url}" class="btn btn-primary btn-affiliate" target="_blank" rel="nofollow">View on Amazon →</a>
    <p class="product-note">Try: {Brand A}, {Brand B}, or {Brand C}</p>
</div>
```

### New FAQ entry (guide.html pattern, guide.html:221-252)

```html
<details class="faq-item">
    <summary>{Question in the reader's words, ending in ?}</summary>
    <p>{Direct answer word first — Yes!/Absolutely!/No, …}. {One or two short
    supporting sentences in second person. Mention the guide or list if it
    genuinely helps.}</p>
</details>
```

### New README section

```markdown
## {emoji} {Title In Title Case}

{One-sentence purpose.}

### {Numbered or named subsection}
- **{Bold key}:** {short value}
```

Pick an emoji not already used as a section marker
(`grep '^## ' README.md` shows the taken set).

### New page meta description

Model on the two shipped ones — index.html:6 (133-char content) and
guide.html:6 (141-char content). Format: **120–155 characters, two sentences:
what the page is +
what the reader gets, no claims from §3's Class A rows.**

```html
<meta name="description" content="{What this page is, with primary keyword}. {Concrete benefit the reader gets from it}.">
```

---

## 5. Skill-library maintenance

1. **When to update a skill:** whenever any re-verification command in its
   "Provenance & maintenance" table returns a value different from the one
   recorded. Drift caught = update the skill in the same working session,
   not a TODO.
2. **Date-stamping:** every substantive edit updates the "as of" date in the
   Provenance section and states what changed in one line. Do not silently
   rewrite verified facts.
3. **No contradictions:** skills must never contradict README.md or each
   other. On conflict, determine which one matches the actual files
   (grep/Read is the arbiter), fix the STALE document, and note the fix in
   the krg-change-control ledger.
4. **New skills follow this format:** YAML frontmatter with `name:` (krg-
   prefixed) and a trigger-rich `description:` saying when to load AND when
   not to; a "When to use / When NOT" block; imperative voice; and a closing
   "Provenance & maintenance" section with date + one-line re-verification
   commands.
5. **Ownership boundaries:** each rule lives in exactly one skill; others
   cross-reference it by name. Copy approval gating lives in
   krg-change-control. Claims-law rationale lives in
   krg-affiliate-monetization-reference. This skill owns style and phrasing.

---

## Provenance & maintenance

Authored **2026-07-06**; reviewed & corrected 2026-07-07. Anchor: site files
at commit `b863b95` (unchanged since 2026-02-04); the skill library itself is
evolving — see `git log -- .claude/skills` (README.md 226 lines). Every quoted
example above was read from the files.
Re-verify from the project folder:

| Fact (as of 2026-07-06) | Re-verify with |
|---|---|
| README section map (11 H2s, emoji-led) | `grep -c '^## ' README.md` → 11; `grep '^## ' README.md` |
| "umami secret weapon" desc at index.html:107 | `grep -n 'umami secret weapon' index.html` |
| "Try:" brand notes on 12 of 16 cards | `grep -c 'product-note">Try:' index.html` → 12 |
| Price ranges `$lo-hi` on cards | `grep -no 'product-price">\$[0-9]*-[0-9]*' index.html \| head -3` |
| Fabricated ratings still present (anti-pattern live) | `grep -c 'product-rating' index.html` → 16 |
| "Join hundreds" still unfixed | `grep -n 'Join hundreds' guide.html` |
| Guarantee/delivery claims still unfixed | `grep -n 'Money-back guarantee\|Delivered in 2 minutes' guide.html` |
| Revenue model figure unchanged | `grep -n '200-240/month' README.md` |
| Meta description lengths 120–155 chars | `grep -o 'name="description" content="[^"]*"' index.html guide.html` |
| FAQ count on guide page | `grep -c 'faq-item' guide.html` → 8 |

If the ratings, "Join hundreds", or guarantee lines disappear from the files,
move them from "present in corpus" to "fixed on {date}" in §2's anti-pattern
table and update §3 accordingly.
