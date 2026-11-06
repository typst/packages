#import "bridge.typ": bridge
#import "layout.typ": is-block
#import "shapes.typ": text-block, trim-text-block
#import "scroll.typ": wide, scroll
#import "css.typ": size, repeated, tracks, paint, sides, alignment-styles, direction, fold-alignment
#import "stroke.typ": stroke-html
#import "grid-strokes.typ": resolve-strokes
#import "grid-layout.typ": resolve, field, normalize
#import "flow.typ": flow-attrs, flow-style

#let per-cell(value, x, y, default: auto) = {
  if type(value) == function { value(x, y) }
  else if type(value) == array {
    if value.len() == 0 { default } else { value.at(calc.rem(x, value.len())) }
  } else { value }
}

#let inherited(own, outer) = if own == auto { outer } else { own }

#let axis-tracks(values, gutters, count, interleave) = {
  let result = ()
  for i in range(count) {
    result.push(repeated(values, i))
    if interleave and i + 1 < count { result.push(repeated(gutters, i, default: 0pt)) }
  }
  tracks(result)
}

#let cell-html(cell, options, col-step, row-step, row-tracks) = {
  let node = cell.node
  let x = cell.x
  let y = cell.y
  let styles = (
    "box-sizing: border-box", "min-width: 0",
    "grid-column: " + str(x * col-step + 1) + " / span " + str(cell.w * col-step - (col-step - 1)),
    "grid-row: " + str(y * row-step + 1) + " / span " + str(cell.h * row-step - (row-step - 1)),
    "display: grid", "grid-template-columns: minmax(0, 1fr)",
  )
  let fill = inherited(field(node, "fill", auto), per-cell(options.fill, x, y, default: none))
  if fill != auto and fill != none { styles.push("background: " + paint(fill)) }
  let inset = sides(per-cell(options.inset, x, y, default: (:)), default: 0pt)
  let own-inset = field(node, "inset", auto)
  if own-inset != auto {
    let own = sides(own-inset, default: auto)
    for side in own.keys() {
      if own.at(side) != auto { inset.insert(side, own.at(side)) }
    }
  }
  for (side, value) in inset { styles.push("padding-" + side + ": " + size(value)) }
  let alignment = per-cell(options.align, x, y)
  let own-align = field(node, "align", auto)
  alignment = fold-alignment(alignment, own-align)
  styles += alignment-styles(alignment)
  let breakable = field(node, "breakable", auto)
  if breakable == auto {
    breakable = range(y, y + cell.h).any(i => repeated(row-tracks, i) == auto)
  }
  styles.push("break-inside: " + if breakable { "auto" } else { "avoid" })
  // Realize a native cell with its resolved position so native show-set rules
  // (for example, bold text where y == 0) still style its HTML body.
  show std.grid.cell: resolved => context {
    if target() != "html" { return resolved }
    html.elem("div", attrs: (
    class: "letmeout-grid-cell", style: styles.join("; "),
    "data-grid-x": str(x), "data-grid-y": str(y),
    "data-grid-group": cell.group, "data-grid-repeat": repr(cell.repeat), "data-grid-level": str(cell.level),
  ), html.elem("div", attrs: (class: "letmeout-grid-cell-body", style: "min-width: 0; max-width: 100%; display: flow-root"),
    // Keep inline runs together: separate spans must not become grid items.
    // Block children (especially align) still stretch across the cell.
    if is-block(resolved.body) { resolved.body } else if text-block(resolved.body) { trim-text-block(resolved.body) }
    else { par(resolved.body) }))
  }
  let fields = node.fields()
  let body = fields.remove("body")
  fields.insert("x", x)
  fields.insert("y", y)
  std.grid.cell(body, ..fields)
}

#let grid-line-html(record, columns, rows, col-step, row-step) = {
  let horizontal = record.kind == "hline"
  let index = record.index
  let count = if horizontal { rows } else { columns }
  let cross-count = if horizontal { columns } else { rows }
  let first = record.first
  let last = record.last
  if last == none { last = cross-count }
  let after = record.after
  assert(index <= count and index >= 0 and (not after or index < count),
    message: "letmeout: grid line is outside the grid")
  assert(first >= 0 and last <= cross-count and first < last,
    message: "letmeout: grid line range must fit the grid")
  let step = if horizontal { row-step } else { col-step }
  let cross-step = if horizontal { col-step } else { row-step }
  let at-end = index == count or after
  let logical = if index == count { count - 1 } else { index }
  let cross-axis = if horizontal { "column" } else { "row" }
  let axis = if horizontal { "row" } else { "column" }
  let styles = (
    "position: absolute", "pointer-events: none", "z-index: 2",
    "grid-" + cross-axis + ": " + str(first * cross-step + 1) + " / " + str(last * cross-step - (cross-step - 1) + 1),
    "grid-" + axis + ": " + str(logical * step + 1) + " / " + str(logical * step + 2),
  )
  let value = record.stroke
  if value == none { return [] }
  if horizontal {
    styles.push("width: 100%; height: " + size(value.thickness) + "; " + if at-end { "bottom: 0" } else { "top: 0" })
  } else {
    styles.push("height: 100%; width: " + size(value.thickness) + "; " + if at-end { "inset-inline-end: 0" } else { "inset-inline-start: 0" })
  }
  html.elem("div", attrs: (class: "letmeout-grid-" + record.kind, "aria-hidden": "true",
    "data-grid-index": str(index), "data-grid-after": repr(after),
    "data-grid-first": str(first), "data-grid-last": str(last), style: styles.join("; ")),
    stroke-html(value, vertical: not horizontal, extra: "width: 100%; height: 100%"))
}

#let html-grid(it) = {
  let columns = it.columns
  if columns.len() == 0 { columns = (auto,) }
  let row-tracks = it.rows
  let layout = resolve(normalize(it.children), columns.len(), row-tracks.len())
  let cg = it.column-gutter
  let rg = it.row-gutter
  let col-interleave = cg.len() > 1 or cg.any(v => v == auto or type(v) == fraction)
  let row-interleave = rg.len() > 1 or rg.any(v => v == auto or type(v) == fraction)
  let col-step = if col-interleave { 2 } else { 1 }
  let row-step = if row-interleave { 2 } else { 1 }
  let styles = (
    "display: grid", "position: relative", "min-width: 0", "isolation: isolate",
    "grid-template-columns: " + axis-tracks(columns, cg, columns.len(), col-interleave),
    "column-gap: " + if col-interleave { "0pt" } else { size(repeated(cg, 0, default: 0pt)) },
    "row-gap: " + if row-interleave { "0pt" } else { size(repeated(rg, 0, default: 0pt)) },
  )
  if layout.rows > 0 {
    styles.push("grid-template-rows: " + axis-tracks(row-tracks, rg, layout.rows, row-interleave))
    styles.push("grid-auto-rows: " + size(repeated(row-tracks, layout.rows)))
  }
  let options = (fill: it.fill, inset: it.inset, align: it.align, stroke: it.stroke)
  let cells = layout.cells.map(cell => cell-html(cell, options, col-step, row-step, row-tracks)).join()
  let edges = resolve-strokes(layout, it.stroke, columns.len(), cg, rg)
  let lines = edges.map(record => grid-line-html(record, columns.len(), layout.rows, col-step, row-step)).join()
  html.elem("div", attrs: (class: "letmeout-grid", dir: direction(), lang: text.lang, style: styles.join("; ")), {
    // Flow content packs at the top of a tall cell. Only an explicit align
    // element needs the full row height for vertical alignment.
    html.elem("style", ".letmeout-grid-cell-body:has(> .letmeout-align:only-child) { display: grid !important; }")
    cells + lines
  })
}

// Fractional tracks have a zero minimum in CSS. Once the fixed tracks and
// gutters fit, this grid needs no clipping scrollport around its decorations.
// Automatic tracks depend on intrinsic content, so keep their scroll fallback.
#let minimum-width(it) = {
  if it.columns.any(v => v == auto) { return none }
  let total = 0pt + 0%
  let values = it.columns
  for i in range(calc.max(0, it.columns.len() - 1)) {
    values.push(repeated(it.column-gutter, i, default: 0pt))
  }
  for value in values {
    if type(value) == fraction { continue }
    if value == auto { return none }
    total += value
  }
  if total.ratio >= 100% { return none }
  total.length.to-absolute() / (1 - total.ratio / 100%)
}

#let render-grid(it) = html.elem("letmeout-grid-flow", attrs: flow-attrs() + (style: "display: flow-root; min-width: 0; " + flow-style()), if wide(it) {
  scroll(html-grid(it), minimum: minimum-width(it))
} else { html-grid(it) })

// Generated by scripts/api-docs.py from the Typst 0.15.1 docs of `grid`,
// https://typst.app/docs/reference/layout/grid/. Edit scripts/api.toml, not this block.
/// Arranges content in a grid.
///
/// The grid element allows you to arrange content in a grid. You can define the number
/// of rows and columns, as well as the size of the gutters between them. There are
/// multiple sizing modes for columns and rows that can be used to create complex
/// layouts.
///
/// While the grid and table elements work very similarly, they are intended for
/// different use cases and carry different semantics. The grid element is intended for
/// presentational and layout purposes, while the `table` element is intended for, in
/// broad terms, presenting multiple related data points. Set and show rules on one of
/// these elements do not affect the other. Refer to the Accessibility Section to learn
/// how grids and tables are presented to users of Assistive Technology (AT) like screen
/// readers.
///
/// #quote(block: true)[*Note:* A CSS Grid. Paged output is Typst's native grid,
/// unchanged. Use `std.grid` for set and show rules, and `letmeout-extras.grid-cell`,
/// `letmeout-extras.grid-hline`, `letmeout-extras.grid-vline`,
/// `letmeout-extras.grid-header`, and `letmeout-extras.grid-footer` for its elements.]
///
/// - columns (auto, int, relative, fraction, array): The column sizes.
///
///   Either specify a track size array or provide an integer to create a grid with that
///   many `auto`-sized columns. Note that opposed to rows and gutters, providing a
///   single track size will only ever create a single column.
///
///   See the track size section above for more details.
///
///   Default: `()`. \
///   #quote(block: true)[*Note:* In HTML, CSS column tracks. `auto` sizes to the
///   content, fractions share the free width as `minmax(0, Nfr)`, and lengths and
///   percentages keep their units. A count creates that many automatic columns; an
///   empty array gives one automatic column.]
///
/// - rows (auto, int, relative, fraction, array): The row sizes.
///
///   If there are more cells than fit the defined rows, the last row is repeated until
///   there are no more cells.
///
///   See the track size section above for more details.
///
///   Default: `()`. \
///   #quote(block: true)[*Note:* In HTML, CSS row tracks, with the same sizing modes as
///   columns. The last definition repeats for additional rows; an empty array gives
///   automatic rows. Explicit rows and otherwise empty slots still receive cells and
///   styling. Percentage row heights follow browser block-size resolution, not a PDF
///   page height.]
///
/// - gutter (auto, int, relative, fraction, array): The gaps between rows and columns.
///   This is a shorthand to set `column-gutter` and `row-gutter` to the same value.
///
///   If there are more gutters than defined sizes, the last gutter is repeated.
///
///   See the track size section above for more details.
///
///   Default: `()`. \
///   #quote(block: true)[*Note:* In HTML, CSS gaps. Varying, `auto`, or fractional
///   gutters become tracks between the content tracks. The last entry repeats; an empty
///   array means zero. Axis-specific gutter settings take precedence.]
///
/// - column-gutter (auto, int, relative, fraction, array): The gaps between columns.
///
///   Default: `()`. \
///   #quote(block: true)[*Note:* In HTML, like `gutter`, between columns. Takes
///   precedence over `gutter`.]
///
/// - row-gutter (auto, int, relative, fraction, array): The gaps between rows.
///
///   Default: `()`. \
///   #quote(block: true)[*Note:* In HTML, like `gutter`, between rows. Takes precedence
///   over `gutter`.]
///
/// - inset (relative, array, dictionary, function): How much to pad the cells’ content.
///
///   To specify a uniform inset for all cells, you can use a single length for all
///   sides, or a dictionary of lengths for individual sides. See the box’s
///   documentation for more details.
///
///   To specify varying inset for different cells, you can:
///
///   - use a single inset for all cells
///   - use an array of insets corresponding to each column
///   - use a function that maps a cell’s position to its inset
///
///   See the styling section above for more details.
///
///   In addition, you can find an example at the `table.inset` parameter.
///
///   Default: `(:)`. \
///   #quote(block: true)[*Note:* In HTML, cell padding: one length for all sides, or a
///   dictionary with `top`, `right`, `bottom`, `left`, `x`, `y`, and `rest`. Explicit
///   sides override axis shorthands, which override `rest`; missing grid sides use
///   zero. Arrays cycle by column and functions receive zero-based `(x, y)`, including
///   empty cells. An empty array uses zero padding. Cell inset overrides named sides.]
///
/// - align (auto, array, function, alignment): How to align the cells’ content.
///
///   If set to `auto`, the outer alignment is used.
///
///   You can specify the alignment in any of the following fashions:
///
///   - use a single alignment for all cells
///   - use an array of alignments corresponding to each column
///   - use a function that maps a cell’s position to its alignment
///
///   See the styling section above for details.
///
///   In addition, you can find an example at the `table.align` parameter.
///
///   Default: `auto`. \
///   #quote(block: true)[*Note:* In HTML, text alignment and CSS alignment inside each
///   cell, on both axes. `left`/`right` are physical; `start`/`end` follow text
///   direction. `top`/`horizon`/`bottom` use available row height. Arrays cycle by
///   column and functions receive zero-based `(x, y)`, including empty cells. An empty
///   array adds no alignment; a cell override replaces only its specified axes.]
///
/// - fill (none, color, gradient, tiling, array, function): How to fill the cells.
///
///   This can be:
///
///   - a single color for all cells
///   - an array of colors corresponding to each column
///   - a function that maps a cell’s position to its color
///
///   Most notably, arrays and functions are useful for creating striped grids. See the
///   styling section above for more details.
///
///   Default: `none`. \
///   #quote(block: true)[*Note:* In HTML, CSS backgrounds. Colours and linear, conic,
///   and radial gradients work; tilings, off-center radial focal circles, and
///   parent-relative gradients fail with an error. `none` is transparent. Arrays cycle
///   by column and functions receive zero-based `(x, y)`, including empty cells. An
///   empty array is transparent. Cell `auto` inherits the grid fill; cell `none`
///   removes it. Colors follow the document's color scheme.]
///
/// - stroke (none, length, color, gradient, stroke, tiling, array, dictionary,
///     function):
///   How to stroke the cells.
///
///   Grids have no strokes by default, which can be changed by setting this option to
///   the desired stroke.
///
///   If it is necessary to place lines which can cross spacing between cells produced
///   by the `gutter` option, or to override the stroke between multiple specific cells,
///   consider specifying one or more of `grid.hline` and `grid.vline` alongside your
///   grid cells.
///
///   To specify the same stroke for all cells, you can use a single stroke for all
///   sides, or a dictionary of strokes for individual sides. See the rectangle’s
///   documentation for more details.
///
///   To specify varying strokes for different cells, you can:
///
///   - use a single stroke for all cells
///   - use an array of strokes corresponding to each column
///   - use a function that maps a cell’s position to its stroke
///
///   See the styling section above for more details.
///
///   Default: `(:)`. \
///   #quote(block: true)[*Note:* In HTML, vector edges painted by CSS, with thickness,
///   caps, dashes, and gradients. Accepts `paint`, `thickness`, `cap`, `join`, `dash`
///   (including `array`/`phase`), and `miter-limit`, or side dictionaries using
///   `top`/`right`/`bottom`/`left`, `x`/`y`/`rest`. Arrays cycle by column and
///   functions receive zero-based `(x, y)`, including empty cells; an empty array adds
///   no edges. Explicit separators override cell strokes, which override grid strokes;
///   explicit `none` erases an edge. Later separators win; equal-priority cell edges
///   use the thicker stroke. See docs/html-semantics.md for every stroke field.]
///
/// - children (content, ...): The contents of the grid cells, plus any extra grid lines
///   specified with the `grid.hline` and `grid.vline` elements.
///
///   The cells are populated in row-major order.
///
///   This parameter is positional. \
///   #quote(block: true)[*Note:* In HTML, cells in row-major order. The page source
///   follows the visual order, so screen readers read cells as they appear. Headers and
///   footers render once: a screen has no page boundaries to repeat them at. Cell
///   `x`/`y`, `colspan`/`rowspan`, `fill`/`inset`/`align`/`stroke`, and `breakable`,
///   separator `x`/`y`/`start`/`end`/`position`/`stroke`, and header/footer
///   `repeat`/`level` are documented individually in docs/html-semantics.md. Nested
///   supported layouts remain selectable HTML.]
///
/// -> content
#let grid(..args) = bridge(std.grid(..args), std.grid, render-grid)
