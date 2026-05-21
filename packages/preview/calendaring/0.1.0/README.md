# calendaring

Lay out month calendar grids from a year and month.

A small Typst utility that takes `(year, month)` and renders a 7-column grid
with correct leading and trailing blank days, sized for handwritten notes.
Designed for personal planners and training logs, not for displaying events.

## Install

```typst
#import "@preview/calendaring:0.1.0": month-grid
```

## Basic usage

```typst
#import "@preview/calendaring:0.1.0": month-grid

#month-grid(2026, 6)
```

Renders a Monday-first grid for June 2026 (Mon 1 → Tue 30, two trailing blanks),
with each cell ~3.5cm × 3.3cm and the day number in the top-left.

## Parameters

| Parameter      | Type      | Default          | Notes                                                  |
|----------------|-----------|------------------|--------------------------------------------------------|
| `year`         | int       | —                | Required.                                              |
| `month`        | int       | —                | Required. 1..12.                                       |
| `cell-height`  | length    | `3.3cm`          | Height of each day cell.                               |
| `cell-width`   | length    | `3.5cm`          | Width of each day cell.                                |
| `week-start`   | str       | `"mon"`          | `"mon"` or `"sun"`.                                    |
| `rotated`      | bool      | `false`          | If `true`, rotates 90° (useful for portrait A4 pages). |
| `header-fill`  | color     | `luma(230)`      | Background of the weekday header row.                  |
| `stroke`       | stroke    | `0.5pt`          | Cell border.                                           |
| `inset`        | length    | `3pt`            | Cell padding.                                          |
| `cell-content` | function  | day-number       | `(day-number) => content`. Override to add labels.     |

## Rotated A4 example (training log)

```typst
#set page(paper: "a4", margin: (x: 1.5cm, y: 1.2cm))
#import "@preview/calendaring:0.1.0": month-grid

#align(center, text(16pt)[*June 2026 — Workout Log*])
#v(0.3cm)

#month-grid(2026, 6, rotated: true)
```

## Custom cell content

Pass a function that takes the day number and returns content:

```typst
#let rotation = ("KB-S&C", "KB-cond", "Cardio", "Gym", "Hyrox", "rest", "rest")

#month-grid(2026, 6, cell-content: day => [
  #text(8pt, weight: "bold")[#day]
  #v(2pt)
  #text(7pt, fill: luma(120))[#rotation.at(calc.rem(day - 1, 7))]
])
```

## License

MIT. See `LICENSE`.
