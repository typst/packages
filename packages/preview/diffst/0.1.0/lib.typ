#import "@preview/elembic:1.1.1" as e
#import "typst/style.typ" as style
#import "typst/report.typ" as report
#import "typst/data.typ" as data

/// Default color dictionary for diff reports.
///
/// Merge with this dictionary when overriding report colors.
#let default-colors = style.default-colors

/// Muted color dictionary intended for print-oriented reports.
#let minimal-colors = style.minimal-colors

/// Default table style dictionary.
///
/// Controls column widths, rule style, and stroke widths.
#let default-table-style = style.default-table-style

/// Minimal table style dictionary.
///
/// Keeps only the middle separator and the rule below the header.
#let minimal-table-style = style.minimal-table-style

/// Build a structured diff report from two text strings.
///
/// Use this when composing your own report layout. The returned dictionary
/// contains `old`, `new`, `labels`, `options`, `meta`, `stats`, `ops`, and
/// `rows`.
///
/// - `old`: Old label, kept for compatibility.
/// - `new`: New label, kept for compatibility.
/// - `old-label`: Label stored as `report.labels.old`.
/// - `new-label`: Label stored as `report.labels.new`.
/// - `algorithm`: `"histogram"`, `"myers"`, `"patience"`, `"lcs"`, or `"hunt"`.
/// - `inline`: `"words"`, `"chars"`, or `"none"`.
#let diffst-report = report.diffst-report

/// Compute renderable rows from a report.
///
/// Applies optional line range filtering and either `"collapsed"` or `"full"`
/// display handling.
///
/// - `range`: `auto` or `(start, end)`, using inclusive 1-based line numbers.
/// - `range-side`: `"both"`, `"old"`, or `"new"`.
#let diffst-rows = data.diffst-rows

/// Group report operations into hunks.
///
/// Returns dictionaries with `ops`, `rows`, `old_start`, `old_len`,
/// `new_start`, `new_len`, and context metadata.
#let diffst-hunks = data.diffst-hunks

#let _color(colors, key) = colors.at(key, default: default-colors.at(key))
#let _mono(body, fill: auto) = {
  let args = if fill == auto { (:) } else { (fill: fill) }
  text(..args)[#raw(str(body), block: false)]
}

#let _muted(colors, body) = {
  text(fill: _color(colors, "line-no"))[#body]
}

#let _cell(colors, fill, body, align: left, stroke: auto) = {
  let args = if stroke == auto { (:) } else { (stroke: stroke) }
  table.cell(
    fill: fill,
    inset: (x: 4.5pt, y: 3pt),
    align: align,
    ..args,
  )[#body]
}

#let _line-no(colors, value) = {
  if value == none {
    _muted(colors, "")
  } else {
    _mono(str(value), fill: _color(colors, "line-no"))
  }
}

#let _span-fill(colors, kind) = {
  if kind == "delete" or kind == "delete-marker" {
    _color(colors, "inline-delete")
  } else if kind == "insert" or kind == "insert-marker" {
    _color(colors, "inline-insert")
  } else {
    _color(colors, "inline-equal")
  }
}

#let _span-text-fill(colors, kind) = {
  if kind == "delete-marker" or kind == "insert-marker" or kind == "equal-marker" {
    _color(colors, "marker")
  } else if kind == "delete" {
    _color(colors, "delete-text")
  } else if kind == "insert" {
    _color(colors, "insert-text")
  } else {
    _color(colors, "text")
  }
}

#let _marker-shape(marker, fill) = {
  if marker == "·" {
    circle(radius: 0.75pt, fill: fill)
  } else if marker == "→" {
    polygon(
      (0pt, 1.2pt),
      (2.2pt, 1.2pt),
      (2.2pt, 0.45pt),
      (3.8pt, 1.5pt),
      (2.2pt, 2.55pt),
      (2.2pt, 1.8pt),
      (0pt, 1.8pt),
      fill: fill,
    )
  } else if marker == "↵" {
    [
      #line(start: (3.5pt, 0pt), end: (3.5pt, 3pt), stroke: 0.55pt + fill)
      #line(start: (1pt, 3pt), end: (4pt, 3pt), stroke: 0.55pt + fill)
      #place(dx: 0pt, dy: 1.75pt)[
        #polygon((0pt, 1.25pt), (2pt, 0pt), (2pt, 2.5pt), fill: fill)
      ]
    ]
  } else if marker == "␍" {
    [
      #rect(width: 5pt, height: 5pt, stroke: 0.55pt + fill)
      #line(start: (1pt, 2.5pt), end: (4pt, 2.5pt), stroke: 0.55pt + fill)
    ]
  } else {
    circle(radius: 0.75pt, fill: fill)
  }
}

#let _marker-span(colors, markers, background: none) = {
  let fill = _color(colors, "marker")
  context {
    let column-width = measure(raw(" ", block: false)).width
    for marker in markers.clusters() {
      let shape-width = if marker == "·" { 1.5pt } else if marker == "→" { 3.8pt } else if marker == "␍" { 5pt } else {
        6pt
      }
      let shape-height = if marker == "·" { 1.5pt } else if marker == "→" { 3pt } else { 5pt }
      let baseline-shift = if marker == "·" { 2.35pt } else { shape-height }

      box(width: column-width)[
        #if background == none {
          raw(" ", block: false)
        } else {
          highlight(fill: background)[#raw(" ", block: false)]
        }
        #place(
          dx: (column-width - shape-width) / 2,
          dy: -baseline-shift,
        )[
          #_marker-shape(marker, fill)
        ]
      ]
    }
  }
}

#let _code-span(colors, span) = {
  let is-marker = span.kind == "delete-marker" or span.kind == "insert-marker" or span.kind == "equal-marker"
  let marker-background = if is-marker { _span-fill(colors, span.kind) } else { none }
  let body = if is-marker {
    _marker-span(colors, span.text, background: marker-background)
  } else {
    _mono(span.text, fill: _span-text-fill(colors, span.kind))
  }

  if is-marker or span.kind == "equal" {
    body
  } else {
    highlight(
      fill: _span-fill(colors, span.kind),
    )[#body]
  }
}

#let _code(colors, value, spans: none) = {
  text(top-edge: "bounds", bottom-edge: "bounds")[
    #box(clip: true)[
      #if spans != none {
        for span in spans {
          _code-span(colors, span)
        }
      } else if value == none {
        _mono("")
      } else {
        _mono(value, fill: _color(colors, "text"))
      }
    ]
  ]
}

#let _row-fill(colors, kind) = {
  if kind == "delete" {
    _color(colors, "delete")
  } else if kind == "insert" {
    _color(colors, "insert")
  } else if kind == "replace" {
    _color(colors, "replace")
  } else {
    _color(colors, "equal")
  }
}

#let _pill(fill, fg, body) = box(
  fill: fill,
  inset: (x: 5pt, y: 2pt),
  radius: 2pt,
)[#text(fill: fg)[#strong[#body]]]

#let _stat-info(report, stat) = {
  if stat == "similarity" {
    (
      value: calc.round(report.stats.similarity * 100),
      summary: (
        fill: "collapsed",
        fg: "text",
        label: value => str(value) + "% similar lines",
      ),
    )
  } else if stat == "additions" {
    (
      value: report.stats.additions,
      summary: (
        fill: "insert",
        fg: "insert-text",
        label: value => "+" + str(value),
      ),
    )
  } else if stat == "deletions" {
    (
      value: report.stats.deletions,
      summary: (
        fill: "delete",
        fg: "delete-text",
        label: value => "-" + str(value),
      ),
    )
  } else if stat == "changed-blocks" {
    (
      value: report.stats.changed_blocks,
      summary: (
        fill: "replace",
        fg: "replace-text",
        label: value => str(value) + " changed blocks",
      ),
    )
  } else {
    panic("unknown summary stat: " + stat)
  }
}

#let _summary-label(report, colors: (:)) = {
  let colors = default-colors + colors
  [
    #strong(report.old)
    #_muted(colors, sym.arrow)
    #strong(report.new)
  ]
}

#let _summary-lines(report, colors: (:)) = {
  let colors = default-colors + colors
  _muted(colors, [
    #report.stats.old_lines old lines, #report.stats.new_lines new lines
  ])
}

#let _summary-title(report, colors: (:)) = [
  #_summary-label(report, colors: colors)
]

#let _summary-stat(report, stat, colors: (:)) = {
  let colors = default-colors + colors
  let info = _stat-info(report, stat)
  _pill(
    _color(colors, info.summary.fill),
    _color(colors, info.summary.fg),
    (info.summary.label)(info.value),
  )
}

#let _summary-stats(
  report,
  stats: ("similarity", "additions", "deletions", "changed-blocks"),
  colors: (:),
) = {
  stats.map(stat => _summary-stat(report, stat, colors: colors))
}

#let _summary-stats-line(report, stats, colors: (:)) = [
  #_summary-lines(report, colors: colors)
  #h(1fr)
  #for stat in _summary-stats(report, stats: stats, colors: colors) {
    stat
    [ ]
  }
]

#let _summary(
  colors,
  report,
  title: auto,
  stats: ("similarity", "additions", "deletions", "changed-blocks"),
) = {
  let title = if title == auto {
    _summary-title(report, colors: colors)
  } else {
    title
  }

  [
    #title
    #linebreak()
    #_summary-stats-line(report, stats, colors: colors)
  ]
}

#let _trailing-newline-rows(colors, report) = {
  if report == none or report.meta.old_trailing_newline == report.meta.new_trailing_newline {
    ()
  } else {
    let old-state = if report.meta.old_trailing_newline {
      "old file ends with newline ↵"
    } else {
      "old file has no trailing newline ∅"
    }
    let new-state = if report.meta.new_trailing_newline {
      "new file ends with newline ↵"
    } else {
      "new file has no trailing newline ∅"
    }

    (
      table.cell(colspan: 4, fill: _color(colors, "collapsed"), inset: (x: 4pt, y: 3pt), align: center)[
        #_muted(colors, [#old-state; #new-state])
      ],
    )
  }
}

#let _resolve-table-style(table-style) = {
  if type(table-style) == str {
    if table-style == "default" {
      default-table-style
    } else if table-style == "minimal" {
      minimal-table-style
    } else {
      panic("table-style must be \"default\", \"minimal\", or a table style dictionary")
    }
  } else {
    default-table-style + table-style
  }
}

#let _table-stroke(colors, table-style) = {
  if table-style.rules == "default" {
    (x, y) => (
      paint: _color(colors, "border"),
      thickness: if y == 0 { table-style.stroke-width.header } else { table-style.stroke-width.body },
    )
  } else if table-style.rules == "minimal" {
    none
  } else {
    panic("table-style.rules must be \"default\" or \"minimal\"")
  }
}

#let _minimal-cell-stroke(colors, table-style, column, header: false) = {
  let rule = table-style.stroke-width + _color(colors, "border")
  if header and column == 1 {
    (right: rule, bottom: rule)
  } else if header {
    (bottom: rule)
  } else if column == 1 {
    (right: rule)
  } else {
    none
  }
}

#let _cell-stroke(colors, table-style, column, header: false) = {
  if table-style.rules == "minimal" {
    _minimal-cell-stroke(colors, table-style, column, header: header)
  } else {
    auto
  }
}

#let _split-rule(colors, table-style, column, header: false, top: false) = {
  if table-style.rules == "minimal" {
    _minimal-cell-stroke(colors, table-style, column, header: header)
  } else if table-style.rules == "default" {
    let width = if header { table-style.stroke-width.header } else { table-style.stroke-width.body }
    let rule = width + _color(colors, "border")
    (
      left: if column == 0 { rule } else { none },
      right: rule,
      top: if header or top { rule } else { none },
      bottom: rule,
    )
  } else {
    panic("table-style.rules must be \"default\" or \"minimal\"")
  }
}

#let _sync-cell(colors, fill, body, height: auto, align: left, stroke: auto) = {
  let args = if stroke == auto { (:) } else { (stroke: stroke) }
  table.cell(
    fill: fill,
    inset: 0pt,
    align: align,
    ..args,
  )[
    #box(height: height)[
      #pad(x: 4.5pt, y: 3pt)[#body]
    ]
  ]
}

#let _diff-columns = (
  (title: [Old], side: "old", part: "line", align: right, header-align: center),
  (title: [Content], side: "old", part: "content", align: left, header-align: left),
  (title: [New], side: "new", part: "line", align: right, header-align: center),
  (title: [Content], side: "new", part: "content", align: left, header-align: left),
)

#let _report-label(report, side) = {
  if report == none {
    none
  } else {
    report.at("labels", default: (:)).at(side, default: report.at(side, default: none))
  }
}

#let _column-title(report, col) = {
  let label = _report-label(report, col.side)
  if col.part == "content" and label != none {
    label
  } else {
    col.title
  }
}

#let _row-part(colors, row, side, part) = {
  if side == "old" and part == "line" {
    _line-no(colors, row.at("old_no", default: none))
  } else if side == "new" and part == "line" {
    _line-no(colors, row.at("new_no", default: none))
  } else if side == "old" {
    _code(
      colors,
      row.at("old", default: none),
      spans: row.at("old_spans", default: none),
    )
  } else {
    _code(
      colors,
      row.at("new", default: none),
      spans: row.at("new_spans", default: none),
    )
  }
}

#let _row-prototype(colors, table-style, row) = table(
  columns: table-style.columns,
  stroke: none,
  inset: 0pt,
  .._diff-columns.map(col => _sync-cell(
    colors,
    _row-fill(colors, row.kind),
    _row-part(colors, row, col.side, col.part),
    align: col.align,
  )),
)

#let _header-prototype(colors, table-style, report: none) = table(
  columns: table-style.columns,
  stroke: none,
  inset: 0pt,
  .._diff-columns.map(col => _sync-cell(
    colors,
    _color(colors, "header"),
    strong(_column-title(report, col)),
    align: col.header-align,
  )),
)

#let _single-row-cells(colors, table-style, row) = {
  let fill = _row-fill(colors, row.kind)
  _diff-columns
    .enumerate()
    .map(((column, col)) => _cell(
      colors,
      fill,
      _row-part(colors, row, col.side, col.part),
      align: col.align,
      stroke: _cell-stroke(colors, table-style, column),
    ))
}

#let _single-table(colors, rows, report: none, table-style: default-table-style) = {
  let table-style = _resolve-table-style(table-style)
  table(
    columns: table-style.columns,
    stroke: _table-stroke(colors, table-style),
    inset: 0pt,
    table.header(
      repeat: true,
      .._diff-columns
        .enumerate()
        .map(((column, col)) => _cell(
          colors,
          _color(colors, "header"),
          strong(_column-title(report, col)),
          align: col.header-align,
          stroke: _cell-stroke(colors, table-style, column, header: true),
        )),
    ),
    ..rows
      .map(row => {
        if row.kind == "collapsed" {
          (
            table.cell(colspan: 4, fill: _color(colors, "collapsed"), inset: (x: 4pt, y: 3pt), align: center)[
              #_muted(colors, [#row.hidden unchanged lines hidden])
            ],
          )
        } else {
          _single-row-cells(colors, table-style, row)
        }
      })
      .flatten(),
    .._trailing-newline-rows(colors, report),
  )
}

#let _split-column-table(
  colors,
  table-style,
  rows,
  title,
  side,
  part,
  column,
  heights,
  header: false,
  top-row-border: false,
) = block(width: 100%)[
  #table(
    columns: (100%,),
    stroke: none,
    inset: 0pt,
    ..if header {
      (
        table.header(
          repeat: true,
          _sync-cell(
            colors,
            _color(colors, "header"),
            strong(title),
            height: heights.header,
            align: if part == "line" { center } else { left },
            stroke: _split-rule(colors, table-style, column, header: true),
          ),
        ),
      )
    } else {
      ()
    },
    ..rows
      .enumerate()
      .map(((index, row)) => _sync-cell(
        colors,
        _row-fill(colors, row.kind),
        _row-part(colors, row, side, part),
        height: heights.rows.at(index),
        align: if part == "line" { right } else { left },
        stroke: _split-rule(colors, table-style, column, top: top-row-border and index == 0),
      )),
  )
]

#let _split-normal-table(colors, table-style, rows, report: none, header: false, top-row-border: false) = layout(
  size => {
    let heights = (
      header: measure(_header-prototype(colors, table-style, report: report), width: size.width).height,
      rows: rows.map(row => measure(_row-prototype(colors, table-style, row), width: size.width).height),
    )

    grid(
      columns: table-style.columns,
      gutter: 0pt,
      .._diff-columns
        .enumerate()
        .map(((column, col)) => _split-column-table(
          colors,
          table-style,
          rows,
          _column-title(report, col),
          col.side,
          col.part,
          column,
          heights,
          header: header,
          top-row-border: top-row-border,
        )),
    )
  },
)

#let _full-width-rule(colors, table-style) = {
  if table-style.rules == "default" {
    let rule = table-style.stroke-width.body + _color(colors, "border")
    (left: rule, right: rule, top: rule, bottom: rule)
  } else if table-style.rules == "minimal" {
    none
  } else {
    panic("table-style.rules must be \"default\" or \"minimal\"")
  }
}

#let _full-width-note-row(colors, table-style, body) = table(
  columns: table-style.columns,
  stroke: none,
  inset: 0pt,
  table.cell(
    colspan: 4,
    fill: _color(colors, "collapsed"),
    stroke: _full-width-rule(colors, table-style),
    inset: (x: 4pt, y: 3pt),
    align: center,
  )[
    #_muted(colors, body)
  ],
)

#let _collapsed-row(colors, table-style, row) = {
  _full-width-note-row(colors, table-style, [#row.hidden unchanged lines hidden])
}

#let _trailing-newline-block(colors, table-style, report) = {
  let rows = _trailing-newline-rows(colors, report)
  if rows.len() == 0 {
    none
  } else {
    let row = rows.first()
    table(
      columns: table-style.columns,
      stroke: _table-stroke(colors, table-style),
      inset: 0pt,
      row,
    )
  }
}

#let _diff-table(colors, rows, report: none, table-style: default-table-style) = {
  let table-style = _resolve-table-style(table-style)
  let chunks = ()
  let current = ()

  for row in rows {
    if row.kind == "collapsed" {
      if current.len() > 0 {
        chunks.push((kind: "normal", rows: current))
        current = ()
      }
      chunks.push((kind: "collapsed", row: row))
    } else {
      current.push(row)
    }
  }
  if current.len() > 0 {
    chunks.push((kind: "normal", rows: current))
  }

  stack(spacing: 0pt)[
    #let header = true
    #let after-note = false
    #for chunk in chunks {
      if chunk.kind == "normal" {
        block(above: 0pt, below: 0pt)[
          #_split-normal-table(
            colors,
            table-style,
            chunk.rows,
            report: report,
            header: header,
            top-row-border: after-note,
          )
        ]
        header = false
        after-note = false
      } else {
        block(above: 0pt, below: 0pt)[
          #_collapsed-row(colors, table-style, chunk.row)
        ]
        after-note = true
      }
    }
    #let trailing = _trailing-newline-block(colors, table-style, report)
    #if trailing != none {
      block(above: 0pt, below: 0pt)[#trailing]
    }
  ]
}

#let _debug-field(name, value) = [
  #strong(name)
  #raw(json.encode(value), block: true)
]

/// Render the raw report fields for debugging.
#let diffst-debug(report) = {
  block[
    #_debug-field("report.old", report.old)
    #_debug-field("report.new", report.new)
    #_debug-field("report.labels", report.labels)
    #_debug-field("report.options", report.options)
    #_debug-field("report.meta", report.meta)
    #_debug-field("report.stats", report.stats)
    #_debug-field("report.ops", report.ops)
    #_debug-field("report.rows", report.rows)
  ]
}

/// Render only the summary/header for a report.
///
/// - `title`: Custom title content, or `auto` for the default labels and line
///   counts.
/// - `stats`: Summary stat keys to render as pills.
/// - `body`: Optional custom renderer `(report, colors) => content`.
#let diffst-summary(
  report,
  colors: (:),
  title: auto,
  stats: ("similarity", "additions", "deletions", "changed-blocks"),
  body: auto,
) = {
  let colors = default-colors + colors
  if body == auto {
    _summary(colors, report, title: title, stats: stats)
  } else {
    body(report, colors)
  }
}

#let _table-rows(report, rows, display, collapse-threshold, context-lines, range, range-side) = {
  if rows != auto {
    rows
  } else {
    diffst-rows(
      report,
      display: display,
      collapse-threshold: collapse-threshold,
      context-lines: context-lines,
      range: range,
      range-side: range-side,
    )
  }
}

/// Render a report as the default split-table diff.
///
/// The split layout uses synchronized tables so old/new text columns can be
/// selected separately in PDFs.
///
/// Pass either `rows` directly or let this function compute rows from
/// `display`, `range`, and collapse options.
#let diffst-table(
  report,
  rows: auto,
  colors: (:),
  display: "full",
  collapse-threshold: 14,
  context-lines: 3,
  range: auto,
  range-side: "both",
  table-style: default-table-style,
) = {
  let colors = default-colors + colors
  let rows = _table-rows(report, rows, display, collapse-threshold, context-lines, range, range-side)
  _diff-table(colors, rows, report: report, table-style: table-style)
}

/// Render a report as one Typst `table`.
///
/// This is useful for simpler table behavior, but PDF text selection is usually
/// better with `diffst-table`.
#let diffst-single-table(
  report,
  rows: auto,
  colors: (:),
  display: "full",
  collapse-threshold: 14,
  context-lines: 3,
  range: auto,
  range-side: "both",
  table-style: default-table-style,
) = {
  let colors = default-colors + colors
  let rows = _table-rows(report, rows, display, collapse-threshold, context-lines, range, range-side)
  _single-table(colors, rows, report: report, table-style: table-style)
}

#let _render-table(colors, report, rows, table-style, table-layout) = {
  if table-layout == "split" {
    _diff-table(colors, rows, report: report, table-style: table-style)
  } else if table-layout == "single" {
    _single-table(colors, rows, report: report, table-style: table-style)
  } else {
    panic("table-layout must be \"split\" or \"single\"")
  }
}

/// Render a complete report layout from an existing report.
///
/// By default this renders a summary followed by either the split or single
/// table. Pass `body: (report, rows, colors) => ...` to reuse diffst's row
/// filtering and color resolution with a custom arrangement.
#let diffst-layout(
  report,
  colors: (:),
  display: "collapsed",
  collapse-threshold: 14,
  context-lines: 3,
  range: auto,
  range-side: "both",
  table-style: default-table-style,
  table-layout: "split",
  body: auto,
) = {
  let colors = default-colors + colors
  let rows = diffst-rows(
    report,
    display: display,
    collapse-threshold: collapse-threshold,
    context-lines: context-lines,
    range: range,
    range-side: range-side,
  )

  if body == auto {
    block(width: 100%)[
      #_summary(colors, report)
      #linebreak()
      #_render-table(colors, report, rows, table-style, table-layout)
    ]
  } else {
    body(report, rows, colors)
  }
}

#let _display(it) = {
  let report = diffst-report(
    it.old,
    it.new,
    old-label: it.at("old-label"),
    new-label: it.at("new-label"),
    ignore-whitespace: it.at("ignore-whitespace"),
    show-whitespace: it.at("show-whitespace"),
    algorithm: it.algorithm,
    inline: it.inline,
    unicode: it.at("unicode"),
    semantic-cleanup: it.at("semantic-cleanup"),
  )

  diffst-layout(
    report,
    colors: it.colors,
    display: it.display,
    collapse-threshold: it.at("collapse-threshold"),
    context-lines: it.at("context-lines"),
    table-style: it.at("table-style"),
    table-layout: it.at("table-layout"),
  )
}

#let _diffst-element = e.element.declare(
  "diffst",
  prefix: "diffst,v1",
  display: _display,
  fields: (
    e.field("old", str, required: true),
    e.field("new", str, required: true),
    e.field("old-label", str, default: "old"),
    e.field("new-label", str, default: "new"),
    e.field("ignore-whitespace", bool, default: false),
    e.field("show-whitespace", bool, default: false),
    e.field("algorithm", str, default: "histogram"),
    e.field("inline", str, default: "words"),
    e.field("unicode", bool, default: true),
    e.field("semantic-cleanup", bool, default: true),
    e.field("display", str, default: "collapsed"),
    e.field("collapse-threshold", int, default: 14),
    e.field("context-lines", int, default: 3),
    e.field("table-style", e.types.any, default: default-table-style),
    e.field("table-layout", str, default: "split"),
    e.field("colors", e.types.dict(e.types.any), default: (:)),
  ),
)

/// Render a diff report from two text strings.
///
/// Use `diffst` for files and `diffst-content` when the text is already in
/// Typst. The visual and diffing options match `diffst`.
///
/// - `old`: Old text content.
/// - `new`: New text content.
/// - `old-label`: Label shown above the old side.
/// - `new-label`: Label shown above the new side.
#let diffst-content(
  old,
  new,
  old-label: "old",
  new-label: "new",
  ignore-whitespace: false,
  show-whitespace: false,
  algorithm: "histogram",
  inline: "words",
  unicode: true,
  semantic-cleanup: true,
  display: "collapsed",
  collapse-threshold: 14,
  context-lines: 3,
  table-style: default-table-style,
  table-layout: "split",
  colors: (:),
) = {
  _diffst-element(
    old,
    new,
    old-label: old-label,
    new-label: new-label,
    ignore-whitespace: ignore-whitespace,
    show-whitespace: show-whitespace,
    algorithm: algorithm,
    inline: inline,
    unicode: unicode,
    semantic-cleanup: semantic-cleanup,
    display: display,
    collapse-threshold: collapse-threshold,
    context-lines: context-lines,
    table-style: table-style,
    table-layout: table-layout,
    colors: colors,
  )
}

/// Render a side-by-side diff report for two files.
///
/// This is the main convenience function. It reads `old-path` and `new-path`,
/// diffs their contents, and renders the report.
///
/// - `old-label` / `new-label`: Override displayed labels. Defaults to the
///   paths.
/// - `algorithm`: `"histogram"`, `"myers"`, `"patience"`, `"lcs"`, or `"hunt"`.
/// - `inline`: `"words"`, `"chars"`, or `"none"`.
/// - `display`: `"collapsed"` or `"full"`.
/// - `table-layout`: `"split"` or `"single"`.
#let diffst(
  old-path,
  new-path,
  old-label: auto,
  new-label: auto,
  ignore-whitespace: false,
  show-whitespace: false,
  algorithm: "histogram",
  inline: "words",
  unicode: true,
  semantic-cleanup: true,
  display: "collapsed",
  collapse-threshold: 14,
  context-lines: 3,
  table-style: default-table-style,
  table-layout: "split",
  colors: (:),
) = {
  diffst-content(
    read(old-path),
    read(new-path),
    old-label: if old-label == auto { repr(old-path) } else { old-label },
    new-label: if new-label == auto { repr(new-path) } else { new-label },
    ignore-whitespace: ignore-whitespace,
    show-whitespace: show-whitespace,
    algorithm: algorithm,
    inline: inline,
    unicode: unicode,
    semantic-cleanup: semantic-cleanup,
    display: display,
    collapse-threshold: collapse-threshold,
    context-lines: context-lines,
    table-style: table-style,
    table-layout: table-layout,
    colors: colors,
  )
}

/// Apply document-wide visual defaults to diffst reports.
///
/// Intended for `#show: diffst-style.with(...)`. This affects Elembic-backed
/// `diffst` and `diffst-content` calls.
#let diffst-style(body, colors: (:), table-style: default-table-style) = {
  show: e.set_(_diffst-element, colors: colors, table-style: table-style)
  body
}

/// Apply the minimal print-oriented table style document-wide.
///
/// Equivalent to `diffst-style.with(colors: minimal-colors, table-style:
/// minimal-table-style)`.
#let minimal-table(body) = {
  diffst-style(body, colors: minimal-colors, table-style: minimal-table-style)
}
