///! Assembly of the spec into one native table.
///!
///! Nothing is stacked around the table, so its own width governs every part.
///! The title block is a level-1 header, the column labels a level-2 header
///! that repeats across page breaks, and the notes a footer that does not.
///! Every cell is emitted explicitly, which gives one place where fills,
///! alignment, and strokes are decided.

#import "../format/align.typ": align-slots
#import "../format/apply.typ": matches-column
#import "../parts/colour.typ": colour-styles
#import "../parts/marks.typ": assign-marks, footer-notes, marks-for
#import "../parts/summaries.typ": summary-values
#import "../locations.typ": PARTS
#import "../style.typ": build-index, style-for
#import "../theme/options.typ": option
#import "layout.typ": (
  column-alignments, column-cells, label-alignment, metrics, slots-to-content,
  stub-alignment, stub-body, stub-cells, stub-depths, summarised, summary-label-alignment,
)
#import "plan.typ": build-plan

// `fill` and `stroke` arrive from the theme and the row plan; an explicit style
// overrides either, which is why the style dictionary is read last.
#let _table-cell(properties, body, align: auto, vertical: auto, colspan: 1, fill: none, stroke: (:)) = {
  // An explicit style's alignment stands as written, its vertical part included.
  // Otherwise the theme's vertical placement applies to whatever the column
  // decided horizontally, which is why the two are added rather than replaced.
  let placement = if "align" in properties {
    properties.align
  } else if vertical == auto {
    align
  } else if align == auto {
    vertical
  } else {
    align + vertical
  }
  table.cell(
    colspan: colspan,
    align: placement,
    fill: properties.at("fill", default: fill),
    inset: properties.at("inset", default: auto),
    stroke: properties.at("stroke", default: stroke),
    if "text" in properties { text(..properties.text, body) } else { body },
  )
}

// A mark rides above the value, after any substitution, so it survives whatever
// the cell turned out to be.
#let _marked(body, marks) = {
  if marks.len() == 0 { return body }
  body + super(marks.join([,]))
}

#let assemble(spec) = context {
  let setting(name) = option(spec.options, name)
  // Every cell takes the theme's vertical placement, so the option is read in
  // one place rather than threaded through a dozen call sites.
  let _cell(..args) = _table-cell(..args, vertical: setting("cell-vertical-align"))
  let names = spec.columns
  let has-stub = spec.stub.rowname != none
  let width = calc.max(names.len() + int(has-stub), 1)
  // The plan carries the spanner rows it counted, so the header the renderer
  // emits and the header the plan described cannot come from different calls.
  let (rows: plan, spanners: levels) = build-plan(spec)
  let indices = range(names.len())
  let cells = column-cells(spec)
  let footnotes = assign-marks(spec)
  let summaries = summary-values(spec)

  // The stub goes through the same formatting pipeline as every other column,
  // so a format directive naming the row-name column takes effect there too.
  let stub-content = stub-cells(spec)
  let depths = stub-depths(spec)

  let full(body) = table.cell(colspan: width, body)

  // Data-driven colour resolves per column and merges under explicit styling,
  // so table-style always wins over a gradient.
  // Colours resolve among themselves first, last directive winning as
  // everywhere else, and the explicit styles are laid over the result.
  let colours = spec.colours.fold((:), (layer, directive) => {
    let out = layer
    for name in spec.columns.filter(name => matches-column(directive.columns, name)) {
      for (position, properties) in colour-styles(directive, spec.data, name) {
        out.insert("body|" + position + "|" + repr(name), properties)
      }
    }
    out
  })

  // How many rows the footer prints is what cells-footnotes addresses, and it is
  // known only once the marks are assigned, so the styles are indexed against a
  // spec that carries the answer.
  // Rows printed, not directives written: two cells carrying the same caveat
  // share a mark and one footer row, so counting the directives addressed a row
  // that is not there.
  let addressable = spec + (footnote-rows: footer-notes(footnotes).len())

  let index = colours.pairs().fold(build-index(addressable), (styles, pair) => {
    let (key, properties) = pair
    let explicit = styles.at(key, default: (:))
    // Deep-merge the text dictionary: a shallow merge would replace it wholesale
    // and take the contrast fill with it, leaving black on black.
    let merged = properties + explicit
    if "text" in properties and "text" in explicit {
      merged.insert("text", properties.text + explicit.text)
    }
    styles.insert(key, merged)
    styles
  })
  let alignments = column-alignments(spec)
  let stub-align = stub-alignment(spec)
  let metrics = metrics(spec, cells, summaries)

  // A rule dictionary carrying only the edges that have a rule. `(top: none)`
  // overrides the table's own stroke on that edge, so a part that names an edge
  // it does not draw swallows whatever the table drew there; an absent key
  // leaves it alone. This is the same trap a cell stroke of `none` set for the
  // table borders.
  let rules(..edges) = {
    let out = (:)
    for (edge, value) in edges.named() {
      if value != none { out.insert(edge, value) }
    }
    out
  }

  let top-border(part) = {
    if part == "group" { setting("row-group-border-top") }
    else if part == "summary" { setting("summary-border-top") }
    else if part == "grand-summary" { setting("grand-summary-border-top") }
    else { none }
  }

  let stripe-fill(entry) = {
    if entry.part != "body" { return none }
    if not setting("row-striping") { return none }
    if entry.stripe { setting("row-striping-fill") } else { none }
  }

  let summary-row(entry, part, row-key) = {
    let cells = ()
    let rule = rules(top: top-border(part))
    let label = text(weight: setting("summary-weight"), [#entry.label])
    // A summary cell takes its marks like any other: the label cell through the
    // stub address, the rest by column.
    let marked(body, column) = _marked(body, marks-for(footnotes, part, row-key, column))
    let label-align = summary-label-alignment(alignments, has-stub, stub-align)
    if has-stub {
      cells.push(_cell(
        style-for(index, part, row-key, none),
        marked(label, none),
        align: label-align,
        fill: setting("summary-fill"),
        stroke: rule,
      ))
    }
    for (position, name) in names.enumerate() {
      if not has-stub and position == 0 {
        cells.push(_cell(
          style-for(index, part, row-key, name),
          marked(label, name),
          align: label-align,
          fill: setting("summary-fill"),
          stroke: rule,
        ))
        continue
      }
      let properties = style-for(index, part, row-key, name)
      // The padding boxes are measured in the surrounding text style, so a cell
      // whose style changes the text keeps the column alignment instead: a box
      // measured for another size is too narrow, and the number wraps inside it.
      // Body cells have always done this; a summary cell could not be styled at
      // all until cells-summary existed, which is what exposed the difference.
      let metric = if "text" in properties { none } else { metrics.at(position) }
      cells.push(_cell(
        properties,
        marked(summarised(spec, entry, name, metric), name),
        align: alignments.at(position),
        fill: setting("summary-fill"),
        stroke: rule,
      ))
    }
    cells
  }

  let titled(name, body, align: auto, stroke: (:)) = _cell(
    style-for(index, PARTS.title, none, name),
    _marked(body, marks-for(footnotes, PARTS.title, none, name)),
    align: align,
    colspan: width,
    stroke: stroke,
  )

  let head = ()
  if spec.header.title != none {
    head.push(titled(
      "title",
      text(size: setting("header-title-size"), weight: setting("header-title-weight"), spec.header.title),
      align: setting("header-align"),
    ))
  }
  if spec.header.subtitle != none {
    head.push(titled(
      "subtitle",
      text(size: setting("header-subtitle-size"), spec.header.subtitle),
      align: setting("header-align"),
      stroke: rules(bottom: setting("header-border-bottom")),
    ))
  }

  // Spanner rows sit above the column labels inside the same repeating header,
  // highest level first, with an empty cell over the stub column. The plan says
  // how many there are and in which order.
  let labels = ()
  for entry in plan.filter(entry => entry.part == "spanner") {
    if has-stub { labels.push(table.cell([])) }
    let row = levels.at(entry.source)
    for cell in row.cells {
      let body = if cell.label == none { [] } else {
        _marked(
          strong(cell.label),
          marks-for(footnotes, PARTS.column-spanners, row.level, cell.label),
        )
      }
      labels.push(_cell(
        style-for(index, PARTS.column-spanners, row.level, cell.label),
        body,
        align: center,
        colspan: cell.span,
        stroke: rules(bottom: setting("spanner-border-bottom")),
      ))
    }
  }

  // The label row carries the rules above and below the column labels. With no
  // title block and no spanners above it, it also carries the table's own top
  // rule, which belongs to whichever row happens to come first.
  let label-rules = rules(
    bottom: setting("column-labels-border-bottom"),
    top: setting("column-labels-border-top"),
  )

  // The stubhead labels the stub column, and is empty unless the stub names it.
  if has-stub {
    // Either spelling labels the stub: the stub's own label, or a columns-label
    // naming the row-name column.
    let label = if spec.stub.label != none {
      spec.stub.label
    } else {
      spec.labels.at(spec.stub.rowname, default: none)
    }
    let stubhead = if label == none { [] } else { strong(label) }
    labels.push(_cell(
      style-for(index, PARTS.stubhead, none, none),
      _marked(stubhead, marks-for(footnotes, PARTS.stubhead, none, none)),
      align: label-alignment(setting("column-labels-align"), stub-align),
      stroke: label-rules,
    ))
  }
  for (position, name) in names.enumerate() {
    labels.push(_cell(
      style-for(index, PARTS.column-labels, none, name),
      _marked(
        text(weight: setting("column-labels-weight"), size: setting("column-labels-size"), spec.labels.at(name, default: [#name])),
        marks-for(footnotes, PARTS.column-labels, none, name),
      ),
      align: label-alignment(setting("column-labels-align"), alignments.at(position)),
      stroke: label-rules,
    ))
  }

  // Group labels are their own headers, so the body is assembled entry by entry
  // rather than as one block of rows.
  let rows = ()
  for entry in plan {
    if entry.part == "group" {
      let label = spec.groups.at(entry.source).label
      rows.push(table.header(
        level: entry.level,
        repeat: setting("row-group-repeat"),
        _cell(
          style-for(index, PARTS.row-groups, entry.source, none),
          _marked(
            text(weight: setting("row-group-weight"), [#label]),
            marks-for(footnotes, PARTS.row-groups, entry.source, none),
          ),
          align: start,
          colspan: width,
          fill: setting("row-group-fill"),
          stroke: rules(top: top-border("group")),
        ),
      ))
    } else if entry.part == "summary" {
      let group = summaries.groups.at(entry.source.group)
      rows += summary-row(group.at(entry.source.row), PARTS.summary, entry.source)
    } else if entry.part == "grand-summary" {
      // Wrapped in a non-repeating header of the same level as a group label, so
      // the last group's label is retired: a repeated "South" above the grand
      // total would say the total belongs to South.
      rows.push(table.header(
        level: 3,
        repeat: false,
        ..summary-row(summaries.grand.at(entry.source), PARTS.grand-summary, entry.source),
      ))
    } else if entry.part == "body" {
      if has-stub {
        let body = stub-body(spec, stub-content.at(entry.source), depths.at(entry.source))
        rows.push(_cell(
          style-for(index, PARTS.stub, entry.source, none),
          _marked(body, marks-for(footnotes, PARTS.stub, entry.source, none)),
          align: stub-align,
          fill: stripe-fill(entry),
        ))
      }
      for position in indices {
        let name = names.at(position)
        let properties = style-for(index, PARTS.body, entry.source, name)
        // Padding measured in the surrounding text style would be wrong under a
        // style that changes the text, and a too-narrow box wraps the number.
        let metric = if "text" in properties { none } else { metrics.at(position) }
        rows.push(_cell(
          properties,
          _marked(
            slots-to-content(align-slots(cells.at(position).at(entry.source), metric)),
            marks-for(footnotes, PARTS.body, entry.source, name),
          ),
          align: alignments.at(position),
          fill: stripe-fill(entry),
        ))
      }
    }
  }

  let notes = ()
  for (position, note) in spec.source-notes.enumerate() {
    notes.push(_cell(
      style-for(index, PARTS.source-notes, position, none),
      text(size: setting("source-note-size"), _marked(note, marks-for(footnotes, PARTS.source-notes, position, none))),
      align: setting("footer-align"),
      colspan: width,
      stroke: rules(top: if position == 0 { setting("footer-border-top") } else { none }),
    ))
  }

  // The footer prints the marked notes behind their marks and then the unmarked
  // ones, and a note's place in that sequence is what cells-footnotes addresses,
  // so the order is decided in one place and counted through once.
  let footnote-row = 0
  for footnote in footer-notes(footnotes) {
    let body = if footnote.mark == none { footnote.note } else {
      super(footnote.mark) + footnote.note
    }
    notes.push(_cell(
      style-for(index, PARTS.footnotes, footnote-row, none),
      text(size: setting("footnote-size"), body),
      align: setting("footer-align"),
      colspan: width,
      stroke: rules(top: if notes.len() == 0 { setting("footer-border-top") } else { none }),
    ))
    footnote-row += 1
  }


  // A named width wins; everything else sizes itself, including the stub.
  //
  // Given a table width, the columns no columns-width names share what the named
  // ones leave: an `auto` track sizes to its content and would never fill the
  // width, so the table would sit inside a block wider than itself.
  let sized = setting("table-width") != auto
  let track(name) = {
    let given = spec.widths.at(name, default: auto)
    if given != auto { given } else if sized { 1fr } else { auto }
  }
  let tracks = if has-stub { (track(spec.stub.rowname),) } else { () }
  for name in names { tracks.push(track(name)) }

  set text(
    ..if setting("table-font") == none { (:) } else { (font: setting("table-font")) },
    ..if setting("table-font-size") == none { (:) } else { (size: setting("table-font-size")) },
  )

  // A table that must stay whole is wrapped rather than left to the page: an
  // unbreakable block is the only thing that stops Typst splitting rows. A table
  // width is a block of its own, inside which the fractional tracks resolve.
  let wrap(body) = {
    let held = if sized { block(width: setting("table-width"), body) } else { body }
    if setting("breakable") { held } else { block(breakable: false, held) }
  }

  // Rows the table will hold, so its own rules land on the first and the last
  // whatever the parts turn out to be. A table with no notes used to lose its
  // closing rule entirely, because the footer drew it.
  let body-rows = plan.filter(entry => entry.part in ("group", "body", "summary", "grand-summary"))
  let row-count = head.len() + levels.len() + 1 + body-rows.len() + notes.len()

  // Where the body opens and closes: the title block and the header are counted
  // from what was built above them, so the body opens under them and closes
  // wherever the footer begins.
  let body-opens = head.len() + levels.len() + 1
  let body-closes = body-opens + body-rows.len() - 1

  wrap(table(
    columns: tracks,
    inset: setting("cell-inset"),
    align: setting("table-align"),
    stroke: (x, y) => (
      top: if y == 0 {
        setting("table-border-top")
      } else if y == body-opens {
        setting("body-border-top")
      } else if y == body-closes + 1 {
        // The rule closing the body is written as the top of whatever follows
        // it. Written as a bottom it would meet the next row's own top on the
        // same edge, and two table-level strokes of one thickness do not both
        // draw there.
        setting("body-border-bottom")
      } else {
        setting("row-border")
      },
      bottom: if y != row-count - 1 {
        none
      } else if setting("table-border-bottom") != none {
        setting("table-border-bottom")
      } else if y == body-closes {
        // Nothing follows the body, so its closing rule is the table's own last
        // edge, unless the table already draws one there.
        setting("body-border-bottom")
      } else {
        none
      },
      // Between the columns rather than around the table, whose own edges are
      // table-border-top and table-border-bottom.
      left: if x == 0 { none } else { setting("column-border") },
    ),
    ..if head.len() > 0 {
      (table.header(level: 1, repeat: false, ..head),)
    } else { () },
    ..if labels.len() > 0 { (table.header(level: 2, repeat: true, ..labels),) } else { () },
    ..rows,
    ..if notes.len() > 0 { (table.footer(repeat: false, ..notes),) } else { () },
  ))
}
