---
name: temporal-api
description: Quick reference for the JavaScript Temporal API — class selection, conversions, arithmetic, timezones, calendars. Use when working with Temporal types, building date/time features, handling timezone logic, migrating from the legacy Date object, or choosing the right Temporal class for a use case.
---

# Temporal API

## Which class to use?

| Need | Use |
|------|-----|
| Exact point in time (logging, timestamps) | `Temporal.Instant` |
| Date + time + timezone (real-world meetings) | `Temporal.ZonedDateTime` |
| Date + time, no timezone (schedules, forms) | `Temporal.PlainDateTime` |
| Calendar date only (birthdays, holidays) | `Temporal.PlainDate` |
| Clock time only (alarms, business hours) | `Temporal.PlainTime` |
| Year + month only (billing cycles) | `Temporal.PlainYearMonth` |
| Month + day only (recurring annual events) | `Temporal.PlainMonthDay` |
| Time span / difference | `Temporal.Duration` |

## Quick start

```ts
// Current time
const now = Temporal.Now.instant();
const today = Temporal.Now.plainDateISO();
const zonedNow = Temporal.Now.zonedDateTimeISO('America/New_York');

// Create from parts or string
const date = Temporal.PlainDate.from({ year: 2025, month: 6, day: 15 });
const zdt = Temporal.ZonedDateTime.from('2025-06-15T09:00:00[America/New_York]');

// Arithmetic — all types are immutable, always capture the return
const nextWeek = date.add({ weeks: 1 });
const diff = date.until(nextWeek); // -> Temporal.Duration

// Compare
Temporal.PlainDate.compare(date, nextWeek); // -1 | 0 | 1

// Format
date.toLocaleString('en-US', { dateStyle: 'long' });
```

## Common patterns

```ts
// Update a single field
const inDecember = date.with({ month: 12 });

// Convert between types
const instant = zdt.toInstant();
const plain = zdt.toPlainDate();
const zoned = plain.toZonedDateTime('America/New_York');

// Duration arithmetic
const twoHours = Temporal.Duration.from({ hours: 2, minutes: 30 });
const later = zdt.add(twoHours);

// How long ago?
const age = someDate.until(Temporal.Now.plainDateISO(), { largestUnit: 'years' });
```

## Rules to remember

- **Plain types** = no timezone. Use for wall-clock or calendar logic.
- **ZonedDateTime** = real-world moments with full DST awareness.
- Never pair `era`/`eraYear` with `year` — pick one representation.
- Never pair `monthCode` with `month` — pick one.
- Use `weekOfYear` + `yearOfWeek` together (never with `year`).
- All mutations return a **new** object — capture the return value.

## Polyfill (not yet baseline)

```ts
import { Temporal } from '@js-temporal/polyfill';
// or
import { Temporal } from 'temporal-polyfill';
```

See [REFERENCE.md](REFERENCE.md) for full class API, calendar system notes, and conversion paths.
