---
name: good-ux-auditor
description: Audit a product's user experience against 16 Good UX heuristics — the four states (loading/success/error/empty), loader selection and duration psychology, error message anatomy and placement, form friction, empty states, graceful degradation, success feedback, Jakob's Law, Hick's Law, progressive disclosure, and Tesler's Law. Use when the user asks to "audit my UX", "run a good UX audit", "check my loading states", "review my error messages", "what states am I missing", "is this form too long", "does this follow UX conventions", "review this screen before I ship", or when reviewing an AI-generated or vibe-coded app that likely only implements the happy path. Accepts a codebase, screenshots, or both.
---

# Good UX Auditor

Audits a product against 16 heuristics from Katherine Gilligan's (@synsation_)
*Build for Good UX* series. The full library with verbatim principles, her examples, and
per-heuristic detection signals is in `references/HEURISTICS.md` — **read it before
auditing.** Do not audit from memory of this file alone; the specific thresholds and
wording matter.

## Why this audit exists

Most UX failures are not ugly-UI failures. They are missing-state failures. Her framing:

> "Beautiful UI with bad UX will make people leave."

And the specific reason this matters for generated code:

> "They often build what I like to call the happy path […] AI tools will often miss the
> loading state, the empty state, the error state."

So the default posture of this audit is: **assume the happy path exists and everything
else is missing until proven otherwise.** Verify, don't assume.

---

## Step 1 — Establish scope

Ask the user only what you cannot determine yourself. Determine from the inputs:

- **What am I auditing?** A codebase path, screenshots/designs, a live URL, or a
  combination.
- **Which surfaces?** If a codebase, enumerate routes/pages first and pick the
  user-critical ones. Never audit all 40 routes — audit the money path, the signup path,
  and the main daily-use screen.
- **Platform targets?** Web only, mobile, both. Needed for H13.
- **Locales?** Needed for H13 (RTL).

If the user gave you a repo with no direction, default to: **auth/signup, the primary
create/submit flow, any payment flow, and the main dashboard or list view.** State the
scope you chose before proceeding.

## Step 2 — Gather evidence

**Codebase.** Run `scripts/scan-ux.sh <path>` for a first pass of grep-level signals. It
is a lead generator, not a verdict — every hit needs to be opened and read in context, and
its misses prove nothing. Then read the actual components for the surfaces in scope.

**Screenshots / designs.** Read each image. For every data-driven region, ask which of the
four states this image represents, and note which states have no image at all — an absent
artboard is itself the finding.

**Live URL.** If browser tools are available, exercise the unhappy paths directly: submit
an empty form, submit an invalid email, kill the network and reload, load a list as a
brand-new account. These four actions surface most P0s.

**Evidence rule:** every finding must cite a file path and line, or a specific screenshot
region. A finding you cannot point at is a guess — drop it or label it explicitly as
"unverified, needs a look."

## Step 3 — Run the four-state matrix (H1)

This is the spine of the audit. Do it first — most other findings fall out of it.

For each screen or data-driven section in scope:

| Screen / section | Loading | Success | Error | Empty |
|---|---|---|---|---|
| `/dashboard` → ProjectList | Present | Present | **Missing** | **Missing** |

Mark each cell **Present**, **Partial**, or **Missing**, with a file/line or screenshot
reference for each. "Partial" means it exists but violates a downstream heuristic — note
which one.

## Step 4 — Run the remaining heuristics

Work through `references/HEURISTICS.md`. Per-screen: H2–H11. Product-wide: H12–H16.

Do not force a finding for every heuristic. A heuristic with nothing to report should be
listed as passing — that is useful information, and padding the report with weak findings
destroys the credibility of the strong ones.

## Step 5 — Score

Two numbers, both reported:

**State coverage** — the hard metric. Count cells in the H1 matrix:
`(Present + 0.5 × Partial) / total cells`, as a percentage.

**Heuristic health** — for each of the 16, assign:

- **Pass** (2) — no findings
- **Weak** (1) — P1/P2 findings only
- **Fail** (0) — any P0 finding

Total out of 32. Report as `n/32` alongside the P0 count. Never report a score without the
P0 count next to it — a 26/32 with two P0s is worse than a 20/32 with none.

## Step 6 — Write the report

Use `references/REPORT-TEMPLATE.md`. Order findings by severity, never by heuristic
number — the reader wants the ship-blockers first.

Every finding needs all five parts:

1. **Heuristic** — ID and name
2. **Location** — file:line or screenshot reference
3. **What's wrong** — the observed behavior, concretely
4. **Why it matters** — the user consequence, ideally in her framing
5. **The fix** — a specific change, with code or copy where useful

Write the fix as something a person can act on today. "Improve error handling" is not a
fix. "Replace the `catch (e) { console.error(e) }` at `checkout.tsx:88` with an inline
error beneath the pay button reading 'Your payment didn't go through. Your card was
declined. Check your card details or try a different card.'" is a fix.

---

## Guardrails

**Report scope honestly.** If you audited 4 of 31 routes, say so at the top. A UX score
implying whole-product coverage from a 4-route sample is misleading.

**Distinguish observed from inferred.** Static code reading cannot confirm what renders at
runtime. Say "no error branch found in this component" rather than "users see nothing when
this fails" unless you actually exercised it.

**Don't confuse the complexity heuristics.** H14 (Hick's Law) and H15 (progressive
disclosure) are about *removable or deferrable* choices. H16 (Tesler's Law) is about
*inherent* complexity that must land on either the builder or the user. Her caption on
Part 16 is explicit that this is "not additional app features or things that you could
easily just remove."

**Respect the caveats she names.** Progressive disclosure has a failure mode — "you don't
wanna hide your most important features so deep that people can't figure it out without
needing a tutorial." Don't recommend hiding a primary action. Similarly, don't recommend
confetti on routine actions; she explicitly says "please don't overdo it."

**Convention is contextual.** Before flagging an H12 violation, check H13 — the "correct"
placement differs between desktop, mobile, and RTL locales. Flagging a mobile bottom-nav
cart as a violation of "carts go top right" is the exact mistake she corrected herself on
in Part 13.

**Optimistic UI needs a rollback.** If you recommend it (H3), also require the revert
path. Optimistic UI without rollback is a silent-failure generator (H5).

**Credit the source.** Include the attribution line from the heuristics library in any
report you produce or share.

---

## Files

- `references/HEURISTICS.md` — the 16 heuristics, verbatim principles, detection signals
- `references/REPORT-TEMPLATE.md` — output structure
- `scripts/scan-ux.sh` — grep-level first-pass signal scanner
