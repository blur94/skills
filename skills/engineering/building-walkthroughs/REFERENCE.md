# Reference: Analysis, Design Rules & Deliverables

## Required analysis

**Replicate mode only.** Work through every item below before proposing anything for the target.
For a running app, answer these by actually driving it (browser tool), not by guessing from a
screenshot. In from-scratch mode, skip to [Designing from scratch](#designing-from-scratch) —
but you must still *decide* each of these dimensions for the new tour; the checklist doubles as
the list of decisions your spec table and Implementation Plan must cover.

**Entry point**
- First visit? Manual trigger (help menu, "?" icon)? Feature flag? User preference/role?
- Does it re-trigger after the triggering condition recurs (e.g. new feature ships) or only once ever?

**Step structure** — for every step:
- Target element (selector/ref it anchors to)
- Tooltip position (top/bottom/left/right/center, and its fallback if the anchor is off-screen)
- Title + description copy
- CTA buttons present (Next/Back/Skip/Finish/Close) and which are shown per step
- Background dimmed? Spotlight cut into the overlay, or overlay absent?
- Is interaction with the rest of the page blocked while the step is showing?
- Does clicking outside the tooltip dismiss the step (and does that count as skip or finish)?

**Navigation** — behavior for Next, Previous, Skip, Finish: does each advance/rewind state, write
persistence, or just close the overlay?

**Highlight mechanism** — spotlight cutout, border, glow, scale animation, pulse, or none?

**Persistence** — localStorage, cookie, database/user-profile field, or session-only (resets on
reload)? Is it keyed per-user, per-account, or per-browser?

**Animation style** — transition type and duration between steps; entrance/exit animation on the
tooltip itself.

**Mobile vs. desktop** — different step count, different anchors, bottom-sheet vs. tooltip,
touch-specific dismiss gestures.

**Accessibility** — focus trapping, ARIA roles/labels on the tooltip, keyboard nav (Tab/Escape/
Arrow keys), screen-reader announcements on step change.

## Designing from scratch

When there is no source walkthrough, derive steps from the target itself:

1. **Name the page's primary user goal** (e.g. "clock in and see who's present"). The tour exists
   to get a new user to that goal faster — every step must serve it.
2. **Pick 3–6 anchors, no more.** Candidates: the primary action, anything non-obvious or novel,
   anything users demonstrably miss (support tickets, empty states nobody fills). Skip anything
   self-explanatory — a labeled "Search" input needs no tooltip.
3. **Each step answers "what would a new user miss without this?"** If the answer is "nothing",
   cut the step.
4. **Order by task flow, end on the primary action** — the last thing spotlighted is the first
   thing they'll do after the tour.
5. **Decide every dimension from the Required Analysis checklist** (entry point, overlay,
   navigation, highlight, persistence, animation, mobile, accessibility) explicitly and record
   the decisions in the spec table and Implementation Plan.

## Choosing a tour library

Only when the target has none wired up (always check first). Criteria, in order: actively
maintained; accessible out of the box (focus trap, ARIA, keyboard); small enough for the app's
bundle budget; supports the behaviors your spec table needs (spotlight, multi-route,
controlled step index).

- **React/Next.js:** `react-joyride` (full-featured, controlled mode, spotlight) or `driver.js`
  (tiny, framework-agnostic, fewer features). Prefer joyride when you need controlled state or
  route-spanning tours; driver.js for a lightweight single-page spotlight.
- **React Native:** `react-native-copilot`, or hand-rolled overlay + measure() for simple cases.
- **Non-React or minimal needs:** `driver.js`, `shepherd.js`, or a hand-rolled popover — for a
  1–3 step tour, a custom component on the app's existing popover primitive often beats a
  dependency.

Record the choice and its rationale in the Implementation Plan.

## Persistence keying and versioning

- **Key per user in authenticated apps.** A bare `walkthrough_<id>` localStorage key shows the
  tour to every account on a shared browser and re-shows it on every new device. Include the user
  id in the key (`walkthrough_<id>_<userId>`) or, better, persist on the user profile server-side
  if the app already stores per-user flags.
- **Version the key when the tour changes materially:** `walkthrough_<id>_v2`. Bumping the
  version re-triggers the tour for everyone — the standard mechanism for "we redesigned this
  page, re-show the tour". Don't invent a separate re-trigger flag.
- **Session-only tours** (demo modes, kiosk) should use in-memory or sessionStorage state, not a
  localStorage key you then have to clean up.

## Implementation hard parts

**Stable anchors.** Anchor every step to a dedicated `data-tour="<step-name>"` attribute — never
to CSS classes, generated class names, or DOM paths, which churn with styling refactors and
silently orphan steps. The attribute names the step, greps cleanly, and survives redesigns.

**Async anchors.** If an anchor renders after data loads (dashboard widgets, lazy lists), gate
the tour start on the data-ready state instead of component mount — otherwise the spotlight
targets a missing element or mispositions before layout settles.

**Route-spanning tours.** Prefer confining each tour to one route; a per-page tour is simpler and
less brittle. If a tour must span routes, use the library's controlled mode: pause before
navigating, navigate, resume at the next step index once the new route's anchor has mounted, and
keep the current step index in sessionStorage so a mid-tour refresh resumes rather than restarts.

**Multiple tours in one app.** One tour id per page/flow, named consistently (`<area>-tour`).
Never run two tours at once: if a global first-login tour and a page tour would both fire, the
first-login tour wins and the page tour waits for the next visit.

**Replay entry point.** The auto-trigger fires once, so always expose a manual "Replay tour"
control (help menu, settings, or "?" icon) wired to the reset function. Without it, a user who
skipped can never see the tour again.

## Adaptation rules

Never assume identical layouts between source and target.

1. Locate the equivalent feature in the target for each source step.
2. Attach the walkthrough step there, adapting copy to the target's existing voice/terminology.
3. If no equivalent exists in the target, omit that step — don't force a placeholder.
4. If the target has additional important features the source didn't cover, propose extra steps
   for them, called out separately so the user can accept/reject.
5. Reorder steps if the target's natural task flow differs from the source's — logical progression
   in the target beats mirroring the source's exact sequence.

## Deliverables

Produce these four, in order:

### 1. Walkthrough Specification

| Step | Target | Purpose | Position | Trigger | Notes |
|------|--------|---------|----------|---------|-------|
| 1 | (target element/component) | (why this step exists) | (tooltip position) | (what shows it) | (dimmed? blocking? persistence key?) |

One row per step. Include omitted-source-step and added-target-step rows explicitly, don't just
drop them silently.

### 2. UX Notes

- Why each step exists (tie back to a target user goal, not just "source had it")
- Recommended ordering and why it may differ from the source
- Any improvements over the source (e.g. source had no skip button; recommend adding one)

### 3. Implementation Plan

- State management (where `runTour`/current-step-index lives)
- Persistence (mechanism + key naming, matching what the target already uses elsewhere)
- Routing considerations (does the tour span multiple routes/pages? survive navigation?)
- Mobile adaptations
- Accessibility considerations (focus management, ARIA, keyboard)

### 4. Framework Implementation

Production-ready code in the target's actual framework/UI library, following its existing
architecture and conventions. Don't introduce a new dependency if the target already has a tour
library wired up — extend that instead.

## Quality checklist

Before calling the work done:

- [ ] No orphaned steps (every step's target element actually exists in the target app)
- [ ] Steps anchor to dedicated `data-tour` attributes, and async anchors gate the tour start —
      see [Implementation hard parts](#implementation-hard-parts)
- [ ] Tour overlay/tooltip renders above the app's sticky headers, sidebars, and any open
      modal/drawer (z-index verified visually)
- [ ] A manual "Replay tour" entry point exists and works after the tour has been completed/skipped
- [ ] Tooltips never render off-screen (test near viewport edges, small screens)
- [ ] Keyboard navigation works (Tab, Escape, Arrow keys as applicable)
- [ ] Screen reader support exists (ARIA roles/labels, focus management)
- [ ] Skip works from every step, not just the first
- [ ] Progress indicator updates correctly on Next/Previous/jump
- [ ] Walkthrough resumes (or correctly restarts) after a page refresh, matching the persistence
      design from the Implementation Plan
- [ ] Persistence is keyed per user (authenticated apps) and versioned — see
      [Persistence keying and versioning](#persistence-keying-and-versioning)
- [ ] Responsive behavior preserved (mobile adaptations from the plan are actually implemented)
- [ ] Verified end-to-end in the running app (persistence key cleared, full tour driven,
      Skip mid-tour tested, refreshed mid-tour) — not just by reading the code
