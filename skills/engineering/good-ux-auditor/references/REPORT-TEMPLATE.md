# Good UX Audit — {Product / Surface}

**Date:** {date}
**Audited:** {what was actually looked at — repo path, screenshots, live URL}
**Scope:** {n} of {m} routes/screens — {list them}
**Not audited:** {be explicit; this protects the reader from over-reading the score}

---

## Summary

**State coverage:** {x}% ({present} present, {partial} partial, {missing} missing of {total} cells)
**Heuristic health:** {n}/32
**P0 findings:** {n} · **P1:** {n} · **P2:** {n}

{Two or three sentences. What is the single most important thing to fix, and what is the
overall shape of the problem — e.g. "error handling is systematically absent rather than
locally weak."}

---

## The four-state matrix (H1)

| Screen / section | Loading | Success | Error | Empty |
|---|---|---|---|---|
| {route → component} | {Present/Partial/Missing} | | | |

{One line per gap, pointing at the file or screenshot.}

---

## P0 — Ship blockers

### {n}. {H-id} {Heuristic name} — {one-line title}

- **Location:** `{file}:{line}` / {screenshot ref}
- **What's wrong:** {concrete observed behavior}
- **Why it matters:** {user consequence}
- **Fix:**

```{lang}
{specific change — code or copy}
```

---

## P1 — Friction and distrust

{Same five-part structure.}

---

## P2 — Polish

{Can be a compact table if numerous.}

| # | Heuristic | Location | Issue | Fix |
|---|---|---|---|---|

---

## Passing

Heuristics with no findings, so the reader knows they were checked and not skipped:

| Heuristic | Note |
|---|---|
| H{n} {name} | {what was verified} |

---

## Not assessable

{Heuristics that could not be judged from the available inputs, and what would be needed
to judge them. E.g. "H13 (device/locale conventions) — no mobile designs or RTL locale
config available."}

---

## Recommended order of work

1. {P0s, grouped so related fixes land together}
2. {P1 clusters — e.g. "add section-level error boundaries + retry across the dashboard"}
3. {P2 batch}

---

*Heuristics from the Build for Good UX series by Katherine Gilligan (@synsation_),
Parts 1–16. Audit tooling and detection signals are derivative.*
