---
name: building-walkthroughs
description: Use when adding, building, porting, or recreating an onboarding tour, product walkthrough, feature spotlight, or coach-mark/tooltip sequence in an application — whether replicating from a source (Figma file, screenshots, video, a running app, another codebase) or designing one from scratch for a target page or flow.
---

# Building Walkthroughs

Anchor a walkthrough to the target app's *real UI and user goals*, not to pixels or assumptions.
Two modes share one pipeline: **replicate** (a source walkthrough exists) and **from-scratch**
(no source — design steps from the target's own features).

## Required inputs

Confirm before drafting. If missing, ask — do not guess:

1. **Target application** — codebase, Figma file, or description
2. **Framework** — React, Next.js, React Native, etc.
3. **UI library** — Mantine, Shadcn, Chakra, custom, etc.
4. **Source walkthrough** — only if replicating. No source = from-scratch mode, which is normal,
   not an error.

Always inspect a target codebase first: search for an existing walkthrough/tour implementation
(`rg -i "walkthrough|onboarding|tour|joyride|shepherd|intro.js|driver.js|reactour"`) before
assuming you need a new library. Reuse what's already wired up. If nothing exists, pick per
[REFERENCE.md](REFERENCE.md#choosing-a-tour-library).

## Workflow

1. **Establish the steps.**
   - *Replicating:* work through every item in the Required Analysis checklist —
     [REFERENCE.md](REFERENCE.md#required-analysis). For a running app, drive it with the browser
     tool; never infer trigger/dismiss behavior from a static screenshot.
   - *From scratch:* derive steps from the target's own features and primary user goal —
     [REFERENCE.md](REFERENCE.md#designing-from-scratch).
2. **Map/adapt to the target** per the Adaptation Rules in
   [REFERENCE.md](REFERENCE.md#adaptation-rules): find the equivalent element for each step, omit
   steps with no anchor, propose extra steps for important uncovered features, and keep the
   progression logical even if ordering shifts.
3. **Produce the four deliverables** in [REFERENCE.md](REFERENCE.md#deliverables) — Walkthrough
   Specification table, UX Notes, Implementation Plan, Framework Implementation. All four apply
   in both modes.
4. **Implement** using the target's existing architecture, conventions, and dependencies. Follow
   the persistence keying/versioning rules and the anchor/async/route/multi-tour/replay rules in
   [REFERENCE.md](REFERENCE.md#persistence-keying-and-versioning) and
   [REFERENCE.md](REFERENCE.md#implementation-hard-parts).
5. **Verify in the running app**, not just by reading code: launch the dev server, clear the
   persistence key, and drive the tour end-to-end (including Skip mid-tour and a page refresh)
   against the Quality Checklist in [REFERENCE.md](REFERENCE.md#quality-checklist).

See [EXAMPLES.md](EXAMPLES.md) for a worked example (SaaS onboarding tour → a Next.js + Mantine +
react-joyride app with a pre-existing walkthrough hook).

## Common mistakes

- Copying screens/pixels instead of behavior — target layouts rarely match the source 1:1.
- Refusing to proceed without a source when the real request is a from-scratch tour.
- Inferring a running source app's behavior from screenshots instead of driving it.
- Adding a second tour library when the target already has one wired up.
- Persisting "seen it" under a global key in an authenticated app — shows the tour to every user
  on a shared browser and re-shows it per device.
- Anchoring steps to CSS classes or DOM paths instead of dedicated `data-tour` attributes — a
  styling refactor then silently orphans steps.
- Starting the tour on component mount when its anchors render after data loads.
- Treating UX Notes and the Implementation Plan as optional — the spec table alone
  under-specifies persistence, accessibility, and mobile behavior.

## Notes

- Adapt copy to the target's existing voice (check its tooltips, empty states, help text); never
  carry source terminology verbatim. Keep tooltip copy short: ~1 sentence title, ≤2 sentence body.
  If the app is localized, tour copy goes through the same i18n pipeline as other UI strings.
- Persistence mechanism should match what the target already uses for similar "seen it once"
  state (localStorage flag, user profile field, DB row) rather than introducing a new one.
- If entry point, step structure, or persistence can't be determined from the material given, say
  so explicitly and ask rather than filling the gap with a plausible-sounding default.
