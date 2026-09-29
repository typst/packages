# Changelog

Notable changes to pivot, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/). Pre-1.0, a breaking change can land in
a minor release — each is flagged with a migration note.

## [0.3.0] - 2026-07-22

### Changed

- `flowchart`: spacing is now set separately for the three gaps that matter —
  node to node (`flowchart-node-gap`), an edge to a node it passes
  (`flowchart-edge-clearance`), and edge to edge (`flowchart-lane-gap`). The
  space between two layers also grows when many arrows must fan through it, an
  arrow always has enough straight run to show its arrowhead where it meets a
  node (`flowchart-stub`), and a node with many connections keeps its
  neighbours a little further away (`flowchart-margin-step`).
- `flowchart`: a node that connects only to a distant step — a feed or store
  sitting off to one side — now lines up with that connection, so its line runs
  straight to the target instead of taking a detour around other nodes.
- `flowchart`: edges cross each other far less. A line now prefers the path
  that crosses the fewest others, and the sideways runs sharing the space
  between two rows are stacked in whichever order avoids crossing. 
- `flowchart`: edge right angles are now curved for a softer look. The radius is
  `flowchart-bend-radius`; set it to `0cm` for square corners.
- `flowchart`: a feed or store whose first consumer sits several layers down
  no longer perches at the top of the chart with its line running the whole
  height. It now sits one layer above its nearest consumer, next to the flow
  it joins — short lines instead of page-length ones.
- `flowchart`: a long line arriving at a diamond from the side now enters
  at the diamond's side point.
- `flowchart`: a tall label on a short line could swallow it, leaving just
  the arrowhead poking out. Line lengthened to avoid this.
- `flowchart`: a decision with several arrows in no longer stretches to
  reach them all. A diamond stays label-sized and the arrows bend in to
  meet its sloped faces, keeping its pointed proportion.

### Added

- `flowchart`: `node(.., outline: <colour>)` draws a node as an outline — no fill,
  just the border and the text. Good for terminal or verdict states as green "pass"
  or a red "block".
- `flowchart`: a `"cylinder"` node shape — useful to visualise a feed, 
  database, or log store. It stays upright in both orientations.
- `flowchart`: `group(id, [Title], ..members)` draws a titled box around
  related nodes. `stroke:` is the border style ("dashed" default, "dotted",
  "solid", or a full Typst stroke); `border-color:` sets the line colour; and
  `fill:` tints the box — a solid colour is washed to a gentle tint for you.
  All three are independent.
- `flowchart`: a self-loop — an `edge` from a node back to itself, such as a
  retry or poll step — now draws as a small loop beside the node. A node can
  have a self-loop and other outgoing edges at once; before, that combination
  failed to lay out.
- `flowchart`: `edge(.., label-offset: (x, y))` moves one label off the spot
  the layout chose for it (`+y` up, `+x` right, the same in either
  orientation). The move is applied exactly — you place it where you want it —
  and the label reserves its new position, so the other labels keep clear of
  it. Handy when a label on a short edge or a self-loop sits on its line; for a
  whole crowded area, widen `flowchart-lane-gap` instead.

### Fixed

- `flowchart`: a node with many incoming arrows could be stretched extremely
  wide trying to reach every source. It now widens only as far as it can while
  staying roughly centred over its sources (`flowchart-widen-skew`,
  `flowchart-max-reach`); a source further out than that keeps its place, and
  its arrow bends in to meet the node rather than dragging the node wider.
- `flowchart`: several arrows arriving at one node could land on top of each
  other. Each arrow now arrives at its own point on the node, spaced from the 
  rest, by its own path in.
- `flowchart`: an edge's arrow could land in the space around a node's rounded corner 
  or slanted edge instead of its outline — a node where arrows converge coming out too narrow,
  or an arrow using the bounding box rather than the shape. Node widths are now computed reliably 
  and every edge meets the shape on its outline.
- `flowchart`: edge labels could overlap one another, be struck through by a
  line drawn later, or blank out part of another edge's line. Labels are now
  positioned as a group — each sits clear of the others, of every node, and of
  every other line — and each stays off its own arrowhead, with its line left
  showing on both sides.
- `flowchart`: a node whose connections all reach past its immediate neighbours
  to more distant steps (a feed off to the side, say) could make the whole
  diagram grow wider and wider without ever reaching a stable layout. Such a
  node now stays put, and the diagram lays out normally.
- `flowchart`: several arrows leaving one node could all depart from the
  same point, showing as one line until they diverged. Each now leaves from
  its own point on the node, spaced from the rest.
- `flowchart`: an edge label inside a group box with a `fill:` showed a white
  rectangle behind its text. The label's backing now matches the tint under it.
- `flowchart`: ensure nodes with many connections get breathing room that edges
  avoid. A busy node was able to extend its boundry over an adjacent lane, fixed.


## [0.2.0] - 2026-07-05

### Added

- **`flowchart`** — nodes joined by directed edges, auto-laid-out in either vertical or
  horizontal (`orientation: "horizontal"`). Built from `node(id, label, shape:, fill:)`
  (shapes: rounded / rectangle / diamond / parallelogram) and `edge(from, to, label:)`.
  Node colour is opt-in via `fill:`.
- **`timeline`** — events on an ordered axis, in three orientations: horizontal,
  vertical, and a snaked layout that wraps long runs into curved U-bends. Built
  from `event(title, time:, description:, shape:, fill:)`; a sparse event is a
  title only. A marker takes a shape (circle / square / triangle / diamond) and
  `fill:`.

## [0.1.0] - 2026-06-28

First release: the byte-region family — three views over the same bytes, sharing
one field model so they never disagree on where a field starts.

### Added

- **`packet`** — flat protocol-header view; fields auto-flow and wrap, narrow
  labels become leader callouts, with a deduplicating bit ruler.
- **`struct`** — vertical memory map; box height tracks byte size (oversized
  fields capped with a break mark), hex offsets, sub-byte fields expand in place.
- **`hexdump`** — real bytes + ASCII gutter; annotations you `fill:` are
  highlighted in place, and every annotation is keyed in a byte-range legend.
  `data:` takes `read(f, encoding: none)` or an int array.
- Shared elements `bytes` / `bits` / `gap` / `reserved`, with `at:` (byte offset
  on `bytes`, bit offset on `bits`) and `fill:`.
- **`palette`** — Okabe–Ito colour-blind-safe highlight colours, for `fill:`.
- Theming via a `theme:` dict; built on `@preview/cetz:0.5.2` (Typst ≥ 0.14).

[0.3.0]: https://github.com/cybermallard/typst-pivot/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/cybermallard/typst-pivot/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/cybermallard/typst-pivot/releases/tag/v0.1.0
