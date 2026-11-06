# ratchet

`ratchet` is a typst package for improved figure/table/equation/math.equation/custom-kind numbering.

This package primarily modifies the numbering of figures and equations to automatically update based on sections and reset counters when entering new sections. Additionally, it allows users to customize the depth and format of numbering. It supports element types such as `image`, `table`, `raw`, `math.equation`, and custom `figure(kind: ...)`.

Chapter/section-aware numbering utilities for Typst (Typst ≥ 0.13).

This package provides consistent figure/table/raw + equation + custom figure.kind numbering with:
- configurable prefix depth,
- correct cross-chapter references,
- and safe “re-installation” (you can apply the package multiple times in one document with different styles).

## What's new in 0.0.3

- `figure-groups` configures several families of `figure(kind: ...)` independently.
- Each family has its own heading depth, numbering pattern, color, and reset behavior.
- `figure-number` lets a custom figure renderer place its Ratchet-managed number anywhere in its body.
- Page settings may be applied either before or after `#show: ratchet` without creating a blank first page.
- Repeated Ratchet configurations use stable document locations as session identities, avoiding layout convergence warnings.
- Existing `reset-figure-kinds`, `fig-*`, and `eq-*` configurations remain compatible.

## Quick start

```typst
#import "@preview/ratchet:0.0.3": *

#show: ratchet.with(
  fig-depth: 2,
  eq-depth: 2,
  fig-outline: "1.1",
  eq-outline: "1.1",
)
```

Then use normal `#figure(...) <label>` and `@label` references.

## Features

### 1) Configuration

| Parameter | Default | Purpose |
| --- | --- | --- |
| `offset` | `0` | Offset applied to the heading backbone |
| `init` | `"rebase"` | Start from current headings; also supports `"reset"` and `"keep"` |
| `reset-figure-kinds` | `(image, table, raw)` | Figure kinds using the base figure configuration |
| `fig-depth` | `2` | Base figure numbering depth |
| `fig-outline` | `"1.1"` | Base figure numbering pattern |
| `fig-color` | `none` | Base figure/reference number color |
| `figure-groups` | `()` | Additional independently configured figure families |
| `eq-depth` | `2` | Equation numbering depth |
| `eq-outline` | `"(1.1)"` | Equation numbering pattern |
| `eq-color` | `none` | Equation/reference number color |

### 2) Independent figure groups

Each item in `figure-groups` is a dictionary with four required fields:

| Field | Type | Meaning |
| --- | --- | --- |
| `kinds` | `array` | Kinds sharing this configuration and reset schedule |
| `depth` | `int` | `1` for global, `2` for level-1 headings, `3` for level-1 and level-2 headings |
| `outline` | `str` or function | Typst numbering pattern |
| `color` | `color` or `none` | Color used by references and outlines |

For example, theorem-like figures can use three-level numbering while algorithms use two-level numbering:

```typst
#show: ratchet.with(
  figure-groups: (
    (
      kinds: ("definition", "theorem"),
      depth: 3,
      outline: "1.1.1",
      color: blue,
    ),
    (
      kinds: ("algorithm",),
      depth: 2,
      outline: "A.1",
      color: purple,
    ),
  ),
)
```

Kinds within one group share formatting and reset depth, but each kind still has its own native Typst figure counter. To share one counter, emit the same `kind` and vary the displayed `supplement`.

If a kind appears in more than one group, the last matching group wins. Additional groups also override the base configuration supplied through `reset-figure-kinds` and `fig-*`.

### 3) Custom renderers with `figure-number`

`figure-number(kind, loc: none)` returns the number configured for `kind` at the current figure location. Call it inside the body of a matching figure:

```typst
#import "@preview/ratchet:0.0.3": figure-number, ratchet

#show: ratchet.with(
  figure-groups: (
    (kinds: ("theorem",), depth: 3, outline: "1.1.1", color: blue),
  ),
)

#let theorem(lab: none, body) = {
  let elem = figure(
    block(stroke: blue, inset: 8pt, width: 100%)[
      *Theorem #figure-number("theorem")*
      #body
    ],
    kind: "theorem",
    supplement: [Theorem],
    caption: none,
    outlined: false,
  )
  [#elem #if lab != none { label(lab) }]
}

= Results
== Main theorem

#theorem(lab: "main-theorem")[The custom block body.]

See @main-theorem.
```

For an unnumbered variant, set `numbering: none` on the figure and omit the `figure-number` call from its rendered title.

### 4) Strict numbering (location-correct)

References use the referenced element’s location to compute the prefix, so chapter/section prefixes are not “polluted” by the reference site.

### 5) Cross-chapter references

You can reference figures from other chapters/sections and still get the correct prefix numbers.

### 6) Custom numbering patterns

Use Typst numbering patterns such as:

* `"1.1"` (decimal)
* `"I.a.1"` (Roman + letter + decimal)

Example:

```typst
#show: ratchet.with(
  fig-depth: 3,
  fig-outline: "I.a.1",
)
```

## List of Figures / Tables (outline)

Typst’s `outline` lists *outlined* elements.
`figure` has an `outlined` parameter, so you can exclude unnumbered sub-figures from the list by setting `outlined: false` when `numbering: none`.

```typst
#outline(
  title: [List of Figures],
  target: figure.where(kind: image, outlined: true),
)

#outline(
  title: [List of Tables],
  target: figure.where(kind: table, outlined: true),
)
```

## Public API

- `ratchet(...)`: installs numbering, counter resets, references, and outline handling.
- `figure-number(kind, loc: none)`: obtains the configured number for a custom figure renderer.

Other helper functions live in the internal modules.

## Migrating from 0.0.2

No change is required for existing base figure and equation configurations. Update the import version, then use `figure-groups` only for custom kinds that need settings independent from `fig-*`:

```typst
#import "@preview/ratchet:0.0.3": ratchet
```

Custom packages that previously maintained their own counters can migrate to native `figure(kind: ...)` counters and use `figure-number` for their rendered titles. Ratchet will then manage resets and cross-references directly.
