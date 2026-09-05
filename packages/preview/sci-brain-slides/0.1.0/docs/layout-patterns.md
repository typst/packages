# Layout guide

Import the package and bind a theme once:

```typst
#import "@preview/sci-brain-slides:0.1.0": *
#let deck = setup(theme: "academic")
#let pal = deck.palette
#let sizes = deck.sizes
#let (spread, twocol, hero, punch) = deck.layouts
#let (figbox, rail_pull, callout, data_table) = deck.gadgets
#show: deck.theme.with(config-info(title: [My talk]))
```

Choose the names you need from the dictionaries. In Typst markup, call a
function stored in a dictionary as `#(deck.gadgets.rail_pull)[...]`, or bind it
to a local name as above.

## Layouts

Every layout arranges content inside a slide. Use `== Heading` to start one.
The [starter](../template/main.typ) uses four layouts in a complete scientific
talk. The [gallery](../gallery.typ) includes all nine; its layout section starts
on PDF page 10.

| Function | Arguments | Purpose |
|---|---|---|
| `spread` | `fig, text, ratio: (2fr, 1fr)` | Wide figure with a narrower interpretation column |
| `twocol` | `left, right, gutter: 20pt` | Two equal columns |
| `threecol` | `a, b, c, gutter: 16pt` | Three equal columns |
| `hero` | `body` | A centered statement within 80% of the available width |
| `band` | `..items, gutter: 14pt` | One row of equal-width items |
| `cards` | `..items, cols: 2, gutter: 8pt` | A grid of bordered cards |
| `card` | `body` | A single bordered card |
| `punch` | `number, desc, label: none, unit: none` | A large statement with an emphasized quantity |
| `centered_figure` | `body, caption: none` | A centered visual and caption |

```typst
== What changes with more samples?
#spread(
  figbox([Standard error], image("error.svg", width: 100%),
    caption: [Compare bar lengths at the same scale.]),
  [#rail_pull[Four times the samples halves the uncertainty.]],
)
```

`hero` centers within the space supplied by its parent. For custom alignment in an explicit slide, use its `setting` callback. A nested `punch` respects the container's width.

## Callouts, figures, and labels

All labels preserve the case you write. No component forces uppercase text.

| Function | Arguments |
|---|---|
| `rail_pull` | `body` |
| `callout` | `label, body, kind: "info", height: auto` |
| `codebox` | `body, size: sizes.normal` |
| `quote_pull` | `body, source: none` |
| `figbox` | `title, body, caption: none` |
| `portrait` | `src, name, size: 64pt` |
| `clip_image` | `src, top: 0pt, bottom: 0pt, left: 0pt, right: 0pt, width: auto` |
| `badge` | `label, fill: pal.primary, fg: auto` |
| `tag` | `label` |
| `time_badge` | `label` |
| `kicker` | `label` |

`codebox` uses monochrome code text so its contrast follows every palette.

`callout` kinds are `info`, `success`, `warning`, `danger`, and `accent`. An
unrecognized kind uses the accent color. Pass the same `height` to sibling
callouts when their bottom edges should align. Keep enough room for the text.

`portrait` and `clip_image` take content such as `image("figure.svg")`, evaluated
in the caller's project. They reject path strings. A portrait sizes and crops an
image to a square; its caption can use the full column width. Crop distances are
Typst lengths. `clip_image` accepts figures drawn directly in Typst too.

`badge` selects black or white text for its actual fill. Supply `fg` only when
you need an explicit override.

## Numbers and tables

`stat(value, label, unit: none)` formats one quantity as a statement.
`stat_row(..items)` makes a row; each item has `value`, `label`, and optional
`unit` fields:

```typst
#let (stat_row,) = deck.gadgets
#stat_row(
  (value: [16], unit: [samples], label: [averaged together]),
  (value: [4×], label: [lower standard error]),
)
```

`spec_list(..items)` takes records with `term`, `desc`, and optional `tag`.

`data_table(..rows, highlight: ())` takes a header row followed by body rows.
Every row must have the same number of cells. `highlight` contains zero-based
body-row indices. The first column is left-aligned; value columns use centered
monospace text. Both string and content headers preserve the case you write.

```typst
#data_table(
  ("Samples", "Standard error"),
  ("4", "0.50 σ"),
  ("16", "0.25 σ"),
  highlight: (1,),
)
```

Keep tables small enough to read at the default 20 pt. They do not reduce their
font size to fit a slide.

## Theory and conclusions

`theorem`, `definition`, `lemma`, `example`, and `proof_box` all take
`body` and optional `title` content:

```typst
#let (theorem, proof_box) = deck.gadgets
#theorem(title: [Sample mean], [For independent samples, $"SE" = sigma / sqrt(N)$.])
#v(16pt)
#proof_box[Expand the variance and use independence.]
```

`conclusion_grid(..cards, highlight: none)` takes records with `label`, `title`,
and `body`. It uses two columns with equal visual weight by default. To emphasize
a particular card, pass its zero-based index through `highlight`. The gallery
shows four conclusion cards; the starter uses `cards` to compare noise models
and closes with one takeaway in `focus-slide`. `key_links(..pairs)` takes `(label, content)` pairs; use a Typst
`link` element in the content when the destination should be clickable.

## Structure

- `title-slide(config: (:), extra: none, ..args)` uses `config-info` metadata.
  Named arguments override that metadata for this cover. Pass a ready-made
  image for `logo`, with its width set in the caller.
- `focus-slide(body)` displays a statement on the primary color.
- `toc(columns: 1, size: sizes.large)` lists outlined level-one headings, numbered
  by column. `columns` must be a positive integer; empty columns are allowed.
- `pacing(minutes)` places a cumulative rehearsal time at the top right of the
  current body area. Call it once per numbered content slide; reveal pages
  retain the same cumulative time. Minutes must be nonnegative. Reserve the
  top-right area when using it.
- `progress_dots(n, current)` uses a zero-based current index.
- Touying's `pause`, `only`, `uncover`, and configuration functions are re-exported.

## Optional diagrams and annotations

```typst
#import "@preview/cetz:0.4.2": canvas
#let (tensor, automaton-state, edge, flowbox) = cetz-gadgets(pal)
#canvas(length: 1cm, {
  tensor((0, 0), "a", [$A$])
  tensor((3, 0), "b", [$B$])
  edge("a", "b")
})
```

| Helper | Arguments |
|---|---|
| `tensor` | `loc, name, label, radius: 0.45` |
| `automaton-state` | `loc, name, label, accept: false, radius: 0.55` |
| `edge` | `from, to, mark: none, stroke: none` |
| `flowbox` | `loc, name, label` |

Coordinates and node radii are in CeTZ canvas units. Use
`mark: (end: "straight")` for arrows and side anchors such as `"a.east"` and
`"b.west"` for flowboxes. Leave at least 2.5 units between node centers.

```typst
#let (pin, highlight, note) = pin-gadgets(pal, sizes: deck.sizes)
Independent #pin(1)samples#pin(2) are required.
#highlight(1, 2)
#note(2, dx: 0pt, dy: 65pt)[Check for correlation.]
```

`pin(id)` inserts a marker; `highlight(..ids)` marks a span;
`note(id, body, dx: 35pt, dy: 35pt)` attaches a note. Pin identifiers must be
unique within the diagram. Leave space for annotations; they float over content.
