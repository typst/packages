#import "themes.typ"
// The inline-code chip inside a card is styled with the same helpers the
// presentation blocks use, so a chip looks the same wherever it sits.
#import "blocks.typ": _style-raw, _block-code-background

/// Thickness of the accent bar drawn along a card's `edge`.
#let card-edge-width = 3pt

/// Corner radius of a card.
#let card-radius = 4pt

/// Padding between a card's border and its content.
#let card-inset = (x: 8pt, y: 6pt)

/// Font size of a card's `num` label.
#let card-num-size = 15pt

/// Font size of a card's body text.
#let card-body-size = 11.5pt

/// Gap between a `num` label and the title it precedes.
#let card-num-gap = 5pt

/// Transparency of a card's body text.
#let card-body-dim = 25%

/// The accent-bar edge used when a call does not name one.
#let card-default-edge = left

/// Default gap between the columns and rows of a `card-grid`.
#let card-grid-gutter = 10pt

/// Asserts that `edge` is a side a card can draw, and returns it.
///
/// = Parameters
/// - `edge` (any): The value to check.
///
/// = Returns
/// `edge` unchanged.
#let check-card-edge(edge) = {
  assert(
    edge == left or edge == right or edge == top or edge == bottom or edge == none,
    message: "card: unknown edge "
      + repr(edge)
      + "; valid edges are left, right, top, bottom and none",
  )
  edge
}

/// Returns the stroke dictionary that draws a card's accent bar on `edge`.
///
/// = Parameters
/// - `edge` (alignment or none): The side to draw the bar on.
/// - `color` (color): The color of the bar.
///
/// = Returns
/// A stroke dictionary, or `none`.
#let card-stroke(edge, color) = {
  let bar = card-edge-width + color
  if edge == top { (top: bar) }
  else if edge == bottom { (bottom: bar) }
  else if edge == left { (left: bar) }
  else if edge == right { (right: bar) }
  else { none }
}

/// Resolves a card's accent to a color.
///
/// Accepts a color, a theme key, or `none` for the theme's `primary`.
///
/// = Parameters
/// - `theme` (dictionary): A resolved theme.
/// - `accent` (color, string or none): The requested accent.
///
/// = Returns
/// The accent color.
#let card-accent(theme, accent) = {
  if type(accent) == color {
    accent
  } else if type(accent) == str {
    themes.color-at(theme, accent)
  } else {
    theme.primary
  }
}

/// Returns an accent adjusted for use as text on a card.
///
/// Lightens on a dark theme and darkens on a light one, so the accent stays
/// legible against the card's background.
///
/// = Parameters
/// - `theme` (dictionary): A resolved theme.
/// - `accent` (color): The accent as drawn for the bar.
///
/// = Returns
/// The accent adjusted for legible text.
#let card-accent-text(theme, accent) = {
  if theme.dark { accent.lighten(25%) } else { accent.darken(25%) }
}

/// Resolves a card's background to a fill.
///
/// Accepts a color, a theme key, or `none` for the theme's `card-background`.
/// Any other value is returned untouched.
///
/// = Parameters
/// - `theme` (dictionary): A resolved theme.
/// - `fill` (color, string or none): The requested background.
///
/// = Returns
/// The background to draw the card with.
#let card-fill(theme, fill) = {
  if fill == none {
    theme.card-background
  } else if type(fill) == str {
    themes.color-at(theme, fill)
  } else {
    fill
  }
}

/// Returns the background a card draws its own inline code with.
///
/// Derived from the card's background so the code stays visible on a tinted
/// panel.
///
/// = Parameters
/// - `theme` (dictionary): A resolved theme.
///
/// = Returns
/// The background color for inline code inside a card.
#let card-code-background(theme) = {
  _block-code-background(theme.card-background, theme.dark)
}

/// Builds the content of a card: an optional `num` label, a title and a body.
///
/// = Parameters
/// - `title` (str, content or none): The card's title.
/// - `body` (content or none): The card's body.
/// - `num` (str, content or none): A label set before the title.
/// - `accent-text` (color): The color of the `num` label.
/// - `body-fill` (color): The color of the body text.
/// - `code-background` (color or none): The chip behind inline code, or `none`
///   for the theme's own `code-background`.
///
/// = Returns
/// The styled content of a card.
#let card-content(
  title,
  body,
  num: none,
  accent-text: black,
  body-fill: black,
  code-background: none,
) = {
  set par(justify: false)
  set text(hyphenate: false)
  // The card's runs are built first and emitted inside the `show` scope, so the
  // code rule reaches them. A `show` written in a block of its own would only
  // cover that block, and the runs would fall back to the theme's code chip.
  let content = {
    if num != none {
      // One line on purpose. A body written as
      //     text(…)[
      //       #num#h(gap)
      //     ]
      // keeps the newline before the closing bracket as a space, which lands
      // between the label and the title on top of the gap itself and makes the
      // label sit further from the title than the gap asks for — enough to wrap
      // a long title one word earlier than it should.
      text(size: card-num-size, weight: "bold", fill: accent-text)[#num#h(card-num-gap)]
    }
    if title != none { text(weight: "bold")[#title] }
    if title != none and body != none { linebreak() }
    if body != none { text(size: card-body-size, fill: body-fill)[#body] }
  }
  if code-background != none {
    // Code inside a card gets the card's own chip, the way code inside a block
    // gets the block's: the theme's code gray is close enough to a tinted card
    // to disappear into it.
    show raw.where(block: false): it => _style-raw(
      code-background: code-background,
      content: it.text,
    )
    content
  } else {
    content
  }
}

/// Draws one card.
///
/// = Parameters
/// - `title` (str, content or none): The card's title.
/// - `body` (content or none): The card's body.
/// - `theme` (dictionary): A resolved theme.
/// - `num` (str, content or none): A label set before the title.
/// - `edge` (alignment or none): The side the accent bar is drawn on.
/// - `accent` (color, string or none): The bar's color.
/// - `fill` (color, string or none): The card's background.
/// - `width` (auto or length): The card's width.
/// - `height` (auto or length): The card's height.
///
/// = Returns
/// A styled box containing the card.
#let draw-card(
  title,
  body,
  theme,
  num: none,
  edge: card-default-edge,
  accent: none,
  fill: none,
  width: 100%,
  height: auto,
) = {
  let resolved = card-accent(theme, accent)
  box(
    width: width,
    height: height,
    fill: card-fill(theme, fill),
    stroke: card-stroke(check-card-edge(edge), resolved),
    radius: card-radius,
    inset: card-inset,
    card-content(
      title,
      body,
      num: num,
      accent-text: card-accent-text(theme, resolved),
      body-fill: theme.main-text.transparentize(card-body-dim),
      code-background: card-code-background(theme),
    ),
  )
}

/// A card: a tinted panel with an accent bar, a title and a body.
///
/// Re-exported from `lib.typ`, which carries the full documentation.
#let card(
  title,
  body,
  num: none,
  accent: none,
  edge: card-default-edge,
  fill: none,
  width: 100%,
  height: auto,
) = context {
  draw-card(
    title,
    body,
    themes.theme-state.get(),
    num: num,
    edge: edge,
    accent: accent,
    fill: fill,
    width: width,
    height: height,
  )
}

/// Assembles the option dictionary `read-cell` returns for a card cell.
///
/// The parameters are the options `card` takes plus the placement keywords of
/// `grid.cell`, each defaulting to `none`.
#let read-card(
  title,
  body,
  num: none,
  edge: none,
  accent: none,
  fill: none,
  colspan: none,
  rowspan: none,
  x: none,
  y: none,
) = (
  kind: "card",
  title: title,
  body: body,
  num: num,
  edge: edge,
  accent: accent,
  fill: fill,
  colspan: colspan,
  rowspan: rowspan,
  x: x,
  y: y,
)

/// Reads one `card-grid` cell apart into the pieces a card is drawn from.
///
/// A cell is written as a `(title, body)` pair, a dictionary of `card` options,
/// plain content standing for a body, or a `grid` element passed through.
///
/// = Parameters
/// - `cell` (content, array or dictionary): The cell as written by the caller.
///
/// = Returns
/// A dictionary classifying the cell: `kind` is `"skip"`, `"line"`, `"row"` or
/// `"cell"` for passthrough cells, or `"card"` with the keys `title`, `body`,
/// `num`, `edge`, `accent`, `fill`, `colspan`, `rowspan`, `x` and `y` — each
/// `none` where the cell did not ask for one.
#let read-cell(cell) = {
  if cell == none {
    (kind: "skip")
  } else if type(cell) == array {
    // A pair is `(title, body)`. Any other length would otherwise slip through
    // to the fallback and be drawn as a body on its own, which reads as a
    // silent typo rather than as the mistake it is.
    assert(
      cell.len() == 2,
      message: "card-grid: a pair cell has to be (title, body), got "
        + str(cell.len()) + " elements",
    )
    read-card(cell.at(0), cell.at(1))
  } else if type(cell) == dictionary {
    read-card(
      cell.at("title", default: none),
      cell.at("body", default: none),
      num: cell.at("num", default: none),
      edge: cell.at("edge", default: none),
      accent: cell.at("accent", default: none),
      fill: cell.at("fill", default: none),
      colspan: cell.at("colspan", default: none),
      rowspan: cell.at("rowspan", default: none),
      x: cell.at("x", default: none),
      y: cell.at("y", default: none),
    )
  } else if type(cell) == content and cell.func() == grid.cell {
    // A caller's own `grid.cell` keeps its coordinates and its size; they are
    // read back off the element for placement, and the element itself is drawn
    // unchanged.
    (kind: "cell", content: cell, fields: cell.fields())
  } else if type(cell) == content and (
    cell.func() == grid.hline or cell.func() == grid.vline
  ) {
    (kind: "line", content: cell)
  } else if type(cell) == content and (
    cell.func() == grid.header or cell.func() == grid.footer
  ) {
    (kind: "row", content: cell, header: cell.func() == grid.header)
  } else {
    read-card(none, cell)
  }
}

/// Asserts that a `card-grid` placement keyword is a plain integer.
///
/// = Parameters
/// - `owner` (string): The option the value came from, e.g. `"colspan"`.
/// - `value` (any): The value as written.
/// - `minimum` (int): The smallest accepted value.
///
/// = Returns
/// The value itself, after the check.
#let check-span(owner, value, minimum: 1) = {
  if value == none {
    return minimum
  }
  assert(
    type(value) == int and value >= minimum,
    message: "card-grid: `" + owner + "` has to be an integer of at least "
      + str(minimum) + ", got " + repr(value),
  )
  value
}

/// Returns the cells of a `card-grid` laid out the way `grid` places them.
///
/// = Parameters
/// - `pieces` (array): The cells, as `read-cell` classified them.
/// - `columns` (int): The number of columns.
///
/// = Returns
/// An array parallel to `pieces`, one entry per piece, with the `row`, `col`,
/// `colspan` and `rowspan` where that cell lands. A line gets a zero extent.
#let place-cells(pieces, columns) = {
  let occupied = (:)               // row name → the columns that row holds
  let spots = ()

  // Rows key as strings: `dict.at` takes strings only, and the rows grow as
  // the scan walks past whatever was in the grid when the scan began. Every
  // mutation walks through a value the caller catches again, because a closure
  // cannot write to an outer `let`.
  let mark = (next-occupied, row, col, colspan, rowspan) => {
    let occupied = next-occupied
    for dr in range(rowspan) {
      let key = str(row + dr)
      let held = occupied.at(key, default: ())
      for dc in range(colspan) {
        held.push(col + dc)
      }
      occupied.insert(key, held)
    }
    occupied
  }

  let fits = (next-occupied, row, col, colspan, rowspan) => {
    let occupied = next-occupied
    if col + colspan > columns { return false }
    for dr in range(rowspan) {
      let held = occupied.at(str(row + dr), default: ())
      for dc in range(colspan) {
        if held.contains(col + dc) { return false }
      }
    }
    true
  }

  let scan = (next-occupied, row, col, colspan, rowspan) => {
    let occupied = next-occupied
    let c = col
    let r = row
    while c + colspan > columns or not fits(next-occupied, r, c, colspan, rowspan) {
      c += 1
      if c + colspan > columns {
        c = 0
        r += 1
      }
    }
    (r, c)
  }

  let advance = (row, col, colspan) => {
    if col + colspan >= columns { (row + 1, 0) } else { (row, col + colspan) }
  }

  // The extent and the coordinates a cell asked for. A card states them in its
  // own dictionary; a caller's `grid.cell` states them as fields on the
  // element, where an unset option is simply absent.
  let extent-of = piece => {
    if piece.kind == "cell" {
      let f = piece.fields
      (
        colspan: check-span("colspan", f.at("colspan", default: none), minimum: 1),
        rowspan: check-span("rowspan", f.at("rowspan", default: none), minimum: 1),
        x: f.at("x", default: none),
        y: f.at("y", default: none),
      )
    } else {
      (
        colspan: check-span("colspan", piece.colspan, minimum: 1),
        rowspan: check-span("rowspan", piece.rowspan, minimum: 1),
        x: piece.x,
        y: piece.y,
      )
    }
  }

  let cursor = (0, 0)
  for (index, piece) in pieces.enumerate() {
    if piece.kind == "line" {
      // A line is not a cell: it takes no slot and does not move the cursor.
      // Grid anchors it against the cells as it lays them out.
      spots.push((row: cursor.at(0), col: 0, colspan: 0, rowspan: 0))
    } else if piece.kind == "row" {
      // A header or a footer spans one whole row of its own.
      occupied = mark(occupied, cursor.at(0), 0, columns, 1)
      spots.push((row: cursor.at(0), col: 0, colspan: columns, rowspan: 1))
      cursor = (cursor.at(0) + 1, 0)
    } else if piece.kind == "skip" {
      // A skip takes the next free slot, not the flow cursor's: a cell placed
      // with explicit coordinates does not move the cursor, so the cursor can
      // sit on a taken slot and a raw placement would collide with it.
      let (row, col) = scan(occupied, cursor.at(0), cursor.at(1), 1, 1)
      occupied = mark(occupied, row, col, 1, 1)
      spots.push((row: row, col: col, colspan: 1, rowspan: 1))
      cursor = advance(row, col, 1)
    } else {
      let e = extent-of(piece)
      for owner in ("x", "y") {
        let v = e.at(owner)
        assert(
          v == none or type(v) == int,
          message: "card-grid: `" + owner + "` has to be an integer or none, got " + repr(v),
        )
      }
      if e.colspan > columns {
        panic(
          "card-grid: a cell's colspan " + str(e.colspan)
            + " exceeds the grid's " + str(columns) + " columns",
        )
      }
      if e.x != none and e.y != none {
        assert(
          fits(occupied, e.y, e.x, e.colspan, e.rowspan),
          message: "card-grid: cell at column " + str(e.x) + " row "
            + str(e.y) + " does not fit there",
        )
        occupied = mark(occupied, e.y, e.x, e.colspan, e.rowspan)
        spots.push((row: e.y, col: e.x, colspan: e.colspan, rowspan: e.rowspan))
      } else if e.x != none {
        assert(
          e.x + e.colspan <= columns,
          message: "card-grid: a cell's colspan " + str(e.colspan) + " at column "
            + str(e.x) + " exceeds the grid's " + str(columns) + " columns",
        )
        let r = 0
        while not fits(occupied, r, e.x, e.colspan, e.rowspan) { r += 1 }
        occupied = mark(occupied, r, e.x, e.colspan, e.rowspan)
        spots.push((row: r, col: e.x, colspan: e.colspan, rowspan: e.rowspan))
      } else if e.y != none {
        assert(
          e.y >= 0,
          message: "card-grid: `y` must be a row, got " + repr(e.y),
        )
        // Bounded: grid answers a row whose columns are all taken with an
        // error, and this has to do the same rather than scan for a fit that
        // can never come.
        let c = 0
        let searching = true
        while searching and c + e.colspan <= columns {
          if fits(occupied, e.y, c, e.colspan, e.rowspan) {
            searching = false
          } else {
            c += 1
          }
        }
        if c + e.colspan > columns {
          panic(
            "card-grid: all columns in row " + str(e.y) + " are already occupied",
          )
        }
        occupied = mark(occupied, e.y, c, e.colspan, e.rowspan)
        spots.push((row: e.y, col: c, colspan: e.colspan, rowspan: e.rowspan))
      } else {
        let (row, col) = scan(occupied, cursor.at(0), cursor.at(1), e.colspan, e.rowspan)
        occupied = mark(occupied, row, col, e.colspan, e.rowspan)
        spots.push((row: row, col: col, colspan: e.colspan, rowspan: e.rowspan))
        cursor = advance(row, col, e.colspan)
      }
    }
  }

  spots
}


/// Picks the value of `edge` for the cell at `index`.
///
/// `edge` is one side, applied to every card, or an array cycled over the cells
/// in reading order.
///
/// = Parameters
/// - `edge` (alignment, none or array): The grid's `edge`.
/// - `index` (int): The position of the cell.
///
/// = Returns
/// The edge for that cell.
#let edge-at(edge, index) = {
  if type(edge) == array {
    check-card-edge(edge.at(calc.rem(index, edge.len())))
  } else {
    check-card-edge(edge)
  }
}

/// Turns the `columns` of a `card-grid` into absolute widths.
///
/// `auto` and `fr` tracks share what is left after the fixed ones, in the order
/// `grid` resolves them. `auto` tracks size to the natural widths the caller
/// passes.
///
/// = Parameters
/// - `columns` (int or array): The `columns` as passed by the caller.
/// - `available` (length): The width the grid has to work with.
/// - `natural` (array): The per-track natural width.
/// - `gutter` (length): The gap between the columns.
///
/// = Returns
/// An array of lengths, one per column.
#let track-widths(columns, available, natural, gutter) = {
  // A bare integer is a count of equal columns, the way `grid(columns: 3)` reads.
  if type(columns) == int {
    let count = columns
    assert(count > 0, message: "card-grid: columns must be at least 1")
    let share = (available - gutter * (count - 1)) / count
    return range(count).map(_ => share)
  }

  let kinds = columns.map(t => if t == auto {
    "auto"
  } else if type(t) == fraction {
    "fr"
  } else {
    "fixed"
  })

  let fixed = 0pt
  let taken = 0pt
  let fr-total = 0.0
  for (i, t) in columns.enumerate() {
    if kinds.at(i) == "auto" {
      taken += natural.at(i)
    } else if kinds.at(i) == "fr" {
      fr-total += float(t)
    } else {
      fixed += t
    }
  }
  let gaps = gutter * calc.max(0, columns.len() - 1)
  let share = (available - gaps - fixed - taken) / calc.max(1.0, fr-total)

  columns.enumerate().map(((i, t)) => {
    if kinds.at(i) == "auto" { natural.at(i) }
    else if kinds.at(i) == "fr" { share * float(t) }
    else { t }
  })
}

/// A grid whose cells are drawn as cards.
///
/// Re-exported from `lib.typ`, which carries the full documentation.
#let card-grid(
  columns: 2,
  gutter: card-grid-gutter,
  row-gutter: none,
  edge: card-default-edge,
  accent: none,
  numbered: false,
  fill: none,
  ..cells
) = layout(size => context {
  let theme = themes.theme-state.get()
  let pieces = cells.pos().map(read-cell)
  let ncols = if type(columns) == int { columns } else { columns.len() }
  assert(ncols > 0, message: "card-grid: columns must be at least 1")
  // A gutter is a length here. `grid` also takes an array of them for unequal
  // gaps, which this does not size cells against, so saying so beats sizing
  // every cell off the wrong track.
  assert(
    type(gutter) == length,
    message: "card-grid: `gutter` has to be a length, got " + repr(gutter),
  )
  assert(
    row-gutter == none or type(row-gutter) == length,
    message: "card-grid: `row-gutter` has to be a length, got " + repr(row-gutter),
  )

  let spots = place-cells(pieces, ncols)
  let rows-used = if spots.len() > 0 {
    calc.max(..spots.map(s => s.row + s.rowspan))
  } else {
    0
  }

  // ----- natural widths -----------------------------------------------------
  // `auto` tracks size to their contents. A card drawn at its own column width
  // would wrap differently from one drawn across several columns, so a spanner
  // contributes its share to every track it covers; the share per track is
  // `natural / colspan`, which is how `grid` reads a spanning cell too.
  let natural-track = range(ncols).map(_ => 0pt)
  for (index, piece) in pieces.enumerate() {
    let spot = spots.at(index)
    if piece.kind == "cell" or piece.kind == "card" {
      let content = if piece.kind == "cell" { piece.content } else {
        draw-card(piece.title, piece.body, theme,
          edge: card-default-edge, accent: accent, fill: fill)
      }
      let share = measure(content).width / spot.colspan
      for c in range(spot.col, spot.col + spot.colspan) {
        if natural-track.at(c) < share {
          natural-track.at(c) = share
        }
      }
    }
  }

  let widths = track-widths(columns, size.width, natural-track, gutter)

  let span-width = spot => {
    let w = 0pt
    for c in range(spot.col, spot.col + spot.colspan) {
      if c > spot.col { w += gutter }
      w += widths.at(c)
    }
    w
  }

  // ----- heights, taller row with rowspan -----------------------------------
  // Rows are sized first from the one-row cards inside them, then grown for
  // rowspan cards that do not fit the rows they span. Two rounds is enough for
  // a row that is only stretched once.
  let heights = pieces.enumerate().map(((index, piece)) => {
    let spot = spots.at(index)
    // A header or a footer sizes its own row; measuring one outside a page
    // makes Typst warn that it was ignored during paged export.
    if piece.kind == "row" or piece.kind == "line" {
      return 0pt
    } else if piece.kind == "cell" {
      return measure(piece.content).height
    } else if piece.kind == "card" {
      return measure(draw-card(
        piece.title, piece.body, theme,
        num: piece.num,
        edge: card-default-edge,
        accent: accent,
        fill: fill,
        width: span-width(spot),
      )).height
    }
    0pt
  })

  let row-heights = range(rows-used).map(_ => 0pt)
  for (index, piece) in pieces.enumerate() {
    let spot = spots.at(index)
    if spot.rowspan > 1 { continue }
    if piece.kind == "skip" { continue }
    if heights.at(index) > row-heights.at(spot.row) {
      row-heights.at(spot.row) = heights.at(index)
    }
  }

  let row-gutter-final = if row-gutter != none { row-gutter } else { gutter }
  for round in range(4) {
    let grown = false
    for (index, piece) in pieces.enumerate() {
      let spot = spots.at(index)
      if spot.rowspan <= 1 { continue }
      let need = heights.at(index)
      let have = 0pt
      for dr in range(spot.rowspan) {
        if dr > 0 {
          have += row-gutter-final
        }
        have += row-heights.at(spot.row + dr)
      }
      if need > have {
        let add = need - have
        row-heights.at(spot.row + spot.rowspan - 1) += add
        grown = true
      }
    }
    if not grown { break }
  }

  // ----- emit ----------------------------------------------------------------
  // Every cardified cell carries its own grid.cell(x, y, colspan, rowspan) so
  // the drawn grid cannot disagree with the one that was measured; a skip is an
  // empty positioned cell; a passthrough is the caller's content verbatim.
  // Numbering and `edge` cycle over card cells only, in reading order.
  let cards = pieces.enumerate().filter(((index, piece)) => piece.kind == "card")
  // Reading order, row by row, folding row and column into one number: a column
  // never reaches `ncols`, so row and column cannot collide. A hand-rolled
  // insertion sort keeps this within the compiler version the package declares
  // (`sorted` is newer), and a slide's worth of cards is small.
  let order-key = (pair) => {
    let spot = spots.at(pair.at(0))
    spot.row * ncols + spot.col
  }
  let ordered = ()
  for pair in cards {
    let key = order-key(pair)
    let next = ()
    let placed = false
    for other in ordered {
      if not placed and key < order-key(other) {
        next.push(pair)
        placed = true
      }
      next.push(other)
    }
    if not placed { next.push(pair) }
    ordered = next
  }
  let slot-of = ordered.enumerate().map(((slot, pair)) => (
    str(pair.at(0)): slot + 1,
  )).fold((:), (acc, entry) => acc + entry)

  // Cards are nailed to the coordinates the placement pass computed, so the
  // drawn grid cannot drift from the measured one. The exception is a grid that
  // contains a line: `grid` anchors a line relative to the cells it flows
  // itself, and a grid whose every cell is placed explicitly has no flow for a
  // line to sit below — an hline would surface above everything. So when a line
  // is present the cards are left to `grid`'s own flow, which the placement
  // pass mirrors anyway, and only a cell whose caller named coordinates keeps
  // them.
  let has-line = pieces.any(piece => piece.kind == "line")

  let emit = pieces.enumerate().map(((index, piece)) => {
    let spot = spots.at(index)
    if piece.kind == "skip" {
      // In explicit mode the hole is a placed empty cell; in flow mode it is an
      // empty cell in reading order, which is what a bare `[]` occupies.
      return if has-line { [] } else { grid.cell(x: spot.col, y: spot.row)[] }
    }
    if piece.kind == "cell" or piece.kind == "line" or piece.kind == "row" {
      return piece.content
    }
    let slot = slot-of.at(str(index), default: none)
    let num = if piece.num != none {
      piece.num
    } else if numbered and slot != none {
      numbering("01", slot)
    } else {
      none
    }
    let height = if spot.rowspan == 1 {
      row-heights.at(spot.row)
    } else {
      let sum = 0pt
      for dr in range(spot.rowspan) {
        if dr > 0 { sum += row-gutter-final }
        sum += row-heights.at(spot.row + dr)
      }
      sum
    }
    // The grid's `edge`, `accent` and `fill` are stated once, so a card that
    // names none of them inherits them; a cycling `edge` array takes its
    // position from the card's place in reading order, never from the slot a
    // hole beside it occupies.
    let own-edge = if piece.edge == none {
      edge-at(edge, slot - 1)
    } else {
      check-card-edge(piece.edge)
    }
    let own-accent = if piece.accent == none {
      accent
    } else {
      piece.accent
    }
    let own-fill = if piece.fill == none {
      fill
    } else {
      piece.fill
    }
    let card = draw-card(
      piece.title,
      piece.body,
      theme,
      num: num,
      edge: own-edge,
      accent: own-accent,
      fill: own-fill,
      width: span-width(spot),
      height: height,
    )
    if has-line {
      if piece.x != none or piece.y != none {
        grid.cell(..(x: piece.x, y: piece.y).filter((k, v) => v != none),
          colspan: spot.colspan, rowspan: spot.rowspan)[#card]
      } else {
        grid.cell(colspan: spot.colspan, rowspan: spot.rowspan)[#card]
      }
    } else {
      grid.cell(x: spot.col, y: spot.row, colspan: spot.colspan, rowspan: spot.rowspan)[#card]
    }
  })

  grid(
    columns: widths,
    column-gutter: gutter,
    row-gutter: row-gutter-final,
    ..emit,
  )
})