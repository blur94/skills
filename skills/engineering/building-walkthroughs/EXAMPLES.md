# Worked Example

Shown in replicate mode; from-scratch mode is identical from the spec table onward — you'd just
derive the steps from the dashboard's own features (per REFERENCE.md "Designing from scratch")
instead of mapping them from a source.

**Source:** a generic SaaS product tour — 5-step spotlight walkthrough triggered on first login,
highlighting Search, Notifications, the primary "Create" button, Settings, and a final "you're
done" modal. Dimmed overlay, Next/Back/Skip, dots progress indicator, dismissible via outside
click (counts as skip), persisted in `localStorage` so it never shows again.

**Target:** `workstat.client` — Next.js 14 App Router + Mantine, client dashboard at
`src/app/self-service/(client)/dashboard/Dashboard.tsx`.

**Framework / UI library:** Next.js / Mantine (confirmed from `package.json`).

## Step 0 — inspect the target first

The target already has a walkthrough system: `react-joyride` wrapped by
`src/lib/components/walkthrough/index.tsx` and `src/lib/hooks/useWalkthrough.ts`, already in use
on the payroll and accounts pages. **Reuse it** — don't add Shepherd/Intro.js/etc.

The existing hook only tracks `runTour` + `steps` and a single "seen it" localStorage flag keyed
by a `hash`/`walkthroughId`. It has no per-step index, so Previous/jump-to-step isn't supported
yet — note that as a gap to close in the Implementation Plan, not something to silently drop.

## 1. Walkthrough Specification

| Step | Target | Purpose | Position | Trigger | Notes |
|------|--------|---------|----------|---------|-------|
| 1 | Dashboard search input | Orient user to global search | bottom | first dashboard visit, no `walkthrough_dashboard-tour` key in localStorage | dimmed, blocking |
| 2 | Notifications bell (`Header.tsx`) | Point out where alerts land | bottom | auto-advance | dimmed, blocking |
| 3 | *(omitted)* — source's "Create" button has no dashboard equivalent | — | — | — | no matching target element; dropped per Adaptation Rule 3 |
| 4 | Settings nav item | Show where profile/org settings live | right | auto-advance | dimmed, blocking |
| 5 *(added)* | Attendance widget | Dashboard has an attendance summary card the source app didn't — worth spotlighting since it's a primary daily action | top | auto-advance | added per Adaptation Rule 4, flagged for user sign-off |
| 6 | Completion | "You're all set" | center | after step 5 | sets `walkthrough_dashboard-tour=true`, closes |

## 2. UX Notes

- Steps reordered vs. source (Settings before the added Attendance step) so the tour ends on the
  page's actual primary action rather than a secondary nav item — stronger final impression.
- Recommend adding a Skip button on every step (source only had it from step 2 onward) since the
  existing `WalkThrough` component already renders `showSkipButton` globally — no extra work.
- Improvement over source: source's outside-click-to-dismiss silently counted as "skip" with no
  visual confirmation; recommend keeping Joyride's default (outside click does nothing mid-tour,
  only Skip/Finish trigger completion) since silent dismissal confused users in the source app.

## 3. Implementation Plan

- **State:** extend `useWalkthrough` with a `stepIndex` so Back/jump works; keep `runTour`/`steps`
  API unchanged so existing callers (payroll, accounts) don't break.
- **Persistence:** same mechanism already in use (localStorage flag via `useWalkthrough`), but the
  existing hook keys globally — in this authenticated app that shows the tour to every account on
  a shared browser. Pass a per-user hash (`dashboard-tour_${userId}`) and version it
  (`_v1`) so a future tour redesign can re-trigger by bumping the suffix. See
  [REFERENCE.md](REFERENCE.md#persistence-keying-and-versioning).
- **Routing:** entire tour stays on `/self-service/dashboard`; no cross-route steps, so no router
  event listeners needed.
- **Mobile:** Joyride tooltips can overflow small viewports — set `disableScrolling` off and verify
  step 5 (Attendance widget) tooltip position on a 375px viewport; likely needs `position: "top"`
  → `"bottom"` fallback there.
- **Accessibility:** Joyride sets `role="alertdialog"` and focuses the tooltip by default — verify
  Escape closes the tour (maps to Skip) and that focus returns to the triggering element on close.
- **Replay:** the existing hook already exposes `resetWalkthrough` but nothing calls it — wire it
  to a "Replay tour" item in the header help menu so users who skipped can revisit.

## 4. Framework Implementation (excerpt)

```tsx
// Dashboard.tsx
import { useEffect } from "react";
import WalkThrough from "@/lib/components/walkthrough";
import { useWalkthrough } from "@/lib/hooks/useWalkthrough";

const DASHBOARD_TOUR_STEPS = [
  { target: '[data-tour="search"]', content: "Search anything across the app from here.", placement: "bottom" as const },
  { target: '[data-tour="notifications"]', content: "Alerts and approvals land here.", placement: "bottom" as const },
  { target: '[data-tour="settings-nav"]', content: "Manage your profile and organization settings.", placement: "right" as const },
  { target: '[data-tour="attendance-widget"]', content: "Your daily attendance summary — clock in/out from here.", placement: "top" as const },
];

export function Dashboard() {
  const { runTour, setSteps, ...tour } = useWalkthrough("dashboard-tour");

  useEffect(() => {
    setSteps(DASHBOARD_TOUR_STEPS);
  }, [setSteps]);

  return (
    <>
      {/* existing dashboard markup, with data-tour attributes added to the four anchors */}
      <WalkThrough hash="dashboard-tour" steps={tour.steps} runTour={runTour} />
    </>
  );
}
```

Note this reuses the existing `WalkThrough`/`useWalkthrough` pair verbatim — the only new work is
the step data and the `data-tour` anchors, which is the point: adapt to what's already there
instead of introducing parallel infrastructure.
