---
name: krg-qa-and-diagnostics
description: >
  Measurement-first QA for the Korean Ramen Guide repo. Load this skill BEFORE any
  deploy, AFTER any edit to index.html / guide.html / styles.css / script.js, when
  asked "is the site OK?", "is it launch-ready?", "did my edit break anything?",
  when auditing links or placeholders, or whenever you need a NUMBER instead of an
  impression. Ships runnable scripts in scripts/ (placeholder audit, link check,
  chrome-consistency check, HTML structure check, run-all). Do NOT load it to FIX
  what a check finds — placeholders route to krg-launch-campaign, broken behavior
  to krg-debugging-playbook, content edits to krg-content-catalog — and do NOT
  load it for live-traffic analytics (that is krg-measurement-and-experiments;
  this skill audits repo state, not visitor behavior).
---

# KRG QA & Diagnostics

**The doctrine of this skill: measure, don't eyeball.** A check passes when a
command prints the expected number, not when the page "looks right". Any claim
of "fixed", "ready", or "done" made in this project must cite a command AND its
output. If you cannot show the output, the claim is not evidence.

Jargon, defined once:

| Term | Meaning |
|---|---|
| Placeholder | A link that goes nowhere on purpose: `href="#"` or the sample URL `https://www.etsy.com/shop/YourShop`. Earns nothing until replaced. |
| Exit code | The number a script hands back when it finishes. `0` = pass. Anything else = findings or an error. See it with `echo $?` right after running a script. |
| Chrome | The page furniture duplicated across both pages by hand: header nav and footer. Because there is no template system, the copies can drift apart. |
| Drift | The two pages' duplicated chrome silently becoming different after someone edits only one page. |

## When to use this skill

- Before every deploy (it is a gate in krg-change-control's pre-deploy checklist).
- After any edit to the four site files, to prove the edit broke nothing.
- When anyone asks whether the site is launch-ready.
- When you need the current placeholder counts, link inventory, or structure status.

## When NOT to use it (use the sibling instead)

| You want to… | Go to |
|---|---|
| Fix placeholder links / launch the site | krg-launch-campaign |
| Diagnose broken page behavior a check surfaced | krg-debugging-playbook |
| Edit products, prices, copy | krg-content-catalog |
| Decide whether a change is allowed at all | krg-change-control |
| Measure live visitor traffic / CTR / conversions | krg-measurement-and-experiments |
| Deploy or preview | krg-preview-and-deploy |

## The scripts

All scripts live in `.claude/skills/krg-qa-and-diagnostics/scripts/`, are
executable, run from ANY directory (they locate the repo root themselves), and
use only bash + grep/sed/awk + python3 stdlib — nothing to install. They work on
macOS and Linux.

Run everything:

```bash
bash .claude/skills/krg-qa-and-diagnostics/scripts/run_all.sh
```

| Script | What it proves | Exit codes |
|---|---|---|
| `audit_placeholders.sh` | Counts every link that must be replaced before the site can earn: affiliate `href="#"`, Etsy `YourShop`, Patreon `#`, any other `#`. | 0 = launch-ready, 1 = placeholders remain |
| `check_links.sh` | Inventories every external http(s) URL on both pages; with `--online`, HEAD-requests each and prints status codes. | offline: always 0. online: 0 = no dead links, 1 = dead link(s) |
| `check_consistency.sh` | Compares the duplicated nav + footer between the two pages against the recorded acceptable baseline (see below). | 0 = no drift, 1 = drift |
| `check_structure.sh` | Parses both pages with python3 `html.parser`: mismatched/unclosed tags; every `.product-card` has a `data-category` matching a filter button's `data-filter`; both pages reference styles.css + script.js. | 0 = pass, 1 = findings, 2 = missing file/python3 |
| `run_all.sh` | Runs the four above in order and prints a summary. Pass `--online` to include the live link test. | 0 = all pass; otherwise = number of failing checks |

## Golden baseline — expected output as of 2026-07-06 (pre-launch state)

`run_all.sh` currently exits `1` with exactly one failing check, and that is
CORRECT for today's repo. The placeholder audit summary reads:

```
CHECK                                         COUNT  LAUNCH TARGET
Affiliate links still href="#" (index.html)      16  0
Etsy 'YourShop' placeholders (guide.html)         3  0
Patreon href="#" links (both pages)               2  0
Other href="#" links (both pages)                 0  0
TOTAL placeholders                               21  0
```

and the other three checks print:

```
[check_links]        Unique external http(s) URLs found: 1  (https://www.etsy.com/shop/YourShop)
[check_consistency]  RESULT: PASS - no unexpected chrome drift between the two pages.
[check_structure]    RESULT: PASS - structure checks all green.
```

**Launch-ready numbers** (the krg-launch-campaign success condition): every
placeholder row `0`, TOTAL `0`, `run_all.sh` exits `0`.

If your numbers differ from BOTH this table and the launch targets, the repo has
changed since this baseline — re-derive the counts, then update this section
(that update routes through krg-docs-and-writing's skill-maintenance rules).

## Interpretation guide — what a failure means and where to go

| Observation | Meaning | Route |
|---|---|---|
| `audit_placeholders.sh` > 0 | Site still has dead money links. Not a bug — it's the unfinished launch. | krg-launch-campaign |
| `check_links.sh --online` prints `000` for a URL | No HTTP response: dead host, timeout, or a corporate/sandbox proxy blocked outbound requests. On a normal home connection treat as a dead link; inside a sandboxed/proxied environment `000` is EXPECTED for external sites and proves nothing — verify in a browser instead. | krg-debugging-playbook |
| `check_links.sh --online` prints `403`/`405` WARN | The server blocks scripted requests (common for Amazon/Etsy). Not evidence of a dead link — open it in a browser. | manual browser check |
| `check_consistency.sh` FAIL | Someone edited nav/footer on one page only — the both-pages rule was violated. | krg-architecture-and-conventions (the rule), then fix and re-run |
| `check_structure.sh` tag mismatch | Broken HTML edit (usually an unclosed `</div>`), which can swallow following cards. | krg-debugging-playbook §2 |
| `check_structure.sh` orphan data-category | A card was added with a category no filter button knows — it disappears when any filter is clicked. | krg-content-catalog (add-a-category checklist) |

Note on `check_consistency.sh`'s recorded baseline: the footers intentionally
differ in exactly ONE line (index.html carries the Amazon Associates line,
guide.html carries "Refund Policy · Privacy Policy · Terms"). The script knows
this and passes on it. If the pages are DELIBERATELY changed so that this
known-acceptable difference changes, update the baseline inside
`check_consistency.sh` in the same commit.

## Manual diagnostics (cannot be scripted here)

1. **Browser devtools console — always the first responder.** Open the page,
   press F12 (or right-click → Inspect → Console). Red text = a JS/asset error;
   copy it verbatim into any bug report. Interpretation: krg-debugging-playbook.
2. **W3C HTML validator** — https://validator.w3.org → "Validate by Direct
   Input" → paste the full contents of index.html (then guide.html). Expect
   warnings at most; errors mean broken markup that `html.parser` may have
   missed. (External web UI — flow as of 2026-07-06.)
3. **Google PageSpeed Insights** — https://pagespeed.web.dev → paste the LIVE
   site URL (works only after deploy). Gives performance/accessibility/SEO
   scores with explanations. Record the numbers; they are the baseline for any
   future "performance improvement" claim (evidence bar:
   krg-measurement-and-experiments). (External web UI.)
4. **Click-test** — after any link change, actually click it on the deployed
   site and confirm where the address bar lands. Scripted HEAD checks cannot
   prove an affiliate tag survives Amazon's redirects; your eyes on the URL bar
   can.

## Evidence standard for reports

When reporting QA status (human or AI session), use this exact form:

> CLAIM: <what you assert>
> COMMAND: <the command run>
> OUTPUT: <the relevant lines, pasted>

A report without the OUTPUT line is an opinion, not a result.

## Provenance & maintenance

Facts in this file verified against the repo on **2026-07-06** (scripts executed
2026-07-07 UTC in a sandboxed environment; the `000` proxy behavior in
`check_links.sh --online` was observed there).

Re-verify any of this in one line each:

```bash
bash .claude/skills/krg-qa-and-diagnostics/scripts/run_all.sh   # full suite; compare against the golden baseline above
bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh   # placeholder counts only
bash .claude/skills/krg-qa-and-diagnostics/scripts/check_links.sh --online # live link statuses (needs internet)
ls -l .claude/skills/krg-qa-and-diagnostics/scripts/            # all five scripts present and executable
```

Maintenance rules: if a script's recorded baseline goes stale (site legitimately
changed), update the script AND this file's golden-baseline section in the same
commit; skill-format rules live in krg-docs-and-writing.
