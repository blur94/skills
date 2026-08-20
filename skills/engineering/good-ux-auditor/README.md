# Good UX Auditor

A UX audit skill built from the 16-part *Build for Good UX* series by
**Katherine Gilligan (@synsation_)**.

Audits a codebase, screenshots, or a live URL against 16 heuristics and returns a scored,
prioritized report with file-level evidence and specific fixes.

## What's in here

| File | Purpose |
|---|---|
| `SKILL.md` | The skill — workflow, scoring, guardrails |
| `references/HEURISTICS.md` | The 16 heuristics: verbatim principles, her examples, code and screenshot detection signals, severities |
| `references/REPORT-TEMPLATE.md` | Output structure for audit reports |
| `scripts/scan-ux.sh` | Grep-level first-pass signal scanner (leads, not verdicts) |

## Install

**As a Cowork / Claude skill** — already installed if you built this in a Cowork session.
Otherwise, drop the `good-ux-auditor/` directory into your skills folder, or install the
`.skill` archive via the Save skill button.

**In a repo** — copy the directory anywhere and point your agent at `SKILL.md`.

## Use

```
audit my UX
run a good ux audit on src/
what states am I missing in the checkout flow?
review these screens before I ship
```

Or run the scanner directly for a fast signal pass:

```bash
chmod +x scripts/scan-ux.sh
./scripts/scan-ux.sh ./src
```

The scanner needs `bash`; it uses `ripgrep` if available and falls back to `grep`.

## The 16 heuristics

| # | Heuristic | Part |
|---|---|---|
| H1 | Every screen has four states: loading, success, error, empty | 2 |
| H2 | Loaders are invisible when present, loud when absent | 2 |
| H3 | Pick the loader that matches the job | 3 |
| H4 | Spinner duration thresholds | 4 |
| H5 | Error anatomy — what / why / what next | 5 |
| H6 | The six form rules | 6 |
| H7 | Error placement — proximity wins | 7 |
| H8 | Empty states are a first impression | 8 |
| H9 | Partial states are normal; plan for them | 9 |
| H10 | Every section owns its data, loading, and errors | 10 |
| H11 | Confirm that it worked | 11 |
| H12 | Jakob's Law — match existing conventions | 12 |
| H13 | Conventions are per-device and per-locale | 13 |
| H14 | Hick's Law — decision time grows with choices | 14 |
| H15 | Progressive disclosure | 15 |
| H16 | Tesler's Law — complexity moves, it doesn't disappear | 16 |

## Scoring

- **State coverage** — `(Present + 0.5 × Partial) / total cells` across the four-state matrix
- **Heuristic health** — `n/32` (Pass 2 / Weak 1 / Fail 0 per heuristic)
- Always reported alongside the **P0 count**, because a 26/32 with two ship-blockers is
  worse than a 20/32 with none

## Attribution

All heuristics, principles, and illustrative examples are the work of **Katherine Gilligan
(@synsation_)**, from the *Build for Good UX* series, Parts 1–16 (May–July 2026):
https://www.instagram.com/synsation_/

This package is a derivative audit tool. It does not reproduce the episodes. Please credit
her when sharing audit output, and go watch the series — the examples land better in her
telling than in a table.
