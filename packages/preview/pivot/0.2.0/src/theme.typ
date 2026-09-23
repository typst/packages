// Style tokens. Render code reads tokens from a theme dict; no style literals
// live in draw code. `default` is the typeset baseline: monochrome line-art
// (RFC style), which is colour-blind-safe by construction — colour only enters
// when the author sets an explicit `fill:` on a field.

#let default = (
  bit-width: 0.42cm, // width of one bit column
  row-height: 0.8cm, // height of a field box
  row-gap: 0.28cm, // vertical space between rows (floating boxes)
  col-gap: 0.12cm, // horizontal space between adjacent fields (floating boxes)
  strip: 0.4cm, // band above each row, holding the bit-edge numbers
  stroke: 0.6pt + black, // box border
  fill: none, // box fill (overridden per-field by `fill:`)
  gap-stroke: (paint: luma(55%), thickness: 0.5pt, dash: "dashed"), // gap border
  gap-fill: luma(96%), // gap (unparsed-span) fill
  label-size: 9pt, // field-label text size
  bit-size: 7pt, // bit-ruler number size
  bit-color: luma(40%), // bit-ruler number colour
  // The ruler is pinned to an embedded monospace so it stays aligned regardless
  // of the document's label font (which field labels inherit). Embedded = present
  // on every Typst install; override only with a font you know consumers have.
  bit-font: "DejaVu Sans Mono",
  // A field whose label is wider than its box (by more than this padding) gets
  // an exploded callout instead of an inline label.
  label-pad: 0.12cm, // inner breathing room when testing if a label fits its box
  callout-drop: 0.55cm, // headroom from the row down to the first callout label
  callout-bottom: 0.35cm, // space below the last callout label before the next row
  callout-spacing: 1.7cm, // horizontal spacing between callout labels (gap mode)
  callout-gap: 2.3cm, // enlarged inter-row gap below a row that has callouts
  callout-line-height: 0.5cm, // vertical pitch of stacked callout labels (left mode)
  callout-stub: 0.16cm, // left mode: short straight stub for a field over its own label
  callout-side-gap: 0.35cm, // gap between the fields and a label column (each side)
  callout-label-pad: 0.08cm, // gap between a leader's end and its label text
  callout-gap-drop: 0.45cm, // gap mode: label row offset up from the band bottom
  callout-gap-lane-top: 0.22cm, // gap mode: topmost leader lane below the row
  callout-gap-lane-bot: 0.28cm, // gap mode: bottom leader lane above the labels
  callout-gap-leader: 0.18cm, // gap mode: leader end just above the label
  leader-stroke: 0.4pt + luma(50%), // the leader line
  // struct (vertical memory-map) view
  struct-width: 4cm, // width of a struct field box
  struct-byte-height: 0.3cm, // box height per byte, before clamping
  struct-min-height: 0.55cm, // floor so small fields stay legible
  struct-max-height: 2.2cm, // ceiling so a huge field can't run off the page
  struct-offset-gap: 0.25cm, // gap between the offset/size columns and the box
  struct-break-amp: 0.1cm, // break-mark zigzag amplitude (clamped/oversized field)
  struct-break-pitch: 0.26cm, // break-mark zigzag tooth width
  // hexdump (annotated byte dump) view
  hexdump-font: "DejaVu Sans Mono", // grid is monospace, pinned like the bit ruler
  hexdump-size: 10pt, // hex/ASCII grid text (mono)
  hexdump-legend-size: 9pt, // legend text (mono range + name), smaller than the grid
  hexdump-line: 0.5cm, // vertical pitch between dump rows
  hexdump-text-color: black, // hex + ASCII glyphs
  hexdump-offset-color: luma(45%), // the dimmer left offset column
  // Field highlights are opt-in: a hexdump colours only the annotations the
  // author gives a `fill:` (e.g. `palette.orange`); there's no auto-cycle.
  hexdump-legend-gap: 0.5cm, // gap from the dump down to the legend
  hexdump-swatch: 0.3cm, // legend colour-swatch size
  hexdump-legend-rows: 3, // target entries per column (drives the 1->2->3 switch)
  hexdump-legend-cols: 3, // hard cap on legend columns
  hexdump-legend-col-gap: 0.7cm, // horizontal gap between legend columns

  // timeline view (events on an axis)
  timeline-margin: 0.5cm, // breathing room above and below the whole diagram
  timeline-axis-stroke: 1.1pt + luma(40%), // the axis rule and the stems
  timeline-pitch: 3.4cm, // spacing between consecutive events along the axis
  timeline-row-height: 4.2cm, // snaked: vertical pitch between wrapped rows
  timeline-turn-bulge: 3cm, // snaked: how far the U-bend curves out (control offset)
  timeline-edge-nudge: 0.1cm, // snaked: optical inset for a marker flush at an edge
  timeline-marker-size: 0.22cm, // marker radius
  timeline-marker-edge-width: 1.1pt, // marker rim / outline weight
  timeline-marker-edge-darken: 40%, // filled marker: rim = the fill darkened by this (>=3:1)
  timeline-marker-outline: luma(30%), // unfilled (default) marker: a hollow outline
  timeline-marker-fill: white, // hollow marker interior: knocks out the axis behind it (not transparent)
  timeline-stem: 0.35cm, // gap from the marker out to its label
  timeline-text-width: 2.9cm, // wrap width of the time/title/description block
  timeline-text-gap: 0.1cm, // gap between the stem end and the label text
  timeline-time-size: 9pt, // the time/date line (matches the title size)
  timeline-title-size: 9pt, // the event title
  timeline-desc-size: 8pt, // the description
  timeline-time-color: luma(35%), // dimmer time/date (7:1 on white, AA)
  timeline-text-color: black, // title + description

  // flowchart (nodes joined by directed edges)
  flowchart-node-pad-x: 0.45cm, // horizontal padding around a node label
  flowchart-node-pad-y: 0.3cm, // vertical padding around a node label
  flowchart-node-min-width: 1.5cm, // floor width so small labels still read as boxes
  flowchart-node-gap: 0.7cm, // horizontal gap between nodes sharing a rank
  flowchart-rank-gap: 1.3cm, // vertical gap between ranks (layers)
  flowchart-back-margin: 0.6cm, // gap from the diagram to a long/back edge's side channel
  flowchart-back-gap: 0.45cm, // spacing between stacked back-edge channels
  flowchart-node-edge-width: 1.1pt, // node border weight (matches timeline marker rim)
  flowchart-node-edge-darken: 40%, // filled node: border = the fill darkened by this
  flowchart-node-outline: luma(25%), // unfilled node: border colour
  flowchart-node-fill: none, // node fill (opt-in per node via fill:)
  flowchart-label-size: 9.5pt, // node label text
  flowchart-label-color: black, // node label
  flowchart-decision-scale: 1.9, // a diamond grows this much around its label
  flowchart-io-slant: 0.35cm, // parallelogram lean (io nodes)
  flowchart-edge-width: 0.9pt, // edge line weight
  flowchart-edge-color: luma(40%), // edge line + arrowhead
  flowchart-arrow-scale: 1.4, // arrowhead size
  flowchart-edge-label-size: 8.5pt, // branch-label text on an edge
  flowchart-edge-label-color: luma(30%), // branch label
  flowchart-edge-label-fill: white, // knockout behind a branch label, so it reads over the line
  flowchart-edge-label-inset: (x: 3pt, y: 1pt), // padding inside that knockout
)
