# Temporal API — Full Reference

## Class Overview

```
Temporal.Instant          — nanoseconds since Unix epoch, no timezone
Temporal.ZonedDateTime    — Instant + timezone (full real-world time)
Temporal.PlainDateTime    — date + time, no timezone
Temporal.PlainDate        — date only (year, month, day)
Temporal.PlainTime        — time only (hour…nanosecond)
Temporal.PlainYearMonth   — year + month
Temporal.PlainMonthDay    — month + day
Temporal.Duration         — a span of time (years…nanoseconds)
Temporal.Now              — factory for current values
```

---

## Temporal.Instant

Unique point in time. No calendar, no timezone.

**Create**
```ts
Temporal.Instant.from('2025-06-15T12:00:00Z')
Temporal.Instant.fromEpochMilliseconds(Date.now())
Temporal.Instant.fromEpochNanoseconds(BigInt)
Temporal.Now.instant()
```

**Properties**: `epochMilliseconds`, `epochNanoseconds`

**Methods**: `add(duration)`, `subtract(duration)`, `since(other)`, `until(other)`,
`round(options)`, `equals(other)`, `compare(a, b)` (static),
`toZonedDateTimeISO(tz)`, `toZonedDateTime({ timeZone, calendar })`,
`toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.ZonedDateTime

Full date + time + timezone. DST-aware.

**Create**
```ts
Temporal.ZonedDateTime.from('2025-06-15T09:00:00[America/New_York]')
Temporal.ZonedDateTime.from({ year: 2025, month: 6, day: 15, hour: 9, timeZone: 'UTC' })
Temporal.Now.zonedDateTimeISO('America/New_York')
instant.toZonedDateTimeISO('America/New_York')
```

**Properties**: `year`, `month`, `day`, `hour`, `minute`, `second`, `millisecond`,
`microsecond`, `nanosecond`, `timeZoneId`, `offset`, `offsetNanoseconds`,
`epochMilliseconds`, `epochNanoseconds`, `calendarId`, `hoursInDay`,
`dayOfWeek`, `dayOfYear`, `weekOfYear`, `yearOfWeek`, `daysInMonth`,
`daysInYear`, `monthsInYear`, `inLeapYear`, `era`, `eraYear`

**Methods**: `with(fields)`, `withTimeZone(tz)`, `withCalendar(cal)`,
`withPlainTime(time)`, `add(duration)`, `subtract(duration)`,
`since(other, options?)`, `until(other, options?)`, `round(options)`,
`equals(other)`, `compare(a, b)` (static), `startOfDay()`,
`getTimeZoneTransition(direction)`,
`toInstant()`, `toPlainDate()`, `toPlainTime()`, `toPlainDateTime()`,
`toPlainYearMonth()`, `toPlainMonthDay()`,
`toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.PlainDateTime

Date + time. No timezone.

**Create**
```ts
Temporal.PlainDateTime.from('2025-06-15T09:00:00')
Temporal.PlainDateTime.from({ year: 2025, month: 6, day: 15, hour: 9 })
Temporal.Now.plainDateTimeISO()
```

**Properties**: All year/month/day + hour/minute/second/ms/µs/ns + `calendarId`,
`dayOfWeek`, `dayOfYear`, `weekOfYear`, `yearOfWeek`, `daysInMonth`,
`daysInYear`, `monthsInYear`, `inLeapYear`, `era`, `eraYear`

**Methods**: `with(fields)`, `withCalendar(cal)`, `withPlainTime(time)`,
`add(duration)`, `subtract(duration)`, `since(other)`, `until(other)`,
`round(options)`, `equals(other)`, `compare(a, b)` (static),
`toZonedDateTime(timeZone)`, `toPlainDate()`, `toPlainTime()`,
`toPlainYearMonth()`, `toPlainMonthDay()`,
`toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.PlainDate

Calendar date only.

**Create**
```ts
Temporal.PlainDate.from('2025-06-15')
Temporal.PlainDate.from({ year: 2025, month: 6, day: 15 })
Temporal.Now.plainDateISO()
```

**Properties**: `year`, `month`, `monthCode`, `day`, `calendarId`, `era`, `eraYear`,
`dayOfWeek`, `dayOfYear`, `weekOfYear`, `yearOfWeek`,
`daysInMonth`, `daysInYear`, `monthsInYear`, `inLeapYear`

**Methods**: `with(fields)`, `withCalendar(cal)`,
`add(duration)`, `subtract(duration)`, `since(other)`, `until(other)`,
`equals(other)`, `compare(a, b)` (static),
`toZonedDateTime(timeZone | { timeZone, plainTime })`,
`toPlainDateTime(time?)`, `toPlainYearMonth()`, `toPlainMonthDay()`,
`toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.PlainTime

Clock time only. No date, no timezone.

**Create**
```ts
Temporal.PlainTime.from('09:30:00')
Temporal.PlainTime.from({ hour: 9, minute: 30 })
Temporal.Now.plainTimeISO()
```

**Properties**: `hour`, `minute`, `second`, `millisecond`, `microsecond`, `nanosecond`

**Methods**: `with(fields)`, `add(duration)`, `subtract(duration)`,
`since(other)`, `until(other)`, `round(options)`,
`equals(other)`, `compare(a, b)` (static),
`toPlainDateTime(date)`, `toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.PlainYearMonth

**Create**
```ts
Temporal.PlainYearMonth.from('2025-06')
Temporal.PlainYearMonth.from({ year: 2025, month: 6 })
```

**Properties**: `year`, `month`, `monthCode`, `calendarId`, `era`, `eraYear`,
`daysInMonth`, `daysInYear`, `monthsInYear`, `inLeapYear`

**Methods**: `with(fields)`, `add(duration)`, `subtract(duration)`,
`since(other)`, `until(other)`, `equals(other)`, `compare(a, b)` (static),
`toPlainDate(day)`, `toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.PlainMonthDay

**Create**
```ts
Temporal.PlainMonthDay.from('06-15')
Temporal.PlainMonthDay.from({ month: 6, day: 15 })
```

**Properties**: `month`, `monthCode`, `day`, `calendarId`

**Methods**: `with(fields)`, `equals(other)`,
`toPlainDate(year)`, `toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.Duration

**Create**
```ts
Temporal.Duration.from({ years: 1, months: 3, days: 5 })
Temporal.Duration.from('P1Y3M5D')  // ISO 8601 duration string
someDate.until(otherDate, { largestUnit: 'months' })
```

**Properties**: `years`, `months`, `weeks`, `days`, `hours`, `minutes`,
`seconds`, `milliseconds`, `microseconds`, `nanoseconds`, `sign`, `blank`

**Methods**: `with(fields)`, `add(other)`, `subtract(other)`,
`negated()`, `abs()`, `round(options)`,
`total(unit)`, `compare(a, b, options)` (static),
`toString()`, `toJSON()`, `toLocaleString()`

---

## Temporal.Now

```ts
Temporal.Now.instant()                       // Instant
Temporal.Now.zonedDateTimeISO(tz)            // ZonedDateTime (ISO calendar)
Temporal.Now.zonedDateTime(calendar, tz)     // ZonedDateTime (any calendar)
Temporal.Now.plainDateTimeISO(tz?)           // PlainDateTime
Temporal.Now.plainDateTime(calendar, tz?)    // PlainDateTime
Temporal.Now.plainDateISO(tz?)               // PlainDate
Temporal.Now.plainDate(calendar, tz?)        // PlainDate
Temporal.Now.plainTimeISO(tz?)               // PlainTime
Temporal.Now.timeZoneId()                    // string (IANA name)
```

---

## Conversion Paths

```
Instant ──toZonedDateTimeISO(tz)──► ZonedDateTime ──toInstant()──► Instant
                                         │
                              ┌──────────┼──────────┐
                         toPlainDate() toPlainTime() toPlainDateTime()
                              │                           │
                         PlainDate                   PlainDateTime
                              │                           │
                    ┌─────────┴────────┐         toPlainDate() / toPlainTime()
               toPlainYearMonth()  toPlainMonthDay()
                    │                  │
               PlainYearMonth     PlainMonthDay
                    │                  │
               toPlainDate(day)   toPlainDate(year)
```

---

## Arithmetic Options

```ts
date.until(other, {
  largestUnit: 'years',   // years | months | weeks | days | hours | ...
  smallestUnit: 'days',
  roundingMode: 'trunc',  // trunc | ceil | floor | halfExpand | expand
})
```

---

## RFC 9557 / ISO 8601 String Format

```
2025-06-15T09:30:00.000000000-05:00[America/New_York][u-ca=iso8601]
└─ date ─┘└── time ──────────────┘└─ offset ─┘└── tz id ──────┘└── calendar ─┘
```

Fractional seconds: up to 9 decimal places (nanosecond precision).

---

## Calendar System Gotchas

- Don't assume 12 months or 365/366 days per year — use `monthsInYear`, `daysInYear`.
- Don't assume `era`/`eraYear` are defined — may be `undefined` in ISO 8601.
- Don't compare `year` across different calendar systems.
- Never display raw `era` strings — use `toLocaleString()`.
- Use `monthCode` for calendar-independent month identity (e.g. `"M06"` for June in ISO).
- Leap months get a suffix: `"M06L"` is a leap June in lunisolar calendars.

---

## Timezone Gotchas

- `hoursInDay` may be 23 or 25 on DST transition days.
- `ZonedDateTime` can represent wall-clock times that are ambiguous or non-existent during DST gaps — control with `disambiguation` option in `.from()`.
- Use IANA timezone identifiers (`'America/New_York'`), not offsets (`'-05:00'`), when you need DST awareness.

---

## Valid Date Range

`±10^8 days` from Unix epoch:
- Min: `-271821-04-20`
- Max: `+275760-09-13`

Out-of-range throws `RangeError`.

---

## Polyfills

```bash
npm install @js-temporal/polyfill    # official, by proposal champions
npm install temporal-polyfill        # by FullCalendar, lighter weight
```
