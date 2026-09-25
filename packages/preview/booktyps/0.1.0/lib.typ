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

/// How many columns a table has, given as a count or a list of track sizes.
#let _column-count(columns) = if type(columns) == int {
  columns
} else if type(columns) == array { columns.len() } else { 1 }

/// An element's settable arguments, without the ones named.
#let _options(element, ..without) = {
  let options = element.fields()
  for name in without.pos() { let _ = options.remove(name, default: none) }
  options
}

/// Spell an inset out as all four sides.
///
/// Takes a single value for every side, or a dictionary keyed by `x` and `y`,
/// or by the sides themselves, which win where both are given.
#let _sides(value) = if type(value) == dictionary {
  let x = value.at("x", default: 0pt)
  let y = value.at("y", default: 0pt)
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
/// Returns the cells as `(column, row, body)`, the rules the author placed with
/// the element each came from, the row the header ends before and the row the
/// footer starts at, each with that part's own arguments so that `repeat` and
/// the like survive, and the number of rows.
#let _read-table(it, ncols) = {
  let cells = ()
  let hlines = ()
  let vlines = ()
  let header = none
  let footer = none
  let column = 0
  let row = 0

  for child in it.children {
    let part = child.func()
    let grouped = part in (table.header, table.footer)
    let first-row = row

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
        cells.push((column: column, row: row, body: cell))
        column += if cell.func() == table.cell {
          cell.fields().at("colspan", default: 1)
        } else { 1 }
        while column >= ncols { column -= ncols; row += 1 }
      }
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
    rows: row + if column > 0 { 1 } else { 0 },
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
/// on the very last trailing edge, if any; and that last index.
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
            (at: boundary, near: piece.near, side: "before"),
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
            (at: boundary, near: piece.near, side: "after"),
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
    last: tracks.len() - 1,
  )
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
/// Example:
/// ```typ
/// #import "@preview/booktyps:0.1.0": booktabs
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
  break-rule: auto,
  it,
) = {
  assert( it.func() == table, 
    message: "The booktabs rule may only be applied to tables: `show table: booktabs`."
  )
  // Already transformed: the stroke is only ever a function once we made it one.
  // Read through `fields`, since a table built by hand rather than handed over
  // by a show rule carries only the arguments it was actually given.
  if type(it.fields().at("stroke", default: none)) == function { return it }

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
  // What the cells have to give. A cell of its own overrides the table's.
  let padding = _sides(it.fields().at("inset", default: 5pt))
  let take(wanted, available) = calc.min(wanted, available)

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
    if stealing {
      let depth(pieces) = pieces.fold(0pt, (sum, piece) => sum + piece.size)
      if boundary > 0 {
        shave-bottom.insert(str(boundary - 1), take(depth(gap.before), padding.bottom))
      }
      if boundary < nrows {
        shave-top.insert(str(boundary), take(depth(gap.after), padding.top))
      }
    }
    hline-spaced.insert(at, gap)
  }

  let vline-spaced = (:)
  for (at, rules) in vrules {
    let boundary = int(at)
    let stops(side) = every(hrules).map(h => hline-stop(h, boundary, side))
    let gap = (
      before: _split(stops("before"), 0pt),
      after: _split(stops("after"), 0pt),
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
    if stealing {
      let depth(pieces) = pieces.fold(0pt, (sum, piece) => sum + piece.size)
      if boundary > 0 {
        shave-right.insert(str(boundary - 1), take(depth(gap.before), padding.right))
      }
      if boundary < ncols {
        shave-left.insert(str(boundary), take(depth(gap.after), padding.left))
      }
    }
    vline-spaced.insert(at, gap)
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
    let own = cell.body.fields().at("inset", default: none)
    let base = if own == none { padding } else { _sides(own) }
    let less = (
      top: shave-top.at(str(cell.row), default: 0pt),
      bottom: shave-bottom.at(str(cell.row), default: 0pt),
      left: shave-left.at(str(cell.column), default: 0pt),
      right: shave-right.at(str(cell.column), default: 0pt),
    )
    if less.values().all(amount => amount == 0pt) { return (:) }
    (inset: (
      top: base.top - less.top,
      bottom: base.bottom - less.bottom,
      left: base.left - less.left,
      right: base.right - less.right,
    ))
  }

  let place-cell(cell) = table.cell(
    x: placed-col.at(str(cell.column)),
    y: placed-row.at(str(cell.row)),
    .._options(cell.body, "x", "y", "body"),
    ..shaved(cell),
    if cell.body.func() == table.cell { cell.body.body } else { cell.body },
  )

  // A header and a footer take their own rules with them when they repeat, so
  // each reaches as far as the blank tracks around its rule. Those tracks hold
  // no cell of their own, so they need one to belong to either. A blank track
  // is the gap itself, so it takes none of the table's padding.
  let spacer-anchor(row) = table.cell(x: 0, y: row, inset: 0pt, [])
  let anchors(rows) = rows
    .filter(row => type(rows-plan.tracks.at(row)) != int)
    .map(spacer-anchor)
  let head-until = if header-end == none { 0 } else {
    placed-row.at(str(header-end), default: rows-plan.tracks.len())
  }
  let foot-from = if footer-start == none { rows-plan.tracks.len() } else {
    let first = placed-row.at(str(footer-start))
    while first > 0 and type(rows-plan.tracks.at(first - 1)) != int { first -= 1 }
    first
  }
  let placed-at(cell) = placed-row.at(str(cell.row))

  let part(wrap, options, rows, cells) = if cells.len() == 0 { () } else {
    (wrap(..options, ..anchors(rows), ..cells.map(place-cell)),)
  }
  let sizes(plan) = plan.tracks.map(track => if type(track) == int { auto } else { track })

  notes.map(_warn).join()
  table(
    rows: sizes(rows-plan),
    columns: sizes(cols-plan).enumerate().map(((index, size)) => if size != auto {
      size
    } else if type(it.columns) == array {
      it.columns.at(cols-plan.tracks.at(index))
    } else { auto }),
    stroke: (x, y) => (
      top: horizontal(hrule-at(y), x),
      bottom: if y == rows-plan.last and rows-plan.trailing != none {
        horizontal(hrules.at(str(rows-plan.trailing)), x)
      },
      left: vertical-at(vrule-at(x), y),
      right: if x == cols-plan.last and cols-plan.trailing != none {
        vertical-at(vrules.at(str(cols-plan.trailing)), y)
      },
    ),
    .._options(it, "children", "stroke", "rows", "columns", "row-gutter"),
    ..part(
      table.header,
      if content.header == none { (:) } else { content.header.options },
      range(head-until),
      content.cells.filter(cell => placed-at(cell) < head-until),
    ),
    ..content
      .cells
      .filter(cell => head-until <= placed-at(cell) and placed-at(cell) < foot-from)
      .map(place-cell),
    ..part(
      table.footer,
      if content.footer == none { (:) } else { content.footer.options },
      range(foot-from, rows-plan.tracks.len()),
      content.cells.filter(cell => placed-at(cell) >= foot-from),
    ),
  )
}
