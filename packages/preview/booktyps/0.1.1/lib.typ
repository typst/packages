// =============================================================================
//  booktyps, the booktabs look for Typst tables. Also handles breaking vlines
//  and uses native typst syntax.
//
//  `#show table: booktabs` is the whole setup. The rules are read off the
//  table's own structure, so nothing has to be written into the table by hand:
//  a heavy rule above and below it, and a light one under `table.header` and
//  above `table.footer`. A table with neither gets just the two heavy rules.
//
//  Sizes are given in `em`, as booktabs gives its own, so that rules keep their
//  weight against the text whatever size it is set at.
//
//  Where two rules meet, one gives way and stops short of the other. By
//  default the thinner one gives way, which is what lets a sideways table built
//  out of plain `table.hline` and `table.vline` keep the same look.
// =============================================================================

#import "@preview/uniwarn:0.1.1": warning

/// This package's own warnings, which a document may silence by name with
/// `uniwarn.disable-warnings("booktyps")`.
#let _warn = warning.with(namespace: "booktyps", prefix: "[booktyps] ")

/// The `stroke` of every table `booktabs` returns, which is how that table is
/// told apart from one still to be transformed when the show rule meets it again.
///
/// The table this function returns goes back through the show rule that produced
/// it, and through any other rule on `table`, so it has to be recognised and
/// handed back as it is; transformed again, it is built from its own output and
/// each pass is bigger than the one before, which exhausts memory long before
/// Typst's limit on recursion is reached. Functions compare by identity, so this
/// one is nothing a table is given by anyone else, a `stroke` function of the
/// author's included, and it is set after everything else passed on to the table,
/// so that nothing passed on can displace it.
#let _output-stroke = (x, y) => none

/// How many columns a table has, given as a count or a list of track sizes.
#let _column-count(columns) = if type(columns) == int {
  columns
} else if type(columns) == array { columns.len() } else { 1 }

/// Spell a track specification out as one size for each of `count` tracks.
///
/// Typst repeats the last size of an array for every track past its end, so the
/// grid built here, which has tracks of its own between the authored ones, has
/// to be given the sizes in full; left to repeat, they would land on the wrong
/// tracks. Typst hands over even a single size or a count of tracks as an array,
/// so only a table with no sizes given at all is not one: that is `fallback` for
/// every track, as an empty array is. A track is `auto` unless it is a gutter, to
/// which no size means none.
#let _track-sizes(spec, count, fallback: auto) = {
  if type(spec) == array and spec.len() > 0 {
    range(count).map(index => spec.at(calc.min(index, spec.len() - 1)))
  } else { (fallback,) * count }
}

/// Half of a gutter, which is what lies each side of a rule standing in it, as
/// an absolute length; or `none` if it is not one that can be halved. `auto`
/// is nothing, and a fraction or a percentage of the table cannot be split in
/// two before the table is laid out.
#let _half-gap(gap) = {
  let size = if type(gap) == relative {
    if gap.ratio == 0% { gap.length } else { return none }
  } else { gap }
  if type(size) == length { size.to-absolute() / 2 } else if gap == auto { 0pt } else { none }
}

/// An element's settable arguments, without the ones named. Its label is never
/// one of them: a label is not an argument, and the element is rebuilt here, so
/// one handed on would be refused. Nor is it put back on the rebuilt element:
/// the label stays with the element being shown, which is what a query or a rule
/// on that label finds, and a second one on the result would be found as well.
#let _options(element, ..without) = {
  let options = element.fields()
  for name in ("label",) + without.pos() { let _ = options.remove(name, default: none) }
  options
}

/// Spell an inset out as all four sides.
///
/// Takes a single value for every side, or a dictionary keyed by `x` and `y`,
/// or by the sides themselves, which win where both are given, with `rest` for
/// whatever none of those names.
#let _sides(value) = if type(value) == dictionary {
  let rest = value.at("rest", default: 0pt)
  let x = value.at("x", default: rest)
  let y = value.at("y", default: rest)
  (
    top: value.at("top", default: y),
    bottom: value.at("bottom", default: y),
    left: value.at("left", default: x),
    right: value.at("right", default: x),
  )
} else {
  (top: value, bottom: value, left: value, right: value)
}

/// The inset a rule stops short by where it merely meets another, which is
/// `meet` if the inset names one and the ordinary inset otherwise.
#let _meet(value) = if type(value) == dictionary and "meet" in value {
  _sides(value.meet)
} else { _sides(value) }

/// How thick a stroke draws, for deciding which of two rules gives way.
///
/// Resolved, since the sizes here default to `em` while a rule written by hand
/// is as likely to be given in `pt`, and the two cannot be ordered unresolved.
#let _thickness(value) = {
  if value == none { return 0pt }
  let width = stroke(value).thickness
  if width == auto { 1pt } else { width.to-absolute() }
}

/// Read a table's cells, rules, header and footer in one pass over its children.
///
/// Returns the cells as `(column, row, colspan, rowspan, body)`, the rules the
/// author placed with the element each came from, the row the header ends
/// before and the row the footer starts at, each with that part's own arguments
/// so that `repeat` and the like survive, and the number of rows.
///
/// Cells are placed the way the table places them: into the next free slot,
/// skipping the ones a span from an earlier cell already covers, unless the cell
/// names both its `x` and `y`.
#let _read-table(it, ncols) = {
  let cells = ()
  let hlines = ()
  let vlines = ()
  let header = none
  let footer = none
  let column = 0
  let row = 0
  let taken = (:)
  // The lowest row any cell reaches into, which a rowspan can push below the
  // row the cursor is on.
  let reach = 0

  for child in it.children {
    let part = child.func()
    let grouped = part in (table.header, table.footer)
    // A header or a footer takes whole rows, so it starts on a fresh one.
    if grouped and column > 0 { column = 0; row += 1 }
    let first-row = row
    let part-reach = row

    for cell in if grouped { child.children } else { (child,) } {
      if cell.func() == table.hline {
        let rule = cell.fields()
        hlines.push((
          at: rule.at("y", default: row),
          start: rule.at("start", default: 0),
          end: rule.at("end", default: none),
          stroke: rule.at("stroke", default: auto),
          element: cell,
        ))
      } else if cell.func() == table.vline {
        let rule = cell.fields()
        vlines.push((
          at: rule.at("x", default: column),
          start: rule.at("start", default: 0),
          end: rule.at("end", default: none),
          stroke: rule.at("stroke", default: auto),
          element: cell,
        ))
      } else {
        let fields = if cell.func() == table.cell { cell.fields() } else { (:) }
        let colspan = fields.at("colspan", default: 1)
        let rowspan = fields.at("rowspan", default: 1)
        let at-x = fields.at("x", default: auto)
        let at-y = fields.at("y", default: auto)
        let pinned = at-x != auto and at-x != none and at-y != auto and at-y != none

        let (x, y) = if pinned { (at-x, at-y) } else {
          // Step over what an earlier span already covers.
          while str(row) + "," + str(column) in taken {
            column += 1
            if column >= ncols { column = 0; row += 1 }
          }
          (column, row)
        }
        for covered-row in range(y, y + rowspan) {
          for covered-column in range(x, x + colspan) {
            taken.insert(str(covered-row) + "," + str(covered-column), true)
          }
        }
        cells.push((
          column: x,
          row: y,
          colspan: colspan,
          rowspan: rowspan,
          body: cell,
        ))
        part-reach = calc.max(part-reach, y + rowspan)
        reach = calc.max(reach, y + rowspan)

        // A cell given its own position leaves the cursor where it was.
        if not pinned {
          column += colspan
          while column >= ncols { column -= ncols; row += 1 }
        }
      }
    }

    // What follows a header or a footer starts a fresh row below it, which a row
    // it did not finish is left blank for, and below whatever a span in it
    // reaches into.
    if grouped {
      if column > 0 { column = 0; row += 1 }
      row = calc.max(row, part-reach)
    }
    if part == table.header {
      header = (end: row, options: _options(child, "children"))
    }
    if part == table.footer {
      footer = (start: first-row, options: _options(child, "children"))
    }
  }

  (
    cells: cells,
    hlines: hlines,
    vlines: vlines,
    header: header,
    footer: footer,
    rows: calc.max(reach, row + if column > 0 { 1 } else { 0 }),
  )
}

/// Split the blank space beside a rule at the distances things stop short by.
///
/// A stroke spans a whole track, so a rule can only stop short of another by
/// some distance if the blank space is divided at that distance. Each piece
/// records how far its near edge lies from the rule, which is what says whether
/// a given rule reaches across it.
///
/// `floor` is space the rule takes regardless, which is how a horizontal rule
/// keeps its booktabs air whether or not anything stops short of it.
#let _split(distances, floor) = {
  // Resolved first, since `em` and `pt` cannot be ordered against one another
  // and two rules may well be given in different units. A show rule carries a
  // context, so the font-relative ones can be settled here.
  let sizes = (distances + (floor,))
    .filter(d => d != none)
    .map(d => d.to-absolute())
  let total = sizes.fold(0pt, (a, b) => calc.max(a, b))
  if total == 0pt { return () }
  let cuts = sizes.filter(d => d > 0pt and d < total).dedup().sorted()
  let pieces = ()
  let near = 0pt
  for cut in cuts + (total,) {
    pieces.push((size: cut - near, near: near))
    near = cut
  }
  pieces
}

/// Plan one axis of the grid as it will actually be laid out.
///
/// `boundaries` gives, for each authored boundary carrying a rule, the pieces
/// of blank space on either side of it. Returns one entry per laid-out track,
/// an authored index or the size of a blank piece; where each rule ends up,
/// keyed by the track whose leading edge draws it; for every blank track the
/// rule it belongs to, which side of it and how far from it; the boundary drawn
/// on the very last trailing edge, if any.
#let _plan-axis(boundaries, count) = {
  let tracks = ()
  let rule-track = (:)
  let belongs = (:)
  let trailing = none

  for boundary in range(count + 1) {
    let rule = boundaries.at(str(boundary), default: none)
    if rule != none {
      // Before the rule the pieces run outwards, so they are laid down in
      // reverse: the one furthest from the rule comes first.
      if boundary > 0 {
        for piece in rule.before.rev() {
          belongs.insert(
            str(tracks.len()),
            (
              at: boundary,
              near: piece.near,
              side: "before",
              gutter: piece.at("gutter", default: false),
            ),
          )
          tracks.push(piece.size)
        }
      }
      if boundary < count {
        // Whatever comes next carries the rule on its leading edge, whether
        // that is the first blank piece or the content track itself.
        rule-track.insert(str(tracks.len()), boundary)
        for piece in rule.after {
          belongs.insert(
            str(tracks.len()),
            (
              at: boundary,
              near: piece.near,
              side: "after",
              gutter: piece.at("gutter", default: false),
            ),
          )
          tracks.push(piece.size)
        }
      } else { trailing = boundary }
    }
    if boundary < count { tracks.push(boundary) }
  }

  (
    tracks: tracks,
    rule-track: rule-track,
    belongs: belongs,
    trailing: trailing,
  )
}

/// The authored rows or columns a laid-out track stands for: itself if it is
/// one, or the two it lies between if it is blank space a rule added.
#let _neighbours(plan, index, count) = {
  let track = plan.tracks.at(index)
  if type(track) == int { return (track,) }
  let at = plan.belongs.at(str(index)).at
  (at - 1, at).filter(authored => 0 <= authored and authored < count)
}

/// Whether a laid-out track is the room beside a rule that the author's gutter
/// became, which is no cell's and so is never filled.
#let _is-gutter(plan, index) = (
  plan.belongs.at(str(index), default: (:)).at("gutter", default: false)
)

/// Make a per-cell setting of the table answer in the table's own coordinates.
///
/// `fill`, `align` and `inset` may be a function of the cell's column and row,
/// or an array over the columns. Both were written against the table as the
/// author sees it, and the grid built here has blank tracks in it, so they have
/// to be asked about the authored cell instead. A track that is blank space
/// takes what the cells either side of it agree on, which keeps a column's fill
/// running through the gap a rule leaves, and `neutral` where they differ. The
/// fill therefore stops where a rule does, rather than running past it into the
/// gap. A track that is a gutter takes `neutral` whatever they say, as a gutter
/// Typst leaves open is not filled either. Anything else, such as a single
/// value, is returned as it is, unless `every` asks for it to be answered for
/// too, which is how a single value is kept out of the gutters.
#let _remap(value, rows-plan, cols-plan, nrows, ncols, neutral, every: false) = {
  let read = if type(value) == function { value } else if type(value) == array {
    (x, y) => value.at(calc.rem(x, value.len()))
  } else if every { (x, y) => value } else { return value }

  (x, y) => {
    if _is-gutter(cols-plan, x) or _is-gutter(rows-plan, y) { return neutral }
    let answers = ()
    for column in _neighbours(cols-plan, x, ncols) {
      for row in _neighbours(rows-plan, y, nrows) {
        answers.push(read(column, row))
      }
    }
    if answers.all(answer => answer == answers.first()) {
      answers.first()
    } else { neutral }
  }
}

/// Give a table the booktabs look.
///
/// Apply it once and then write plain tables; the rules follow from the
/// structure. A heavy rule goes above and below the table, a light one under a
/// `table.header` and above a `table.footer`. A table with neither gets only
/// the two heavy ones.
///
/// Placing a `table.hline` adds a light rule of your own, and `start` and `end`
/// narrow it to some columns, the way booktabs' `\cmidrule` does. A
/// `table.vline` runs down the table the same way, and several rules may share
/// a boundary, which is booktabs setting two `\cmidrule`s on one alignment.
///
/// Where two rules cross, one gives way and stops short of the other, which is
/// the part plain `table` strokes cannot express; `break-rule` names the one
/// that gives way. Where a rule only runs up to another rather than past it,
/// there is nothing to decide: whichever rule ends there stops short by `meet`,
/// and one that carries on is left alone. A header or a
/// footer keeps its own arguments, so whether it repeats across a page break
/// stays `table.header(repeat: ..)`, as usual.
/// 
/// No inset is applied so write your own. The booktabs default inset is `2.7pt`.
///
/// The table's own `stroke` is ignored: the rules are the ones read off its
/// structure and the `table.hline`s and `table.vline`s placed in it, and nothing
/// else is drawn. A cell's own `stroke` is left alone.
///
/// Example:
/// ```typ
/// #import "@preview/booktyps:0.1.1": booktabs
/// #show table: booktabs.with(heavy: 1.3pt)
///
/// #table(
///   columns: 3,
///   align: (left, center, right),
///   table.vline(x: 1),
///   table.header([*Language*], [*Typed*], [*Year*]),
///   [Typst], [yes], [2019],
///   [TeX],   [no],  [1978],
///   table.hline(start: 1),
///   [Lout],  [no],  [1991],
///   table.footer([*Total*], [], [3]),
/// )
/// ```
///
/// The author's `column-gutter` and `row-gutter` are kept, an array repeating its
/// last size as it does for any table. Where no rule stands in a gutter it is
/// Typst's own, and the rules run across it unbroken. A rule that does stand in
/// one is centred in it, and its half of the gutter is room that the rules meet
/// in. A gutter is nobody's cell, so no `fill` reaches it. One that is not a
/// length, a fraction or a share of the table, cannot be halved around a rule,
/// so none is kept there, and a warning says so.
///
/// A table laid out sideways has no header to read a rule off, so draw the
/// rules yourself and let the thinner ones give way:
///
/// ```typ
/// #table(
///   columns: 4,
///   table.vline(x: 1, stroke: 0.9pt),
///   table.hline(y: 1, stroke: 0.4pt),
///   [*Language*], [Typst], [TeX],  [Lout],
///   [*Year*],     [2019],  [1978], [1991],
/// )
/// ```
///
/// - heavy (stroke): The rule above and below the table, booktabs' `\toprule`
///   and `\bottomrule`. Default is `0.08em`, booktabs' `\heavyrulewidth`. 
///   Set this to `0pt` if you are writing horizontal tables.
///
/// - light (stroke): The rule under a header, above a footer, and for a
///   `table.hline` that sets no stroke of its own, booktabs' `\midrule`.
///   Default is `0.05em`, booktabs' `\lightrulewidth`.
///
/// - vertical (stroke): The rule for a `table.vline` that sets no stroke of its
///   own. Default is `0.04em`, thinner than `light` so a horizontal
///   rule wins a crossing between the two by default.
///
/// - rule-inset (length, dictionary, function): How far a rule is held away
///   from what it divides, booktabs' `\aboverulesep`, and equally how far a
///   rule that loses a crossing stops short of the one that wins. Takes one
///   value for every side, or a dictionary keyed by `x` and `y`, or by `top`,
///   `bottom`, `left` and `right`. Default is `0.27em`, measured off booktabs'
///   own output, which sets `0.4ex` above a rule and `0.65ex` below it.
///   Rules sharing a boundary share the one band of air, so where they ask for
///   different amounts the widest wins; anything less would crowd the rule that
///   asked for more.
///
///   It also takes a function, `(x, y, rule)=>{..}`, 
///   giving each rule its own air. 
///   One of `x` and `y` is always `none`: a
///   horizontal rule has no column, a vertical one no row. `rule` is the rule
///   itself, so it can be read for its stroke. Return whatever the parameter
///   takes otherwise, and it applies to that rule alone. \
///   The inset may also name `meet`, taking a value or a dictionary of its own,
///   for the narrower gap a rule leaves where it merely runs up to another
///   instead of being cut by it, as in `(x: 6pt, y: 3pt, meet: 1pt)`. It
///   defaults to the ordinary inset, and `meet: 0pt` makes such rules run into
///   each other and close up the corner.
///
///   Leaving a gap therefore costs room: it has to come from somewhere,
///   so a table is wider at a vertical rule that anything stops short of, just
///   as every horizontal rule makes it taller. A vertical rule that nothing
///   gives way to costs no width at all.
///
/// - rule-steals-space (bool): Where the gap around a rule comes from. `false`,
///   the default, adds it, so rules push the rows apart. `true` takes it out of
///   the padding of the cells beside the rule instead, leaving the table the
///   height it would have with no rules at all; where the padding cannot cover
///   the gap, only the shortfall is added.
///
///   A single rule can be marked either way, whatever the table is set to, by
///   labelling it `<steals-space>` or `<injects-space>`. A label has to be
///   attached to the rule inside a content block, as in
///   `[#table.hline()<steals-space>]`, since a table takes content and a bare
///   label is not content. The rules read off the table's own structure carry
///   no label, so they follow the table.
///
///   Rules sharing a boundary share the one gap, so they cannot disagree about
///   where it comes from. Where they do, none of them steals, which can only
///   ever leave the table larger rather than overlapping anything, and a
///   warning says so. Silence it with
///   `uniwarn.disable-warnings("booktyps")`.
///
///   A `column-gutter` or `row-gutter` the author gave is room beside a rule as
///   the padding is, and it is used up before the padding is: a rule standing in
///   it takes half of it each side, the rule's gap is taken out of that first
///   and out of the padding only for what it cannot hold, and the table is as
///   wide or as tall as it would be with no rule. Without stealing, the gap is
///   added to the gutter.
///
/// - vertical-space (bool): Whether a vertical rule keeps the air `rule-inset`
///   gives it either side, as every horizontal rule does. `false`, the default,
///   gives a vertical rule room only where something stops short of it, so one
///   that nothing gives way to costs no width and sits against the cells beside
///   it. `true` holds every vertical rule away from them, which makes the gap
///   the same whether or not another rule breaks at it. It follows
///   `rule-steals-space` for where the room comes from.
///
/// - break-rule (auto, function): Which of two rules is to break under the other. `auto` breaks the thinner one, and if both are equal the vertical one. Pass `table.hline` or
///   `table.vline` to always break that one, or a function
///   `(x, y, hl, vl)` taking the column and row the two meet at and the two
///   instantiated rules themselves, and returning `table.hline` or `table.vline`. 
///   Default is `auto`. 
///
/// - it (content): The table to restyle, handed over by the show rule.
///
/// -> content
#let booktabs(
  heavy: 0.08em,
  light: 0.05em,
  vertical: 0.04em,
  rule-inset: 0.27em,
  rule-steals-space: false,
  vertical-space: false,
  break-rule: auto,
  it,
) = {
  assert( it.func() == table, 
    message: "The booktabs rule may only be applied to tables: `show table: booktabs`."
  )
  // Already transformed. Read through `fields`, since a table built by hand
  // rather than handed over by a show rule carries only the arguments it was
  // actually given.
  if it.fields().at("stroke", default: none) == _output-stroke { return it }

  let ncols = _column-count(it.columns)
  let content = _read-table(it, ncols)
  let nrows = content.rows
  let header-end = if content.header == none { none } else { content.header.end }
  let footer-start = if content.footer == none { none } else { content.footer.start }

  // Every horizontal rule, the ones read off the table's structure together
  // with the ones the author placed, which win where both fall on a boundary.
  let structural(at, stroke) = (
    at: at,
    start: 0,
    end: ncols,
    stroke: stroke,
    element: table.hline(y: at, stroke: stroke),
  )
  let from-structure = (structural(0, heavy), structural(nrows, heavy))
  if header-end != none and 0 < header-end and header-end < nrows {
    from-structure.push(structural(header-end, light))
  }
  if footer-start != none and 0 < footer-start and footer-start < nrows {
    from-structure.push(structural(footer-start, light))
  }

  // Several rules may share a boundary, the way booktabs sets two `\cmidrule`s
  // on one vertical alignment, so each boundary holds a list. An authored rule
  // joins the structural one rather than replacing it.
  let gather(rules) = {
    let by-boundary = (:)
    for rule in rules {
      let at = str(rule.at)
      by-boundary.insert(at, by-boundary.at(at, default: ()) + (rule,))
    }
    by-boundary
  }
  let drawn(rules) = rules.filter(rule => rule.stroke != none)
  let hrules = gather(
    drawn(from-structure + content.hlines.map(rule => (
      ..rule,
      end: if rule.end == none { ncols } else { rule.end },
      stroke: if rule.stroke == auto { light } else { rule.stroke },
    ))),
  )
  let vrules = gather(
    drawn(content.vlines.map(rule => (
      ..rule,
      end: if rule.end == none { nrows } else { rule.end },
      stroke: if rule.stroke == auto { vertical } else { rule.stroke },
    ))),
  )
  let every(by-boundary) = by-boundary.values().flatten()

  // Two rules cross only where each reaches past the other; meeting end to end
  // is not a crossing and needs no decision.
  // Does a rule reach past the boundary the other one sits on? Reaching only
  // as far as it is not a crossing: the two touch end to end, and since neither
  // is in the other's way, neither gives way.
  let spans-column(hrule, column) = hrule.start < column and column < hrule.end
  let spans-row(vrule, row) = vrule.start < row and row < vrule.end
  let crosses(hrule, vrule) = (
    spans-column(hrule, vrule.at) and spans-row(vrule, hrule.at)
  )
  /// Which of two crossing rules is the one broken; the other runs through.
  let broken(hrule, vrule) = {
    if break-rule == table.hline or break-rule == table.vline {
      break-rule
    } else if break-rule == auto {
      // The thinner rule gives way, the horizontal one where they are equal.
      if _thickness(vrule.stroke) <= _thickness(hrule.stroke) { table.vline } else { table.hline }
    } else {
      break-rule(vrule.at, hrule.at, hrule.element, vrule.element)
    }
  }

  // What a rule stops short by, on each of its own sides: `rule-inset` where it
  // is cut by another, `meet` where it only runs up to one.
  let cut-of(rule, x, y) = _sides(if type(rule-inset) == function {
    rule-inset(x, y, rule.element)
  } else { rule-inset })
  let meet-of(rule, x, y) = _meet(if type(rule-inset) == function {
    rule-inset(x, y, rule.element)
  } else { rule-inset })
  let widest(sizes) = if sizes.len() == 0 { 0pt } else { calc.max(..sizes) }

  // A rule either adds its gap to the table or takes it out of the padding of
  // the cells beside it. A label on the rule settles it, otherwise the table
  // does. Rules the structure supplies carry no label, so they follow the table.
  let steals(rule) = {
    let marked = rule.element.fields().at("label", default: none)
    if marked == <steals-space> { true } else if marked == <injects-space> {
      false
    } else { rule-steals-space }
  }
  // What a cell has to give: its own inset if it has one, otherwise the
  // table's, which may be a function of the cell's authored column and row.
  // Resolved, so that a gap in `pt` can be weighed against a padding in `em`.
  // An inset is a relative length, whose percentage cannot be weighed against
  // a gap, so only its length counts.
  let table-inset = it.fields().at("inset", default: 5pt)
  let padding-of(cell) = {
    let own = cell.body.fields().at("inset", default: none)
    let value = if own != none { own } else if type(table-inset) == function {
      table-inset(cell.column, cell.row)
    } else { table-inset }
    let sides = _sides(value)
    for (side, size) in sides {
      sides.insert(side, if type(size) == relative {
        size.length.to-absolute()
      } else if type(size) == length { size.to-absolute() } else { size })
    }
    sides
  }
  let take(wanted, available) = calc.min(wanted, available)

  // What a row or column can give at a rule is what its tightest cell has, since
  // the whole row gives the same amount. A cell takes its place in the row it
  // starts in for the top, the row it ends in for the bottom, and likewise for
  // the sides.
  let room-top = (:)
  let room-bottom = (:)
  let room-left = (:)
  let room-right = (:)
  let tighten(room, key, amount) = {
    room.insert(key, calc.min(room.at(key, default: amount), amount))
    room
  }
  for cell in content.cells {
    let padding = padding-of(cell)
    room-top = tighten(room-top, str(cell.row), padding.top)
    room-bottom = tighten(room-bottom, str(cell.row + cell.rowspan - 1), padding.bottom)
    room-left = tighten(room-left, str(cell.column), padding.left)
    room-right = tighten(room-right, str(cell.column + cell.colspan - 1), padding.right)
  }

  // A blank track is where a rule that gives way stops short, so one is needed
  // wherever any rule is cut or meets another, and it must be wide enough for
  // every gap that lands in it. A horizontal rule also always takes its own
  // air, since booktabs sets one apart from the rows it divides either way.
  let notes = ()
  // How far a rule stops short of the one it meets on a given side, or `none`
  // where it does not reach that side at all. Running through is stopping short
  // by nothing, which is what lets a rule cross a blank track unbroken.
  let vline-stop(v, boundary, side) = {
    let beside = hrules.at(str(boundary), default: ())
    let reaches = beside.any(h => h.start <= v.at and v.at <= h.end)
    if spans-row(v, boundary) {
      if not beside.any(h => crosses(h, v) and broken(h, v) == table.vline) {
        0pt
      } else if side == "before" {
        cut-of(v, v.at, none).bottom
      } else { cut-of(v, v.at, none).top }
    } else if reaches and side == "before" and v.end == boundary {
      meet-of(v, v.at, none).bottom
    } else if reaches and side == "after" and v.start == boundary {
      meet-of(v, v.at, none).top
    }
  }
  let hline-stop(h, boundary, side) = {
    let beside = vrules.at(str(boundary), default: ())
    let reaches = beside.any(v => v.start <= h.at and h.at <= v.end)
    if spans-column(h, boundary) {
      if not beside.any(v => crosses(h, v) and broken(h, v) == table.hline) {
        0pt
      } else if side == "before" {
        cut-of(h, none, h.at).right
      } else { cut-of(h, none, h.at).left }
    } else if reaches and side == "before" and h.end == boundary {
      meet-of(h, none, h.at).right
    } else if reaches and side == "after" and h.start == boundary {
      meet-of(h, none, h.at).left
    }
  }

  let notes = ()
  let shave-top = (:)
  let shave-bottom = (:)
  let shave-left = (:)
  let shave-right = (:)

  // The gutters the author asked for, one for each gap between neighbouring
  // rows or columns and spelt out in full, so that none is left to repeat itself
  // onto the blank tracks the rules add. The gap after the authored track `n`
  // is the one at the boundary `n + 1`.
  let gutters-of(name, count) = _track-sizes(
    it.fields().at(name, default: ()), calc.max(count - 1, 0), fallback: 0pt,
  )
  let column-gutters = gutters-of("column-gutter", ncols)
  let row-gutters = gutters-of("row-gutter", nrows)
  let gutter-at(gutters, boundary, count) = {
    if 1 <= boundary and boundary < count { gutters.at(boundary - 1) } else { 0pt }
  }

  let depth(pieces) = pieces.fold(0pt, (sum, piece) => sum + piece.size)
  // The author's gutter is room beside a rule as the padding of the cells is. A
  // rule standing in it takes half of it each side, and its air is either added
  // to that or taken out of it, as `rule-steals-space` has it: stealing uses up
  // the gutter before the padding, so only what the gutter cannot hold is left to
  // take from the cells, and whatever the cells cannot give is added after all.
  // The room lies outside the air, away from the rule, and a rule that reaches
  // that far is drawn across it.
  let seat(gap, half, stealing) = {
    let air = (before: depth(gap.before), after: depth(gap.after))
    let room(side) = {
      let size = if stealing { calc.max(half - air.at(side), 0pt) } else { half }
      if size > 0pt { ((size: size, near: air.at(side), gutter: true),) } else { () }
    }
    (
      gap: (
        before: gap.before + room("before"),
        after: gap.after + room("after"),
      ),
      from-cells: (
        before: calc.max(air.before - half, 0pt),
        after: calc.max(air.after - half, 0pt),
      ),
    )
  }

  // A horizontal rule keeps its own air whatever happens around it; a vertical
  // one takes only what something actually stops short by, so one that nothing
  // gives way to costs the table no width.
  let hline-spaced = (:)
  for (at, rules) in hrules {
    let boundary = int(at)
    let air = rules.map(h => cut-of(h, none, h.at))
    let stops(side) = every(vrules).map(v => vline-stop(v, boundary, side))
    let gap = (
      before: _split(stops("before"), widest(air.map(a => a.top))),
      after: _split(stops("after"), widest(air.map(a => a.bottom))),
    )

    let wants = rules.map(steals)
    let stealing = wants.all(w => w)
    if not stealing and wants.any(w => w) {
      notes.push(
        "rules sharing row " + at + " disagree about stealing space, so none of "
          + "them steals. Mark them all `<steals-space>`, or none of them, to "
          + "settle it.",
      )
    }
    let size = gutter-at(row-gutters, boundary, nrows)
    let half = _half-gap(size)
    if half == none {
      notes.push(
        "the row-gutter " + repr(size) + " between rows " + str(boundary) + " and "
          + str(boundary + 1) + " is not a length, which cannot be split around a "
          + "rule, so none is kept there.",
      )
      half = 0pt
    }
    let seated = seat(gap, half, stealing)
    if stealing {
      if boundary > 0 {
        shave-bottom.insert(str(boundary - 1), take(seated.from-cells.before, room-bottom.at(str(boundary - 1), default: 0pt)))
      }
      if boundary < nrows {
        shave-top.insert(str(boundary), take(seated.from-cells.after, room-top.at(str(boundary), default: 0pt)))
      }
    }
    hline-spaced.insert(at, seated.gap)
  }

  let vline-spaced = (:)
  for (at, rules) in vrules {
    let boundary = int(at)
    let stops(side) = every(hrules).map(h => hline-stop(h, boundary, side))
    // Air a vertical rule keeps only if it was asked to, since otherwise it
    // costs the table no width unless something stops short of it.
    let air = if vertical-space {
      rules.map(v => cut-of(v, v.at, none))
    } else { ((left: 0pt, right: 0pt),) }
    let gap = (
      before: _split(stops("before"), widest(air.map(a => a.left))),
      after: _split(stops("after"), widest(air.map(a => a.right))),
    )

    let wants = rules.map(steals)
    let stealing = wants.all(w => w)
    if not stealing and wants.any(w => w) {
      notes.push(
        "rules sharing column " + at + " disagree about stealing space, so none "
          + "of them steals. Mark them all `<steals-space>`, or none of them, to "
          + "settle it.",
      )
    }
    let size = gutter-at(column-gutters, boundary, ncols)
    let half = _half-gap(size)
    if half == none {
      notes.push(
        "the column-gutter " + repr(size) + " between columns " + str(boundary)
          + " and " + str(boundary + 1) + " is not a length, which cannot be split "
          + "around a rule, so none is kept there.",
      )
      half = 0pt
    }
    let seated = seat(gap, half, stealing)
    if stealing {
      if boundary > 0 {
        shave-right.insert(str(boundary - 1), take(seated.from-cells.before, room-right.at(str(boundary - 1), default: 0pt)))
      }
      if boundary < ncols {
        shave-left.insert(str(boundary), take(seated.from-cells.after, room-left.at(str(boundary), default: 0pt)))
      }
    }
    vline-spaced.insert(at, seated.gap)
  }

  let rows-plan = _plan-axis(hline-spaced, nrows)
  let cols-plan = _plan-axis(vline-spaced, ncols)

  // Where each authored row and column ended up, so the cells and the rules can
  // be placed against the laid-out grid rather than the authored one.
  let placed(plan) = {
    let by-index = (:)
    for (index, track) in plan.tracks.enumerate() {
      if type(track) == int { by-index.insert(str(track), index) }
    }
    by-index
  }
  let placed-row = placed(rows-plan)
  let placed-col = placed(cols-plan)


  let hrule-at(index) = hrules.at(
    str(rows-plan.rule-track.at(str(index), default: -1)),
    default: (),
  )
  let vrule-at(index) = vrules.at(
    str(cols-plan.rule-track.at(str(index), default: -1)),
    default: (),
  )

  // A rule is drawn where it covers the track. Across a blank track it is drawn
  // only once past the distance it stops short by, which is how a rule reaches
  // part of the way into the air beside another.
  let horizontal(rules, x) = {
    let track = cols-plan.tracks.at(x)
    let drawn = if type(track) == int {
      rules.find(h => h.start <= track and track < h.end)
    } else {
      let here = cols-plan.belongs.at(str(x), default: none)
      if here == none { none } else {
        rules.find(h => {
          let stop = hline-stop(h, here.at, here.side)
          stop != none and stop.to-absolute() <= here.near
        })
      }
    }
    if drawn != none { drawn.stroke }
  }
  let vertical-at(rules, y) = {
    let track = rows-plan.tracks.at(y)
    let drawn = if type(track) == int {
      rules.find(v => v.start <= track and track < v.end)
    } else {
      let here = rows-plan.belongs.at(str(y), default: none)
      if here == none { none } else {
        rules.find(v => {
          let stop = vline-stop(v, here.at, here.side)
          stop != none and stop.to-absolute() <= here.near
        })
      }
    }
    if drawn != none { drawn.stroke }
  }

  // What a cell is left with once the rules beside it have taken their gap.
  let shaved(cell) = {
    let base = padding-of(cell)
    let less = (
      top: shave-top.at(str(cell.row), default: 0pt),
      bottom: shave-bottom.at(str(cell.row + cell.rowspan - 1), default: 0pt),
      left: shave-left.at(str(cell.column), default: 0pt),
      right: shave-right.at(str(cell.column + cell.colspan - 1), default: 0pt),
    )
    if less.values().all(amount => amount == 0pt) { return (:) }
    (inset: (
      top: base.top - less.top,
      bottom: base.bottom - less.bottom,
      left: base.left - less.left,
      right: base.right - less.right,
    ))
  }

  // A span covers the blank tracks lying inside it as well as the authored ones,
  // so it is counted again in the laid-out grid.
  let placed-span(cell) = (
    colspan: placed-col.at(str(cell.column + cell.colspan - 1))
      - placed-col.at(str(cell.column)) + 1,
    rowspan: placed-row.at(str(cell.row + cell.rowspan - 1))
      - placed-row.at(str(cell.row)) + 1,
  )
  let place-cell(cell) = table.cell(
    x: placed-col.at(str(cell.column)),
    y: placed-row.at(str(cell.row)),
    .._options(cell.body, "x", "y", "body", "colspan", "rowspan"),
    ..placed-span(cell),
    ..shaved(cell),
    if cell.body.func() == table.cell { cell.body.body } else { cell.body },
  )

  // The first column of a laid-out row that no cell covers, which is where a
  // placeholder can sit without landing on a span.
  let free-column(y) = {
    let covered(x) = content.cells.any(cell => {
      let span = placed-span(cell)
      let cx = placed-col.at(str(cell.column))
      let cy = placed-row.at(str(cell.row))
      cx <= x and x < cx + span.colspan and cy <= y and y < cy + span.rowspan
    })
    range(cols-plan.tracks.len()).find(x => not covered(x))
  }

  // A header and a footer take their own rules with them when they repeat, so
  // each reaches as far as the blank tracks around its rule. Those tracks hold
  // no cell of their own, so they need one to belong to either. A blank track
  // is the gap itself, so it takes none of the table's padding.
  let spacer-anchor(row) = {
    let free = free-column(row)
    if free == none { () } else { (table.cell(x: free, y: row, inset: 0pt, []),) }
  }
  let anchors(rows) = rows
    .filter(row => type(rows-plan.tracks.at(row)) != int)
    .map(spacer-anchor)
    .flatten()
  let head-until = if header-end == none { 0 } else {
    placed-row.at(str(header-end), default: rows-plan.tracks.len())
  }
  let foot-from = if footer-start == none { rows-plan.tracks.len() } else {
    let first = placed-row.at(str(footer-start))
    while first > 0 and type(rows-plan.tracks.at(first - 1)) != int { first -= 1 }
    first
  }
  let placed-at(cell) = placed-row.at(str(cell.row))

  // The authored tracks keep the sizes the author gave them, and the blank
  // ones between them are as wide as the gap they stand for.
  let sizes(plan, spec, count) = {
    let authored = _track-sizes(spec, count)
    plan.tracks.map(track => if type(track) == int { authored.at(track) } else { track })
  }

  // What the author said about cells, put into terms of the grid built here.
  let options = _options(
    it, "children", "stroke", "rows", "columns", "row-gutter", "column-gutter",
  )
  // A gutter the author asked for stays a gutter of Typst's where nothing stands
  // in it, between two neighbouring authored tracks, and is nothing beside the
  // blank tracks, which hold the rest of it where a rule does stand in it.
  let gutter-array(plan, gutters) = range(plan.tracks.len() - 1).map(index => {
    let (here, next) = (plan.tracks.at(index), plan.tracks.at(index + 1))
    if type(here) == int and type(next) == int { gutters.at(here) } else { 0pt }
  })
  let spaced = (:)
  for (name, plan, gutters) in (
    ("column-gutter", cols-plan, column-gutters),
    ("row-gutter", rows-plan, row-gutters),
  ) {
    let array = gutter-array(plan, gutters)
    if array.any(gap => gap != 0pt) { spaced.insert(name, array) }
  }
  // The room that became a gutter beside a rule belongs to no cell, so a fill
  // that is one value for the whole table is answered for as well, to keep it out.
  let has-gutter = (rows-plan, cols-plan).any(plan => {
    plan.belongs.values().any(here => here.gutter)
  })
  for (name, neutral) in (fill: none, align: auto, inset: 0pt) {
    if name in options {
      options.insert(
        name,
        _remap(
          options.at(name), rows-plan, cols-plan, nrows, ncols, neutral,
          every: name == "fill" and has-gutter,
        ),
      )
    }
  }

  // The rules, as native lines over the laid-out grid. A line is drawn wherever
  // a rule covers a track, so each rule becomes one line per unbroken run of
  // tracks. Native lines cross whatever lies between the tracks, and stop at a
  // spanning cell as a cell's own stroke would.
  let runs(count, stroke-at) = {
    let found = ()
    let begin = none
    let current = none
    for index in range(count + 1) {
      let drawn = if index < count { stroke-at(index) } else { none }
      if begin != none and drawn != current {
        found.push((begin, index, current))
        begin = none
      }
      if begin == none and drawn != none { begin = index; current = drawn }
    }
    found
  }
  let ntracks-x = cols-plan.tracks.len()
  let ntracks-y = rows-plan.tracks.len()

  let hlines = ()
  let hline-rows = range(ntracks-y).map(y => (y, hrule-at(y)))
  if rows-plan.trailing != none {
    hline-rows.push((ntracks-y, hrules.at(str(rows-plan.trailing))))
  }
  for (y, rules) in hline-rows {
    if rules.len() > 0 {
      for (begin, end, drawn) in runs(ntracks-x, x => horizontal(rules, x)) {
        hlines.push((y: y, start: begin, end: end, stroke: drawn))
      }
    }
  }
  let vlines = ()
  let vline-cols = range(ntracks-x).map(x => (x, vrule-at(x)))
  if cols-plan.trailing != none {
    vline-cols.push((ntracks-x, vrules.at(str(cols-plan.trailing))))
  }
  for (x, rules) in vline-cols {
    if rules.len() > 0 {
      for (begin, end, drawn) in runs(ntracks-y, y => vertical-at(rules, y)) {
        vlines.push((x: x, start: begin, end: end, stroke: drawn))
      }
    }
  }

  // A header and a footer carry the lines inside them when they repeat, so each
  // line goes to the part that holds it. A vertical one running through more
  // than one part is cut at the part's edge.
  let header-cells = content.cells.filter(cell => placed-at(cell) < head-until)
  let footer-cells = content.cells.filter(cell => placed-at(cell) >= foot-from)
  let has-header = header-cells.len() > 0
  let has-footer = footer-cells.len() > 0
  let header-rows = if has-header { (0, head-until) } else { (0, 0) }
  let footer-rows = if has-footer { (foot-from, ntracks-y) } else { (ntracks-y + 1, ntracks-y + 1) }
  let body-rows = (header-rows.at(1), footer-rows.at(0))

  let hlines-in(rows, last: false) = hlines
    .filter(line => rows.at(0) <= line.y and (line.y < rows.at(1) or (last and line.y == rows.at(1))))
    .map(line => table.hline(..line))
  let vlines-in(rows) = vlines
    .map(line => (..line, start: calc.max(line.start, rows.at(0)), end: calc.min(line.end, rows.at(1))))
    .filter(line => line.start < line.end)
    .map(line => table.vline(..line))

  let part(wrap, options, rows, cells, lines) = if cells.len() == 0 { () } else {
    (wrap(..options, ..anchors(rows), ..cells.map(place-cell), ..lines),)
  }

  notes.map(_warn).join()
  table(
    rows: sizes(rows-plan, it.fields().at("rows", default: auto), nrows),
    columns: sizes(cols-plan, it.fields().at("columns", default: auto), ncols),
    ..options,
    ..spaced,
    // Nothing is drawn by cell strokes, and none of the default grid either. It
    // follows the options so as to be the one that counts, being what a table
    // already given the look is told apart by.
    stroke: _output-stroke,
    ..part(
      table.header,
      if content.header == none { (:) } else { content.header.options },
      range(head-until),
      header-cells,
      hlines-in(header-rows) + vlines-in(header-rows),
    ),
    ..content
      .cells
      .filter(cell => head-until <= placed-at(cell) and placed-at(cell) < foot-from)
      .map(place-cell),
    ..hlines-in(body-rows) + vlines-in(body-rows),
    ..part(
      table.footer,
      if content.footer == none { (:) } else { content.footer.options },
      range(foot-from, ntracks-y),
      footer-cells,
      hlines-in(footer-rows, last: true) + vlines-in(footer-rows),
    ),
  )
}
