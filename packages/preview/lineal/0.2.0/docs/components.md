# Content components

Import the functions you need from Lineal. They work in a `lineal-theme` slide or
an ordinary Typst document. Content remains selectable text; there are no image
snapshots, extra package dependencies or required fonts.

```typst
#import "@preview/lineal:0.2.0": callout, metric, steps, data-table, comparison
```

Use the local `lib.typ` import when trying an unpublished checkout. Each component
inherits the surrounding font. `size` sets its base text size; most components
default to `1em` to keep the surrounding size. Tables default to `.85em`.
Named colour options let a component fit a custom
palette without changing a global theme. Colours default to Lineal's neutral ink
and deep blue accent.

Components use their available width and natural content height. Put them inside
`grid`, `columns` or Lineal layouts to compose a slide. They do not shrink text or
clip overflowing content. Leave enough room for their content; `data-table` can
continue across document pages and repeats its header.

## Callout

```typst
#callout(title: [Review the source], tone: "info")[
  Keep the measurement conditions beside the result.
]
```

```typst
callout(
  title: none, tone: "info", accent: auto, fill: auto,
  ink: colour.neutral-dark, size: 1em, inset: .8em, radius: .25em,
  body,
)
```

`tone` accepts `"info"`, `"success"`, `"warning"`, `"danger"` or `"neutral"`.
It selects the default accent; an explicit `accent` overrides that colour. The
default background is a light tint of the accent. Set `fill: none` for no
background. `title` is optional. `body` is trailing Typst content.

## Metric

```typst
#grid(columns: (1fr, 1fr), gutter: 1em,
  metric("82%", label: [Less JavaScript], detail: [Median browser transfer]),
  metric(12, label: [Teams onboarded], change: [+3 this quarter]),
)
```

```typst
metric(
  value, label: none, detail: none, change: none,
  accent: colour.primary, ink: colour.neutral-dark, muted: rgb("#626b73"),
  fill: none, size: 1em, value-size: 2.5em, inset: .8em,
  radius: .25em, align: left,
)
```

`value` accepts text, a number or rich Typst content such as `[1.4 s]`. `label`,
`detail` and `change` are optional content. Change text is deliberately explicit:
write `[12% faster]` or `[−4 defects]` to preserve its meaning. Lineal does not
infer whether an increase is good or bad. `value-size` is relative to the base
`size` when expressed in `em`. `align` accepts a Typst alignment.

## Steps

```typst
#steps((
  (title: [Prepare], description: [Gather source material.]),
  (title: [Review], description: [Check measurements and examples.]),
  (title: [Publish], description: [Share the finished presentation.]),
), direction: "horizontal")

#steps(([Draft], [Review], [Approve]), start: 4)
```

```typst
steps(
  items, direction: "vertical", start: 1,
  accent: colour.primary, ink: colour.neutral-dark, muted: rgb("#626b73"),
  marker-ink: white, size: 1em, marker-size: 1.65em,
  gap: .85em, inset: 0pt,
)
```

`items` is a non-empty array. Each item is content or a dictionary with `title`
and optional `description`. Unexpected dictionary keys are rejected to catch
misspelled options. `direction` accepts `"vertical"` or `"horizontal"`.
Horizontal steps share the available width equally. `start` must be a positive
integer. `gap` separates steps; `marker-size` controls the numbered circles.

## Data table

```typst
#data-table(
  ([Route], [Before], [After]),
  (
    ([Home], [1.8 MB], [320 KB]),
    ([Calendar], [1.8 MB], [310 KB]),
    ([Reader], [3.9 MB], [690 KB]),
  ),
  columns: (2fr, 1fr, 1fr),
  align: (left, right, right),
  highlight: (2,),
)
```

```typst
data-table(
  headers, rows, columns: auto, align: left, highlight: (), striped: true,
  accent: colour.primary, ink: colour.neutral-dark,
  header-fill: auto, header-ink: white, fill: white,
  stripe-fill: rgb("#f3f5f6"), highlight-fill: auto,
  rule: rgb("#dce1e4"), size: .85em, inset: (x: .7em, y: .6em),
)
```

`headers` is a non-empty array. `rows` is an array of equally sized arrays. An
empty rows array renders only the header. Cells accept content, strings, integers,
floats, booleans or `none` for an empty cell. Pass formatted content when a value
needs units, a date or a specific number format.

`columns` defaults to equal widths; a custom array must match the header count.
`align` accepts the native Typst table alignment, including one alignment per
column. `highlight` is an array of **zero-based data-row indices**, so `(2,)`
highlights the third data row. Header and highlighted backgrounds take precedence
over stripes. `header-fill: auto` uses `accent`; `highlight-fill: auto` uses a
light tint of `accent`. The header is semantic Typst `table.header` content and
repeats when a table crosses a page.

## Comparison

```typst
#comparison(
  [Find settings across several configuration files.],
  [Set a named option at the call site.],
  labels: ([Current workflow], [Simpler workflow]),
)
```

```typst
comparison(
  before, after, labels: ([Before], [After]), columns: (1fr, 1fr), gap: 1em,
  accent: colour.primary, ink: colour.neutral-dark,
  fill: colour.neutral-light, size: 1em, inset: .8em, radius: .25em,
)
```

Both panels accept arbitrary Typst content: prose, lists, a figure, a metric or a
`code-block`. Their labels can describe alternatives rather than a sequence.
`labels` and `columns` must each have two entries. Panels align at the top and
keep their natural heights. Set `columns: (2fr, 3fr)` for asymmetric examples or
`fill: none, inset: 0pt` for an open layout.

## A custom palette

```typst
#let accent = rgb("#b5d9ff")
#let surface = rgb("#263449")

#callout(
  title: [Local styling], accent: accent, fill: surface, ink: white,
)[
  Rich content keeps its usual Typst behaviour.
]
```

Choose an appropriate `header-ink` for a custom table header, or `marker-ink` for
light step markers. For further working examples, see
[`tests/components.typ`](https://github.com/ellsphillips/lineal/blob/941f266c40b5b24ba881fded1e6a52d6eafec8de/tests/components.typ) and
[`tests/components-custom.typ`](https://github.com/ellsphillips/lineal/blob/941f266c40b5b24ba881fded1e6a52d6eafec8de/tests/components-custom.typ).
