# better-numbering

`better-numbering` is a typst package for improved figure/table/equation/math.equation/custom-kind numbering.

This package primarily modifies the numbering of figures and equations to automatically update based on sections and reset counters when entering new sections. Additionally, it allows users to customize the depth and format of numbering. It supports element types such as `image`, `table`, `raw`, `math.equation`, and custom `figure(kind: ...)`.

Chapter/section-aware numbering utilities for Typst (Typst ≥ 0.13).

This package provides consistent figure/table/raw + equation + custom figure.kind numbering with:
- configurable prefix depth,
- correct cross-chapter references,
- and safe “re-installation” (you can apply the package multiple times in one document with different styles).

## Quick start

```typst
#import "@preview/better-numbering:0.0.1": *

#show: better-numbering.with(
  fig-depth: 2,
  eq-depth: 2,
  fig-outline: "1.1",
  eq-outline: "1.1",
)
````

Then use normal `#figure(...) <label>` and `@label` references.

## Features

### 1) Configurable display properties

* `fig-outline`: figure numbering pattern
* `fig-depth`: figure prefix depth to display 
* `fig-color`: figure prefix color
* `eq-outline`: equation numbering pattern
* `eq-depth`: equation prefix depth to display 
* `eq-color`: equation prefix color
* `reset-figure-kind`: list of figure kinds to reset numbering on new sections, e.g. `(image, table, raw, "custom-kind")`
* `offset`: heading level offset

### 2) Strict numbering (location-correct)

References use the referenced element’s location to compute the prefix, so chapter/section prefixes are not “polluted” by the reference site.

### 3) Cross-chapter references

You can reference figures from other chapters/sections and still get the correct prefix numbers.

### 4) Custom numbering patterns

Use Typst numbering patterns such as:

* `"1.1"` (decimal)
* `"I.a.1"` (Roman + letter + decimal)

Example:

```typst
#show: better-numbering.with(
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

* `better-numbering(...)`

(Other helper functions live in the internal modules; the intended entrypoint is `better-numbering`.)

