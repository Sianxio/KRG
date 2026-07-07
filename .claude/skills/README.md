# KRG Skill Library — Index

Eleven skills documenting the Korean Ramen Guide site (two-page static affiliate site,
5 files at the repo root). Date-stamp: 2026-07-07.

**Start here (newcomers):** read `krg-architecture-and-conventions` (how the site works),
then `krg-change-control` (what gates every edit), then the skill your task routes to below.

## Routing table — skill → load when

| Skill | Load when |
|---|---|
| krg-architecture-and-conventions | Before any structural HTML/CSS/JS edit; "how does this site work?"; both-pages rule; HTML↔JS contract |
| krg-change-control | Before ANY edit — Class A/B/C classification, gates, pre-deploy checklist, open-items ledger |
| krg-content-catalog | Adding/editing content: product cards, categories, prices, FAQ, CTAs, nav/footer, palette, new HTML pages (§3.7) |
| krg-debugging-playbook | Something looks broken, doesn't filter, doesn't update, looks wrong |
| krg-qa-and-diagnostics | Before deploy / after any edit — runnable audit scripts, "is it launch-ready?" |
| krg-preview-and-deploy | Preview locally, deploy to Netlify, verify/roll back a deploy, disaster recovery |
| krg-launch-campaign | Launch/monetize: replace placeholder links, compliance pre-clean, platform setup |
| krg-affiliate-monetization-reference | WHY compliance rules exist: Amazon Associates, FTC disclosure, nofollow, claims |
| krg-measurement-and-experiments | Analytics install, experiments, evidence bar for "it worked" claims |
| krg-growth-frontier | What to build next: SEO, meta tags, structured data, email capture, new content pages |
| krg-docs-and-writing | Writing any prose: README, page copy, claims discipline, skill-library maintenance |

## Fact homes — one authoritative home per volatile fact

| Fact | Home |
|---|---|
| Placeholder baseline counts (16/3/2, 21 total) | krg-qa-and-diagnostics golden baseline + `scripts/audit_placeholders.sh` |
| Price rule ($7.99 all-locations sweep + registered count) | krg-change-control §1–§2 |
| Both-pages chrome rule + drift diff baseline | krg-architecture-and-conventions §1 |
| Compliance WHY (ratings, claims, disclosure law) | krg-affiliate-monetization-reference |
| Ratings/claims status ledger | krg-change-control §4 |
| Claims/copy style rules | krg-docs-and-writing |
| Launch execution + campaign status board | krg-launch-campaign |

Skill-maintenance rules (format, provenance, no-contradiction covenant):
krg-docs-and-writing §5.
