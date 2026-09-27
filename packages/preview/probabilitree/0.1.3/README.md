# probabilitree

Probability trees **n×p**, growing **left-to-right** (the standard reading direction for probability trees). This module is built on [CeTZ](https://typst.app/universe/package/cetz) (`@preview/cetz:0.5.2`). The sources are available on [GitHub](https://github.com/mmaunier/probabilitree).

![Version badge:0.1.3](https://img.shields.io/badge/version-0.1.3-blue)
![Licence badge: MIT](https://img.shields.io/badge/licence-MIT-green)
[![GitHub repository](https://img.shields.io/badge/GitHub-r%C3%A9f%C3%A9rentiel-blue)](https://github.com/mmaunier/probabilitree)

## Features

- Probability trees n×p, growing left-to-right.
- Local overrides for every node and probability (`sn` / `sp`).
- Global and local text styles (weight, italic, small caps, highlight, custom function…).
- Probability labels above, below or on top of the edge (`above`, `below`, `on`, `hybrid`), optionally sloped along the edge.
- In `on` mode, the edge is cut under the label, with transparency preserved.
- Improved error messages for malformed tree data.
- Exact node positions exposed for precise custom labels or annotations (`extra` callback).
- Quick list-based syntax (`proba-tree-short`) to write the tree with Typst lists instead of nested tuples.

## Table of contents

- [Installation](#installation)
- [Quick start](#quick-start)
- [Data structure](#data-structure)
- [Quick tree syntax (`proba-tree-short`)](#quick-tree-syntax-proba-tree-short)
- [API](#api)
- [Node positions (`extra`)](#node-positions-extra)
- [Text styles](#text-styles)
- [Probability positions](#probability-positions)
- [Default tree](#default-tree)
- [Error handling](#error-handling)
- [Dependencies](#dependencies)
- [License](#license)
- [Authors](#authors)

## Installation

```typ
#import "@preview/probabilitree:0.1.3": proba-tree, sn, sp, proba-tree-short
```

If the package is installed locally:

```typ
#import "@local/probabilitree:0.1.3": proba-tree, sn, sp, proba-tree-short
```

## Quick start

```typ
#proba-tree(data: (
  $Omega$,
  (sn($A$, style: (fill: green)), $p$, ($B$, $q$), ($overline(B)$, $1-q$)),
  ($overline(A)$, $1-p$, ($B$, $q$), ($overline(B)$, $1-q$)),
))
```

## `data` structure

Each node is an array `(label, proba, ..children)`:

- `label`: node content (e.g. `$A$`, `[A]`, `"A"`) or a local setting `sn(...)`.
- `proba`: probability shown on the branch (e.g. `$p$`, `$1-p$`) or a local setting `sp(...)`.
- `..children`: zero or more child nodes, with the same structure.

The root has no probability: `$Omega$` is just the label.

```typ
#proba-tree(data: (
  $Omega$,
  (sn($A$, style: (fill: green)), sp($p$, style: (fill: red, weight: "bold")), ($B$, $q$)),
  ($overline(A)$, $1-p$, ($B$, $q$)),
))
```

## Quick tree syntax (`proba-tree-short`)

Writing nested tuples can get verbose. `proba-tree-short` lets you write the same tree with Typst lists — `-` for a node, `+` for the probability of the branch leading to it, alternating and nested:

```typ
#proba-tree-short[
  - $Omega$
    + $p$
    - $A$
      + $q$
      - $B$
      + $1-q$
      - $overline(B)$
    + $1-p$
    - $overline(A)$
      + $q$
      - $B$
      + $1-q$
      - $overline(B)$
]
```

All the `proba-tree` options (`h`, `v`, `proba-position`, `node-style`, `extra`, …) remain available — only the construction of `data` changes. Per-node fine styles (`sn` / `sp`) are not expressible in this syntax: use `proba-tree` directly if you need them.

`proba-tree-short-data` returns the `data` array alone, so you can reuse it in `proba-tree`:

```typ
#let data = proba-tree-short-data[
  - $Omega$
    + $p$
    - $A$
]
#proba-tree(data: data)
```

## API

### `proba-tree(...)`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `h` | `float` | `2.0` | Horizontal stretch of the edges. |
| `v` | `float` | `0.8` | Vertical spacing between branches. |
| `proba-position` | `string` | `hybrid` | Probability placement: `above`, `below`, `on` or `hybrid`. |
| `proba-distance` | `float` | `0.3` | Label distance from the edge. |
| `proba-sloped` | `bool` | `false` | Align probabilities along the edge ("sloped"). |
| `proba-padding` | `length` | `3pt` | In `on` mode, gap between the cut line and the probability bbox. |
| `proba-style` | `dictionary` | `(size: 80%)` | Global style for probabilities (size `80%` is always kept as a base). |
| `node-style` | `dictionary` | `none` | Global style for node labels. |
| `first-child-top` | `bool` | `true` | Put the first listed child on top. |
| `node-padding` | `float` | `0.3` | Gap left around each letter (the edge is not drawn there). |
| `data` | `array` | default Ω tree | The tree to draw. |
| `extra` | `function` | `none` | Callback `(pos, draw) => ...` drawn in the same canvas, receiving the exact position of every node. |

### `proba-tree-short(..options, markup)` — quick list-based syntax

Writes a tree with Typst lists instead of nested tuples (`-` for a node, `+` for the probability of the branch leading to it, alternating and nested). All the `proba-tree` options are forwarded; only `data` is built from the markup.

```typ
#proba-tree-short[
  - $Omega$
    + $p$
    - $A$
]
```

### `sp(content, ...)` — local probability settings

Returns a dictionary usable as a probability in `data`. Any omitted parameter falls back to the global settings.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `content` | `content` | — | The probability to display (e.g. `$p$`, `1-p`). |
| `position` | `string` | `auto` | `above`, `below`, `on` or `hybrid`. |
| `sloped` | `bool` | `auto` | Align the probability along the edge ("sloped"). |
| `distance` | `number` | `auto` | Label distance from the edge. |
| `style` | `dictionary` | `auto` | Local style merged with `proba-style`. |

```typ
#proba-tree(data: (
  $Omega$,
  ($A$, sp($p$, style: (fill: red, weight: "bold")), ($B$, $q$)),
  ($overline(A)$, $1-p$),
))
```

### `sn(content, ...)` — local node settings

| Parameter | Type | Default | Description |
|---|---|---|---|
| `content` | `content` | — | The node text (e.g. `$A$`, `[A]`, `"A"`). |
| `style` | `dictionary` | `auto` | Local style merged with `node-style`. |

```typ
#proba-tree(data: (
  $Omega$,
  (sn($A$, style: (fill: green, weight: "bold")), $p$, ($B$, $q$)),
  ($overline(A)$, $1-p$),
))
```

## Node positions (`extra`)

`proba-tree` exposes the **exact canvas position of every node**, so you can overlay labels, annotations or lines that align perfectly with the tree — without importing CeTZ yourself.

```typ
#proba-tree(
  data: (
    $Omega$,
    ($F$, $$, ($F$, $$, ($F$, $$), ($P$, $$)), ($P$, $$, ($F$, $$), ($P$, $$))),
    ($P$, $$, ($F$, $$, ($F$, $$), ($P$, $$)), ($P$, $$, ($F$, $$), ($P$, $$))),
  ),
  extra: (pos, draw) => {
    let issues = ("FFF", "FFP", "FPF", "FPP", "PFF", "PFP", "PPF", "PPP")
    for i in range(0, 8) {
      let p = pos.at("N4" + str(i + 1))
      draw.content((p.at(0) + 0.35, p.at(1)), anchor: "west", [$space arrow.long.r space #issues.at(i)$])
    }
  },
)
```

The callback receives two arguments:

- `pos`: a dictionary keyed `N<level><index>` (1-indexed) → `(x, y)` in canvas units. `N11` is the root, `N41` the 1st leaf of a 4-level tree, etc. Indices follow the **visual top-to-bottom order**, whatever the value of `first-child-top`.
- `draw`: the CeTZ `draw` namespace, usable directly (`draw.content`, `draw.line`, …).

## Text styles

Styles apply globally (`proba-style` / `node-style`) or locally (`sp(style:)` / `sn(style:)`). Local keys **override** global ones; the others are preserved.

Accepted keys:

- **All `#text` parameters**: `size`, `fill`, `weight`, `style` (italic), `background`, `font`, `features`, …
- **`smallcaps`** (`bool`): small caps (via the OpenType `smcp` feature).
- **`highlight`** (`color`): highlighting (background box) — works with **text and equations**.
- **`function`** (`content -> content`): custom function applied **last**.

```typ
#proba-tree(
  proba-style: (fill: blue),
  node-style: (size: 11pt, fill: blue),
  data: (
    $Omega$,
    ($A$, $p$, ($B$, sp($q$, style: (highlight: yellow)))),
    ($overline(A)$, $1-p$),
  ),
)
```

## Probability positions

Constants: `above`, `below`, `on`, `hybrid`.

- `above` / `below`: above / below the edge.
- `on`: the probability sits **on** the edge, which is **cut** under the label (no colored background, transparency preserved). The gap between the cut line and the probability is set with `proba-padding`.
- `hybrid` (default): `above` if the branch goes up, `below` if it goes down.

```typ
#proba-tree(proba-position: "on", proba-padding: 5pt)
```

## Default tree

If `data` is omitted, the following tree is drawn: root Ω, with A/Ā (probabilities p/1-p), each leading to B/B̄ (q/1-q).

## Error handling

If a non-root node is missing a probability (i.e., the tuple is malformed), the package now provides a clear error message:

```
proba-tree: non-root node without probability — expected format is (label, proba, ..children). Received: ...
```

This replaces the generic Typst index error, making debugging easier.

## Dependencies

- [CeTZ](https://typst.app/universe/package/cetz) `@preview/cetz:0.5.2`

## License

Distributed under the [MIT License](LICENSE).

```
Copyright (c) 2026 Mikaël MAUNIER and DeepSeek
```

## Authors

- Mikaël MAUNIER
- DeepSeek
- Claude
