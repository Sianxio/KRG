---
name: krg-preview-and-deploy
description: >
  Run, preview, deploy, and recover the Korean Ramen Guide site. Load this skill when you need to:
  view the site locally (open in browser, local server, localhost preview), set up the environment
  from scratch, get the code (git clone / git pull), deploy to Netlify (drag-and-drop or
  GitHub auto-deploy), verify a deploy went live, roll back a bad deploy, set up a custom
  domain or HTTPS, or rebuild everything after losing the repo or Netlify account.
  Do NOT load for editing page content (krg-content-catalog), debugging page behavior
  (krg-debugging-playbook), or pre-deploy review gates (krg-change-control).
---

# KRG: Preview & Deploy

## When to use / When NOT

| Situation | Use |
|---|---|
| "How do I see the site on my computer?" | **This skill** |
| "How do I put my changes live?" / rollback / custom domain / HTTPS | **This skill** |
| Repo or Netlify account lost — rebuild from scratch | **This skill** |
| What files exist, how the code is organized | krg-architecture-and-conventions |
| What to check BEFORE deploying (review gates) | krg-change-control |
| "I deployed but the live site didn't change" | krg-debugging-playbook |
| Audit scripts (link checks, HTML checks) | krg-qa-and-diagnostics |
| Editing products, prices, links, copy | krg-content-catalog |
| Replacing placeholder affiliate links, launch prep | krg-launch-campaign |
| Analytics / measuring traffic | krg-measurement-and-experiments |

## 1. What "running this site" means (read first)

This site is **5 plain files** at the repo root: `index.html`, `guide.html`, `styles.css`, `script.js`, `README.md`. There is **nothing to install, nothing to build, no package.json, no tests, no CI**. A web browser can display the HTML files directly. "Deploying" just means copying these files to Netlify's servers.

Jargon, one sentence each:
- **Git** — a program that tracks every saved version of your files so you can go back in time.
- **GitHub** — a website (github.com) that stores your git history online; this project's canonical home is `github.com/Sianxio/KRG` per the session record (recorded, not verified from this environment).
- **Netlify** — a hosting service that takes your files and serves them to the world as a website; historically its free tier covers sites like this — verify current plans on netlify.com.
- **localhost** — a web address (`http://localhost:8000`) that points at your own computer, so only you can see it.

Environment from scratch = a browser. Optionally git (to get/update code) and python3 (for a nicer local preview). That's the whole setup.

## 2. Local preview — two ways

### Way A: zero tools — just open the file
Double-click `index.html` (or in a browser: File → Open File → pick `index.html`). This works for THIS site because every reference is relative — verified 2026-07-06: `styles.css` and `script.js` are loaded with plain relative paths, and there are no absolute paths (`href="/..."`), no `fetch()` calls, and no external images in any of the 5 files. So the `file://` view is faithful.

### Way B: proper local server (verified working in this repo)
```bash
cd /home/user/KRG && python3 -m http.server 8000
```
Then open **http://localhost:8000** in a browser (`/guide.html` for page two). Verified 2026-07-06 with python3 3.11: `/`, `/guide.html`, and `/styles.css` all return HTTP 200.

To stop the server: press **Ctrl+C** in the terminal window where it is running.

## 3. Getting the code (git one-liners)

Find your repo URL (this prints where "origin" — your git remote — lives):
```bash
git remote -v
```
**Your checkout's URL may differ** (mirrors and proxies exist — e.g. AI/sandbox sessions
see a local proxy URL) — run `git remote -v` and use whatever IT prints. The canonical
repo is `github.com/Sianxio/KRG` per the session record (recorded, not verified from
this environment — confirm at github.com before relying on it for recovery).

- **First time on a new computer** — download a full copy from the canonical repo:
  ```bash
  git clone https://github.com/Sianxio/KRG.git KRG
  ```
  (`git clone <url>` copies the whole project and its history into a new folder.)
- **Already have the folder** — pull the latest changes:
  ```bash
  cd /home/user/KRG && git pull
  ```
  (`git pull` downloads any commits on GitHub that your computer doesn't have yet.)

For committing/pushing changes, follow the gates in **krg-change-control** — that skill owns the pre-deploy checklist; don't improvise one here.

## 4. Deploying to Netlify — the two README-documented paths

**Before ANY deploy (either path below): complete the krg-change-control pre-deploy
checklist (includes running the QA suite).** That checklist is the gate; this skill is
only the mechanics — drag-and-drop involves no commit/push, so nothing else stops an
ungated deploy.

There is **no `netlify.toml` or any Netlify config file in the repo** (verified 2026-07-06) — Netlify needs zero configuration for this site: build command = **none**, publish directory = **repo root**.

### Path A: drag-and-drop (easiest; UI flow — as documented in README / Netlify docs, verify on site)
1. Go to app.netlify.com and log in (or sign up).
2. Drag the **entire KRG folder** into the deploy drop-zone (do not drag files one by one — drag the folder so all 5 root files come along: `index.html`, `guide.html`, `styles.css`, `script.js`, `README.md`).
3. Netlify uploads it and gives you a live URL. Done.

Repeat the same drag to publish updates — each drag is a new deploy.

### Path B: GitHub-connected auto-deploy (UI flow — as documented in README / Netlify docs, verify on site)
One-time setup: app.netlify.com → "New site from Git" → choose GitHub → select the `sianxio/krg` repository → leave build command **empty** and publish directory as the **root** → "Deploy site".

After setup, every push to the `main` branch deploys automatically — no Netlify visit needed. Deploys are typically fast (historically well under a minute for a site this small — verify in the Netlify deploy log).

## 5. Verifying a deploy actually went live

After deploying, confirm your change is on the live site (not just on your computer):

```bash
curl -s https://YOUR-SITE.netlify.app/ | grep -i 'text you just changed'
```
Example against this site's homepage title (pattern verified locally 2026-07-06):
```bash
curl -s https://YOUR-SITE.netlify.app/ | grep -io '<title>[^<]*'
# expected: <title>Korean Ramen Ingredients Shopping List | Complete Guide ...
```
A match printed = your change is live. No output = the deploy didn't include it — see the "live site doesn't update" triage in **krg-debugging-playbook**.

**Hard-refresh caveat:** browsers cache old copies. If curl shows the change but your browser doesn't, force-reload: **Ctrl+Shift+R** (Windows/Linux) or **Cmd+Shift+R** (Mac).

Also spot-check monetization state on the live page (placeholder Amazon links are `href="#"` — details in **krg-launch-campaign**):
```bash
curl -s https://YOUR-SITE.netlify.app/ | grep -c 'href="#"'
# 17 today (16 product buttons + footer Patreon placeholder); should trend to 0 before launch
# (baseline 2026-07-06 — authoritative source: run
#  bash .claude/skills/krg-qa-and-diagnostics/scripts/audit_placeholders.sh)
```

## 6. Rollback (undoing a bad deploy)

- **Netlify way (fast, no git needed; UI flow — verify on site):** app.netlify.com → your site → **Deploys** tab → click an older deploy that was good → **"Publish deploy"**. The live site instantly reverts to that version. Your files/repo are untouched — fix them at leisure, then deploy again.
- **Git way (reverting the code itself):** this rewrites project history — hand it to an engineer or an AI session and follow **krg-change-control**; don't run revert commands from memory.

## 7. Custom domain + free HTTPS (UI flow — as documented in README / Netlify docs, verify on site)

1. Buy a domain from a registrar (e.g. Namecheap).
2. In Netlify: Site settings → **Domain management** → **Add custom domain** → enter your domain.
3. Update the DNS records at your registrar exactly as Netlify instructs on that screen.
4. HTTPS (the padlock) is automatic and free — Netlify issues the SSL certificate itself; wait up to ~24h for DNS to settle.

## 8. What lands where (outputs)

Nothing. No build artifacts, no generated files, no databases, no server logs on your side — the **only output of this project is the live site itself**. If analytics get added later (GA4 snippet or Netlify Analytics), the data lives in those dashboards, not in the repo — see **krg-measurement-and-experiments**.

## 9. From-scratch disaster recovery checklist

- [ ] **Laptop/repo lost?** The code is safe on GitHub (canonical home `github.com/Sianxio/KRG` per the session record — recorded, not verified; confirm at github.com). `git clone https://github.com/Sianxio/KRG.git` on any machine (Section 3) and you're back. Before redeploying the recovered copy, run the krg-change-control pre-deploy checklist as with any deploy.
- [ ] **Netlify account lost?** Make a new free account and drag-and-drop the folder (Section 4A, including its pre-deploy gate) — typically live again in minutes. Re-add the custom domain (Section 7) if you had one.
- [ ] **Both lost but you have the 5 files anywhere** (old download, email attachment)? Drag-and-drop those 5 files' folder to Netlify — the repo is the deployable artifact, so any complete copy of it is a full backup.
- [ ] **GitHub account lost AND no local copy?** Only then is code gone — this is why Path B (GitHub-connected) plus an occasional local `git pull` is the resilient setup.

## Provenance & maintenance

Verified 2026-07-06 against repo state; reviewed & corrected 2026-07-07. The five site files have not changed since commit `b863b95` (2026-02-04, 3 commits on `main`); later commits touch only `.claude/skills/`. The canonical GitHub home `Sianxio/KRG` is from the session record, not verified from this environment (`git remote -v` here prints a sandbox proxy URL). Local server test with python3 3.11 returned HTTP 200 for `/`, `/guide.html`, `/styles.css`. Netlify UI flows are from README.md and were not executable here — re-verify on app.netlify.com. Re-verification one-liners:

```bash
ls /home/user/KRG                                   # still exactly 5 root files?
ls /home/user/KRG/netlify.toml 2>&1                 # still no Netlify config file?
grep -cE 'href="/|src="/|fetch\(' /home/user/KRG/*.html /home/user/KRG/script.js  # still 0 → file:// preview still safe
(cd /home/user/KRG && python3 -m http.server 8000 & sleep 2; curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/; kill %1)  # expect 200
```
