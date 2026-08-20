# Research Works — Reference

## Work type fields to populate

```
slug          — already known, don't change
title         — verify spelling/casing against official branding
descriptor    — their one-liner, adapted to your role
overview      — what the product does + what you specifically built
role          — your exact role (already in works.ts, confirm accuracy)
client        — legal/official company name
year          — year of your engagement (confirm from LinkedIn or project dates)
category      — Fintech | Sports | Regtech | Civic | SaaS | …
tags          — actual tech stack (verify from job posts, GitHub, site source)
isLive        — is the product publicly reachable today?
coverImage    — (no change needed — this is a local asset path)
context       — the real business problem; use company's own framing where possible
constraints   — real engineering/product constraints; can come from public writing or your memory confirmed by research
process       — your authentic process; research helps verify product details referenced in each step
outcomes      — the most important field: find real published numbers wherever possible
lessons       — your authentic takeaway (research context only, not fabricated)
```

---

## Known slugs

| slug | title | client | isLive |
|------|-------|--------|--------|
| verivafrica | VerivAfrica | VerivAfrica Ltd. | true |
| recurrent | Recurrent.ng | Recurrent.ng | true |
| qatapolt | Qatapolt Admin | Qatapolt | true |
| prune | Prune Payments | Prune | true |
| raia | Raia | Raia | false |
| reunitar | Reunitar | Reunitar | false |

---

## Grill-with-docs questions

Use these when invoking `/grill-with-docs` on a company blog post, press release, or docs page:

1. What specific problem does this product solve, and who is the primary customer?
2. What quantitative outcomes or metrics are stated (numbers, percentages, volume, growth)?
3. What compliance, regulatory, or technical constraints shaped the product?
4. What technology stack is used or mentioned?
5. How large is the user base, transaction volume, or revenue (any scale signal)?
6. Are there any case studies, testimonials, or dated launch announcements?

---

## Per-project note template

Save as `C:\Users\hp\Claude Workspace\works-research\{slug}.md`

```md
# {title} — Portfolio Research Notes

Researched: {ISO date}

## Sources found
- Official site: {url or UNKNOWN}
- LinkedIn: {url or UNKNOWN}
- Crunchbase/press: {url or UNKNOWN}
- Wayback snapshot: {url or N/A}

## Field findings

### title
{official brand name and casing}

### descriptor
{their one-liner, or UNKNOWN}

### overview
{what the product does in 2–3 sentences, drawn from their copy}

### context
{the business problem they describe publicly}

### category
{best-fit category}

### tags (tech stack)
{what's confirmed from site source, job posts, or stated publicly}

### isLive
{yes/no — did the site resolve and load?}

### year
{year of engagement or launch, source: }

### outcomes
| number | label | confidence | source |
|--------|-------|------------|--------|
| | | HIGH/MED/LOW | |
| | | HIGH/MED/LOW | |
| | | HIGH/MED/LOW | |

### constraints
{any publicly stated engineering or compliance constraints}

### Additional context for process steps
{anything found that confirms or enriches the process narrative}

## Gaps (UNKNOWN fields)
- 

## Notes
{anything else worth knowing for writing the portfolio entry}
```
