---
name: research-works
description: Collects accurate data points for a portfolio Work entry by scraping a live website, browsing a remote repository, or reading a local project directory. Saves structured research notes to C:\Users\hp\Claude Workspace\works-research\{slug}.md. Use when the user provides a slug plus a URL or local path, or is already inside the project directory and says "research [slug]", "scrape this", "get data from this", or "collect data points for [project]".
---

# Research Works

Extracts accurate data points for a `Work` entry in `src/lib/works.ts` from wherever the project lives.

## Usage

```
/research-works verivafrica https://verivafrica.com        # live site
/research-works recurrent https://github.com/org/repo     # remote repo
/research-works qatapolt C:\Users\hp\Projects\qatapolt    # local path
/research-works prune                                      # current directory
```

If no URL or path is given, treat the current working directory as the project root.

## Workflow

### 1. Load the current entry
Read `src/lib/works.ts`, extract the entry for the given slug. Note which fields already have real data vs. which need to be filled or verified.

### 2. Read the source — pick the mode that matches

**Live website (`https://` — not github.com/gitlab.com):**
- [ ] Browse homepage — screenshot it
- [ ] Browse 2–3 interior pages: Features, About, Case Studies, Pricing, Blog
- [ ] Screenshot each page
- [ ] If a docs or blog URL is found, invoke `/grill-with-docs` on it — see question set in [REFERENCE.md](REFERENCE.md)
- [ ] Note any visible metrics: user counts, transaction volume, uptime, customer logos, case study numbers
- [ ] Check page source for tech signals: framework meta tags, API subdomains, bundle filenames

**Auth-gated dashboard (product is behind a login wall):**

Most operator/admin dashboards in this portfolio are fully behind auth. When the public URL redirects to a login page, use this fallback stack in order:

1. **Credentials available** — invoke `/setup-browser-cookies` to inject a session, then proceed as a normal live site browse
2. **Repo available** — switch to the remote or local repo mode; source code reveals tech stack, data models, constraints, and sometimes seeded demo metrics in fixtures or README
3. **Public marketing site** — scrape the company's main site for product description, stated outcomes, and tech signals even if the dashboard itself is inaccessible
4. **User-supplied material** — ask the user: "Can you share a screenshot, Loom, or demo login?" and extract data from that; note source as `user-provided`
5. **Nothing accessible** — mark all dashboard-specific fields as `UNKNOWN` and note: "Dashboard behind auth — repo or credentials needed"

Never attempt to bypass, guess, or brute-force authentication. If a path is blocked, say so and move to the next fallback.

**Remote repository (github.com / gitlab.com):**
- [ ] Browse the repo root — read README
- [ ] Browse `package.json` / `pyproject.toml` / `Cargo.toml` / equivalent for real dependency list
- [ ] Browse `docs/` or `wiki/` if present
- [ ] Browse `CHANGELOG.md` or release notes for outcome signals
- [ ] Infer architecture and constraints from visible folder structure

**Local project directory (local path or current directory):**
- [ ] Read `README.md` (or `README.rst`, `README.txt`)
- [ ] Read `package.json` / `pyproject.toml` / equivalent — real dependency list for `tags` field
- [ ] Glob for `docs/**`, `*.md` files at root — read any found
- [ ] Read `CHANGELOG.md` or `HISTORY.md` if present
- [ ] List top-level folder structure — infer architecture and constraints
- [ ] Look for any analytics config, env example files, or infra files that reveal scale/constraints

### 3. Map findings to Work fields
For each `Work` field (see [REFERENCE.md](REFERENCE.md)), record:
- The found value
- The source (URL, file path, or line reference)
- Confidence: `HIGH` (explicitly stated) · `MED` (inferred) · `LOW` (estimated)

Mark anything not found as `UNKNOWN`. Never invent a value.

### 4. Save output
Write `C:\Users\hp\Claude Workspace\works-research\{slug}.md` using the template in [REFERENCE.md](REFERENCE.md).
Save screenshots to `C:\Users\hp\Claude Workspace\works-research\screenshots\{slug}-{page}.png`.

## Rules
- Never write directly to `src/lib/works.ts` — output folder only
- `UNKNOWN` is correct when data is not findable — never guess
- If a site blocks scraping, extract what loaded and note the block
- When running from a local path, prefer reading files directly over spawning a dev server
