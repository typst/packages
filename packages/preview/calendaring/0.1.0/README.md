# calendaring

Lay out month calendar grids from a year and month.

A small Typst utility that takes `(year, month)` and renders a 7-column grid
with correct leading and trailing blank days, sized for handwritten notes.
Designed for personal planners, training logs, and habit trackers — not for
displaying scheduled events (see [`cineca`](https://typst.app/universe/package/cineca/)
for that).

## Install

```typst
#import "@preview/calendaring:0.1.0": month-grid, year-grid
```

## Basic usage

```typst
#import "@preview/calendaring:0.1.0": month-grid

#month-grid(2026, 6)
```

Renders a Monday-first grid for June 2026, sized 3.5cm × 3.3cm per cell
(tuned for a rotated A4 page). For unrotated portrait layouts, pass
`cell-width: 1fr` so the grid fills the page width.

## Functions

### `month-grid(year, month, ...)`

| Parameter        | Type                       | Default      | Notes                                                          |
|------------------|----------------------------|--------------|----------------------------------------------------------------|
| `year`           | int                        | —            | Required.                                                      |
| `month`          | int                        | —            | Required. 1..12.                                               |
| `cell-height`    | length                     | `3.3cm`      | Height of each day cell.                                       |
| `cell-width`     | length / fraction          | `3.5cm`      | Width of each day cell. Use `1fr` to fit the page width.       |
| `week-start`     | str                        | `"mon"`      | `"mon"` or `"sun"`.                                            |
| `rotated`        | bool                       | `false`      | Rotate 90° (useful for portrait A4).                           |
| `weekday-names`  | array of 7 strings         | `none`       | Override header labels for localization.                       |
| `header-fill`    | color                      | `luma(230)`  | Background of the weekday header row.                          |
| `today-fill`     | color                      | `luma(220)`  | Background of the cell matching `today`.                       |
| `today`          | datetime or `none`         | `none`       | Highlight the matching day, if in this month.                  |
| `events`         | `((datetime, content),)`   | `()`         | Each event renders below the day number in its matching cell.  |
| `week-numbers`   | bool                       | `false`      | Prepend an ISO 8601 week-number column.                        |
| `week-number-width` | length                  | `0.8cm`      | Width of the week-number column when shown.                    |
| `stroke`         | stroke                     | `0.5pt`      | Cell border.                                                   |
| `inset`          | length                     | `3pt`        | Cell padding.                                                  |
| `cell-content`   | `(datetime) -> content`    | built-in     | Override per-cell rendering. Receives a `datetime`.            |

### `year-grid(year, columns: 3, cell-height: 0.55cm, inset: 1pt, month-label-size: 9pt)`

Lay out all twelve months of `year` on one page, three columns by four rows
by default. Composes twelve small `month-grid` calls.

### `is-leap-year(year)`

Returns `true` for Gregorian leap years (divisible by 4 but not by 100,
unless also divisible by 400). Exposed for user code that needs the same
predicate the grid uses internally.

## Notes

- `weekday-names`, when overridden, must be in the same order as `week-start`.
  For `week-start: "sun"`, the array starts with the Sunday label.
- ISO 8601 week numbers are always anchored to the row's Monday, even in
  Sunday-first layouts.

## Inspirations

The API borrows patterns from established LaTeX calendar packages:

- **`events`** parameter — TikZ calendar's `\if (equals: <date>) { ... }` conditional rendering.
- **`today`** highlight — wallcalendar's `\today` macro.
- **`weekday-names`** — wallcalendar's localization hooks.
- **`week-numbers`** — wallcalendar's ISO 8601 week column.
- **`year-grid`** — TikZ calendar's `month list` layout.
- **`cell-content` receiving a `datetime`** — TikZ calendar's date conditions (`Monday`, `weekend`).

## Examples

| File                                                          | What it shows                                                       |
|---------------------------------------------------------------|---------------------------------------------------------------------|
| [`basic.typ`](examples/basic.typ)                             | Minimal usage, leap year, Sunday-first weeks, custom-cell rotation. |
| [`workout-log.typ`](examples/workout-log.typ)                 | Rotated A4 monthly training log with large handwriting cells.       |
| [`habit-tracker.typ`](examples/habit-tracker.typ)             | Daily habit checkboxes per cell.                                    |
| [`weekend-shading.typ`](examples/weekend-shading.typ)         | Grey-shade Sat/Sun by inspecting `date.weekday()` in the callback.  |
| [`training-calendar.typ`](examples/training-calendar.typ)     | `events` and `today` highlight — peak/deload/race periodization.    |
| [`wall-calendar.typ`](examples/wall-calendar.typ)             | ISO 8601 week-number column in a wall-calendar layout.              |
| [`leap-year.typ`](examples/leap-year.typ)                     | Leap-year handling (Feb 2024 vs Feb 2025) and `is-leap-year`.       |
| [`year-at-a-glance.typ`](examples/year-at-a-glance.typ)       | All twelve months on one A4 via `year-grid`.                        |

Compile any of them locally:

```bash
typst compile --root . examples/training-calendar.typ
```

## License

MIT. See `LICENSE`.
