# MonthWeave

MonthWeave builds deterministic calendar data and printable month and year layouts in Typst. It handles leap years, week-start conventions, six-row months, ISO week labels, blank planning grids, event markers, and compact year overviews.

## Why MonthWeave

Calendar pages have a deceptively large number of layout edge cases. A month can begin on any weekday, contain 28 through 31 days, and need five or six visual rows. Week starts differ by region, while ISO week numbers always use Monday-based weeks and can belong to a different week-year near New Year. These details affect both correctness and predictable print pagination.

MonthWeave keeps Gregorian arithmetic in a small data layer and uses that data to render repeatable tables. The package has no external runtime dependency.

## Features

- Calendar arithmetic for Gregorian leap years and month lengths.
- Sunday-first, Monday-first, or any other selected weekday start.
- Adaptive five- or six-row months and validated fixed-height grids.
- Optional adjacent-month dates, ISO week numbers, blank cells, and event markers.
- Caller-supplied weekday and month labels for localized documents.
- A compact 12-month overview and customizable colors, borders, type sizes, and cell padding.
- A4 portrait, A4 landscape, and US Letter portrait page helpers.

## Installation

Import the released package with its full version:

```typst
#import "@preview/monthweave:0.1.0": month-calendar
```

## Quick start

```typst
#import "@preview/monthweave:0.1.0": month-calendar

#month-calendar(2028, 2, week-start: 1, week-numbers: true)
```

This generates February 2028 with a Monday-first header, 29 days, and ISO week numbers.

## Month calendar

`month-calendar(year, month, ...)` renders a seven-column month table. `week-start` is Sunday-zero: use `0` for Sunday, `1` for Monday, and `2`–`6` for Tuesday through Saturday. `rows: auto` selects the minimum number of complete rows. Set `rows: 5` or `rows: 6` for consistent page layouts; an error is raised if the month cannot fit.

Adjacent dates are shown by default. Set `show-outside: false` to retain empty edge cells. `week-numbers: true` adds ISO week labels. Week numbers follow ISO-8601 regardless of the selected visual week start. Adaptive height uses at least five rows and expands to six when the dates require it.

## Week starts and labels

```typst
#month-calendar(2027, 1, week-start: 1) // Monday first
#month-calendar(2027, 1, week-start: 0) // Sunday first
```

`weekdays` takes seven labels in Sunday-to-Saturday order, and `months` takes twelve labels from January through December. Month names and weekday abbreviations are not baked into the arithmetic.

## ISO week numbers

```typst
#month-calendar(2026, 12, week-start: 1, week-numbers: true)
```

The data helper `iso-week(year, month, day)` returns a record with `year` and `week`. For example, 2021-01-01 belongs to ISO week 53 of 2020.

## Events

Pass event records for any visible date. A `marker` is optional; without it, the renderer uses a bullet.

```typst
#let releases = (
  (year: 2028, month: 2, day: 29, label: "Leap-day review", marker: "◆"),
  (year: 2028, month: 2, day: 14, label: "Planning", marker: "•"),
)

#month-calendar(2028, 2, week-start: 1, events: releases)
```

The same event records are available on the matching cell in `calendar-grid` output, so a document can build its own summaries or annotations.

## Year overview

```typst
#import "@preview/monthweave:0.1.0": year-calendar

#set page(width: 297mm, height: 420mm, margin: 12mm)
#year-calendar(2028, week-start: 1)
```

`year-calendar` lays out twelve compact months in three columns. It shares the month-grid arithmetic and theme with the single-month renderer.

## Blank planning calendar

```typst
#import "@preview/monthweave:0.1.0": blank-calendar

#blank-calendar(2028, 2, week-start: 1)
```

Blank mode preserves the calendar structure and event markers while leaving day numbers out of the rendered cells.

## Custom styling

`calendar-theme` returns a theme record that can be passed to month and year renderers. Its options include `title-size`, `heading-fill`, `day-fill`, `weekend-fill`, `outside-fill`, text colors, `event-color`, `border`, and `cell-padding`.

```typst
#import "@preview/monthweave:0.1.0": calendar-theme, month-calendar

#let planning-theme = calendar-theme(
  heading-fill: rgb("DDEAF7"),
  weekend-fill: rgb("F4F7FA"),
  event-color: rgb("8A2635"),
  cell-padding: 8pt,
)

#month-calendar(2028, 2, week-start: 1, theme: planning-theme)
```

## Print layouts

Use `printable-calendar(year, month, format: ...)` to set a page and render one month. Supported formats are `a4-portrait`, `a4-landscape`, and `us-letter-portrait`.

```typst
#import "@preview/monthweave:0.1.0": printable-calendar

#printable-calendar(2028, 2, format: "a4-landscape", week-start: 1)
```

See the examples for portrait A4, landscape A4, and US Letter documents.

## Calendar arithmetic notes

Calendar functions use Gregorian years from 1 onward and do not depend on time zones, timestamps, or the host's current date. Month numbering follows the familiar range 1–12. Weekday indices use Sunday-zero numbering. Invalid years, months, days, and fixed row counts raise an assertion instead of silently normalizing an input.

## Project website and calendar resources

MonthWeave focuses on deterministic document layout. BetaCalendars provides human-facing printable and planning calendar resources at [betacalendars.com](https://www.betacalendars.com/).

## License

MIT. See [LICENSE](LICENSE).
