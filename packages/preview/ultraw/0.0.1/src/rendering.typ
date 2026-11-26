#import "highlight.typ" as hl
#import "content.typ" as ct
#import "utils.typ" as ut

/// Create the cell of a column of the gutter (beside the code): a number, a marker, a diff marker.
///
/// - body (content): The content of the cell.
/// - width (length): The width of the column.
/// - height (length): The height of the line.
/// - inset (inset):
/// - radius (radius):
/// - stroke (stroke):
/// - fill (color, none):
/// - sep (stroke, none): The separating stroke on the right of the column, none if there is none.
/// - alignment (alignment):
/// -> block
#let side-cell(
  body,
  width,
  height,
  inset,
  radius,
  stroke,
  fill,
  sep,
  alignment,
) = block(
  breakable: false,
  clip: true,
  width: width,
  height: height,
  inset: inset,
  radius: radius,
  stroke: stroke,
  outset: ut.seam-outset(stroke, fill),
  fill: fill,
  {
    align(alignment, body)

    if sep != none {
      let s = std.stroke(sep)
      let thickness = if s.thickness == auto { 1pt } else { s.thickness }
      // The line is inside the cell, which clips its content
      place(right + top, dx: inset.right - thickness / 2, dy: -inset.top, line(
        start: (0mm, 0mm),
        end: (0mm, height),
        stroke: s,
      ))
    }
  },
)

/// Create the block of a code line whose highlights are computed.
///
/// - l (dictionary): The line, with its styled sub-lines.
/// - highlight-blocks (array): The highlight blocks, as `(sub-line, start, block)` (`start` being a length from the start of the code).
/// - width (length): The width of the code.
/// - height (length): The height of the line.
/// - inset (inset):
/// - radius (radius):
/// - stroke (stroke):
/// - fill (color, none):
/// - lang-tag (block, none):
/// - char-width (length):
/// - char-height (length):
/// - indentation (stroke, none): The indentation strokes, none if there is no indentation.
/// -> block
#let code-block(
  l,
  highlight-blocks,
  width,
  height,
  inset,
  radius,
  stroke,
  fill,
  color,
  lang-tag,
  char-width,
  char-height,
  indentation,
  extra: (top: 0pt, bottom: 0pt),
) = block(
  breakable: false,
  width: inset.left + width + inset.right,
  height: height,
  radius: radius,
  outset: ut.seam-outset(stroke, fill),
  fill: fill,
  // The content is clipped inside the stroke and the rounded corners (the highlights not covering them), and overlaps the next lines without stroke between them to hide their seam
  block(
    width: 100%,
    height: 100%,
    inset: ut.grow-inset(inset, extra),
    radius: radius,
    stroke: stroke,
    outset: (:)
      + for side in ("top", "bottom") {
        if (
          type(stroke) != dictionary or stroke.at(side, default: none) == none
        ) {
          ((side): .5pt)
        }
      },
    clip: true,
    align(top + left, {
      // Place highlights blocks
      for (k, s, hl-block) in highlight-blocks {
        place(
          left + top,
          dx: s,
          dy: -.24em + k * (inset.top + char-height + inset.bottom),
          hl-block,
        )
      }

      // (the lines have the height of the code font, even with taller characters of other fonts, as the emojis)
      set text(top-edge: char-height)
      ut.colored(
        color,
        l
          .slines
          .map(sl => h(sl.offset * char-width) + sl.body)
          .join("\n", default: []),
      )

      // Lang tag
      if lang-tag != none {
        place(
          right + top,
          dy: (
            -inset.top + char-height + inset.bottom - measure(lang-tag).height
          )
            / 2,
          lang-tag,
        )
      }

      // Indentation (over the sub-lines shown at the indentation, only over the first one otherwise)
      if indentation != none {
        let rows = if l.slines.any(sl => sl.offset > 0) {
          l.slines.len()
        } else {
          1
        }
        for p in l.pos-indent.slice(0, -1) {
          let x = p * char-width
          place(left + top, line(
            start: (x, -inset.top - extra.top),
            end: (
              x,
              (rows - 1) * (inset.top + char-height + inset.bottom)
                + char-height
                + inset.bottom
                + if rows == l.slines.len() { extra.bottom } else { 0pt },
            ),
            stroke: indentation,
          ))
        }
      }
    }),
  ),
)

/// Create a code cell.
///
/// - i (int): The index of the line.
/// - l (dictionary): The line.
/// - width (length): The width of the code.
/// - height (length): The height of the line.
/// - inset (inset):
/// - radius (radius):
/// - stroke (stroke):
/// - fill (color, none):
/// - lang-tag (block, none):
/// - char-width (length):
/// - char-height (length):
/// - indentation (stroke, none): The indentation strokes, none if there is no indentation.
/// - highlights (array): The list of highlights on the code.
/// -> block
#let code-cell(
  i,
  l,
  width,
  height,
  inset,
  radius,
  stroke,
  fill,
  color,
  lang-tag,
  char-width,
  char-height,
  indentation,
  highlights,
  extra: (top: 0pt, bottom: 0pt),
) = {
  let (new-slines, highlight-blocks) = hl.compute-highlights(
    i,
    l,
    width,
    inset,
    char-width,
    char-height,
    highlights,
  )
  l.slines = new-slines

  code-block(
    l,
    highlight-blocks,
    width,
    height,
    inset,
    radius,
    stroke,
    fill,
    color,
    lang-tag,
    char-width,
    char-height,
    indentation,
    extra: extra,
  )
}

/// Create the cell of a line of pseudo code.
///
/// - l (dictionary): The line (see `pseudo-lines`).
/// - body (content): Its content (see `pseudo-line-body`).
/// - code (dictionary): The code parameters, with an absolute `indent-size`.
/// - width (length): The width of the code.
/// - height (length): The height of the line.
/// - radius (radius):
/// - stroke (stroke):
/// - fill (color, none):
/// - extra (dictionary): The space added above and below (on the first and last lines).
/// -> block
#let pseudo-line-cell(
  l,
  body,
  code,
  width,
  height,
  radius,
  stroke,
  fill,
  color,
  extra,
) = {
  let inset = ut.grow-inset(code.inset, extra)
  block(
    breakable: false,
    width: code.inset.left + width + code.inset.right,
    height: height,
    inset: inset,
    radius: radius,
    stroke: stroke,
    outset: ut.seam-outset(stroke, fill),
    fill: fill,
    align(left, {
      // Indentation
      if code.indentation != none {
        for k in range(l.level) {
          let x = k * code.indent-size
          place(left + top, line(
            start: (x, -inset.top),
            end: (x, height - inset.top),
            stroke: code.indentation,
          ))
        }
      }

      ut.colored(color, body)
    }),
  )
}

/// Half the thickness of a stroke (`0pt` for `none`).
///
/// - s (stroke, none):
/// -> length
#let half-thickness(s) = {
  let t = if s != none { std.stroke(s).thickness }
  if t == none or t == auto { 0pt } else { t / 2 }
}

/// Create a comment cell.
///
/// - c (dictionary): The comment.
/// - height (length): The height of the row.
/// - radius (radius):
/// - stroke (stroke):
/// - sep (dictionary): The separators drawn on the top and bottom sides (inside the cell).
/// - sep-start (length, auto): The horizontal start of the separators, relative to the cell (before it to cross the marker cells), inside the left stroke of the cell by default.
/// - overlap (length): The height of the bottom of the cell covered by the next row.
/// -> block
#let comment-cell(
  c,
  height,
  radius,
  stroke,
  indentation,
  char-width,
  sep: (top: none, bottom: none),
  sep-start: auto,
  overlap: 0pt,
) = {
  block(
    breakable: false,
    width: c.width,
    height: height,
    inset: c.inset,
    radius: radius,
    stroke: stroke,
    // (a bottom separator covers the seam)
    outset: ut.seam-outset(stroke, c.fill)
      + if sep.bottom != none { (bottom: 0pt) },
    fill: c.fill,
    align(left + horizon, c.body),
  )

  // The separators, inside the visible part of the cell (and inside the frame strokes on its sides)
  let half(side) = half-thickness(if type(stroke) == dictionary {
    stroke.at(side, default: none)
  })
  let start = if sep-start == auto { half("left") } else { sep-start }
  for (side, s) in sep.pairs().filter(((_, s)) => s != none) {
    let t = if s.thickness == auto { 1pt } else { s.thickness }
    let y = if side == "top" { t / 2 } else { height - overlap - t / 2 }
    place(left + top, line(
      start: (start, y),
      end: (c.width - half("right"), y),
      stroke: s,
    ))
  }

  // Add indentation if needed
  if (
    indentation != none and c.to-indent and c.pos-indent.len() > 0
  ) {
    let x-offset = c.inset.left - c.pos-indent.last() * char-width
    for p in c.pos-indent.slice(0, -1) {
      let x = x-offset + p * char-width
      place(left + top, line(
        start: (x, 0mm),
        end: (x, c.height),
        stroke: indentation,
      ))
    }
  }
}

/// The separator of a header (`side: bottom`) or of a footer (`side: top`), drawn inside its block (offset by half its thickness), between the strokes of the sides of the frame.
///
/// - stroke (dictionary): The stroke of the header or footer, with its separator.
/// - inset (dictionary): The inset of the header or footer.
/// - side (alignment): `top` or `bottom`.
/// -> content
#let hf-sep(stroke, inset, side) = {
  let sep = stroke.at(repr(side), default: none)
  if sep != none {
    let thickness(s) = {
      let t = if s != none { std.stroke(s).thickness }
      if t == none or t == auto { 1pt } else { t }
    }
    let half(key) = if stroke.at(key, default: none) == none { 0pt } else {
      thickness(stroke.at(key)) / 2
    }
    let t = thickness(sep)
    let inset = ut.vertical-inset(inset) + ut.left-right-inset(inset)
    place(
      side + left,
      dx: -inset.left + half("left"),
      dy: if side == bottom { inset.bottom - t / 2 } else {
        -inset.top + t / 2
      },
      line(
        length: 100% + inset.left + inset.right - half("left") - half("right"),
        stroke: sep,
      ),
    )
  }
}

/// Create a header cell.
///
/// - header (dictionary): The header parameters.
/// - frame (dictionary): The frame parameters.
/// - nbr-columns (int): The number of columns of the grid.
/// -> grid.header, none
#let header-cell(header, frame, nbr-columns) = if header.content != none {
  grid.header(
    repeat: header.repeat,
    grid.cell(
      colspan: nbr-columns,
      block(
        width: frame.width,
        radius: header.radius,
        inset: header.inset,
        stroke: header.stroke + (bottom: none),
        outset: ut.seam-outset(header.stroke, header.fill),
        fill: header.fill,
        breakable: false,
        {
          align(header.align, header.content)
          hf-sep(header.stroke, header.inset, bottom)
          // The lang tag placed in the header
          if header.at("tag", default: none) != none {
            place(right + horizon, dx: header.tag-width, header.tag)
          }
        },
      ),
    ),
  )
}

/// Create a footer cell.
///
/// - footer (dictionary): The footer parameters.
/// - frame (dictionary): The frame parameters.
/// - nbr-columns (int): The number of columns of the grid.
/// -> grid.footer, none
#let footer-cell(footer, frame, nbr-columns) = if footer.content != none {
  grid.footer(
    repeat: footer.repeat,
    grid.cell(
      colspan: nbr-columns,
      block(
        width: frame.width,
        radius: footer.radius,
        inset: footer.inset,
        stroke: footer.stroke + (top: none),
        outset: ut.seam-outset(footer.stroke, footer.fill),
        fill: footer.fill,
        breakable: false,
        {
          align(footer.align, footer.content)
          hf-sep(footer.stroke, footer.inset, top)
        },
      ),
    ),
  )
}

/// Render a whole block of raw code.
///
/// - nl (int): The number of lines.
/// - number (dictionary): The number parameters.
/// - numbers-width (length):
/// - code (dictionary): The code parameters.
/// - code-lines (array):
/// - code-width (length):
/// - lines-height (length):
/// - frame (dictionary): The frame parameters.
/// - header (dictionary): The header parameters.
/// - footer (dictionary): The footer parameters.
/// - lang-tag (dictionary): The lang tag parameters.
/// - lang-tag-block (block):
/// - char-width (length):
/// - char-height (length):
/// - highlights (array): The list of highlights per line.
/// - comments (array): The list of comments placed before the first line, then after each line.
/// - line-cell (none, function): The function creating the cell of a line from its index, height, radius, stroke, fill, color and extra space (top and bottom), instead of a code cell.
/// - marker (dictionary): The marker column parameters (formatted, see `format-marker`), only its visibility is needed when it is not visible.
/// - markers-width (length): The width of the marker column.
/// - markers (array): For each line, its marker (`none` if it has none).
/// -> grid
#let render(
  nl,
  number,
  numbers-width,
  code,
  code-lines,
  code-width,
  lines-height,
  frame,
  header,
  footer,
  lang-tag,
  lang-tag-block,
  char-width,
  char-height,
  highlights,
  comments,
  line-cell: none,
  marker: (visible: false),
  markers-width: 0pt,
  markers: (),
) = {
  // Compute the number of columns and the associated widths: the numbers, the markers, the code

  let nbr-columns = 1 + int(number.visible) + int(marker.visible)
  let column-widths = ()
  if number.visible { column-widths.push(numbers-width) }
  if marker.visible { column-widths.push(markers-width) }
  column-widths.push(code.inset.left + code-width + code.inset.right)
  // Wether there are columns before the code (the first one takes the left side of the frame)
  let has-side = number.visible or marker.visible
  let gutter-width = column-widths.slice(0, -1).sum(default: 0pt)

  // Order the code lines and the comments

  // The commented line: the line before for a comment after it, the line after otherwise
  let commented(c) = calc.clamp(
    if c.copy-before { c.gap - 1 } else { c.gap },
    0,
    nl - 1,
  )
  // (a comment without fill takes the background of the commented line)
  let comment-row(c) = (
    kind: "comment",
    comment: if c.filled { c } else { c + (fill: (code.fill)(commented(c))) },
  )
  let rows = comments.at(0).map(comment-row)
  for i in range(nl) {
    rows.push((kind: "code", i: i))
    rows += comments.at(i + 1).map(comment-row)
  }
  let nr = rows.len()

  let row-height(row) = if row.kind == "code" {
    lines-height.at(row.i)
  } else {
    row.comment.height
  }

  let is-filled(row) = if row.kind == "code" {
    (
      (has-side and (number.fill)(row.i) != none) or (code.fill)(row.i) != none
    )
  } else {
    row.comment.fill != none
  }

  // The separators of a comment: against code lines, and against comments without separator on this side (not at the frame, the header or the footer)
  let separated(q, side) = (
    0 <= q
      and q < nr
      and (
        rows.at(q).kind == "code" or rows.at(q).comment.sep.at(side) == none
      )
  )
  let has-sep(r, side) = (
    rows.at(r).kind == "comment"
      and rows.at(r).comment.sep.at(side) != none
      and separated(
        if side == "top" { r - 1 } else { r + 1 },
        if side == "top" { "bottom" } else { "top" },
      )
  )

  // Compute effective line heights and row gutters (two filled rows overlap to hide their seam, unless a separator covers it: the bottom of the first row would show at a page break)

  let height-offset = .5pt

  let row-gutters = ()
  let row-heights = ()
  for r in range(nr - 1) {
    if (
      is-filled(rows.at(r))
        and is-filled(rows.at(r + 1))
        and not has-sep(r, "bottom")
        and not has-sep(r + 1, "top")
    ) {
      row-heights.push(row-height(rows.at(r)) + height-offset)
      row-gutters.push(-height-offset)
    } else {
      row-heights.push(row-height(rows.at(r)))
      row-gutters.push(0mm)
    }
  }
  row-heights.push(row-height(rows.at(nr - 1)))

  // The space before the first row and after the last one
  let edge(r) = (
    top: if r == 0 { code.edge.top } else { 0pt },
    bottom: if r == nr - 1 { code.edge.bottom } else { 0pt },
  )
  row-heights.at(0) += code.edge.top
  row-heights.at(nr - 1) += code.edge.bottom

  // Compute cells

  let is-first(r) = r == 0 and header.content == none
  let is-last(r) = r == nr - 1 and footer.content == none

  // The radius and stroke of a column beside the code, `leftmost` when it is the first column (a single row being both the first and the last one)
  let side-radius(r, leftmost) = if not leftmost { (:) } else {
    (
      (if is-first(r) { (top-left: frame.radius.top-left) } else { (:) })
        + if is-last(r) { (bottom-left: frame.radius.bottom-left) } else { (:) }
    )
  }

  // The stroke of the sides of a cell which are sides of the grid (the other ones being absent)
  let edge-stroke(r, left: true, right: true) = (
    (top: is-first(r), left: left, right: right, bottom: is-last(r))
      .pairs()
      .filter(((_, edge)) => edge)
      .map(((side, _)) => (side, frame.stroke.at(side)))
      .to-dict()
  )

  let side-stroke(r, leftmost) = edge-stroke(r, left: leftmost, right: false)

  let code-radius(r) = (
    (
      if is-first(r) {
        (
          (top-right: frame.radius.top-right)
            + if not has-side { (top-left: frame.radius.top-left) }
        )
      } else { (:) }
    )
      + if is-last(r) {
        (
          (bottom-right: frame.radius.bottom-right)
            + if not has-side { (bottom-left: frame.radius.bottom-left) }
        )
      } else { (:) }
  )

  let code-stroke(r) = edge-stroke(r, left: not has-side)

  let full-radius(r) = (
    (
      if is-first(r) {
        (top-left: frame.radius.top-left, top-right: frame.radius.top-right)
      } else { (:) }
    )
      + if is-last(r) {
        (
          bottom-left: frame.radius.bottom-left,
          bottom-right: frame.radius.bottom-right,
        )
      } else { (:) }
  )

  let full-stroke(r) = edge-stroke(r)

  // The separator between the gutter and the code, drawn on the left edge of the code cell (above its content)
  let with-sep(cell, height) = if has-side and number.sep != none {
    cell
    place(left + top, line(
      start: (0pt, 0pt),
      end: (0pt, height),
      stroke: number.sep,
    ))
  } else { cell }

  // The cells of the gutter of a row: the number column then the marker column (when visible), a marker being centered (`marked` when it is in the number column)
  let gutter-cells(r, height, extra, number-body, marker-body, fill, marked) = {
    let cells = ()
    if number.visible {
      cells.push(side-cell(
        if number-body != none { number-body } else { [] },
        numbers-width,
        height,
        ut.grow-inset(number.inset, extra),
        side-radius(r, true),
        side-stroke(r, true),
        fill,
        none,
        number.align,
      ))
    }
    if marker.visible {
      cells.push(side-cell(
        if marker-body != none { marker-body } else { [] },
        markers-width,
        height,
        ut.grow-inset(marker.inset, extra),
        side-radius(r, not number.visible),
        side-stroke(r, not number.visible),
        fill,
        none,
        center + number.align.y,
      ))
    }
    cells
  }

  let comment-sep(r, c) = (
    top: if separated(r - 1, "bottom") { c.sep.top },
    bottom: if separated(r + 1, "top") { c.sep.bottom },
  )
  // The part of a row covered by the next one
  let overlap(r) = if r < nr - 1 { -row-gutters.at(r) } else { 0pt }

  let row-cells = rows
    .enumerate()
    .map(((r, row)) => {
      let height = row-heights.at(r)
      let extra = edge(r)

      if row.kind == "code" {
        let i = row.i
        let code-cell = if line-cell != none {
          line-cell(
            i,
            height,
            code-radius(r),
            code-stroke(r),
            (code.fill)(i),
            (code.color)(i),
            extra,
          )
        } else {
          code-cell(
            i,
            code-lines.at(i),
            code-width,
            height,
            code.inset,
            code-radius(r),
            code-stroke(r),
            (code.fill)(i),
            (code.color)(i),
            if i == 0 and lang-tag.visible and lang-tag.in-code {
              lang-tag-block
            },
            char-width,
            char-height,
            code.indentation,
            highlights.at(i),
            extra: extra,
          )
        }

        (
          gutter-cells(
            r,
            height,
            extra,
            (number.color)(i, number.cells.at(i)),
            (number.color)(i, markers.at(i, default: none)),
            (number.fill)(i),
            number.marked.at(i),
          )
            + (with-sep(code-cell, height),)
        )
      } else {
        let c = row.comment
        c.inset = ut.grow-inset(c.inset, extra)

        if c.marker == none {
          // The comment spans over the gutter
          (
            grid.cell(
              colspan: nbr-columns,
              comment-cell(
                c,
                height,
                full-radius(r),
                full-stroke(r),
                code.indentation,
                char-width,
                sep: comment-sep(r, c),
                overlap: overlap(r),
              ),
            ),
          )
        } else {
          let k = commented(c)
          let fill = if c.marker-fill == auto { c.fill } else if (
            c.marker-fill == none
          ) {
            // (the number fill of the commented line)
            (number.fill)(k)
          } else { c.marker-fill }
          let in-number = c.marker-placement == "numbers"
          // (in the color of the numbers)
          c.marker = (number.color)(k, c.marker)
          (
            gutter-cells(
              r,
              height,
              extra,
              if in-number { c.marker },
              if not in-number { c.marker },
              fill,
              in-number,
            )
              + {
                let cell = comment-cell(
                  c,
                  height,
                  code-radius(r),
                  code-stroke(r),
                  code.indentation,
                  char-width,
                  sep: comment-sep(r, c),
                  // (crossing the marker cells, before the comment cell)
                  sep-start: -gutter-width + half-thickness(frame.stroke.left),
                  overlap: overlap(r),
                )
                (if c.gutter-sep { with-sep(cell, height) } else { cell },)
              }
          )
        }
      }
    })

  row-cells = row-cells.flatten()

  let header-cell = header-cell(header, frame, nbr-columns)

  let cells = if header-cell != none {
    row-heights.insert(0, auto)
    row-gutters.insert(0, 0mm)

    (header-cell,)
  } else { () }

  cells += row-cells

  let footer-cell = footer-cell(footer, frame, nbr-columns)

  if footer-cell != none {
    row-heights.push(auto)
    row-gutters.push(0mm)

    cells.push(footer-cell)
  }

  // Final grid

  grid(
    rows: row-heights,
    columns: column-widths,
    row-gutter: row-gutters,
    ..cells,
  )
}


// -----------------------------------------------------------------------------
// Diff
// -----------------------------------------------------------------------------

// A code cell with the highlights of one or two versions (`sources`: the index of the line in a version and the highlights of this line)
#let diff-code-cell(
  l,
  sources,
  width,
  height,
  inset,
  radius,
  stroke,
  fill,
  color,
  lang-tag,
  char-width,
  char-height,
  indentation,
  extra,
) = {
  let blocks = ()
  for (i, highlights) in sources {
    let (slines, b) = hl.compute-highlights(
      i,
      l,
      width,
      inset,
      char-width,
      char-height,
      highlights,
    )
    l.slines = slines
    blocks += b
  }
  code-block(
    l,
    blocks,
    width,
    height,
    inset,
    radius,
    stroke,
    fill,
    color,
    lang-tag,
    char-width,
    char-height,
    indentation,
    extra: extra,
  )
}

#let render-diff(
  rows,
  versions,
  same-code,
  number,
  code,
  diff-marker,
  general,
  gutter,
  frame,
  header,
  footer,
  lang-tag-block,
  char-width,
  char-height,
) = {
  // The columns, by key: the number, marker and diff marker columns and the code of each version (only once for merged codes), and the gutter between separated codes
  let columns = ()
  for v in ("old", "new") {
    let side = (
      (number.visible, "numbers"),
      (versions.at(v).marker.visible, "markers"),
      (diff-marker.visible, "diff-marker"),
      (true, "code"),
    )
    if v == "new" and not same-code and gutter > 0pt {
      columns.push(("new-gutter", gutter))
    }
    for (visible, key) in side {
      let shared = same-code and key != "numbers"
      if visible and not (shared and v == "old") {
        columns.push((
          if shared { key } else { v + "-" + key },
          if key == "numbers" { versions.at(v).numbers-width } else if (
            key == "markers"
          ) { versions.at(v).markers-width } else if key == "diff-marker" {
            diff-marker.width
          } else {
            (
              versions.at(v).code.inset.left
                + versions.at(v).code-width
                + versions.at(v).code.inset.right
            )
          },
        ))
      }
    }
  }
  let keys = columns.map(c => c.first())
  let column-widths = columns.map(c => c.last())
  let key(v, name) = if same-code and name != "numbers" { name } else {
    v + "-" + name
  }
  let has(k) = k in keys
  let first-key(v) = keys.find(k => k.starts-with(v + "-") or same-code)
  let width-between(a, b) = column-widths
    .slice(keys.position(k => k == a), keys.position(k => k == b) + 1)
    .sum()
  let cell(a, b, body) = grid.cell(
    colspan: keys.position(k => k == b) - keys.position(k => k == a) + 1,
    body,
  )

  let nr = rows.len()

  // The parts of the frame of a cell of the row `r` in the columns `a`-`b`: the cells on the sides of the grid have its stroke and radius
  let is-first(r) = r == 0 and header.content == none
  let is-last(r) = r == nr - 1 and footer.content == none
  let framing(r, a, b) = {
    let sides = (
      left: a == keys.first(),
      right: b == keys.last(),
      top: is-first(r),
      bottom: is-last(r),
    )
    let corner(y, x) = if sides.at(y) and sides.at(x) {
      frame.radius.at(y + "-" + x)
    } else { 0pt }
    (
      radius: (
        top-left: corner("top", "left"),
        top-right: corner("top", "right"),
        bottom-left: corner("bottom", "left"),
        bottom-right: corner("bottom", "right"),
      ),
      // (only the sides of the grid, the other ones having a seam outset)
      stroke: sides
        .keys()
        .filter(side => sides.at(side))
        .map(side => (side, frame.stroke.at(side)))
        .to-dict(),
    )
  }

  let edge(r) = (
    top: if r == 0 { code.edge.top } else { 0pt },
    bottom: if r == nr - 1 { code.edge.bottom } else { 0pt },
  )
  let line-height(v, i) = (
    versions.at(v).lines.at(i).slines.len() * (char-height + code.line-spacing)
  ).to-absolute()
  let row-heights = rows
    .enumerate()
    .map(((r, row)) => {
      let present = ("old", "new").filter(v => row.at(v) != none)
      let heights = if row.kind == "line" {
        present.map(v => line-height(v, row.at(v)))
      } else if "span" in row { (row.span.height,) } else {
        present.map(v => row.at(v).height)
      }
      calc.max(..heights) + edge(r).top + edge(r).bottom
    })

  // The separator between the gutter and the code, on the left of the first cell of the code side
  let gutter-visible(v) = number.visible or versions.at(v).marker.visible
  let with-sep(v, body, height) = if gutter-visible(v) and number.sep != none {
    body
    place(left + top, line(
      start: (0pt, 0pt),
      end: (0pt, height),
      stroke: number.sep,
    ))
  } else { body }

  // (a whole changed line takes the fill of the changes, the code fill when it is `none`)
  let code-fill(v, i, k) = if (
    versions.at(v).status.at(i) == "whole" and versions.at(v).conf.fill != none
  ) {
    versions.at(v).conf.fill
  } else { (code.fill)(k) }

  // A cell over the fill of the frame (when the cells take it), for the fills which do not cover it (as the blank fill)
  let over-frame(f, cell) = if code.frame-fill == none { cell } else {
    block(
      fill: code.frame-fill,
      outset: ut.seam-outset(f.stroke, code.frame-fill),
      radius: f.radius,
      cell,
    )
  }

  let side(body, width, inset, fill, alignment, height, extra, f) = side-cell(
    body,
    width,
    height,
    ut.grow-inset(inset, extra),
    f.radius,
    f.stroke,
    fill,
    none,
    alignment,
  )

  // The fill of the number of the line `i` of the version `v` (of key `k`)
  // (for a changed line: `auto` for the fill of the changes, `none` or no fill of the changes for the fill of the numbers)
  let number-fill(v, i, k) = {
    let conf = versions.at(v).conf
    let fill = if conf.numbers-fill == auto { conf.fill } else {
      conf.numbers-fill
    }
    if versions.at(v).status.at(i) == "same" or fill == none {
      (versions.at(v).number.fill)(k)
    } else { fill }
  }

  // The number color of the line `i` of the version `v` (of key `k`), applied to `it`
  let number-color(v, i, k, it) = {
    let conf = versions.at(v).conf
    if versions.at(v).status.at(i) != "same" and conf.numbers-color != auto {
      ut.colored(conf.numbers-color, it)
    } else { (versions.at(v).number.color)(k, it) }
  }

  // The key of each line of each version
  let line-keys = (old: (:), new: (:))
  for row in rows.filter(row => row.kind == "line") {
    for v in ("old", "new") {
      if row.at(v) != none { line-keys.at(v).insert(str(row.at(v)), row.k) }
    }
  }

  let number-cell(v, i, k, height, extra, f) = {
    let body = number-color(v, i, k, versions.at(v).number.cells.at(i))
    side(
      body,
      versions.at(v).numbers-width,
      versions.at(v).number.inset,
      number-fill(v, i, k),
      if versions.at(v).number.marked.at(i) { center + number.align.y } else {
        number.align
      },
      height,
      extra,
      f,
    )
  }

  let marker-cell(v, body, fill, height, extra, f) = side(
    if body != none { body } else { [] },
    versions.at(v).markers-width,
    versions.at(v).marker.inset,
    fill,
    center + number.align.y,
    height,
    extra,
    f,
  )

  // The cells of a line of a version (the code of a merged unchanged line having the highlights of both versions)
  let code-side-cells(v, row, k, r, height, extra) = {
    let i = row.at(v)
    let status = versions.at(v).status.at(i)
    let fill = code-fill(v, i, k)
    let cells = ()
    if diff-marker.visible {
      cells.push(side(
        if status == "same" { diff-marker.unchanged } else {
          versions.at(v).conf.diff-marker
        },
        diff-marker.width,
        diff-marker.inset,
        fill,
        center + number.align.y,
        height,
        extra,
        framing(r, key(v, "diff-marker"), key(v, "diff-marker")),
      ))
    }
    let f = framing(r, key(v, "code"), key(v, "code"))
    let sources = if same-code and row.old != none and row.new != none {
      (("old", row.old), ("new", row.new))
    } else { ((v, i),) }
    cells.push(diff-code-cell(
      versions.at(v).lines.at(i),
      sources.map(((sv, si)) => (si, versions.at(sv).highlights.at(si))),
      versions.at(v).code-width,
      height,
      versions.at(v).code.inset,
      f.radius,
      f.stroke,
      fill,
      (code.color)(k),
      if (if same-code { k == 0 } else { v == "new" and i == 0 }) {
        lang-tag-block
      },
      char-width,
      char-height,
      code.indentation,
      extra,
    ))
    cells.first() = with-sep(v, cells.first(), height)
    cells
  }

  // A blank cell over the columns `a`-`b`, merged with the ones of the same columns in the next rows (see `blank-cell`)
  let blank(a, b) = (a: a, b: b)

  // The cell of a blank of the row `r` spanning over `n` rows (so that its tiling is continuous), or of the gutter of the separated new code (with the `fill` of its row, separated from the old code)
  let blank-cell(c, r, n, fill: general.blank-fill) = {
    let (top, bottom) = (framing(r, c.a, c.b), framing(r + n - 1, c.a, c.b))
    let f = (
      radius: (
        top-left: top.radius.top-left,
        top-right: top.radius.top-right,
        bottom-left: bottom.radius.bottom-left,
        bottom-right: bottom.radius.bottom-right,
      ),
      stroke: top
        .stroke
        .pairs()
        .filter(((side, _)) => side != "bottom")
        .to-dict()
        + bottom
          .stroke
          .pairs()
          .filter(((side, _)) => side == "bottom")
          .to-dict(),
    )
    // (a blank spanning over several rows is drawn after them: the one of the separated old code does not cover the new code, its seam outset and the half of the separator over it)
    let sep-half = if (
      c.b == "old-code" and has("new-gutter") and general.sep != none
    ) {
      let t = std.stroke(general.sep).thickness
      (if t == auto { 1pt } else { t }) / 2
    } else { 0pt }
    if c.b == "old-code" { f.stroke.right = none }
    grid.cell(
      colspan: keys.position(k => k == c.b) - keys.position(k => k == c.a) + 1,
      rowspan: n,
      box(width: width-between(c.a, c.b) - sep-half, over-frame(f, block(
        width: 100%,
        height: row-heights.slice(r, r + n).sum(),
        radius: f.radius,
        stroke: f.stroke + if c.a == "new-gutter" { (left: general.sep) },
        outset: ut.seam-outset(f.stroke, fill),
        fill: fill,
      ))),
    )
  }

  // The width of the gutter of a version
  let pre-width(v) = ("numbers", "markers")
    .map(name => key(v, name))
    .filter(has)
    .map(k => width-between(k, k))
    .sum(default: 0pt)

  // A comment in the columns of a version from `from` (with the gutter of the separated new code) to `to` (the code by default), its marker being in the gutter of the version, its text being shifted by `shift` (the gutter of the separated new code by default)
  let comment-cells(v, c, k, from, r, height, extra, to: auto, shift: auto) = {
    // The separators: against the code lines and the comments without separator on this side (of the version of the comment, when the codes are separated)
    let separated(q, side) = {
      if q < 0 or q >= nr { return false }
      let row = rows.at(q)
      let v = if same-code or "span" in rows.at(r) {
        if row.at("new", default: none) != none { "new" } else { "old" }
      } else { c.version }
      if row.kind == "line" { return row.at(v) != none }
      let n = if "span" in row { row.span } else { row.at(v) }
      n != none and n.sep.at(side) == none
    }
    let sep = (
      top: if separated(r - 1, "bottom") { c.sep.top },
      bottom: if separated(r + 1, "top") { c.sep.bottom },
    )
    let to = if to == auto { key(v, "code") } else { to }
    let first-code-key = if diff-marker.visible { key(v, "diff-marker") } else {
      key(v, "code")
    }
    // (a comment with a marker starts at the code, after the gutter of the separated new code)
    let shift = if shift != auto { shift } else if (
      from == "new-gutter" and c.marker == none
    ) { gutter } else { 0pt }
    let c = c + (inset: ut.grow-inset(c.inset, extra))
    c.inset.left += shift
    // The commented line: the line before for a comment after it, the line after otherwise
    let cv = c.version
    let i = calc.clamp(
      if c.copy-before { c.gap - 1 } else { c.gap },
      0,
      versions.at(cv).status.len() - 1,
    )
    let ck = line-keys.at(cv).at(str(i), default: k)
    // (a comment without fill takes the background of the commented line)
    if not c.filled { c.fill = code-fill(cv, i, ck) }
    if c.marker == none {
      let f = framing(r, from, to)
      c.width = width-between(from, to)
      return (
        cell(from, to, comment-cell(
          c,
          height,
          f.radius,
          f.stroke + if from == "new-gutter" { (left: general.sep) },
          code.indentation,
          char-width,
          sep: sep,
        )),
      )
    }

    let fill = if c.marker-fill == auto { c.fill } else if (
      c.marker-fill == none
    ) { number-fill(cv, i, ck) } else { c.marker-fill }
    // (in the color of the numbers of the commented line)
    c.marker = number-color(cv, i, ck, c.marker)
    let cells = ()
    if from == "new-gutter" {
      cells.push(blank-cell(
        blank("new-gutter", "new-gutter"),
        r,
        1,
        fill: fill,
      ))
    }
    for gv in if same-code { ("old", "new") } else { (v,) } {
      if number.visible {
        cells.push(side(
          if gv == v and c.marker-placement == "numbers" { c.marker } else {
            []
          },
          versions.at(gv).numbers-width,
          versions.at(gv).number.inset,
          fill,
          center + number.align.y,
          height,
          extra,
          framing(r, key(gv, "numbers"), key(gv, "numbers")),
        ))
      }
    }
    if versions.at(v).marker.visible {
      cells.push(marker-cell(
        v,
        if c.marker-placement == "markers" { c.marker },
        fill,
        height,
        extra,
        framing(r, key(v, "markers"), key(v, "markers")),
      ))
    }
    // The width of the marker cells, and the stroke on their left
    let gutter-width = (
      width-between(from, to) - width-between(first-code-key, to)
    )
    let left-stroke = if from == "new-gutter" { general.sep } else {
      framing(r, from, to).stroke.at("left", default: none)
    }
    let f = framing(r, first-code-key, to)
    c.width = width-between(first-code-key, to)
    let body = comment-cell(
      c,
      height,
      f.radius,
      f.stroke,
      code.indentation,
      char-width,
      sep: sep,
      // (crossing the marker cells, before the comment cell)
      sep-start: -gutter-width + half-thickness(left-stroke),
    )
    cells.push(cell(first-code-key, to, if c.gutter-sep {
      with-sep(v, body, height)
    } else { body }))
    cells
  }

  let k = 0
  let row-cells = ()
  for (r, row) in rows.enumerate() {
    let height = row-heights.at(r)
    let extra = edge(r)
    let cells = ()

    if row.kind == "line" {
      k = row.k
      if same-code {
        let v = if row.new != none { "new" } else { "old" }
        if number.visible {
          for nv in ("old", "new") {
            let nk = key(nv, "numbers")
            cells.push(if row.at(nv) == none { blank(nk, nk) } else {
              number-cell(nv, row.at(nv), k, height, extra, framing(r, nk, nk))
            })
          }
        }
        if versions.new.marker.visible {
          let m = ("new", "old")
            .filter(mv => row.at(mv) != none)
            .map(mv => {
              let m = versions.at(mv).markers.at(row.at(mv))
              if m != none { number-color(mv, row.at(mv), k, m) }
            })
            .find(m => m != none)
          cells.push(marker-cell(
            "new",
            m,
            number-fill(v, row.at(v), k),
            height,
            extra,
            framing(r, "markers", "markers"),
          ))
        }
        cells += code-side-cells(v, row, k, r, height, extra)
      } else {
        for v in ("old", "new") {
          let from = if v == "new" and has("new-gutter") { "new-gutter" } else {
            first-key(v)
          }
          if from == "new-gutter" and row.new != none {
            cells.push(blank-cell(
              blank("new-gutter", "new-gutter"),
              r,
              1,
              fill: code-fill("new", row.new, k),
            ))
          }
          if row.at(v) == none {
            cells.push(blank(from, key(v, "code")))
            continue
          }
          if number.visible {
            cells.push(number-cell(
              v,
              row.at(v),
              k,
              height,
              extra,
              framing(r, key(v, "numbers"), key(v, "numbers")),
            ))
          }
          if versions.at(v).marker.visible {
            cells.push(marker-cell(
              v,
              number-color(
                v,
                row.at(v),
                k,
                versions.at(v).markers.at(row.at(v)),
              ),
              number-fill(v, row.at(v), k),
              height,
              extra,
              framing(r, key(v, "markers"), key(v, "markers")),
            ))
          }
          cells += code-side-cells(v, row, k, r, height, extra)
        }
      }
    } else if "span" in row {
      // A comment spanning over both separated codes (its marker being in the gutter of the old code), its text being at the same place as in its code
      let c = row.span
      cells += comment-cells(
        "old",
        c,
        k,
        first-key("old"),
        r,
        height,
        extra,
        to: keys.last(),
        shift: if c.version == "new" {
          (
            width-between(first-key("old"), "old-code")
              + gutter
              + if c.marker != none {
                pre-width("new") - pre-width("old")
              } else {
                0pt
              }
          )
        } else { 0pt },
      )
    } else if same-code {
      let v = if row.new != none { "new" } else { "old" }
      cells += comment-cells(v, row.at(v), k, keys.first(), r, height, extra)
    } else {
      for v in ("old", "new") {
        let from = if v == "new" and has("new-gutter") { "new-gutter" } else {
          first-key(v)
        }
        cells += if row.at(v) == none {
          (blank(from, key(v, "code")),)
        } else { comment-cells(v, row.at(v), k, from, r, height, extra) }
      }
    }
    row-cells.push(cells)
  }

  // The blank cells, merged with the ones of the same columns in the next rows
  let is-blank(c) = type(c) == dictionary
  let blanks = row-cells.map(cells => cells.filter(is-blank))
  let continues(c, r) = c in blanks.at(r)
  row-cells = row-cells
    .enumerate()
    .map(((r, cells)) => cells
      // (a blank continuing the one of the previous row is in its cell)
      .filter(c => not (is-blank(c) and r > 0 and continues(c, r - 1)))
      .map(c => if is-blank(c) {
        let n = 1
        while r + n < row-cells.len() and continues(c, r + n) { n += 1 }
        blank-cell(c, r, n)
      } else { c }))

  let cells = row-cells.flatten()
  let heights = row-heights
  let header-cell = header-cell(header, frame, keys.len())
  if header-cell != none {
    heights.insert(0, auto)
    cells.insert(0, header-cell)
  }

  let footer-cell = footer-cell(footer, frame, keys.len())
  if footer-cell != none {
    heights.push(auto)
    cells.push(footer-cell)
  }

  grid(columns: column-widths, rows: heights, ..cells)
}

// -----------------------------------------------------------------------------
// Lang tag on the frame
// -----------------------------------------------------------------------------

/// Return the vertical alignment of the lang tag.
///
/// - lt (dictionary):
/// -> alignment
#let lang-tag-alignment(lt) = {
  if lt.placement == "top-left" or lt.placement == "bottom-left" {
    left
  } else if lt.placement == "top" or lt.placement == "bottom" {
    center
  } else if lt.placement == "top-right" or lt.placement == "bottom-right" {
    right
  }
}

/// Return a placed object containing the lang tag.
///
/// - lt (dictionary):
/// - lt-block (block):
/// -> place
#let place-frame-lang-tag(lt, lt-block, frame) = {
  let x-align = if lt.placement.contains("left") { right } else { left }
  let y-align = if lt.placement.contains("top") {
    top
  } else if lt.placement.contains("bottom") { bottom } else { horizon }
  place(
    x-align + y-align,
    dx: if x-align == left { frame.width } else { -frame.width },
    lt-block,
  )
}
