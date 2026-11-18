// typart — one import for every diagram.
//
//   #import "@preview/typart:0.3.0": *
//
// Each diagram lives in its own file under this directory.
//
// Families:
//   Figures      flowchart + node / edge / group (grid or automatic layout)   panels   loop-ring
//                sequence   network   convnet   convnet3d   autoencoder   rnn   contrastive   prisma
//                kfold   split   windows
//                confusion   checks   layers   annotate   signal (a drawn waveform)
//                packet (bit fields)   timing   graph   pixels (image patch, kernel)
//   Helpers      icon (Font Awesome glyph)   hstack (items in a centred row)
//   List         steps   hlist   cards   swot   hexagons
//   Process      flow   chevron   snake   stairs   timeline   vtimeline   stepper   gantt
//   Cycle        cycle   donut
//   Hierarchy    hierarchy (1 level)   tree (multi-level)
//   Relationship venn   target   radial   arrows (converging/diverging)   opposing   equation   gears
//   Matrix       matrix (2x2 + axes)   pyramid (flip: true -> funnel)
//   Data/poster  kpi   bars   gauges   waffle   pill-steps   process   card-table
//
// Every diagram takes `width` (auto never overflows its container) and `theme`
// (overrides of `default-theme`); `typart-theme(..)` sets the theme for a document and
// `themed(..)` returns the diagrams with a theme applied.
//
// Each diagram below is a thin wrapper that loads its module on first use, so importing
// typart costs the parsing of this file alone.

#import "common.typ": default-theme, fill, palette, typart-theme

// `above` and `below` read better than top and bottom as the place of a flowchart node
#let (above, below) = (top, bottom)

/// A row of `card-table` with its own fill and text colour.
///
/// Parameters:
/// - `cells`: The cells of the row.
/// - `fill`: Fill of the row; `none` takes the table's.
/// - `text-fill`: Text colour of the row; `none` takes the table's.
#let card-row(..args) = { import "table.typ": card-row; card-row(..args) }

/// A table of rounded cells with a coloured header and alternating row tints, filling the width. Every cell in a row takes the height of the tallest one. Wrap a row in `card-row` to give it its own colours.
///
/// Parameters:
/// - `headers`: Header cells; their number sets the number of columns.
/// - `rows`: Rows: an array of cells each, or `card-row(cells, fill: none, text-fill: none)`.
/// - `weights`: Relative column widths, one number per column; `none` = all equal.
/// - `header-fill`: Header colour; `auto` = the palette's first colour.
/// - `row-fills`: Colours the rows alternate through; `auto` = two neutral tints.
/// - `gap`: Space between cells.
/// - `inset`: Cell padding.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let card-table(..args) = { import "table.typ": card-table; card-table(..args) }

/// A Gantt chart that fills the width: task bars with progress, period headers, grid lines and a "today" marker. It works in any unit: `span` is the total number of months, years or weeks.
///
/// Parameters:
/// - `tasks`: `(name, start, end)`, `(name, start, end, progress)` or `(name, start, end, progress, group)` tuples; `progress` is a percentage, `group: false` greys the task out (e.g. papers), and a trailing colour replaces the accent for that task.
/// - `span`: Length of the time axis, in the unit of `start` and `end`.
/// - `grid-step`: A faint vertical line every this many units; `auto` draws one per period boundary.
/// - `today`: Position of the dashed marker; `none` hides it.
/// - `today-label`: Label under the marker.
/// - `periods`: Header labels spread evenly across the span.
/// - `progress-fill`: Fill of the completed part of every bar; `auto` is the task's colour.
/// - `track-fill`: Fill of the rest of every bar; `auto` is a tint of the task's colour.
/// - `row-gap`: Space between task rows.
/// - `period-gap`: Space between the headers and the first task.
/// - `name-width`: Share of the width taken by the task names; names wrap to it.
/// - `gap`: Space between the names and the bars.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let gantt(..args) = { import "gantt.typ": gantt; gantt(..args) }

/// A central ring joined to icon cards on both sides: the first three items go on the left, the rest on the right. Items are `(icon, label)` or `(icon, label, color)`, up to six; the icon is a Font Awesome glyph string or any content. An item without a colour takes the theme's accent. Requires the [Font Awesome 7 Free](https://fontawesome.com) font for glyph icons.
///
/// Parameters:
/// - `items`: One to six cards: `(icon, label)` or `(icon, label, color)`.
/// - `core`: Content inside the ring; `auto` = a heartbeat icon in the ring's colour.
/// - `item-width`: Card width.
/// - `item-height`: Minimum card height; cards grow to fit their text, and the icon badge is as tall as the card.
/// - `core-radius`: Radius of the central ring.
/// - `ring`: Ring colour; `auto` = the palette's red.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let process(..args) = { import "process.typ": process; process(..args) }

/// A pyramid of stacked levels, or a funnel with `flip: true`. Labels share one size that fits every level.
///
/// Parameters:
/// - `levels`: Array of labels or `(label, color)` tuples, top first.
/// - `base`: Width of the widest edge.
/// - `height`: Total height.
/// - `gap`: Space between levels.
/// - `flip`: Widest level on top (a funnel).
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let pyramid(..args) = { import "pyramid.typ": pyramid; pyramid(..args) }

/// One root over a single row of children. The root takes the first palette colour and the children cycle through the rest.
///
/// Parameters:
/// - `root`: Label of the root box.
/// - `children`: Array of labels or `(label, color)` tuples.
/// - `item-width`: Box width.
/// - `item-height`: Minimum box height; all boxes grow to fit the tallest label.
/// - `gap`: Space between children and between the root and the children's row (one length for both).
/// - `root-fill`: Fill of the root; `auto` is the first palette colour.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let hierarchy(..args) = { import "hierarchy.typ": hierarchy; hierarchy(..args) }

/// A vertical numbered list that fills the width. Items without a colour of their own sit on the neutral panel fill, so a `(label, color)` item stands out.
///
/// Parameters:
/// - `items`: Labels, or `(label, color)` pairs.
/// - `gap`: Space between rows, and between a number and its box.
/// - `inset`: Padding inside each box.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let steps(..args) = { import "steps.typ": steps; steps(..args) }

/// Two or three overlapping circles.
///
/// Parameters:
/// - `items`: Two or three labels or `(label, color)` tuples.
/// - `radius`: Radius of each circle.
/// - `transparency`: Transparency of the circle fills, so the overlaps show.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let venn(..args) = { import "venn.typ": venn; venn(..args) }

/// Equal blocks side by side that share the width. All blocks take the height of the tallest label.
///
/// Parameters:
/// - `items`: Labels, or `(label, color)` pairs.
/// - `item-height`: Minimum block height; blocks grow to fit the tallest label.
/// - `gap`: Space between blocks.
/// - `inset`: Padding inside each block.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let hlist(..args) = { import "hlist.typ": hlist; hlist(..args) }

/// Sequential chevrons pointing right, for phases that follow each other.
///
/// Parameters:
/// - `items`: Labels, or `(label, color)` pairs.
/// - `item-width`: Length of each chevron, point included.
/// - `item-height`: Minimum height; grows to fit the tallest label.
/// - `notch`: Depth of the notch and of the point.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let chevron(..args) = { import "chevron.typ": chevron; chevron(..args) }

/// Nodes on a ring joined by curved arrows. Labels share one size that fits every circle.
///
/// Parameters:
/// - `items`: Array of labels or `(label, color)` tuples, clockwise from the top.
/// - `radius`: Ring radius; `auto` grows with the number of items. A minimum: the ring widens until an arrow fits between neighbours.
/// - `node-radius`: Radius of each node circle.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let cycle(..args) = { import "cycle.typ": cycle; cycle(..args) }

/// Concentric rings, outermost first; the last item is the bullseye.
///
/// Parameters:
/// - `items`: Array of labels or `(label, color)` tuples, from the outer ring inwards.
/// - `radius`: Radius of the outermost ring.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let target(..args) = { import "target.typ": target; target(..args) }

/// A 2×2 matrix with optional axis labels.
///
/// Parameters:
/// - `cells`: Exactly four labels or `(label, color)` tuples: top-left, top-right, bottom-left, bottom-right.
/// - `x-axis`: Two labels under the columns.
/// - `y-axis`: Two labels beside the rows, top first.
/// - `item-width`: Cell width.
/// - `item-height`: Minimum cell height; cells grow to fit the tallest label.
/// - `gap`: Space between cells.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let matrix(..args) = { import "matrix.typ": matrix; matrix(..args) }

/// A process that wraps into rows, each row running the opposite way to the one above.
///
/// Parameters:
/// - `items`: Labels, or `(label, color)` pairs.
/// - `columns`: Boxes per row.
/// - `item-width`: Box width.
/// - `item-height`: Minimum box height; boxes grow to fit the tallest label.
/// - `gap`: Space between boxes: one length, or an `(x, y)` pair.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let snake(..args) = { import "snake.typ": snake; snake(..args) }

/// An ascending staircase joined by elbow arrows, for growth or maturity levels.
///
/// Parameters:
/// - `items`: Labels, or `(label, color)` pairs, lowest step first.
/// - `item-width`: Box width.
/// - `item-height`: Minimum box height; boxes grow to fit the tallest label.
/// - `step`: Offset `(right, up)` from one step to the next: one length for both, or a pair. Never less than what keeps the steps apart and the arrows visible.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let stairs(..args) = { import "stairs.typ": stairs; stairs(..args) }

/// Up to three interlocking cogs.
///
/// Parameters:
/// - `items`: One to three labels or `(label, color)` tuples.
/// - `radius`: Outer radius of each cog.
/// - `teeth`: Teeth per cog.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let gears(..args) = { import "gears.typ": gears; gears(..args) }

/// Milestones along a horizontal arrow, alternating above and below it.
///
/// Parameters:
/// - `items`: `(date, label)` or `(date, label, color)` tuples.
/// - `step`: Distance between milestones.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let timeline(..args) = { import "timeline.typ": timeline; timeline(..args) }

/// A multi-level hierarchy, top-down by default, written as a nested list. The root takes the first palette colour and the other nodes the second; `fills` gives your own colours, one per level. Box heights grow to fit wrapped text.
///
/// Parameters:
/// - `root`: A nested list with one top item, or the root node as data.
/// - `dir`: Direction the levels follow: `ttb`, `btt`, `ltr` or `rtl`.
/// - `item-width`: Box width.
/// - `item-height`: Minimum box height; a box grows to fit its label.
/// - `gap`: `(siblings, levels)` space between boxes (one length for both); `auto` is `(1em, 2.2em)`, or `(0.7em, 2.7em)` for sideways trees.
/// - `filled`: Filled boxes; `false` draws outlines in the node's colour.
/// - `fills`: The colours of the levels, root first: `(navy, orange, olive)`. The last one serves every deeper level; `auto` is the first two palette colours. A `#fill(..)` on a node wins.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let tree(..args) = { import "tree.typ": tree; tree(..args) }

/// Boxes around a centre with arrows converging on it, or diverging from it with `diverge: true`.
///
/// Parameters:
/// - `items`: Array of labels or `(label, color)` tuples, clockwise from the top.
/// - `core`: Label of the central circle.
/// - `diverge`: Arrows point away from the centre.
/// - `radius`: Distance from the centre to the boxes. A minimum: it grows until every arrow has room and neighbouring boxes are clear of each other.
/// - `item-width`: Box width.
/// - `item-height`: Minimum box height; all boxes grow to fit the tallest label.
/// - `core-radius`: Radius of the central circle.
/// - `core-fill`: Fill of the centre; `auto` is the theme's line colour.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let arrows(..args) = { import "arrows.typ": arrows; arrows(..args) }

/// Two block arrows facing each other, for contrasts and trade-offs.
///
/// Parameters:
/// - `items`: Exactly two labels or `(label, color)` tuples.
/// - `item-width`: Width of each arrow.
/// - `item-height`: Minimum arrow height; grows to fit the labels.
/// - `notch`: Depth of the arrow point.
/// - `gap`: Space between the two points.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let opposing(..args) = { import "opposing.typ": opposing; opposing(..args) }

/// Boxes joined by `+` signs, with `=` before the last one: A + B = C. `operators` replaces the signs, e.g. `operators: ($xor$, [=])` for plaintext ⊕ keystream = ciphertext.
///
/// Parameters:
/// - `items`: Two or more labels or `(label, color)` tuples; the last one is the result.
/// - `item-width`: Box width.
/// - `item-height`: Minimum box height; all boxes grow to fit the tallest label.
/// - `gap`: Space between boxes, holding the operator.
/// - `operators`: The sign between each pair of boxes; `auto` is `+` between items and `=` before the last.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let equation(..args) = { import "equation.typ": equation; equation(..args) }

/// Stat cards with a headline value and a caption, filling the width. Items are `(value, label)` or `(value, label, color)`.
///
/// Parameters:
/// - `items`: Cards: `(value, label)` or `(value, label, color)`. The value is set at the theme's `large` size, the label at `small`.
/// - `item-height`: Minimum card height; cards grow to fit their content.
/// - `gap`: Space between cards.
/// - `inset`: Card padding.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let kpi(..args) = { import "kpi.typ": kpi; kpi(..args) }

/// A hub joined to numbered pill rows, each with a title, a body and an optional icon. Items are `(title, body)`, `(title, body, icon)` or either with a trailing colour; the icon is a Font Awesome glyph string or any content. Pills grow to fit wrapped text.
///
/// Parameters:
/// - `items`: Steps: `(title, body[, icon][, color])`.
/// - `title`: Hub title.
/// - `hub-body`: Smaller text under the hub title.
/// - `hub-radius`: Radius of the hub.
/// - `node-radius`: Radius of the numbered circles.
/// - `item-width`: Pill width.
/// - `item-height`: Minimum pill height; a pill grows to fit its text.
/// - `gap`: Space between pills.
/// - `hub-gap`: Space between the hub and the pills.
/// - `hub-fill`: Fill of the hub; `auto` is the theme's line colour.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let pill-steps(..args) = { import "pill-steps.typ": pill-steps; pill-steps(..args) }

/// Blocks joined by block arrows: the basic process. `dir: ttb` stacks it top to bottom.
///
/// Parameters:
/// - `items`: Labels, or `(label, color)` pairs.
/// - `dir`: `ltr` runs left to right, `ttb` top to bottom.
/// - `item-width`: Block width.
/// - `item-height`: Minimum block height; blocks grow to fit the tallest label.
/// - `gap`: Space between blocks, which holds the arrow.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let flow(..args) = { import "flow.typ": flow; flow(..args) }

/// A centre joined by spokes to satellite circles.
///
/// Parameters:
/// - `center`: Label of the central circle.
/// - `items`: Array of labels or `(label, color)` tuples, clockwise from the top.
/// - `radius`: Distance from the centre to the satellites. A minimum: it grows until the satellites clear the centre and each other.
/// - `node-radius`: Radius of each satellite.
/// - `core-radius`: Radius of the central circle.
/// - `core-fill`: Fill of the centre; `auto` is the theme's line colour.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let radial(..args) = { import "radial.typ": radial; radial(..args) }

/// A ring split into equal labelled segments, with an optional label in the hole.
///
/// Parameters:
/// - `items`: Array of labels or `(label, color)` tuples, clockwise from the top.
/// - `center`: Content shown in the hole.
/// - `radius`: Outer radius.
/// - `thickness`: Ring thickness.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let donut(..args) = { import "donut.typ": donut; donut(..args) }

/// A coloured header over a tinted body: a horizontal bullet list. Cards in one row share the height of the tallest header and body.
///
/// Parameters:
/// - `items`: `(title, body)` or `(title, body, color)` tuples.
/// - `columns`: Cards per row; `auto` puts them all in one row.
/// - `gap`: Space between cards.
/// - `inset`: Padding inside headers and bodies.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let cards(..args) = { import "cards.typ": cards; cards(..args) }

/// A zig-zag honeycomb strip. The hexagons keep their size; the labels shrink to one shared size that fits.
///
/// Parameters:
/// - `items`: Labels, or `(label, color)` pairs.
/// - `radius`: Centre-to-corner radius of each hexagon.
/// - `gap`: Space between neighbouring hexagons.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let hexagons(..args) = { import "hexagons.typ": hexagons; hexagons(..args) }

/// Strengths, weaknesses, opportunities and threats as a 2×2 of `cards`, in the palette's green, red, sky and amber.
///
/// Parameters:
/// - `strengths`: The body of each card.
/// - `weaknesses`: The body of each card.
/// - `opportunities`: The body of each card.
/// - `threats`: The body of each card.
/// - `titles`: The four headers.
/// - `fills`: The four header colours, in the order of the quadrants; `auto` is the palette's green, red, sky and amber.
/// - `style`: Any `cards` parameter: `gap`, `inset`, `text-size`, `width`, `theme`.
#let swot(..args) = { import "swot.typ": swot; swot(..args) }

/// Labelled horizontal bars with their values: a results table made visual. One series takes one colour (the palette's first); give an item its own colour to highlight it. A value that does not fit inside its bar is drawn right after it.
///
/// Parameters:
/// - `items`: Bars: `(label, value)` or `(label, value, color)`; values are numbers.
/// - `max`: Value of a full bar; `auto` = the largest value.
/// - `unit`: Text appended to every value, e.g. `"%"` or `" ms"`.
/// - `item-height`: Bar thickness.
/// - `gap`: Space between bars.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let bars(..args) = { import "bars.typ": bars; bars(..args) }

/// Progress rings with a headline percentage and a caption. Items are `(value, label)` or `(value, label, color)`, with the value from 0 to 100.
///
/// Parameters:
/// - `items`: Rings: `(value, label)` or `(value, label, color)`; the value is a percentage.
/// - `radius`: Outer radius of each ring.
/// - `thickness`: Ring thickness.
/// - `gap`: Space between rings.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let gauges(..args) = { import "gauges.typ": gauges; gauges(..args) }

/// A grid of squares showing shares of a whole, with a legend. Items are `(label, count)` or `(label, count, color)`; cells beyond the counts stay neutral.
///
/// Parameters:
/// - `items`: Parts: `(label, count)` or `(label, count, color)`; counts are whole cells.
/// - `total`: Number of cells.
/// - `columns`: Cells per row.
/// - `cell`: Side of a cell.
/// - `gap`: Space between cells.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let waffle(..args) = { import "waffle.typ": waffle; waffle(..args) }

/// Numbered milestones on a line with done, current and upcoming states: where a project stands.
///
/// Parameters:
/// - `items`: Labels.
/// - `current`: Index (from 0) of the step in progress: earlier steps are done, later ones upcoming. `items.len()` marks every step done.
/// - `step`: Distance between milestones; labels wrap to it.
/// - `node-radius`: Radius of each numbered circle.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let stepper(..args) = { import "stepper.typ": stepper; stepper(..args) }

/// A vertical timeline that fills the width: cards alternate left and right of a central spine, each facing its date.
///
/// Parameters:
/// - `items`: `(date, label)` or `(date, label, color)` tuples.
/// - `gap`: Space between rows.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let vtimeline(..args) = { import "vtimeline.typ": vtimeline; vtimeline(..args) }

/// Arrows of a flowchart: `edge("a", "b", "c")` chains a -> b -> c. An end without a node of its own becomes a node labelled with its name; the same name twice draws a loop.
///
/// Parameters:
/// - `names`: Two or more node or group names; consecutive pairs are connected. In a flowchart that declares no nodes, every name becomes a box labelled with it. The same name twice draws a loop on that node.
/// - `label`: Content shown on the edge.
/// - `label-pos`: How far along the edge the label sits, `0%` to `100%`; `auto` is the middle of the longest leg.
/// - `marks`: `"->"`, `"<-"`, `"<->"` or `"-"`.
/// - `stroke`: Stroke of this edge; what it leaves out comes from the theme, so `stroke: red` keeps the default thickness and `stroke: 2pt` the default colour.
/// - `dash`: Dash pattern, e.g. `"dashed"`, `"dotted"`.
/// - `route`: `"straight"`, `"hv"`, `"vh"`, `"hvh"`, `"vhv"` (h = horizontal, v = vertical leg) or `"detour"`.
/// - `exit`: Side the edge leaves its first end and reaches its last end by: `left`, `right`, `top` or `bottom`. On a loop, `exit` is the side it sits on.
/// - `enter`: Side the edge leaves its first end and reaches its last end by: `left`, `right`, `top` or `bottom`. On a loop, `exit` is the side it sits on.
/// - `bend`: Curves the edge by this angle; positive bends to the left of the direction of travel.
/// - `via`: Grid points the edge passes through, e.g. `((1.5, 4), (1.5, 0))`; fractions allowed.
#let edge(..args) = { import "flowchart.typ": edge; edge(..args) }

/// A flowchart: nodes, edges and groups, placed by their `(column, row)` positions or automatically.
///
/// Parameters:
/// - `children`: Nodes, edges and groups, in any order.
/// - `dir`: Flow direction for automatic layout and elbow routing: `ltr` or `ttb`.
/// - `gap`: Minimum gap between columns and between rows (one length for both); gaps widen to fit group frames and titles.
/// - `inset`: Default padding inside nodes.
/// - `group-inset`: Space between a group frame and its nodes.
/// - `group-stretch`: Default `stretch` of every group, e.g. `(top, bottom)`.
/// - `title-style`: Text settings for every group title, e.g. `(weight: "regular", size: 1.2em)`.
/// - `caption-style`: Text settings for every node caption, e.g. `(size: 0.8em)`.
/// - `avoid-crossings`: `true` makes an edge whose usual path runs through a node, crosses another edge or lies on it take another shape. It costs time, more so with many edges.
/// - `independent-columns`: `true` lets each lane (columns joined by nodes placed between them) size its own rows, so a tall node in one lane does not stretch the others.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
#let flowchart(..args) = { import "flowchart.typ": flowchart; flowchart(..args) }

/// A dashed frame of a flowchart around the nodes written inside it, named, or lying between two `(column, row)` corners.
///
/// Parameters:
/// - `title`: Title of the frame; `none` for a plain frame.
/// - `members`: What the frame encloses: nodes (and groups) written inside it, names of nodes and earlier named groups, or `(column, row)` corners: `(1, 0), (5, 2)` encloses every node inside that rectangle and every earlier named group whose nodes all lie there.
/// - `name`: Lets edges start or end at the frame.
/// - `fill`: Frame background.
/// - `stroke`: Frame outline; `auto` is a dashed soft line.
/// - `title-pos`: `top` or `bottom`.
/// - `inside`: `true` writes the title inside the frame, centred, instead of on its border.
/// - `stretch`: Edges that grow until they meet another frame or node, or the outer edge of the diagram: `bottom`, `right`, `(bottom, right)`, … Groups stretch in declaration order; `auto` takes the flowchart's `group-stretch`.
/// - `join`: Name of another group; the two frames are drawn as the outline of their union (one shape when they touch).
#let group(..args) = { import "flowchart.typ": group; group(..args) }

/// A box of a flowchart: `node(name, [(column, row)], body, ..)`.
///
/// Parameters:
/// - `name`: Identifier used by edges and groups; unique.
/// - `at-body`: An optional position, then the body. The position is `(column, row)`, a side of the node before (`right`, `left`, `above`, `below`) or `(side, "name")`.
/// - `shape`: `"rect"`, `"pill"`, `"circle"`, `"ellipse"`, `"diamond"`, `"loop"` (an open ellipse with an arrowhead, coloured by `stroke`) or `none` (the content alone).
/// - `fill`: Fill colour; the text takes the colour that reads best on it.
/// - `stroke`: Outline.
/// - `width`: Fixed width (the text wraps inside); `auto` = natural width.
/// - `height`: Minimum height of the shape.
/// - `inset`: Padding; `auto` = the flowchart's `inset`.
/// - `caption`: Content below the shape; edges leaving downwards start under it.
/// - `shift`: `(dx, dy)` offset from the grid point; the grid and the other nodes stay put, the edges follow.
#let node(..args) = { import "flowchart.typ": node; node(..args) }

/// A grid of framed sub-figures, each with an optional caption inside and a number below: a), b), … Items are a body or a `(body, caption)` pair; panels in one row share their height.
///
/// Parameters:
/// - `items`: Panels: a body or `(body, caption)`.
/// - `columns`: Panels per row.
/// - `numbering`: Numbering pattern for the labels below the panels; `none` hides them.
#let panels(..args) = { import "panels.typ": panels; panels(..args) }

/// Items side by side, centred on a common middle line.
///
/// Parameters:
/// - `items`: Items to lay out in a row.
/// - `gap`: Space between items.
#let hstack(..args) = { import "helpers.typ": hstack; hstack(..args) }

/// A glyph from an icon font (Font Awesome 7 Free by default).
///
/// Parameters:
/// - `glyph`: The glyph, e.g. `"\u{f023}"` (any font's codepoint).
/// - `fill`: Glyph colour; `auto` = the current text colour.
/// - `size`: Glyph size.
/// - `font`: Icon font.
#let icon(..args) = { import "helpers.typ": icon; icon(..args) }

/// An open ellipse with an arrowhead around any content, for "repeat" or "continuous" steps. It is an inline box sized by its content, so it has no `width`.
///
/// Parameters:
/// - `body`: Content inside the ring.
/// - `inset`: Space between the content and the ring.
/// - `theme`: The ring takes the theme's `accent` colour and `thick` stroke.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let loop-ring(..args) = { import "loop-ring.typ": loop-ring; loop-ring(..args) }

/// A UML-style sequence diagram: participants across the top, their lifelines, and one arrow per message in time order. Use it for protocols, handshakes and any exchange between parties or system components.
///
/// Parameters:
/// - `participants`: Array of `(name, label)` or `(name, label, color)`; `name` is the string the messages refer to.
/// - `messages`: Array of `(from, to, label)` or `(from, to, label, kind)`, drawn top to bottom. `kind` is `"call"` (solid line, the default) or `"reply"` (dashed line); a message from a participant to itself is a loop beside its lifeline.
/// - `item-width`: Width of a participant box; its height grows to fit the label.
/// - `gap`: Space between participant boxes and minimum distance between consecutive arrows (one length for both); a row grows to fit a wrapped label.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let sequence(..args) = { import "sequence.typ": sequence; sequence(..args) }

/// A fully connected neural network: one column of neurons per layer, every neuron linked to every neuron of the next layer. Layers too large to draw are abbreviated with an ellipsis.
///
/// Parameters:
/// - `layers`: Array of `(count, label)` or `(count, label, color)`: the number of neurons and the caption under the layer (`none` for no caption).
/// - `node-radius`: Radius of a neuron.
/// - `gap`: Space between layers and between the neurons of a layer (one length for both).
/// - `max-nodes`: A layer with more neurons shows this many around a vertical ellipsis.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let network(..args) = { import "network.typ": network; network(..args) }

/// A PRISMA flow diagram for systematic reviews: the records go down a column of steps and what each step leaves out branches to the right. A step is a box or a `(box, excluded)` pair; `stages` label consecutive steps on the left.
///
/// Parameters:
/// - `steps`: Array of steps, top to bottom: a box, or `(box, excluded)` to branch a second box to the right.
/// - `stages`: Array of `(label, count)` or `(label, count, color)`: each stage covers its `count` consecutive steps; the counts must add up to the number of steps.
/// - `item-width`: Width of a box; its height grows to fit the text.
/// - `gap`: Space between the two columns and between steps (one length for both).
/// - `inset`: Padding inside the boxes.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let prisma(..args) = { import "prisma.typ": prisma; prisma(..args) }

/// K-fold cross-validation: one row per fold, split into `k` parts with the validation part highlighted, and an optional held-out test block. Fills the available width.
///
/// Parameters:
/// - `k`: Number of folds (at least 2).
/// - `labels`: Legend labels for the three kinds of block.
/// - `prefix`: Text before each row's number.
/// - `test`: Share of the data held out for testing, as a ratio such as `20%`; drawn at the right of every row.
/// - `item-height`: Height of a row.
/// - `gap`: Space between rows.
/// - `fills`: The colours of the training, validation and test parts, in that order.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let kfold(..args) = { import "kfold.typ": kfold; kfold(..args) }

/// A confusion matrix: actual classes in rows, predicted classes in columns, each cell shaded by its value. With other titles it is a plain labelled heatmap of any square matrix.
///
/// Parameters:
/// - `matrix`: Array of rows of numbers, one row and one column per label.
/// - `labels`: One label per class, used for both rows and columns; they shrink together to fit a cell's width.
/// - `x-title`: Title above the columns (`none` to omit).
/// - `y-title`: Title beside the rows, read bottom to top (`none` to omit).
/// - `cell`: Side of a cell.
/// - `normalize`: Shade and show each cell as a percentage of its row total instead of the raw value (shaded against the largest cell).
/// - `fill`: The colour of the largest value, the others fading to the surface; `auto` is the first palette colour.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let confusion(..args) = { import "confusion.typ": confusion; confusion(..args) }

/// A comparison matrix for related-work sections: methods in rows, criteria in columns, and a check, a cross or a dash in each cell. Set like a booktabs table: three rules, no vertical lines.
///
/// Parameters:
/// - `columns`: Array of header contents; the first heads the label column.
/// - `rows`: Array of rows, each with a label followed by one cell per remaining column: `true` (check mark), `false` (cross), `none` (dash, for unknown or not applicable) or any content shown as is.
/// - `gap`: Vertical padding of every cell.
/// - `fills`: The colours of the check and of the cross, in that order; `auto` is the accent and the palette's red.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let checks(..args) = { import "checks.typ": checks; checks(..args) }

/// A layered architecture or protocol stack: one full-width band per layer, with its name on the left and its components as equal blocks. The first item is the top layer.
///
/// Parameters:
/// - `items`: Array of `(label, blocks)` or `(label, blocks, color)`; `blocks` is an array of contents (a single block takes a trailing comma: `([IP],)`).
/// - `gap`: Space between layers and between the blocks of a layer.
/// - `inset`: Padding inside each band.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let layers(..args) = { import "layers.typ": layers; layers(..args) }

/// Callouts on any content — an image, a plot, another diagram: a dot at each point of interest and a leader line to a label beside the content. Labels on the same side never overlap; a label is pushed below the previous one when their points are close.
///
/// Parameters:
/// - `body`: The content to annotate; it keeps its own size (give an image a `width`).
/// - `notes`: Array of `((x, y), label)`, `((x, y), label, color)` or `(point: (x, y), label: .., color: ..)`; `x` and `y` are ratios of the body's width and height from its top-left corner. Notes with `x` below `50%` are labelled on the left, the others on the right.
/// - `gap`: Space between the body and the labels.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let annotate(..args) = { import "annotate.typ": annotate; annotate(..args) }

/// A convolutional network as stacks of feature maps that shrink and multiply along the network, ending in vectors: the LeNet-style figure. A layer is `(size, channels, label)`; a size of 1 is a vector (dense layer). The caption under each layer adds its shape.
///
/// Parameters:
/// - `layers`: Array of `(size, channels, label)` or `(size, channels, label, color)`: the side of the feature maps, how many there are, and the caption (`none` for the shape alone). A size of 1 draws a vector.
/// - `item-height`: Side of the largest feature map; the others follow the square root of their size.
/// - `gap`: Space between layers, which holds the arrow.
/// - `max-planes`: A layer with more channels draws this many maps.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let convnet(..args) = { import "convnet.typ": convnet; convnet(..args) }

/// A convolutional network as blocks in perspective, the VGG-style figure (`convnet` draws it as feature maps). An item is a stage: `(size, channels, label, repeat)` draws `repeat` layers of that shape, as tall as their feature maps and as thick as their channels. A pooling slab is added wherever the next stage is smaller, a size of 1 is a fully connected layer, and `input` stands an image in front as the first face.
///
/// Parameters:
/// - `stages`: Array of `(size, channels, label)` or `(size, channels, label, repeat)`, with an optional colour: the side of the feature maps, their number, the caption over the stage and how many layers it has. A size of 1 is a fully connected layer.
/// - `input`: Content (an image) drawn in front of the first stage, in the same perspective.
/// - `legend`: The labels of the legend, for the kinds of layer present; `none` hides it.
/// - `pool`: Draws a pooling slab between a stage and a smaller one.
/// - `item-height`: Height of the largest layer; the others follow the square root of their size.
/// - `gap`: Space between stages.
/// - `fills`: The colours of the convolution, pooling and fully connected layers, in that order. A stage's own colour wins.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let convnet3d(..args) = { import "convnet3d.typ": convnet3d; convnet3d(..args) }

/// The branches of a contrastive model. One input fans out into two views that go through the same stages and meet in the loss; several inputs (a Siamese pair, a triplet) take one branch each. A dashed line joins the twins that share weights.
///
/// Parameters:
/// - `inputs`: One input, which feeds two branches, or an array with one input per branch.
/// - `stages`: The stages every branch goes through, as labels or `(label, color)`.
/// - `loss`: The box where the branches meet; `none` leaves them open.
/// - `shared`: The note on the dashed line between twin stages; `none` removes the lines. With one input the first stage makes the views and is not joined.
/// - `item-width`: Width of a box.
/// - `item-height`: Minimum height of a box; boxes grow to fit the tallest label.
/// - `gap`: Space between stages and between branches (one length for both).
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let contrastive(..args) = { import "contrastive.typ": contrastive; contrastive(..args) }

/// An autoencoder: layers as bars whose height follows their size, narrowing to the latent code and widening back. Also the figure for any bottleneck, such as dimensionality reduction or a projection head.
///
/// Parameters:
/// - `layers`: Array of `(count, label)` or `(count, label, color)`: the number of units, shown above the bar, and the caption under it (`none` for no caption).
/// - `item-width`: Width of a bar.
/// - `height`: Height of the largest layer; the others follow the square root of their size.
/// - `gap`: Space between layers.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let autoencoder(..args) = { import "autoencoder.typ": autoencoder; autoencoder(..args) }

/// A recurrent network unrolled in time. Each step is `(input, state, output)`, read bottom to top as it is drawn; `weights` labels the input, recurrent and output arrows, and `folded` adds the compact network with its loop and an arrow that unfolds it.
///
/// Parameters:
/// - `steps`: One item per time step: an input, `(input, state)` or `(input, state, output)`, with an optional colour for the state box. A `none` state shows `cell`.
/// - `cell`: The label of a state that has none of its own.
/// - `weights`: The labels of the input, recurrent and output arrows, e.g. `($U$, $V$, $W$)`.
/// - `folded`: `(input, state, output)` of the folded network, drawn before the steps with its loop and the unfold arrow.
/// - `unfold`: The label over the unfold arrow.
/// - `ellipsis`: Dots before the first step and after the last: the sequence goes on.
/// - `item-width`: Width of a state box.
/// - `item-height`: Height of a state box.
/// - `node-radius`: Radius of the input and output circles.
/// - `gap`: Space between steps and between a state and its input or output (one length for both).
/// - `state-fill`: Fill of the state boxes; `auto` is the first palette colour. A step's own colour wins.
/// - `input-fill`: Fill of the input circles; `auto` is the second palette colour.
/// - `output-fill`: Fill of the output circles; `auto` is the fifth palette colour.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let rnn(..args) = { import "rnn.typ": rnn; rnn(..args) }

/// A signal cut into sliding windows: each window is drawn under the stretch it covers, and overlapping windows take turns on separate rows. The body is any content — a `signal`, an image, a plot.
///
/// Parameters:
/// - `body`: What is segmented; the windows span its width.
/// - `count`: Number of windows.
/// - `overlap`: Share of a window that the next one repeats; `0%` puts them side by side.
/// - `prefix`: Text before each window's number.
/// - `item-height`: Height of a window.
/// - `gap`: Space between the rows of windows.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let windows(..args) = { import "windows.typ": windows; windows(..args) }

/// One bar divided in proportion to its parts: a train / validation / test partition, or the phases of an experimental protocol with their durations (`unit: " min"`). Fills the available width.
///
/// Parameters:
/// - `items`: Array of `(label, value)` or `(label, value, color)`; each part is as wide as its value.
/// - `unit`: Text after each value.
/// - `item-height`: Height of the bar.
/// - `gap`: Space between parts.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let split(..args) = { import "split.typ": split; split(..args) }

/// A short waveform drawn natively, to stand for a signal inside a node, a panel or `windows` without an image file.
///
/// Parameters:
/// - `kind`: `"sine"`, `"square"`, `"sawtooth"`, `"ecg"` (P wave, QRS complex, T wave) or `"ppg"` (systolic peak and dicrotic wave).
/// - `cycles`: Number of periods drawn.
/// - `width`: Width of the waveform.
/// - `height`: Height of the waveform.
/// - `stroke`: Colour, thickness or both; `auto` is the theme's line.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let signal(..args) = { import "signal.typ": signal; signal(..args) }

/// The layout of a packet header, a frame or a register: fields as wide as their bits, wrapped in rows, under a ruler of bit positions. A field that crosses a row continues on the next one; fields of whole rows become one tall box. Fills the available width.
///
/// Parameters:
/// - `fields`: The fields in order, as a term list (`/ name: bits`) or an array of `(label, bits)` or `(label, bits, color)`.
/// - `bits`: Bits per row.
/// - `item-height`: Height of a row.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let packet(..args) = { import "packet.typ": packet; packet(..args) }

/// A digital timing diagram: one row per signal, each written as a string with one character per time step: `0` low, `1` high, `x` unknown.
///
/// Parameters:
/// - `signals`: Array of `(label, levels)` or `(label, levels, color)`; `levels` is a string of `0`, `1` and `x`.
/// - `step`: Width of a time step.
/// - `item-height`: Height of a signal.
/// - `gap`: Space between signals.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let timing(..args) = { import "timing.typ": timing; timing(..args) }

/// A graph: nodes on a ring joined by the edges you write, `"A -- B"` for a link and `"A -> B"` for an arrow. An edge may carry a label, such as a weight, and `nodes` colours the ones you name.
///
/// Parameters:
/// - `edges`: Array of edges: `"A -- B"` (a line) or `"A -> B"` (an arrow), or `(edge, label)` / `(edge, label, color)`. Nodes are created from the names.
/// - `nodes`: Node names to place first, in this order, or `(name, color)` to colour a node.
/// - `layout`: `"circle"` puts every node on the ring; `"star"` puts the first one in the middle.
/// - `radius`: Minimum radius of the ring; it grows so neighbours never touch.
/// - `node-radius`: Radius of a node; `auto` fits the longest name.
/// - `node-fill`: Fill of the nodes without a colour of their own; `auto` is the first palette colour.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let graph(..args) = { import "graph.typ": graph; graph(..args) }

/// A matrix drawn cell by cell: an image patch, a convolution kernel, an S-box, an array. `shade` paints the cells as an image (smallest value black, largest white) and `mark` outlines a window of cells.
///
/// Parameters:
/// - `cells`: Array of rows of equal length; a cell is a number or any content.
/// - `cell`: Side of a cell.
/// - `shade`: `true` shades each cell by its value, as a greyscale image; every cell must then be a number.
/// - `values`: `false` hides the values and leaves the cells.
/// - `mark`: `((row, column), (row, column))`: the first and last cell of a window to outline, counted from 0.
/// - `text-size`: Size of the labels, relative to the surrounding text.
/// - `width`: `auto` keeps the natural size and never overflows the container; a length or a ratio sets the width.
/// - `theme`: Overrides of `default-theme`, e.g. `(accent: gray)`.
/// - `style`: Any key of `default-theme` as a named argument, e.g. `accent: gray`, for this diagram only.
#let pixels(..args) = { import "pixels.typ": pixels; pixels(..args) }

/// Every diagram with a theme applied, at no layout cost; a `theme:` passed to one of
/// them adds to it: `#let (cycle, flow) = themed(accent: gray)`, then `#cycle[..]`.
///
/// - theme (arguments): Keys of `default-theme` with their new values.
/// -> dictionary
#let themed(..theme) = {
  let widgets = (
    annotate: annotate, arrows: arrows, autoencoder: autoencoder, bars: bars, card-table: card-table, cards: cards, checks: checks,
    chevron: chevron, confusion: confusion, contrastive: contrastive, convnet: convnet, convnet3d: convnet3d, cycle: cycle, donut: donut, equation: equation, flow: flow,
    flowchart: flowchart, gantt: gantt, gauges: gauges, gears: gears, graph: graph, hexagons: hexagons, hierarchy: hierarchy,
    hlist: hlist, kfold: kfold, kpi: kpi, layers: layers, loop-ring: loop-ring, matrix: matrix, network: network,
    opposing: opposing, packet: packet, panels: panels, pill-steps: pill-steps, pixels: pixels, prisma: prisma, process: process, pyramid: pyramid,
    radial: radial, rnn: rnn, sequence: sequence, signal: signal, snake: snake, split: split, stairs: stairs, stepper: stepper, steps: steps, swot: swot,
    target: target, timeline: timeline, timing: timing, tree: tree, venn: venn, vtimeline: vtimeline, waffle: waffle, windows: windows,
  )
  let with-theme(widget) = (..args) => widget(..args, theme: theme.named() + args.named().at("theme", default: (:)))
  let plain = (above: above, below: below, card-row: card-row, edge: edge, fill: fill, group: group, hstack: hstack,
    icon: icon, node: node)
  plain + widgets.pairs().map(((name, widget)) => (name, with-theme(widget))).to-dict()
}
