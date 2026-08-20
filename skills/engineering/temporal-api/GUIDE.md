# JavaScript Temporal API — Learning Guide

> A clear, concept-first guide to using Temporal, JavaScript's modern replacement for the `Date` object.

---

## Why Temporal Exists

The built-in `Date` has been broken since the 90s. Here is what it gets wrong:

**1. It tries to be two things at once.**
A `Date` is simultaneously a timestamp (milliseconds since epoch) and a calendar date (year, month, day). These two meanings collide constantly. `getMonth()` returns 0 for January. `getTimezoneOffset()` returns minutes as a sign-flipped number. Parsing a date string gives you different results depending on whether you include a time component.

**2. It barely knows timezones exist.**
You get UTC and "local" (your device's timezone). That's it. Want to show a time in Tokyo? Do it yourself.

**3. It has no concept of "wall-clock time."**
Sometimes you just want to say "3:00 PM" without caring what timezone that is. `Date` can't express that.

**4. Everything mutates.**
`setMonth()`, `setFullYear()`, etc. all modify the object in place. Pass a date to a function and it might come back changed.

Temporal fixes all of this with a set of purpose-built immutable types.

---

## The Mental Model

Temporal gives you **one type per purpose**. Before writing any code, ask: _what am I actually representing?_

```
"A specific instant in history" ──────────────► Temporal.Instant
"A meeting at 3pm in New York" ───────────────► Temporal.ZonedDateTime
"A form field with a date and time" ──────────► Temporal.PlainDateTime
"A birthday (like July 4th)" ─────────────────► Temporal.PlainDate
"Wake up at 7am every day" ───────────────────► Temporal.PlainTime
"The billing month of March 2025" ────────────► Temporal.PlainYearMonth
"Christmas (December 25th, any year)" ────────► Temporal.PlainMonthDay
"How long something took" ────────────────────► Temporal.Duration
```

The **Plain** prefix always means "no timezone attached." Think of it as what you'd read off a clock on the wall or a calendar on the wall — no location information, no DST.

---

## Getting Started

Temporal is not yet in all browsers. Install the polyfill:

```bash
npm install @js-temporal/polyfill
```

```ts
import { Temporal } from '@js-temporal/polyfill';
```

---

## The Types, One by One

### Temporal.Instant — A Point in Time

Think of an `Instant` as a timestamp. It's the number of nanoseconds since the Unix epoch (1970-01-01 00:00:00 UTC). No calendar, no timezone. Just a moment.

```ts
// Get the current instant
const now = Temporal.Now.instant();

// Create from an existing timestamp
const fromMs = Temporal.Instant.fromEpochMilliseconds(Date.now());

// Create from an ISO string (must include UTC offset)
const specific = Temporal.Instant.from('2025-06-15T12:00:00Z');

// Access raw epoch values
specific.epochMilliseconds; // number (safe for JSON)
specific.epochNanoseconds;  // BigInt

// Arithmetic
const oneHourLater = specific.add({ hours: 1 });
const diff = specific.until(oneHourLater); // Duration of 1 hour

// Compare
Temporal.Instant.compare(specific, oneHourLater); // -1 (specific is earlier)
```

**When to use**: Log entries, event timestamps, "when did X happen?", converting to/from `Date.now()`.

**When NOT to use**: Anything that needs to display in a human timezone or calendar — convert to `ZonedDateTime` first.

---

### Temporal.ZonedDateTime — Real-World Date and Time

This is the most complete type. It combines a calendar date, a clock time, and a timezone. It is DST-aware — if your timezone changes clocks, `ZonedDateTime` handles that automatically.

```ts
// From a string with timezone in brackets
const meeting = Temporal.ZonedDateTime.from(
  '2025-06-15T09:00:00[America/New_York]'
);

// Current time in a specific timezone
const tokyoNow = Temporal.Now.zonedDateTimeISO('Asia/Tokyo');

// Create from parts
const deadline = Temporal.ZonedDateTime.from({
  year: 2025,
  month: 12,
  day: 31,
  hour: 23,
  minute: 59,
  timeZone: 'UTC',
});

// Access components
meeting.year;       // 2025
meeting.month;      // 6
meeting.day;        // 15
meeting.hour;       // 9
meeting.timeZoneId; // 'America/New_York'
meeting.offset;     // '-04:00' (EDT in June)

// Arithmetic — fully DST-aware
const nextWeek = meeting.add({ weeks: 1 });
const twoHoursLater = meeting.add({ hours: 2 });

// hoursInDay accounts for DST clock changes
meeting.hoursInDay; // usually 24, sometimes 23 or 25

// Convert to other types
const instant = meeting.toInstant();
const plainDate = meeting.toPlainDate();
const plainTime = meeting.toPlainTime();
```

**When to use**: Scheduling, calendar events, anything that needs to display in a real timezone and handle DST correctly.

---

### Temporal.PlainDateTime — Date + Time, No Timezone

A `PlainDateTime` is what you'd read off a clock and a calendar simultaneously — but without knowing what city you're in. Use it when the timezone either doesn't matter or will be applied later.

```ts
// Create
const appt = Temporal.PlainDateTime.from('2025-06-15T14:30:00');
const appt2 = Temporal.PlainDateTime.from({
  year: 2025, month: 6, day: 15, hour: 14, minute: 30,
});

// Current local date-time (in UTC if no tz given)
const now = Temporal.Now.plainDateTimeISO();

// Arithmetic
const rescheduled = appt.add({ days: 3, hours: 1 });

// Attach a timezone to get a ZonedDateTime
const zoned = appt.toZonedDateTime('Europe/London');

// Split into parts
const justDate = appt.toPlainDate();
const justTime = appt.toPlainTime();
```

**When to use**: Form fields, user-entered date/time before timezone is known, database storage of "local" times.

---

### Temporal.PlainDate — A Calendar Date

Just a year, month, and day. No time of day, no timezone. This is your workhorse for calendar logic.

```ts
// Create
const today = Temporal.Now.plainDateISO();
const birthday = Temporal.PlainDate.from('1990-07-04');
const christmas = Temporal.PlainDate.from({ year: 2025, month: 12, day: 25 });

// Arithmetic
const nextBirthday = birthday.with({ year: 2026 }); // same month/day, new year
const inTwoWeeks = today.add({ weeks: 2 });
const thirtyDaysAgo = today.subtract({ days: 30 });

// How many days until christmas?
const daysUntil = today.until(christmas, { largestUnit: 'days' });
daysUntil.days; // number

// Calendar info
today.dayOfWeek;    // 1 (Monday) to 7 (Sunday) in ISO calendar
today.daysInMonth;  // 28, 29, 30, or 31
today.inLeapYear;   // boolean

// Compare
Temporal.PlainDate.compare(birthday, christmas); // -1, 0, or 1

// Convert
const asDateTime = birthday.toPlainDateTime({ hour: 12 }); // noon on that date
const zoned = birthday.toZonedDateTime('America/New_York');
```

**When to use**: Birthdays, holidays, all-day events, "what day of the week is X?", date arithmetic without time.

---

### Temporal.PlainTime — A Clock Time

Just hour, minute, second, and sub-second precision. No date, no timezone. Think "time on a clock."

```ts
// Create
const alarm = Temporal.PlainTime.from('07:00:00');
const openingTime = Temporal.PlainTime.from({ hour: 9, minute: 30 });

// Current time
const now = Temporal.Now.plainTimeISO();

// Arithmetic (wraps around midnight)
const thirtyMinLater = openingTime.add({ minutes: 30 }); // 10:00

// Is it within business hours?
const businessOpen = Temporal.PlainTime.from('09:00');
const businessClose = Temporal.PlainTime.from('17:00');
const isOpen =
  Temporal.PlainTime.compare(now, businessOpen) >= 0 &&
  Temporal.PlainTime.compare(now, businessClose) < 0;

// Combine with a date
const today = Temporal.Now.plainDateISO();
const dateTime = today.toPlainDateTime(alarm);
```

**When to use**: Recurring alarms, business hours, time-of-day logic independent of any calendar date.

---

### Temporal.PlainYearMonth — A Month in a Year

When you need to refer to an entire month — March 2025, not a specific day.

```ts
const billingMonth = Temporal.PlainYearMonth.from('2025-03');
const nextMonth = billingMonth.add({ months: 1 });

billingMonth.year;        // 2025
billingMonth.month;       // 3
billingMonth.daysInMonth; // 31

// Get any specific day from this month
const lastDay = billingMonth.toPlainDate(billingMonth.daysInMonth);
```

**When to use**: Billing cycles, monthly reports, "which month does this belong to?"

---

### Temporal.PlainMonthDay — A Recurring Annual Date

A month and day without a year. Useful for things that repeat every year on the same date.

```ts
const christmas = Temporal.PlainMonthDay.from('12-25');
const independenceDay = Temporal.PlainMonthDay.from({ month: 7, day: 4 });

// Get the next occurrence in a specific year
const thisYearChristmas = christmas.toPlainDate(2025);
// -> PlainDate for 2025-12-25
```

**When to use**: Holidays, annual events, birthdays when you don't want to store the year.

---

### Temporal.Duration — A Span of Time

A duration is not a point in time — it's a length of time. It can have years, months, weeks, days, hours, minutes, seconds, milliseconds, microseconds, and nanoseconds.

```ts
// Create
const twoWeeks = Temporal.Duration.from({ weeks: 2 });
const complex = Temporal.Duration.from({ years: 1, months: 3, days: 5 });
const fromString = Temporal.Duration.from('P1Y3M5D'); // ISO 8601 duration

// Get a duration between two dates
const today = Temporal.Now.plainDateISO();
const birthDate = Temporal.PlainDate.from('1990-07-04');
const age = birthDate.until(today, { largestUnit: 'years' });
age.years;  // how old in years
age.months; // remaining months

// Use in arithmetic
const inTwoWeeks = today.add(twoWeeks);

// Convert to a single unit
const totalDays = complex.total({ unit: 'days', relativeTo: today });

// Negate (flip sign)
const negative = twoWeeks.negated();
negative.sign; // -1
```

**When to use**: Representing how long something takes, differences between dates, age calculations, countdowns.

---

## Immutability

Every Temporal type is **immutable**. No operation changes the original object. Always capture the return value:

```ts
// WRONG — this does nothing
const date = Temporal.Now.plainDateISO();
date.add({ days: 7 }); // the result is thrown away

// CORRECT
const date = Temporal.Now.plainDateISO();
const nextWeek = date.add({ days: 7 }); // keep the new value
```

---

## Updating Fields with `.with()`

Use `.with()` to create a new object with one or more fields changed:

```ts
const date = Temporal.PlainDate.from('2025-06-15');

// Change the month — everything else stays the same
const sameDay = date.with({ month: 12 }); // 2025-12-15

// Change the year and day
const newDate = date.with({ year: 2026, day: 1 }); // 2026-06-01
```

This is the immutable equivalent of `setMonth()` on `Date`.

---

## Converting Between Types

The main conversion paths are:

```
Instant ──► ZonedDateTime (attach a timezone)
  instant.toZonedDateTimeISO('America/New_York')

ZonedDateTime ──► Instant (drop the timezone)
  zdt.toInstant()

ZonedDateTime ──► PlainDateTime / PlainDate / PlainTime
  zdt.toPlainDateTime()
  zdt.toPlainDate()
  zdt.toPlainTime()

PlainDate ──► PlainDateTime (attach a time)
  date.toPlainDateTime({ hour: 12 })

PlainDate ──► ZonedDateTime (attach a timezone)
  date.toZonedDateTime('UTC')

PlainDate ──► PlainYearMonth / PlainMonthDay
  date.toPlainYearMonth()
  date.toPlainMonthDay()
```

---

## Serialization

All Temporal types serialize to/from strings in RFC 9557 format (a superset of ISO 8601):

```ts
const date = Temporal.PlainDate.from('2025-06-15');
date.toString();  // '2025-06-15'
date.toJSON();    // '2025-06-15' (same, for JSON.stringify)

const zdt = Temporal.ZonedDateTime.from('2025-06-15T09:00:00[America/New_York]');
zdt.toString();
// '2025-06-15T09:00:00-04:00[America/New_York]'

// Round-trip
const restored = Temporal.ZonedDateTime.from(zdt.toString());
zdt.equals(restored); // true
```

Store and transmit Temporal values as strings. Parse them back with `.from()`.

---

## Comparison and Sorting

Use the static `.compare()` method for sorting:

```ts
const dates = [
  Temporal.PlainDate.from('2025-12-25'),
  Temporal.PlainDate.from('2025-01-01'),
  Temporal.PlainDate.from('2025-06-15'),
];

dates.sort(Temporal.PlainDate.compare);
// -> [2025-01-01, 2025-06-15, 2025-12-25]
```

Use `.equals()` for exact equality:

```ts
date1.equals(date2); // true or false
```

---

## Formatting for Display

Use `.toLocaleString()` with `Intl` options:

```ts
const date = Temporal.PlainDate.from('2025-06-15');

date.toLocaleString('en-US', { dateStyle: 'long' });
// 'June 15, 2025'

date.toLocaleString('fr-FR', { dateStyle: 'full' });
// 'dimanche 15 juin 2025'

const zdt = Temporal.ZonedDateTime.from('2025-06-15T09:00:00[America/New_York]');
zdt.toLocaleString('en-US', { dateStyle: 'medium', timeStyle: 'short' });
// 'Jun 15, 2025, 9:00 AM'
```

---

## Common Gotchas

**1. `weekOfYear` and `yearOfWeek` are always a pair.**
The last week of the year might belong to week 1 of the _next_ year. Always use both together:
```ts
const { weekOfYear, yearOfWeek } = date;
// NOT: `year` + `weekOfYear`
```

**2. `era` and `eraYear` are always a pair.**
Some calendars use eras (CE/BCE for Gregorian, Heisei/Reiwa for Japanese). If you use one, use both. Never mix with `year`.

**3. `month` and `monthCode` are always a pair.**
`monthCode` is a calendar-independent string like `"M06"` for June. Use it when working with non-Gregorian calendars where leap months may be inserted. Pick one convention and stick to it.

**4. Don't assume months, days, or week lengths.**
Non-ISO calendars can have different counts. Always use `daysInMonth`, `daysInYear`, `monthsInYear`, `daysInWeek`.

**5. DST can make a day 23 or 25 hours long.**
Never assume `hoursInDay === 24` when working with `ZonedDateTime`.

**6. Not yet baseline — use a polyfill.**
Temporal is not supported in all browsers as of 2025. Always install `@js-temporal/polyfill` in production.

---

## Quick Reference Card

| Task | Code |
|------|------|
| Current date | `Temporal.Now.plainDateISO()` |
| Current instant | `Temporal.Now.instant()` |
| Current time in timezone | `Temporal.Now.zonedDateTimeISO('America/New_York')` |
| Add 7 days | `date.add({ days: 7 })` |
| Subtract 1 month | `date.subtract({ months: 1 })` |
| Days until X | `today.until(target, { largestUnit: 'days' }).days` |
| Age in years | `birthday.until(today, { largestUnit: 'years' }).years` |
| Change one field | `date.with({ month: 12 })` |
| Sort dates | `arr.sort(Temporal.PlainDate.compare)` |
| Are dates equal? | `a.equals(b)` |
| Format for display | `date.toLocaleString('en-US', { dateStyle: 'long' })` |
| To JSON string | `date.toString()` |
| From string | `Temporal.PlainDate.from('2025-06-15')` |
| Attach timezone | `date.toZonedDateTime('UTC')` |
| Strip timezone | `zdt.toPlainDate()` |
| Date → Instant | `date.toZonedDateTime('UTC').toInstant()` |
| Instant → Date | `instant.toZonedDateTimeISO('UTC').toPlainDate()` |

---

## Further Reading

- [MDN Temporal Overview](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Temporal)
- [TC39 Temporal Proposal Cookbook](https://tc39.es/proposal-temporal/docs/cookbook.html)
- [Temporal Polyfill on npm](https://www.npmjs.com/package/@js-temporal/polyfill)
