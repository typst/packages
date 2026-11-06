// Native vector planning tools. No TikZ, external renderer or package dependency.

/// A Gantt chart with inclusive, one-based month or quarter intervals.
///
/// Wrap it in an ordinary `figure` for a caption, numbering, and reference.
/// Intervals must not overlap and must stay within `periods`. With
/// `start-year`, year headings use plain years instead of `Year 1`, `Year 2`.
///
/// ```example
/// #figure(
///   proposal-gantt((
///     (label: [Recruitment], spans: ((1, 6),)),
///     (label: [Analysis], spans: ((7, 12),)),
///   )),
///   caption: [Example timeline],
/// )
/// ```
///
/// - rows (array): records with `label` (str or content), `kind`
///   (`"task"` default, `"group"`, or `"milestone"`), `spans` for tasks/groups,
///   `at` for milestones, and optional `resources`
/// - periods (int): number of month or quarter columns; defaults to 24
/// - unit (str): `"month"` (default) or `"quarter"`
/// - start-year (int, none): first calendar year; `none` labels years relatively
/// - resources (array of str, content): optional resource headings
/// - label-width (length): row-label column width; defaults to 40mm
/// - resource-width (length): each resource column width; defaults to 10mm
/// - size (length): chart text size; defaults to 11pt
/// - color (color): bar and milestone color; defaults to `#314158`
/// - language (str): `"english"` (default) or `"german"`
#let proposal-gantt(
  rows, periods: 24, unit: "month", start-year: none,
  resources: (), label-width: 40mm, resource-width: 10mm,
  size: 11pt, color: rgb("314158"), language: "english",
) = {
  assert(type(rows) == array and rows.len() > 0, message: "Gantt rows must be a nonempty array of records.")
  assert(type(resources) == array and resources.all(r => type(r) == content or type(r) == str),
    message: "Gantt resources must be an array of labels.")
  assert(type(periods) == int and periods > 0, message: "Gantt periods must be a positive integer.")
  assert(unit in ("month", "quarter"), message: "Gantt unit must be month or quarter.")
  assert(language in ("english", "german"), message: "Gantt language must be english or german.")
  assert(start-year == none or type(start-year) == int, message: "Gantt start-year must be an integer.")
  assert(rows.len() > 0, message: "A Gantt chart needs at least one row.")
  let de = language == "german"
  let per-year = if unit == "month" { 12 } else { 4 }
  let cells = (table.cell(rowspan: 2, align: left)[*#if de [Arbeitspaket / Aufgabe] else [Work package / task]*],)
  for resource in resources { cells.push(table.cell(rowspan: 2)[*#resource*]) }
  for first in range(0, periods, step: per-year) {
    let year = if start-year == none { first / per-year + 1 } else { start-year + first / per-year }
    cells.push(table.cell(colspan: calc.min(per-year, periods - first))[
      *#if start-year == none { if de [Jahr #int(year)] else [Year #int(year)] } else { int(year) }*
    ])
  }
  for n in range(periods) {
    let index = calc.rem(n, per-year) + 1
    cells.push(table.cell(inset: (x: 0pt, y: 3pt))[#if unit == "quarter" [Q#index] else { index }])
  }
  for row in rows {
    assert(type(row) == dictionary, message: "Each Gantt row must be a record.")
    assert("label" in row and (type(row.label) == content or type(row.label) == str),
      message: "Each Gantt row needs a string or content `label`.")
    let kind = row.at("kind", default: "task")
    assert(kind in ("task", "group", "milestone"), message: "Unknown Gantt row kind.")
    cells.push(table.cell(align: left, inset: (right: 4pt, y: 4pt))[
      #if kind == "group" { strong(row.label) } else { row.label }
    ])
    let values = row.at("resources", default: resources.map(_ => []))
    assert(type(values) == array and values.all(v => type(v) == content or type(v) == str),
      message: "Gantt row resources must be an array of labels.")
    assert(values.len() == resources.len(), message: "Gantt resource values must match resource headings.")
    cells += values
    if kind == "milestone" {
      assert("at" in row and type(row.at) == int, message: "A Gantt milestone needs an integer `at` period.")
    } else {
      assert("spans" in row and type(row.spans) == array,
        message: "Each Gantt task or group needs a `spans` array.")
    }
    let spans = if kind == "milestone" { ((row.at, row.at),) } else { row.spans }
    assert(spans.len() > 0, message: "A Gantt row needs at least one interval.")
    let cursor = 1
    for span in spans.sorted(key: s => s.first()) {
      assert(type(span) == array and span.len() == 2 and span.all(n => type(n) == int),
        message: "Gantt intervals must contain two integer period numbers.")
      let (first, last) = span
      assert(first >= 1 and last >= first and last <= periods, message: "Gantt interval is outside the chart.")
      assert(first >= cursor, message: "Gantt intervals in one row must not overlap.")
      for _ in range(cursor, first) { cells.push([]) }
      cells.push(table.cell(colspan: last - first + 1, inset: (x: 0.5pt, y: 4pt),
        if kind == "milestone" {
          rotate(45deg, square(size: 4.5pt, fill: color, stroke: none))
        } else {
          rect(width: 100%, height: if kind == "group" { 3pt } else { 6pt },
            fill: if kind == "group" { color } else { color.lighten(35%) }, stroke: none)
        }))
      cursor = last + 1
    }
    for _ in range(cursor, periods + 1) { cells.push([]) }
  }
  set text(size: size)
  show table: set text(size: size)
  set par(justify: false, first-line-indent: 0pt, leading: 0.3em)
  block(breakable: false, width: 100%)[
    #layout(available => {
      let width = (available.width - label-width - resources.len() * resource-width) / periods
      let widest = measure(if unit == "quarter" { [Q4] } else if periods >= 10 { [12] } else { [9] }).width
      assert(width >= widest, message: "Gantt cells are too narrow: use quarters, a smaller size, fewer resource columns or a wider page.")
      table(
        columns: (label-width, ..resources.map(_ => resource-width), ..range(periods).map(_ => 1fr)),
        align: center + horizon, inset: (x: 1pt, y: 3pt),
        stroke: 0.3pt + luma(85%),
        fill: (x, y) => if y < 2 { luma(96%) } else { none },
        table.header(..cells.slice(0, 1 + resources.len() + calc.ceil(periods / per-year) + periods)),
        ..cells.slice(1 + resources.len() + calc.ceil(periods / per-year) + periods),
      )
    })
  ]
}

/// A numbered, referenceable work-package summary, independent of section numbers.
///
/// ```example
/// #work-package(
///   title: [Data collection],
///   objective: [Collect the pilot sample.],
///   tasks: ([Recruit participants], [Acquire data]),
/// ) <wp:data>
/// // Refer with @wp:data.
/// ```
///
/// - title (content, str): work-package title; defaults to empty
/// - objective (content, str): objective text; defaults to empty
/// - lead (content, str, none): optional lead partner
/// - period (content, str, none): optional period text
/// - tasks (array of content): task list; strings are not accepted
/// - deliverables (array of content): deliverable list
/// - milestones (array of content): milestone list
/// - risk (content, str, none): optional risk and contingency paragraph
/// - language (str): `"english"` (default) or `"german"`
/// - body (content): additional content inside the box; defaults to empty
///
/// The `work-package` figure kind has its own WP numbering. Attach a label after
/// the call and reference it with `@wp:label`; no manual WP IDs are needed.
#let work-package(
  title: [], objective: [], lead: none, period: none,
  tasks: (), deliverables: (), milestones: (), risk: none,
  language: "english", body: [],
) = {
  assert(language in ("english", "german"), message: "Work-package language must be english or german.")
  let de = language == "german"
  figure(
    {
    set align(left)
    set par(first-line-indent: 0pt, justify: false)
    block(width: 100%, breakable: true, inset: 8pt, stroke: 0.5pt + luma(75%))[
      #if lead != none [*#if de [Leitung:] else [Lead:]* #lead #linebreak()]
      #if period != none [*#if de [Zeitraum:] else [Period:]* #period #parbreak()]
      *#if de [Ziel:] else [Objective:]* #objective
      #for (label, entries) in (
        (if de [Aufgaben] else [Tasks], tasks),
        (if de [Ergebnisse] else [Deliverables], deliverables),
        (if de [Meilensteine] else [Milestones], milestones),
      ) {
        if entries.len() > 0 [#parbreak()*#label*#parbreak()#list(..entries)]
      }
      #if risk != none [#parbreak()*#if de [Risiko und Alternative:] else [Risk and contingency:]* #risk]
      #if body != [] [#parbreak()#body]
    ]
    },
    kind: "work-package", supplement: if de [AP] else [WP], numbering: "1",
    caption: figure.caption(position: top, separator: [ – ], title), outlined: false,
  )
}
