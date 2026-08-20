# The Good UX Heuristics Library

16 heuristics extracted from the *Build for Good UX* series by Katherine Gilligan
(@synsation\_ on Instagram), Parts 1–16. Quoted lines are hers, verbatim from the
episodes. Detection signals and severities are audit tooling built on top of her
principles.

**Framing principle for the whole library (Part 1):**

> "Beautiful UI with bad UX will make people leave."

UI is what the app looks like — colors, buttons, layout. UX is whether a person can
actually get through it: *"Can someone figure out what to do without extensive
instructions? What happens if something fails? Does the user get to know about that in
a graceful way?"*

Her recurring warning about AI-assisted builds is the reason this audit exists:

> "They often build what I like to call the happy path, what the screen looks like when
> everything goes perfectly like you planned it. […] AI tools will often miss the
> loading state, the empty state, the error state."

And the reason the builder is the worst judge of their own UX:

> "As someone who is building this, you're gonna know your app in and out, and so
> sometimes the way that you behave on your app is not the way that the user will."

---

## Severity scale

| Level | Meaning |
|---|---|
| **P0** | Users get stuck, lose money, or cannot tell whether their action worked. Ship-blocking. |
| **P1** | Users complete the task but with avoidable confusion, friction, or distrust. |
| **P2** | Polish. Real but non-blocking; batch these. |

---

# Dimension A — The Four States

## H1. Every screen has four states

**Source:** Part 2 · **Severity:** P0

> "Every screen in your app has four states you should be building: loading, success,
> error, and empty. And if you're not thinking about all four, your users will notice."

This is the backbone of the entire audit. Run it per screen, per data-driven section —
not per app.

**Code signals**
- A component that fetches data but renders only the resolved case — no `isLoading`, no
  `error`, no zero-length branch.
- `data.map(...)` with no guard for `data.length === 0`.
- `useEffect` + `fetch` with no `.catch` and no error state variable.
- A `try/catch` whose `catch` only does `console.error`.
- Route/page components with exactly one return statement and an `await`/hook fetch.

**Screenshot signals**
- Only the populated "happy" screen exists in the design set. If there is no artboard
  for empty / loading / error, they were not designed.

**Verdict format:** a four-cell matrix per screen — Loading / Success / Error / Empty —
each marked Present, Partial, or Missing.

---

## H2. Loaders are invisible when present and loud when absent

**Source:** Part 2 · **Severity:** P1

> "Loaders should feel intuitive most of the time. When they're there, you don't really
> even think or notice them, but when they're missing, users do notice, and they assume
> something is broken."

> "When they're done well, people will wait longer without even realizing it."

Why skeletons work, in her words: *"your brain starts processing all of the layout
before the data arrives."*

**Code signals**
- Async action with no pending indicator anywhere in the render tree.
- A single global full-page spinner used for every fetch regardless of scope (see H3
  and H9).

---

# Dimension B — Loading

## H3. Pick the loader that matches the job

**Source:** Part 3 · **Severity:** P1

> "Each one will trigger a different psychological response in your user."

| Loader | Use when | Her words |
|---|---|---|
| **Skeleton screen** | An entire page or large section of content is loading | "You're telling the user the layout is here, the data is coming." Feeds — Instagram, LinkedIn, YouTube. "The page structure is what shows up first, and then the content fills in a little later." |
| **Progress bar** | You *know* how long it will take — file uploads, downloads, installations | "The user needs to have a sense of how far along they are and how much longer they might need to wait." |
| **Inline spinner** | Small contained actions — a button just clicked, one part of the page refreshing | "Just a small indicator that's like, We're working on it." |
| **Optimistic UI (no loader)** | Action almost always succeeds and is cheap to reverse | "When you like a photo on Instagram, the heart turns red immediately. It doesn't wait for the server to confirm. […] Later, if it fails, it rolls back, but for you, it feels instant, and that is by design." |

**The named anti-pattern:**

> "If you show a spinner on a file upload, people might assume that it's stuck."

**Code signals**
- Spinner component rendered inside an upload/download handler where progress is
  available (`onUploadProgress`, `ReadableStream`, `XMLHttpRequest.upload`) — should be
  a progress bar.
- Full-page spinner gating a feed or list render — should be a skeleton.
- Skeleton blocks used for a single button action — should be an inline spinner.
- Like/favorite/toggle handlers that `await` before updating local state — candidate for
  optimistic UI. Flag missing rollback logic if optimistic updates exist without a
  revert path.

---

## H4. Spinner duration thresholds

**Source:** Part 4 · **Severity:** P1 (P0 past 10s with a looped animation)

Her thresholds, as stated:

| Duration | Rule |
|---|---|
| Blank screen, no loader | "Users will leave in two to three seconds." |
| **< 1s** | "You should never show a spinner if something will take less than a second to load." It flashes, "the user's brain registers like something weird just happened. You actually make it feel slower." → just show the results. |
| **2–5s** | "A plain spinner with no text works for about two to five seconds." |
| **> 5s** | "Past five seconds, a spinner with no text starts to feel broken." |
| **+ static text** | "Loading" or "Saving" — "that buys you maybe one more second." |
| **+ changing text** | "Connecting to your account, then almost there. This is where people are willing to wait significantly longer because they feel that there's action happening, even if it's fake." |
| **> 10s** | "After ten seconds, looped animations just stop working. Don't do them. They actually start hurting. The user's patience flips." → progress bar, step-by-step indicator, or something else. |

**On failures during load:**

> "If something fails, just show the error immediately as soon as you can. Try not to
> make them wait twenty seconds with a loading spinner and then be like, Sorry, that
> didn't work."

**Code signals**
- Spinner shown unconditionally on mount with no minimum-duration guard *and* no delay
  guard. Look for the missing `setTimeout(..., ~300ms)` before showing.
- Long-running jobs (video processing, exports, migrations, batch imports, AI
  generation) rendering a looped spinner with static or no text.
- Retry/backoff logic that swallows failures until a total timeout instead of surfacing
  the first hard error.
- Any spinner whose copy is a hardcoded single string on an operation known to exceed
  ~5s — recommend a message sequence.

---

# Dimension C — Errors

## H5. Error message anatomy: what / why / what next

**Source:** Part 5 · **Severity:** P0

> "A good error message does three things. It tells them what happened, why it happened,
> and gives them a clear action."

Her worked example:

> Instead of "Something went wrong" → **"Your payment didn't go through. Your card was
> declined. Please check your card details or try a different payment method."**

Three failures she calls out, in escalating order:

1. **Raw backend dumped on screen.** *"Your error message should never be your database
   or back-end logic just dumped on the screen."* Two reasons: a regular person can't
   read it, and *"this could also be a security vulnerability if you're exposing details
   about your app's back end."*
2. **Vague catch-all.** *"So then you just put, Something went wrong, right? Wrong."*
   Her test: *"If you enter your card information and you press pay, and it says,
   Something went wrong, you have no idea if your payment went through or not."*
3. **Silent failure — the worst.** *"No message at all. The user clicks submit, the
   button does nothing. The screen doesn't change. They don't know if it worked, if it
   broke."* She names this as a common AI-tool default.

**Code signals**
- `catch (e) { setError(e.message) }` — leaks backend text to the UI.
- Rendering `error.stack`, SQL text, ORM errors, or raw HTTP bodies.
- String literals `"Something went wrong"`, `"An error occurred"`, `"Error"`,
  `"Oops"`, `"Failed"` with no accompanying cause or action.
- `catch {}`, `catch (e) { console.error(e) }`, `.catch(() => {})` — silent failure.
- Any error copy with no actionable verb and no retry affordance nearby.
- **Highest priority:** apply this to payment, auth, delete, and submit paths first.

**Screenshot signals**
- Error text that states a condition but offers no next step.
- Error toast/banner with no button, link, or instruction.

---

## H7. Error placement: proximity wins

**Source:** Part 7 · **Severity:** P1

> "As a general rule, the closer your error is to your issue, the better."

| Placement | Behavior | Use for | Her guidance |
|---|---|---|---|
| **Toast** | Pops at top/bottom, auto-dismisses | Low-stakes, transient | "Don't use toast for an important error. Think, if the user looks away and they miss this, are they gonna be okay?" Good fit: "Couldn't connect, retrying." |
| **Modal** | Takes over center, blocks everything | Only when the user cannot continue without addressing it | "Use this sparingly." Payment failed + button to update payment; "You don't have access to this project" + button to request access. **"If you're gonna block the user, you have to give them a way forward."** |
| **Inline** | Right next to the thing that went wrong | Most cases | "These are the ones that you'll probably use most often." Red border on the offending field; "If the user clicks Save and it fails, it should say, Try again, right next to it. The user's eyes are already there." |

**Code signals**
- `toast.error(...)` on a payment, auth, permission, or destructive-action failure →
  should be inline or modal.
- A blocking modal with a single dismiss/close and no forward action → violates "give
  them a way forward."
- Form submit errors rendered only in a page-level banner while the invalid field has no
  indicator.
- Global error boundary used as the only error surface for section-level failures (see
  H10).

---

# Dimension D — Forms

## H6. The six form rules

**Source:** Part 6 · **Severity:** P1 (rules 1 & 2 are P0 on payment/signup)

> "Nobody likes filling out forms."

1. **Gate submit — but explain the gate.** "Keep that button grayed out until all the
   required fields are done, but please make it really obvious what's missing. The
   grayed out button with no explanation is even more frustrating. Mark your required
   fields so the user's never guessing why they can't submit."
2. **Validate inline, on blur.** "The moment that someone leaves an email field and it's
   not a real email address, you need to let them know. Nothing is more frustrating than
   filling out a form, submitting it, having it load, and then you have to scroll all the
   way up just to fix something."
3. **Show character count** as they type, wherever there's a limit. "Why would you let
   someone write a whole paragraph and then come to find out they have to leave half of
   it?"
4. **Pre-fill what you can.** "If they're logged in, don't make them type their email
   again."
5. **Show password requirements as they type, and check off what's done.** "Don't let
   someone submit a password and then it turns out they need a capital letter."
6. **Be forgiving with formatting.** "If someone types their phone number with dashes or
   parentheses or nothing at all, can you handle all of those and just take care of
   formatting it to be the same in the back end?"

**Code signals**
- `disabled={!valid}` with no adjacent list of what's missing and no `required` markers.
- Validation only inside `onSubmit` — no `onBlur` / `mode: 'onBlur'` / `validateOn`.
- `maxLength` on an input with no character counter rendered.
- Authenticated forms with empty `defaultValue` for fields already on the user record.
- Password field whose requirements appear only in helper text or only after a failed
  submit.
- Strict regex on phone / postal code / card number that rejects spaces, dashes, or
  parentheses instead of normalizing.

---

# Dimension E — Empty states

## H8. Empty states are a first impression, not a blank

**Source:** Part 8 · **Severity:** P1 (P0 for a new user's first screen)

> "Although they're not sexy to think about, because as designers and developers, we like
> to think about all the new features, the empty state is often what your user will see
> first, so let's make a good impression."

**A good empty state:** *"tells a user why it's empty, shows them what to do next, and
doesn't feel broken."*

Four cases she distinguishes:

1. **First-run / zero data.** "You have no projects leaves the user with no actions. They
   don't know what to do. So you add, Create your first project with a button right here."
   She goes further: "Maybe let's add a step-by-step gamified instructions to get them
   started."
2. **Any section without content yet.** "Don't just leave it blank. Let the user know what
   the section is for and how to start using it."
3. **Empty search results.** "No results is okay, but what about no results for *purble
   shoes*? What about *purple shoes*, with a link to search that term. That keeps the user
   moving." — i.e. echo the query, then offer a correction or next move.
4. **Empty as an achievement.** "Sometimes the goal is empty state, a zero inbox. So when
   someone clears all their mail and hits zero, make it feel like an achievement. Add a
   nice animation. Add a background that is something that they look forward to seeing."

**Code signals**
- `list.length === 0` rendering only a string, or nothing at all.
- Empty-state copy with no CTA element.
- Search results component with no zero-result branch, or one that doesn't echo the query
  term.
- Inbox/queue/task-completion screens whose zero state is visually identical to a loading
  or broken state.
- Copy strings matching `/^no \w+( yet)?\.?$/i` with no sibling button or link.

---

# Dimension F — Resilience

## H9. Partial states are normal; plan for them

**Source:** Part 9 · **Severity:** P1

> "When you open an app, it looks like one page, but almost nothing on that page comes
> from the same place."

Her analogy:

> "Imagine you order delivery from three different restaurants. Do you expect all of them
> to show up at exactly the same time? And if one of the three doesn't show up, do you
> just throw all the food away? Of course not. You eat what showed up."

Two anti-patterns, stated plainly:

> "You might see a loading screen until every single component is ready, or if one thing
> breaks, everything breaks, and then you see an entire page error."

The term and the goal:

> "It's called graceful degradation. It means your app keeps working with whatever it has.
> Each section loads on its own, fails on its own, and the rest of the page is still
> usable."

**Code signals**
- `Promise.all` gating a page render — one rejection kills the whole view. Look for
  `allSettled` or per-section queries instead.
- A single top-level `isLoading` for a page with multiple independent data sources.
- One error boundary at the route level and none at section level.
- Server components / loaders that `await` every data source before returning any markup,
  with no streaming or `Suspense` boundaries.

---

## H10. Every section owns its data, loading, and errors

**Source:** Part 10 · **Severity:** P1

> "The general rule is that every section on your page should be responsible for its own
> data, its own loading state, and its own errors."

> "If a section fails, it should have its own error message and its own retry button. The
> rest of the page stays completely usable."

The cached-then-swap technique, in her words:

> "When you open Instagram, your feed might load immediately, but it might actually be a
> cached version of photos and videos from a couple of hours ago that shows while the
> fresh content loads in the background. Once the new data is ready, it just swaps into
> your feed. You've been scrolling content this whole time. You didn't even notice this
> trick."

Her planning questions: *"how to build things so they operate individually, what the page
might look like when some things work and others don't, and how to make that feel as
seamless as possible to the user."*

**Code signals**
- Section components receiving data purely as props from a page-level fetch, with no local
  error/retry capability.
- No retry affordance anywhere in an error branch (`onClick={refetch}` absent).
- Cache config that blocks render on revalidation instead of serving stale
  (`staleWhileRevalidate`, `keepPreviousData`, `placeholderData` unset where appropriate).

---

# Dimension G — Success

## H11. Confirm that it worked

**Source:** Part 11 · **Severity:** P0 on money, auth, and destructive actions

> "When a user does something in your app, there has to be some kind of feedback."

Her example of the failure:

> "Think about booking a flight. You paid a couple hundred dollars, you clicked confirm,
> and then nothing happened. Did it go through? Did it charge me? Should I press it again?
> That uncertainty is the worst feeling for a user."

Calibrate the size of the confirmation to the size of the action:

- **Big moments** — "Some actions might deserve a page with confetti, finishing a big
  task, your first milestone, but please don't overdo it."
- **Small moments** — "Not every success state is a huge pop-up or a full-page shebang.
  Some can be very small, intuitive signs that, Okay, yeah, that worked, like moving a
  card on a board from to-do to done and it stays in done."
- **The state change itself can be the confirmation** — "Sometimes the cleanest
  confirmation is the action itself."

**Code signals**
- Mutation handlers with no success branch — no toast, no redirect, no state change, no
  copy update.
- `await mutate()` followed only by `router.refresh()` with no visible acknowledgement on
  a payment, booking, or submission path.
- Confetti / full-page celebration on routine repeated actions (over-celebration).
- Destructive actions (delete, cancel, revoke) that complete with no confirmation.

---

# Dimension H — Conventions and cognitive load

## H12. Jakob's Law — match the conventions users already carry

**Source:** Part 12 · **Severity:** P1

> "Users spend most of their time on other websites and apps, so they already expect your
> site to work the same as others."

(Jakob Nielsen, co-founder of Nielsen Norman Group — *"basically the gold standard for UX
research."*)

Her worked example — the cart:

> "Think about every e-commerce site that you've ever used, Amazon, Target, Shopify. The
> cart is always top right. […] So if you build your site and you put the cart in the
> bottom right, you might be thinking, I am being so innovative. I am doing something
> different. But accessing your cart is something you want zero friction on."

The cost of novelty in a high-frequency control:

> "That microsecond of extra thought, that tiny moment of wait, where is it, that's
> unnecessary."

And the rebuttal to "how boring":

> "The structure being predictable is what lets the user focus on what actually matters."

**Audit approach.** Novelty budget belongs in brand expression, not in the location of
high-frequency controls. Check placement against convention for: cart, search, primary
nav, account/profile menu, logo-links-home, settings, logout, notifications, close/X on
modals, submit-on-right in dialogs.

**Code / screenshot signals**
- Cart, search, or account controls in non-conventional positions.
- Logo that doesn't link to home.
- Modal primary action on the left, or destructive action in the primary slot.
- Custom-built controls replacing a native pattern (`<select>`, date picker) with a
  different interaction model and no affordance cues.

---

## H13. Conventions are per-device and per-locale

**Source:** Part 13 · **Severity:** P1

The correction she makes to her own Part 12 example — worth keeping because it's the
subtler point:

> "The expected layouts that people are used to seeing are not the same on mobile and web.
> On desktop, the shopping cart often does live top right. Amazon, Target, Lululemon. But
> pull up the mobile app for any of these stores. Where's the cart now? […] It's in the
> bottom nav."

The reason:

> "Your thumb lives at the bottom of the screen. If you're using your phone one-handed,
> the top right is one of the hardest places to reach."

And locale:

> "Open the Arabic version of Amazon. Everything is mirrored. The cart is top left."

Her summary: consider *"the patterns that people are used to seeing, but also the
difference in devices that people are using and where your customers are gonna be located
in the world."*

**Code signals**
- Primary mobile navigation or primary actions placed in a top bar with no bottom-nav or
  thumb-zone alternative.
- Hardcoded `left`/`right`, `margin-left`, `text-align: left` on directional layout
  instead of logical properties (`inline-start`, `margin-inline-start`) in a product that
  ships or plans RTL locales.
- No `dir` attribute handling; no RTL test coverage.
- Desktop-derived layout reused verbatim at mobile breakpoints for high-frequency
  controls.

---

## H14. Hick's Law — decision time grows with the number of choices

**Source:** Part 14 · **Severity:** P1

> "The time that it takes to make a decision increases with the complexity and the number
> of choices."

Her examples: 24 jars of jam vs. 6; Cheesecake Factory's 250-item menu vs. In-N-Out's
four; and:

> "Look at Google versus Yahoo. The web browser for Google will give you one clear action,
> search. Yahoo has so much going on. You could call it clutter, but really it's a lot of
> unnecessary additional choices competing for your attention."

Three concrete moves:

1. **Split long forms.** "Instead of showing someone a long form all at once, break it up
   into several pages. Studies have shown that if you have over seven fields, multi-page
   can increase conversion by over 300%."
2. **Collapse long menus into search + filter.** "Instead of this menu where everything is
   listed out, keep a couple of options, and then let people filter in the search results."
3. **Curate instead of exposing everything.** Netflix — "80% of what you watch comes from
   recommendations, not what you search. They have thousands and thousands of movies you
   can watch, but you don't see them all at once, and the homepage is just a few curated
   rows."

The framing that keeps this from becoming feature-cutting:

> "It's not about limiting what a person can do. It's more about keeping the options
> manageable."

**Code signals**
- Single-step forms with **more than seven** input fields → recommend multi-step. (Use her
  seven-field threshold as the trigger.)
- Nav or menu components rendering more than ~7 sibling items at one level with no search
  or grouping.
- Screens with multiple competing primary-styled buttons.
- Settings pages that are one flat list of every option.
- Dropdowns/selects with large option counts and no type-ahead filter.

---

## H15. Progressive disclosure — show what's needed now

**Source:** Part 15 · **Severity:** P1

Her framing question:

> "If you're driving somewhere you've never been, would you rather the GPS list out all 35
> turns before you even leave the driveway, or just tell you where to turn one at a time as
> you drive?"

The definition:

> "Progressive disclosure just basically means showing people what they need right now,
> whether that is the next step, the next layer of options, whatever they need as they go.
> None of the features that you built are removed, they're just not thrown at the user all
> at once."

**Her bad example** — an image-generation dropdown so large it scrolls:

> "Now say my goal is to create a motion graphic. It's here at the bottom of this menu, but
> naturally, my eyes go to create video at the top, and up until now, as I'm making this
> video for you guys, I didn't realize that the motion graphic option actually existed."

**Her good example** — Notion:

> "Notion can do a million things. […] but the interface feels clean. […] The AI chat only
> shows up when I ask for it, and this menu of everything you can add to your doc, it's
> hidden until I hit the slash key. Then I can see what's possible, and I can keep typing
> to really specify the thing that I'm looking for."

**The caveat — this is where progressive disclosure goes wrong:**

> "You don't wanna hide your most important features so deep that people can't figure it
> out without needing a tutorial."

**The audit question she leaves you with:**

> "Are all the things that I see here needed to be shown at this time?"

**Code signals**
- Menus/dropdowns whose option list overflows the viewport and requires scrolling to reach
  named features.
- All advanced/rarely-used options rendered at the same visual level as primary ones.
- No command palette, `/` menu, or type-ahead in a feature-dense surface.
- Conversely: a core feature reachable only via 3+ nested menus, or documented only in
  onboarding.

---

## H16. Tesler's Law — complexity moves, it doesn't disappear

**Source:** Part 16 · **Severity:** P1 (P0 when the burden lands on a payment or onboarding path)

> "There's a law in tech that says you can never actually get rid of complexity. You can
> only decide who suffers from it, the person building the app or the person using it."

Larry Tesler, 1980s — *"the guy who you can thank for inventing copy/paste."* His quote,
as she gives it:

> "If a million users each waste a minute on a complexity that an engineer could have
> solved within a week's time, you are penalizing the user to make the engineer's job
> easier."

Her examples of complexity absorbed by the builder: Google search; Netflix's skip-intro
button — *"because someone had to figure out the exact second that the intro starts and
ends for thousands of shows and movies"*; Apple Pay and Face ID — *"you just buy something
with one tap. You don't have to enter a password and then pull out your credit card and
then enter those numbers."*

The takeaway:

> "As much as possible, you wanna take the burden and the complexity off the user and put
> it on yourself […] during the design and the development phases."

And the user model to hold:

> "Remember that you're not building for the most perfectly patient, rational user. Real
> people are busy and distracted. They just want the easiest path, and it'll make your
> product more likable, so it's on you to handle the hard part for them."

**Important scoping note from her caption:** this is about *inherent* complexity — "not
additional app features or things that you could easily just remove." Don't confuse
Tesler's Law with feature-cutting; that's H14/H15 territory.

**Code signals**
- Users asked to supply data the system already has or could derive (IDs, timezone,
  currency, locale, region, account type).
- Manual formatting demands pushed to the user — see H6.6.
- Configuration required before first value is delivered, with no sensible defaults.
- Error recovery that requires the user to figure out the fix rather than offering it
  (e.g. "invalid date format" vs. parsing what they typed).
- Onboarding that front-loads setup work that could be deferred or inferred.

---

## Cross-cutting audit note

H1 is the spine — run the four-state matrix first, because most findings in H3, H4, H5,
H8, and H11 are discovered while filling it in. H12–H16 are read against the whole
product, not per screen.

---

## Attribution

All quoted principles and examples are the work of **Katherine Gilligan (@synsation\_)**,
from the *Build for Good UX* series, Parts 1–16 (May–July 2026). This library is a
derivative audit tool; it does not reproduce the episodes. Credit her when sharing audit
output.

| Part | Topic | Heuristic |
|---|---|---|
| 1 | UI vs. UX; the happy-path problem | Framing |
| 2 | The four states; history of loaders | H1, H2 |
| 3 | Choosing skeleton / progress / spinner / optimistic | H3 |
| 4 | Spinner duration psychology | H4 |
| 5 | Error message anatomy | H5 |
| 6 | Forms — six rules | H6 |
| 7 | Error placement: toast / modal / inline | H7 |
| 8 | Empty states | H8 |
| 9 | Partial states, graceful degradation (concept) | H9 |
| 10 | Graceful degradation (implementation) | H10 |
| 11 | Success states | H11 |
| 12 | Jakob's Law | H12 |
| 13 | Jakob's Law across devices and locales | H13 |
| 14 | Hick's Law | H14 |
| 15 | Progressive disclosure | H15 |
| 16 | Tesler's Law | H16 |
