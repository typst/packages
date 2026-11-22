#import "config.typ" as cf
#import "content.typ" as ct
#import "highlight.typ" as hl
#import "utils.typ" as ut

// -----------------------------------------------------------------------------
// Style
// -----------------------------------------------------------------------------

/// Apply a style saved with `outside-style`.
///
/// - style (dictionary): The text, paragraph and block settings.
/// - body (content):
/// -> content
#let with-style(style, body) = {
  set text(..style.text)
  set par(..style.par)
  set block(..style.block)
  body
}

// -----------------------------------------------------------------------------
// Frame
// -----------------------------------------------------------------------------

#let frame-width(frame, layout-size) = {
  if type(frame.width) == ratio {
    frame.width = layout-size.width * frame.width
  } else if type(frame.width) == relative {
    frame.width = layout-size.width * frame.width.ratio + frame.width.length
  }
  return frame
}

#let frame(frame, lang-tag, with-dst) = {
  frame.sharp-page-break = frame.sharp-page-break and frame.breakable

  frame.radius = ut.full-radius(frame.radius)
  if lang-tag.visible {
    if lang-tag.placement == "top-left" or lang-tag.placement == "left-top" {
      frame.radius.top-left = 0mm
    }
    if (
      lang-tag.placement == "bottom-left" or lang-tag.placement == "left-bottom"
    ) {
      frame.radius.bottom-left = 0mm
    }
    if lang-tag.placement == "top-right" or lang-tag.placement == "right-top" {
      frame.radius.top-right = 0mm
    }
    if (
      lang-tag.placement == "bottom-right"
        or lang-tag.placement == "right-bottom"
    ) {
      frame.radius.bottom-right = 0mm
    }
  }

  frame.stroke = with-dst(frame.stroke)
  frame.stroke = ut.full-stroke(frame.stroke)

  return frame
}

/// Draw the frame by its block (`frame.block`, which clips the cells), or with sharp page breaks (no radius at the page breaks) by its cells: the cells on the sides of the grid take its stroke and radius (`frame.stroke` and `frame.radius`), and the cells without fill its fill (see `coloring`).
///
/// -> array: the frame, the header and the footer
#let frame-block(frame, header, footer) = {
  if frame.sharp-page-break {
    frame.block = (fill: none, radius: (:), stroke: none)
  } else {
    frame.block = (fill: frame.fill, radius: frame.radius, stroke: frame.stroke)
    // (the sides of the cells stay the sides of the grid, without stroke)
    frame.radius = frame.radius.keys().map(k => (k, 0pt)).to-dict()
    frame.stroke = frame.stroke.keys().map(k => (k, none)).to-dict()
    header.radius = (:)
    footer.radius = (:)
    for side in ("top", "left", "right") { header.stroke.insert(side, none) }
    for side in ("bottom", "left", "right") { footer.stroke.insert(side, none) }
  }
  (frame, header, footer)
}

// -----------------------------------------------------------------------------
// Header & Footer
// -----------------------------------------------------------------------------

#let header-footer(
  header,
  footer,
  frame,
  code,
  lang-tag,
  base-style,
  nbr-lines,
  with-dst,
) = {
  header.insert(
    "tag",
    if lang-tag.visible and lang-tag.placement == "header" { lang-tag.block },
  )
  header.insert("tag-width", if header.tag != none { lang-tag.width })

  // (`auto` for the color of the code of the first or last line)
  let color(c, i) = if c == auto { (code.color)(i) } else { c }
  if header.content != none {
    header.content = ut.colored(
      color(header.color, -1),
      with-style(base-style(), header.content),
    )
  }
  if footer.content != none {
    footer.content = ut.colored(
      color(footer.color, nbr-lines),
      with-style(base-style(), footer.content),
    )
  }

  // (`none` for the fill of the frame, when it is not filled itself)
  header.fill = if header.fill == auto {
    (code.fill)(-1)
  } else if header.fill == none { code.frame-fill } else { header.fill }
  footer.fill = if footer.fill == auto {
    (code.fill)(nbr-lines)
  } else if footer.fill == none { code.frame-fill } else { footer.fill }

  header.inset = ut.full-inset(header.inset)
  if header.tag != none { header.inset.right += lang-tag.width }
  footer.inset = ut.full-inset(footer.inset)

  header.radius = (
    top-left: frame.radius.top-left,
    top-right: frame.radius.top-right,
  )
  footer.radius = (
    bottom-left: frame.radius.bottom-left,
    bottom-right: frame.radius.bottom-right,
  )

  header.sep = with-dst(header.sep)
  header.stroke = (
    top: frame.stroke.top,
    left: frame.stroke.left,
    right: frame.stroke.right,
    bottom: if header.sep == auto { frame.stroke.top } else { header.sep },
  )
  if header.stroke.bottom == none { let _ = header.stroke.remove("bottom") }
  if header.content != none { let _ = header.remove("sep") }
  footer.sep = with-dst(footer.sep)
  footer.stroke = (
    top: if footer.sep == auto { frame.stroke.bottom } else { footer.sep },
    left: frame.stroke.left,
    right: frame.stroke.right,
    bottom: frame.stroke.bottom,
  )

  return (header, footer)
}

/// Align the header and the footer with the code when they are `code-aligned`.
///
/// - header (dictionary): The formatted header parameters.
/// - footer (dictionary): The formatted footer parameters.
/// - pre-width (length): The width of the columns before the code.
/// -> array: the header and the footer parameters
#let align-header-footer(header, footer, pre-width, code) = {
  if header.remove("code-aligned") {
    header.inset.left = pre-width + code.inset.left
  }
  if footer.remove("code-aligned") {
    footer.inset.left = pre-width + code.inset.left
  }
  return (header, footer)
}

// -----------------------------------------------------------------------------
// Numbering
// -----------------------------------------------------------------------------

#let number(number, nbr-lines, jumps, with-dst) = {
  assert(
    number.format in (none, auto) or type(number.format) in (str, function),
    message: "The `format` of the numbers must be `none` (hidden), `auto`, a string or a function.",
  )
  assert(
    type(number.start) == int,
    message: "The `start` of the number must be an integer.",
  )
  number.start = if not number.visible {
    1
  } else if number.end != none {
    (
      number.end
        + 1
        - nbr-lines
        - jumps.map(j => j.to - j.from - 1).sum(default: 0)
    )
  } else {
    number.start
  }

  number.sep = with-dst(number.sep)

  return number
}

// The anchor of a line, labeled after the figure containing the code (if any) by its show rule
#let add-line-label(n, line-reference, version: none) = if (
  line-reference != none
) {
  [#metadata((
      uraw-line-anchor: (
        number: n,
        reference: line-reference,
        version: version,
      ),
    ))<uraw-line-anchor>]
}

/// The shown line number, with the number format applied.
///
/// - number (dictionary): The number parameters.
/// - n (int): The line number.
/// -> str, content
#let shown-number(number, n) = if number.format == auto {
  str(n)
} else if type(number.format) == str {
  let k = number.format.position("1")
  assert(
    k != none,
    message: "A number format given as a string must contain a `1`, replaced by the line number (as \"1:\").",
  )
  number.format.slice(0, k) + str(n) + number.format.slice(k + 1)
} else {
  let n = (number.format)(n)
  if type(n) == int { str(n) } else { n }
}

/// The line number and the widest marker given by `follows` or `precedes`: a line number, a marker, or both as a pair `(number, marker)`.
///
/// - value (bool, int, str, content, array): The value of `follows` or `precedes`.
/// - name (str): `"follows"` or `"precedes"`.
/// -> array: the line number and the marker (`none` when not given)
#let continuation(value, name) = {
  assert(
    type(value) in (bool, int, str, content)
      or (
        type(value) == array
          and value.len() == 2
          and type(value.first()) == int
          and type(value.last()) in (str, content)
      ),
    message: "`"
      + name
      + "` must be a boolean, "
      + if name == "follows" {
        "the last line number of the preceding block, the widest marker of the preceding blocks"
      } else {
        "the largest line number of the following blocks, their widest marker"
      }
      + " (as content), or both as a pair `(number, marker)`.",
  )
  if type(value) == array { value } else if type(value) == int {
    (value, none)
  } else if type(value) in (str, content) { (none, value) } else {
    (none, none)
  }
}

/// Format the number cells, a marker of `number-markers` taking the place of the number of its line.
///
/// - number (dictionary): The number parameters.
/// - general (dictionary): The general parameters.
/// - number-markers (array): The markers shown in the number column, for each line (`none` if it has none).
/// - line-numbers (array): The displayed line numbers.
/// -> dictionary: the number parameters, with the `cells` and whether each line has a marker in place of its number (`marked`)
#let number-cells(
  number,
  general,
  number-markers,
  line-numbers,
  version: none,
) = {
  number.cells = line-numbers
    .enumerate()
    .map(((i, n)) => if number-markers.at(i) != none {
      number-markers.at(i)
      add-line-label(n, general.line-reference, version: version)
    } else if n == none or not number.visible { [] } else {
      shown-number(number, n)
      add-line-label(n, general.line-reference, version: version)
    })
  number.marked = number-markers.map(m => m != none)

  return number
}

// The numbers of the shown lines, the index of a shown line number, and the indexes of the shown lines in the code (the lines skipped by the jumps not being shown)
#let line-numbers(number, nbr-lines, jumps, jumps-map) = {
  let line-numbers = ()
  let kept = ()
  let (i, n) = (0, number.start)
  // (a jump from `start` being taken before the first line)
  let j = jumps-map.at(str(n - 1), default: none)
  if j != none {
    if j.skip-lines { i += j.to - j.from - 1 }
    n = j.to
  }
  while i < nbr-lines {
    line-numbers.push(n)
    kept.push(i)
    let j = jumps-map.at(str(n), default: none)
    if j == none {
      (i, n) = (i + 1, n + 1)
    } else {
      if j.skip-lines {
        // (a jump to `end` skipping exactly the remaining lines)
        assert(
          i + j.to - j.from <= nbr-lines,
          message: "The jump from line "
            + str(j.from)
            + " to line "
            + str(j.to)
            + " skips lines after the end of the code.",
        )
        i += j.to - j.from
      } else { i += 1 }
      n = j.to
    }
  }

  for j in jumps {
    assert(
      j.from in line-numbers or j.from == number.start - 1,
      message: "The jump from line "
        + str(j.from)
        + " does not start from a line of the code block.",
    )
  }

  // The index of each line number (its first one), computed once
  let indexes = (:)
  for (i, d) in line-numbers.enumerate() {
    if d != none and str(d) not in indexes { indexes.insert(str(d), i) }
  }
  // (a jump from `start` comes after the line before the first one)
  if str(number.start - 1) in jumps-map {
    indexes.insert(str(number.start - 1), -1)
  }
  let line-index(n) = {
    let i = if type(n) == int { indexes.at(str(n), default: none) }
    assert(
      i != none,
      message: "The line " + str(n) + " is not displayed in the code block.",
    )
    i
  }

  return (line-numbers, line-index, kept)
}

// -----------------------------------------------------------------------------
// Marker
// -----------------------------------------------------------------------------

#let marker(general, number) = {
  let marker = (:)
  marker.over-numbers = general.markers-over-numbers and number.visible
  return marker
}

#let single-marker(marker, char-height) = if marker != none {
  box(
    height: char-height,
    align(horizon, marker),
  )
}

#let markers(line-markers, comments, marker, char-height) = {
  let line-markers = line-markers.map(m => single-marker(m, char-height))
  let comment-markers(placement) = comments
    .filter(c => c.marker != none and c.marker-placement == placement)
    .map(c => single-marker(c.marker, char-height))

  // The markers in the number column (by line), and all of them
  let number-markers = line-markers.map(m => if marker.over-numbers { m })
  let all-number-markers = (
    number-markers.filter(m => m != none) + comment-markers("numbers")
  )
  // The markers in the marker column (by line), and all of them
  let markers = line-markers.map(m => if not marker.over-numbers { m })
  let all-markers = markers.filter(m => m != none) + comment-markers("markers")

  marker.visible = all-markers.len() > 0
  marker.number-markers = all-number-markers
  marker.markers = all-markers

  return (number-markers, markers, marker)
}

// -----------------------------------------------------------------------------
// Code
// -----------------------------------------------------------------------------

#let code(code, frame, with-dst) = {
  code.indentation = with-dst(code.indentation)

  code.color = if code.color != auto { code.color }

  // The top and bottom of the frame inset are on the first and last lines
  let edge = ut.vertical-inset(frame.inset)
  code.edge = (
    top: edge.top.to-absolute(),
    bottom: edge.bottom.to-absolute(),
  )

  return code
}

/// The insets of the cells, left and right (their top and bottom being half the line spacing): the frame inset on the sides of the frame, between the number and marker columns (left) and between the diff marker and code columns (right), and the numbers gutter between the columns before the code and the code (the separator being between its two parts).
///
/// - frame (dictionary): The frame parameters.
/// - number (dictionary): The number parameters, with their visibility.
/// - marker-visible (bool): Whether the marker column is visible.
/// - line-spacing (length):
/// - diff-marker-visible (bool): Whether the diff marker column is visible.
/// -> dictionary: the insets of the `number`, `marker`, `diff-marker` and `code` cells
#let cell-insets(
  frame,
  number,
  marker-visible,
  line-spacing,
  diff-marker-visible: false,
) = {
  let (left, right) = ut.left-right-inset(frame.inset)
  // (the parts of the gutter before and after the separator, a length being split in two halves)
  let gutter = if number.gutter == auto { (left, right) } else if (
    type(number.gutter) == length
  ) { (number.gutter / 2,) * 2 } else { number.gutter }
  assert(
    type(gutter) == array
      and gutter.len() == 2
      and gutter.all(g => type(g) == length),
    message: "The `gutter` of the numbers must be auto, a length or an array of two lengths (before and after the separator).",
  )
  let (before, after) = gutter
  let first = if number.visible or marker-visible { after } else { left }
  (
    number: (left: left, right: if marker-visible { 0pt } else { before }),
    marker: (left: left, right: before),
    diff-marker: (left: first, right: 0pt),
    code: (left: if diff-marker-visible { right } else { first }, right: right),
  )
    .pairs()
    .map(((k, inset)) => (k, ut.line-inset(inset, line-spacing)))
    .to-dict()
}

// -----------------------------------------------------------------------------
// Coloring
// -----------------------------------------------------------------------------

#let coloring(
  number,
  code,
  general,
  frame,
  line-numbers,
  nbr-lines,
) = {
  number.true-number = i => if (
    number.visible
      and general.coloring-follow-numbers
      and nbr-lines > 0
      and line-numbers.len() > 0
  ) {
    if i < 0 {
      line-numbers.first() + i
    } else if i >= nbr-lines {
      line-numbers.last() + i - nbr-lines + 1
    } else {
      line-numbers.at(i)
    }
  } else { i + 1 }

  // The fills and colors given as functions of the line number
  let per-line(f) = if type(f) == function {
    i => f((number.true-number)(i))
  } else { i => f }
  // With sharp page breaks, the frame is not filled (its fill would be rounded at the page breaks): the cells without fill take its fill
  code.frame-fill = if frame.sharp-page-break { frame.fill }
  let or-frame(c) = if c == none { code.frame-fill } else { c }
  let code-fill = per-line(code.fill)
  code.fill = i => or-frame(code-fill(i))
  code.color = per-line(code.color)
  // (`auto` for the ones of the code)
  let numbers-fill = per-line(number.fill)
  number.fill = i => {
    let c = numbers-fill(i)
    if c == auto { (code.fill)(i) } else { or-frame(c) }
  }
  let numbers-color = per-line(number.color)
  number.color = (i, it) => {
    let c = numbers-color(i)
    ut.colored(if c == auto { (code.color)(i) } else { c }, it)
  }

  return (number, code)
}

// -----------------------------------------------------------------------------
// Lang tag
// -----------------------------------------------------------------------------

/// Check that the placement of the lang tag is correct.
///
/// - plcmt (str):
/// -> none
#let check-lang-tag-placement(plcmt) = assert(
  plcmt == "code"
    or plcmt == "header"
    or plcmt == "inline"
    or plcmt == "top-left"
    or plcmt == "top"
    or plcmt == "top-right"
    or plcmt == "left-top"
    or plcmt == "left"
    or plcmt == "left-bottom"
    or plcmt == "right-top"
    or plcmt == "right"
    or plcmt == "right-bottom"
    or plcmt == "bottom-left"
    or plcmt == "bottom"
    or plcmt == "bottom-right",
  message: "Wrong placement for the language tag.",
)

/// Return for every position whether the lang tag occupies it.
///
/// - lt (dictionary):
/// -> array
#let lang-tag-position(lt) = {
  let is-top = (
    lt.placement == "top-left"
      or lt.placement == "top"
      or lt.placement == "top-right"
  )
  let is-left = (
    lt.placement == "left-top"
      or lt.placement == "left"
      or lt.placement == "left-bottom"
  )
  let is-right = (
    lt.placement == "right-top"
      or lt.placement == "right"
      or lt.placement == "right-bottom"
  )
  let is-bottom = (
    lt.placement == "bottom-left"
      or lt.placement == "bottom"
      or lt.placement == "bottom-right"
  )

  assert(
    is-top or is-left or is-right or is-bottom,
    message: "The placement of the language tag should be a string among the following: 'top-left', 'top', 'top-right', 'left-top', 'left', 'left-bottom', 'right-top', 'right', 'right-bottom', 'bottom-left', 'bottom' or 'bottom-right'.",
  )

  return (is-top, is-left, is-right, is-bottom)
}

/// Return a dictionary containing no or one field. If applied to a dictionary, it keeps the field of the dictionary if it was present, otherwise create a dictionary with that field and value the input.
///
/// - d ():
/// - k (str): The name of the field.
/// -> dictionary
#let field-of(d, k) = if type(d) == dictionary {
  if k in d { ((k): d.at(k)) } else { (:) }
} else {
  let nd = (:)
  nd.insert(k, d)
  nd
}

#let lang-tag-content(lang, lt) = box(
  height: .8em,
  ut.colored(lt.color, {
    let name = if lt.name != auto { lt.name } else { lang }
    if lt.icon != none and name != none {
      (
        box(lt.icon)
          + h(.2em)
          + if (
            (type(name) == str and not name.contains(regex("[A-Z0-9]")))
              or (
                type(name) == content
                  and "text" in name.fields()
                  and not name.text.contains(regex("[A-Z0-9]"))
              )
          ) { box(move(dy: -0.1em, name)) } else { name }
      )
    } else if name != none { name } else { lt.icon }
  }),
)

/// Create the lang tag.
///
/// - lang (str): The language of the raw code.
/// - lt (dictionary): The lang tag parameters.
/// - frame (dictionary): The frame parameters.
/// -> block
#let lang-tag-block(lang, lt, frame) = {
  if not lt.visible { return none }
  let ltc = lang-tag-content(lang, lt)

  if lt.visible and lt.placement not in ("code", "inline", "header") {
    let (is-top, is-left, is-right, is-bottom) = lang-tag-position(lt)

    let r = lt.radius
    let radius = (
      if is-top {
        field-of(r, "top-left") + field-of(r, "top-right")
      } else if is-left {
        field-of(r, "top-left") + field-of(r, "bottom-left")
      } else if is-right {
        field-of(r, "top-right") + field-of(r, "bottom-right")
      } else if is-bottom {
        field-of(r, "bottom-left") + field-of(r, "bottom-right")
      }
    )

    let frame-stroke = (
      if is-top { frame.stroke.top } else if is-left {
        frame.stroke.left
      } else if is-right { frame.stroke.right } else if is-bottom {
        frame.stroke.bottom
      }
    )

    let fill = if lt.fill == auto { frame.fill } else { lt.fill }

    block(
      stroke: if lt.stroke == auto { frame-stroke } else { lt.stroke },
      fill: fill,
      radius: radius,
      inset: .25em,
      if is-left { rotate(-90deg, reflow: true, ltc) } else if is-right {
        rotate(90deg, reflow: true, ltc)
      } else { ltc },
    )
  } else if lt.visible {
    block(
      height: 1.2em,
      stroke: if lt.stroke == auto { none } else { lt.stroke },
      fill: if lt.fill == auto { none } else { lt.fill },
      radius: lt.radius,
      inset: 0.2em,
      ltc,
    )
  }
}

#let lang-tag(lang-tag, lang, frame, header, with-dst) = {
  if lang-tag.visible {
    check-lang-tag-placement(lang-tag.placement)
  }

  if lang-tag.placement == "header" and header.content == none {
    lang-tag.placement = "code"
  }
  lang-tag.insert(
    "in-code",
    lang-tag.placement == "code" or lang-tag.placement == "inline",
  )
  lang-tag.insert("in-header", lang-tag.placement == "header")
  lang-tag.insert(
    "on-frame",
    lang-tag.placement not in ("code", "inline", "header"),
  )

  lang-tag.stroke = with-dst(lang-tag.stroke)

  return lang-tag
}

// -----------------------------------------------------------------------------
// Lines
// -----------------------------------------------------------------------------

/// The lines of a raw element: their content, their text, the positions of their indentation levels (in characters) and their end.
///
/// - it (content): The raw element.
/// - code (dictionary): The code parameters.
/// -> array
#let lines(it, code) = {
  // The number of spaces of an indentation level, inferred from the lines (or the tab size of the raw element when they are not indented)
  let indent-size = if code.indent-size == auto {
    ct.infer-indent-size(it.lines.map(l => l.text), it.tab-size)
  } else { code.indent-size }
  assert(
    type(indent-size) == int and indent-size > 0,
    message: "The `indent-size` of the code must be auto or a positive integer (a number of spaces).",
  )

  let lines = it.lines.map(l => if ct.is-whitespace-line(l.text) {
    (line: [], text: "", pos-indent: (0,), line-end: 0)
  } else {
    let num-indent = ct.get-text-indent(l.text, indent-size)
    let pos-indent = range(num-indent + 1).map(i => i * indent-size)
    (
      line: l.body,
      text: l.text,
      pos-indent: pos-indent,
      line-end: ct.text-len(l.text),
    )
  })

  // The blank lines have the indentation of the next line
  let i = lines.len() - 2
  while 0 <= i {
    if lines.at(i).text.len() == 0 {
      lines.at(i).pos-indent = lines.at(i + 1).pos-indent
    }
    i -= 1
  }

  return lines
}

/// Break the lines in sub-lines fitting in the code width.
///
/// - lines (array): The lines (see `lines`).
/// - code-width (length): The width of the code.
/// - lang-tag (dictionary): The lang tag parameters, with its `width`.
/// - char-width (length):
/// - indented (bool): Whether the sub-lines after the first one start at the indentation of the line (when it leaves at least half of the width).
/// -> array
#let break-lines(lines, code-width, lang-tag, char-width, indented: false) = {
  let width = (
    code-width
      + if lang-tag.visible and lang-tag.placement == "code" {
        -lang-tag.width
      }
  )
  // The positions of the columns of a line, measured when its characters are not all `char-width` wide (as the characters of some scripts and the emojis)
  // (a word joiner ends the measured parts, so that their trailing spaces are kept)
  let columns-x(l) = {
    let x(c) = measure([#c#sym.wj]).width
    if calc.abs(x(l.line) - l.line-end * char-width) < .01pt { return none }
    range(l.line-end + 1).map(c => x(ct.content-split-pos(l.line, c).first()))
  }
  lines
    .enumerate()
    .map(((i, l)) => {
      let indent = if indented { l.pos-indent.last() } else { 0 }
      if indent * char-width > width / 2 { indent = 0 }
      let xs = columns-x(l)
      let slines = ct.format-line(
        l.line,
        width,
        char-width,
        l.line-end,
        if lang-tag.placement == "inline" and i == 0 { lang-tag.width },
        indent: indent,
        xs: xs,
      )
      // The positions of the columns of each sub-line, from its start
      if xs != none {
        slines = slines.map(sl => {
          let cols = xs.slice(sl.start, calc.min(sl.end, l.line-end) + 1)
          sl + (xs: cols.map(x => x - cols.first()))
        })
      }
      (
        line: l.line,
        slines: slines,
        pos-indent: l.pos-indent,
        line-end: l.line-end,
      )
    })
}

// -----------------------------------------------------------------------------
// Highlights
// -----------------------------------------------------------------------------

/// Resolve the highlights: the lines of the manual ones become indexes, the automatic columns are computed, and they are checked.
///
/// - manual (array): The manual highlights (on displayed line numbers).
/// - delimited (array): The highlights read from the delimiters (on line indexes).
/// - lines (array): The lines (see `lines`).
/// - line-index (function): The index of a displayed line number.
/// -> array: the highlights, the last ones first
#let highlights(manual, delimited, lines, line-index, with-dst) = {
  let manual = manual.map(h => {
    h.range.first().first() = line-index(h.range.first().first())
    h.range.last().first() = line-index(h.range.last().first())
    h
  })

  let highlights = hl
    .merge-right-sort-highlights(manual, delimited)
    .map(h => {
      if h.range.first().last() == auto {
        h.range.first().last() = lines
          .at(h.range.first().first())
          .pos-indent
          .last()
      }
      if h.range.last().last() == auto {
        h.range.last().last() = lines.at(h.range.last().first()).line-end
      }
      h.stroke = with-dst(h.stroke)
      h
    })

  let _ = highlights.map(hl.check-highlight)

  return highlights.rev()
}

/// Group the highlights by line, with the highlight blocks touching each other.
///
/// - highlights (array): The resolved highlights (see `highlights`).
/// - lines (array): The lines broken in sub-lines (see `break-lines`).
/// - code-width (length):
/// - code (dictionary): The code parameters.
/// - char-width (length):
/// -> array: for each line, its highlights
#let highlights-by-line(highlights, lines, code-width, code, char-width) = {
  let by-line = lines.map(_ => ())
  for h in highlights {
    let (first, last) = (h.range.first().first(), h.range.last().first())
    h.touches = hl.compute-touches(
      h,
      lines.slice(first, last + 1),
      code-width,
      code.inset,
      char-width,
    )
    for i in range(first, last + 1) { by-line.at(i).push(h) }
  }
  return by-line
}

// -----------------------------------------------------------------------------
// Comments
// -----------------------------------------------------------------------------

#let single-comment(comment, gap, key, numbers, code, base-style, with-dst) = {
  let comment = comment + (gap: gap, key: key)

  // A comment separated from the code (`separate` is not `false`) is drawn over it, with its separators above and below (drawn only against code lines and comments without separator on the shared side); otherwise it is drawn under the code, whose numbers separator and guidelines go through it
  let sep = comment.at("separate", default: false)
  comment.separated = sep != false
  if sep == false { sep = none } else if sep == true or sep == auto {
    sep = numbers.sep
  }
  let per-side = (
    type(sep) == dictionary
      and sep.len() > 0
      and sep.keys().all(k => k in ("top", "bottom"))
  )
  if per-side {
    sep = sep.map(s => (
      if s == true { numbers.sep } else if s == false { none } else { s }
    ))
  } else {
    sep = (top: sep, bottom: sep)
  }
  comment.sep = (
    top: with-dst(sep.at("top", default: none)),
    bottom: with-dst(sep.at("bottom", default: none)),
  )
  for s in comment.sep.values() {
    assert(
      s == none or type(s) == stroke,
      message: "The `separate` setting of a comment must be a boolean, `auto`, `none`, a stroke or a dictionary with a `top` and a `bottom` stroke.",
    )
  }

  assert(
    type(comment.indent) == bool,
    message: "The `indent` of a comment must be a boolean.",
  )
  assert(
    comment.marker-placement in ("numbers", "markers"),
    message: "The `placement` of a comment marker must be \"numbers\" or \"markers\".",
  )
  // Without numbers, the marker is in the marker column
  if not numbers.visible { comment.marker-placement = "markers" }
  // Under the code, an indented comment shows the numbers separator: it gets an empty marker, its part in the gutter being then a marker cell
  if not comment.separated and comment.indent and comment.marker == none {
    comment.marker = []
  }
  // The numbers separator is drawn beside the marker of a comment under the code
  comment.gutter-sep = not comment.separated and comment.marker != none
  // A comment with a marker starts after the gutter, so at the start of the code
  comment.in-code = comment.indent or comment.marker != none
  comment.indented = comment.indent
  comment.to-indent = comment.indent and not comment.separated

  // Without fill, the comment looks like the commented line: it takes its background (given when rendering), and its marker the one of its number
  comment.filled = comment.fill != none
  if not comment.filled and comment.marker-fill == auto {
    comment.marker-fill = none
  }

  let body = comment.content
  if comment.style != none { body = (comment.style)(body) }
  // The comments look as they would outside of the raw block, in the color of the code of the line before them (which their style overrides)
  let color = (code.color)(gap - 1)
  comment.body = ut.colored(color, with-style(base-style(), body))
  // (the marker being colored as the numbers when rendered)
  // if comment.marker != none {
  //   comment.marker = with-style(base-style(), comment.marker)
  // }

  return comment
}

// The comments of the jumps (the style of a comment being given by its content, a jump has no comment `style`). A jump gives its comment settings as a comment (e.g. `fill`), and the `jump` settings with a `comment-` prefix.
#let jump-comments(jumps, jump, comment, line-index, format) = {
  jumps
    .map(j => {
      let j = ut.known-keys(
        j,
        ("from", "to", "skip-lines", "comment")
          + comment.keys().filter(k => k != "style"),
      )

      let settings = (:)
      for k in comment.keys() {
        let v = j.at(k, default: jump.at(k))
        settings.insert(k, if v == auto { comment.at(k) } else { v })
      }

      let content = j.at("comment", default: jump.comment)
      if type(content) == function { content = content(j.from, j.to) }
      if content != none {
        format(
          settings
            + (
              content: content,
              copy-before: true,
            ),
          if j.from == start { 0 } else { line-index(j.from) + 1 },
          none,
        )
      }
    })
    .filter(c => c != none)
}

// The comments (the style of a comment being given by its content, a comment has no `style`)
#let comments(comments, comment, line-numbers, format) = {
  // (a for loop rather than a closure, whose captured line numbers would be hashed at each call)
  let formatted = ()
  for c in ut.single-to-list(comments) {
    let c = c
    if type(c) == array {
      assert(
        c.len() == 2,
        message: "A comment given as an array must be of the form `(line, content)`.",
      )
      c = (after: c.at(0), content: c.at(1))
    }
    assert(
      type(c) == dictionary
        and ("after" in c or "before" in c)
        and "content" in c,
      message: "A comment must have an `after` or `before` line and a `content`.",
    )
    c = ut.known-keys(c, comment.keys() + ("after", "before", "content"))

    let after = "after" in c
    let n = if after { c.after } else { c.before }
    assert(
      type(n) == int,
      message: "The `after` or `before` line of a comment must be an integer.",
    )

    // The number of lines before the comment, by binary search (the line numbers increasing)
    let (lo, hi) = (0, line-numbers.len())
    while lo < hi {
      let mid = calc.quo(lo + hi, 2)
      let d = line-numbers.at(mid)
      if d < n or (after and d == n) { lo = mid + 1 } else { hi = mid }
    }

    formatted.push(format(
      ut.filter-add-dict(comment, c)
        + (
          content: c.content,
          copy-before: after,
        ),
      lo,
      if after { 2 * n } else { 2 * n - 1 },
    ))
  }
  formatted.sorted(key: c => c.key)
}

/// Place the comments horizontally: their indentation and their insets.
///
/// - comments (array): The formatted comments.
/// - lines (array): The lines (see `lines`).
/// - number (dictionary): The number parameters.
/// - code (dictionary): The code parameters.
/// - numbers-width (length): The width of the number column.
/// - pre-width (length): The width of the gutter (the columns before the code: numbers and markers).
/// - gutter-inset (dictionary): The inset of the first column of the gutter.
/// - char-width (length):
/// - code-start (auto, length): The start of the code (after the diff markers of diffs), the end of the gutter by default.
/// -> array
#let comments-position(
  comments,
  lines,
  code,
  pre-width,
  gutter-inset,
  char-width,
  code-start: auto,
) = comments.map(c => {
  let code-start = if code-start == auto { pre-width } else { code-start }
  // An indented comment takes the indentation of the line before it (or after it for `before`)
  // (unless it is already given, as for pseudo code)
  if c.indented and not "pos-indent" in c {
    let k = if c.copy-before { c.gap - 1 } else { c.gap }
    c.pos-indent = if 0 <= k and k < lines.len() {
      lines.at(k).pos-indent
    } else { () }
  }

  // The comment cell starts after the gutter when it has a marker (the marker being in the gutter), at the left of the frame otherwise
  let cell-start = if c.marker != none { pre-width } else { 0mm }
  // The horizontal position of the code in the comment cell
  c.code-offset = code-start - cell-start
  let indent = if c.indented and c.pos-indent.len() > 0 {
    c.pos-indent.last() * char-width
  } else { 0mm }
  let left = if c.in-code {
    c.code-offset + code.inset.left + indent
  } else if code-start.to-absolute() > 0mm {
    gutter-inset.left
  } else { code.inset.left }
  c.inset = (
    left: left,
    right: code.inset.right,
    top: code.inset.top,
    bottom: code.inset.bottom,
  )
  c
})

/// Size the comments (once the code width is known) and group them by gap (the gap `k` is before the line of index `k`).
///
/// - comments (array): The placed comments (see `comments-position`).
/// - code (dictionary): The code parameters.
/// - code-width (length):
/// - number (dictionary): The number parameters.
/// - numbers-width (length): The width of the number column.
/// - marker (dictionary): The marker column parameters.
/// - markers-width (length): The width of the marker column.
/// - nbr-lines (int):
/// -> array
#let comments-by-gap(
  comments,
  code,
  code-width,
  number,
  numbers-width,
  marker,
  markers-width,
  nbr-lines,
) = {
  let by-gap = range(nbr-lines + 1).map(_ => ())
  for c in comments {
    c.insert(
      "width",
      c.code-offset + code.inset.left + code-width + code.inset.right,
    )
    let body-height = measure(width: c.width, block(
      inset: c.inset,
      c.body,
    )).height
    // The marker of a comment is in the number or the marker column
    c.height = if c.marker != none {
      let (width, inset) = if c.marker-placement == "numbers" {
        (numbers-width, number.inset)
      } else { (markers-width, marker.inset) }
      calc.max(
        body-height,
        measure(width: width, block(inset: inset, c.marker)).height,
      )
    } else { body-height }
    by-gap.at(c.gap).push(c)
  }
  return by-gap
}

// -----------------------------------------------------------------------------
// Jumps
// -----------------------------------------------------------------------------

// The jumps, checked, with whether they skip their lines (`skip-lines`, `false` by default), and stored by starting line
#let jumps(jumps, number, nbr-lines, skip-lines: false) = {
  jumps = ut
    .single-to-list(jumps)
    .map(j => {
      let j = j
      if type(j) == array {
        assert(
          j.len() == 2,
          message: "A jump given as an array must be of the form `(from, to)`.",
        )
        j = (from: j.at(0), to: j.at(1))
      }
      assert(
        type(j) == dictionary and "from" in j and "to" in j,
        message: "A jump must have a `from` and a `to` line.",
      )
      assert(
        (type(j.from) == int or j.from == start)
          and (type(j.to) == int or j.to == end),
        message: "The `from` and `to` lines of a jump must be integers (or `start` and `end`).",
      )
      j.skip-lines = j.at("skip-lines", default: skip-lines)
      assert(
        type(j.skip-lines) == bool,
        message: "The `skip-lines` of a jump must be a boolean.",
      )
      assert(
        j.to != end or j.skip-lines,
        message: "A jump to `end` must skip its lines.",
      )
      j
    })
    // Without numbers, only the jumps skipping lines have an effect
    .filter(j => number.visible or j.skip-lines)

  // A jump from `start` starts before the first line, and a jump to `end` skips the lines after its start
  let s = if number.visible { number.start } else { 1 }
  assert(
    not number.visible
      or number.end == none
      or jumps.all(j => j.from != start and j.to != end),
    message: "The numbers cannot have an `end` with jumps from `start` or to `end`.",
  )
  jumps = jumps
    .map(j => if j.from == start { j + (from: s - 1) } else { j })
    .sorted(key: j => j.from)
  // (the index of a line in the code is its number, minus the numbers jumped by the previous jumps not skipping lines)
  let jumped = 0
  for (k, j) in jumps.enumerate() {
    if j.to == end {
      jumps.at(k).to = j.from + nbr-lines - (j.from - s - jumped)
    } else if not j.skip-lines { jumped += j.to - j.from - 1 }
  }
  for j in jumps {
    assert(
      j.from < j.to,
      message: "The jump from line "
        + str(j.from)
        + " to line "
        + str(j.to)
        + " must go forward.",
    )
  }

  // Store jumps at their starting line
  let jumps-map = (:)
  for j in jumps {
    assert(
      not str(j.from) in jumps-map,
      message: "Several jumps start from line " + str(j.from) + ".",
    )
    jumps-map.insert(str(j.from), j)
  }

  // Sort the jumps and verify than none overlap
  let sorted-jumps = jumps.sorted(key: j => j.from)
  for k in range(sorted-jumps.len() - 1) {
    let (j1, j2) = (sorted-jumps.at(k), sorted-jumps.at(k + 1))
    assert(
      j1.to <= j2.from,
      message: "The jump from line "
        + str(j1.from)
        + " to line "
        + str(j1.to)
        + " overlaps the jump from line "
        + str(j2.from)
        + " to line "
        + str(j2.to)
        + ".",
    )
  }

  return (jumps, jumps-map)
}

// The number of lines skipped by the jumps
#let nbr-skipped(jumps) = (
  jumps.filter(j => j.skip-lines).map(j => j.to - j.from - 1).sum(default: 0)
)

// The highlights of the kept lines (see `highlights-by-line`, on all the lines of the code), drawn as if the skipped lines were shown: their ends on skipped lines stay open
#let kept-highlights(by-line, kept) = {
  let index = kept.enumerate().map(((k, i)) => (str(i), k)).to-dict()
  // For each line, the index of the first kept line from it and of the last kept line up to it (computed once, the kept lines being sorted)
  let (first-from, last-upto) = ((), ())
  let k = 0
  for l in range(by-line.len()) {
    while k < kept.len() and kept.at(k) < l { k += 1 }
    first-from.push(k)
    last-upto.push(if k < kept.len() and kept.at(k) == l { k } else { k - 1 })
  }
  // (for loops rather than closures, whose captured arrays would be hashed at each call)
  let kept-by-line = ()
  for i in kept {
    let hls = ()
    for h in by-line.at(i) {
      let ((l1, c1), (l2, c2)) = h.range
      let k1 = first-from.at(l1)
      let k2 = last-upto.at(l2)
      h.open-start = kept.at(k1) != l1
      h.open-end = kept.at(k2) != l2
      h.range = ((k1, c1), (k2, c2))
      // The blocks touching the ones of the kept lines can be on skipped lines
      let touches = (:)
      for (key, t) in h.touches {
        let (j, k) = key.split("-")
        if j in index { touches.insert(hl.block-key(index.at(j), int(k)), t) }
      }
      h.touches = touches
      hls.push(h)
    }
    kept-by-line.push(hls)
  }
  kept-by-line
}

// -----------------------------------------------------------------------------
// Pseudo code
// -----------------------------------------------------------------------------

/// Mark pseudo code, so that the figures containing it can be detected.
///
/// - algorithm-figure (auto, bool): Whether the figure is an algorithm, `auto` to use the configured setting.
#let pseudo-marker(algorithm-figure) = metadata((
  uraw-pseudo: (algorithm-figure: algorithm-figure),
))

/// The value of the pseudo code marker in some content, `none` if there is none.
#let find-pseudo-marker(body) = {
  if type(body) != content { return none }
  if (
    body.func() == metadata
      and type(body.value) == dictionary
      and "uraw-pseudo" in body.value
  ) {
    return body.value.uraw-pseudo
  }
  if body.has("children") {
    for child in body.children {
      let m = find-pseudo-marker(child)
      if m != none { return m }
    }
    return none
  }
  if body.has("body") { return find-pseudo-marker(body.body) }
  if body.has("child") { return find-pseudo-marker(body.child) }
  none
}

/// Split pseudo code in lines and comments: each item of its numbered list is a line, its nested items being indented by one more level, and each comment (`pseudo-comment`, `pseudo-info`) is placed where it is written.
///
/// - body (content): The numbered list of the lines (`+ ...`), with comments.
/// -> array: the lines, as dictionaries with a `body` (content) and a `level` (int), and the comments, as dictionaries with their `settings` (and `content`), their `gap` (the number of lines before them) and the `level` where they are written
#let pseudo-lines(body) = {
  let children(it) = if it.func() == [].func() { it.children } else { (it,) }
  let blank(it) = it.func() in ([ ].func(), parbreak)
  let is-comment(it) = (
    it.func() == metadata
      and type(it.value) == dictionary
      and "uraw-pseudo-comment" in it.value
  )

  // (the lines before the items being `before`)
  let parse(items, level, before) = {
    let (lines, comments) = ((), ())
    for it in items {
      if blank(it) { continue }
      if it.func() == enum.item {
        // The content of the item (its line), then its nested lines and comments
        let cs = children(it.body)
        let k = cs.position(c => c.func() == enum.item or is-comment(c))
        let (own, nested) = if k == none { (cs, ()) } else {
          (cs.slice(0, k), cs.slice(k))
        }
        while own.len() > 0 and blank(own.first()) { own = own.slice(1) }
        while own.len() > 0 and blank(own.last()) { let _ = own.pop() }
        lines.push((body: own.sum(default: []), level: level))
        let (l, c) = parse(nested, level + 1, before + lines.len())
        lines += l
        comments += c
      } else if is-comment(it) {
        comments.push((
          settings: it.value.uraw-pseudo-comment,
          gap: before + lines.len(),
          level: level,
        ))
      } else {
        panic(
          "The lines of pseudo code are the items of a numbered list (`+ ...`), with comments (`pseudo-comment`, `pseudo-info`).",
        )
      }
    }
    (lines, comments)
  }

  parse(children(body), 0, 0)
}

/// The content of a line of pseudo code, indented and styled.
///
/// - l (dictionary): The line (see `pseudo-lines`).
/// - code (dictionary): The code parameters, with an absolute `indent-size`.
/// -> content
#let pseudo-line-body(l, code) = pad(
  left: l.level * code.indent-size,
  if code.style != none { (code.style)(l.body) } else { l.body },
)

// -----------------------------------------------------------------------------
// Diff
// -----------------------------------------------------------------------------

// The longest common subsequence of two arrays, as operations: `("=", i, j)` for common elements, `("-", i, none)` for removed ones and `("+", none, j)` for added ones
#let lcs-ops(a, b) = {
  let (n, m) = (a.len(), b.len())

  // The common prefix and suffix
  let p = 0
  while p < n and p < m and a.at(p) == b.at(p) { p += 1 }
  let q = 0
  while q < n - p and q < m - p and a.at(n - 1 - q) == b.at(m - 1 - q) {
    q += 1
  }

  let (a2, b2) = (a.slice(p, n - q), b.slice(p, m - q))
  let (n2, m2) = (a2.len(), b2.len())

  // The lengths of the longest common subsequences of the suffixes
  let w = m2 + 1
  let t = range((n2 + 1) * w).map(_ => 0)
  for i in range(n2 - 1, -1, step: -1) {
    for j in range(m2 - 1, -1, step: -1) {
      t.at(i * w + j) = if a2.at(i) == b2.at(j) {
        t.at((i + 1) * w + j + 1) + 1
      } else {
        calc.max(t.at((i + 1) * w + j), t.at(i * w + j + 1))
      }
    }
  }

  let ops = range(p).map(k => ("=", k, k))
  let (i, j) = (0, 0)
  while i < n2 or j < m2 {
    if i < n2 and j < m2 and a2.at(i) == b2.at(j) {
      ops.push(("=", p + i, p + j))
      i += 1
      j += 1
    } else if (
      j >= m2 or (i < n2 and t.at((i + 1) * w + j) >= t.at(i * w + j + 1))
    ) {
      ops.push(("-", p + i, none))
      i += 1
    } else {
      ops.push(("+", none, p + j))
      j += 1
    }
  }
  ops + range(q).map(k => ("=", n - q + k, m - q + k))
}

// The tokens of a line, with their positions in characters: the separating characters (one token each), the words, the spaces and the chains of other symbols
#let tokenize(s) = (
  s
    .matches(regex(
      "[\",;_\\-(){}\\[\\]']|[^\\W_]+|\\s+|[^\\w\\s\",;\\-(){}\\[\\]']+",
    ))
    .map(m => {
      let start = ct.text-len(s.slice(0, m.start))
      (text: m.text, start: start, end: start + ct.text-len(m.text))
    })
)

// The ranges of the changed tokens, the spaces between changed tokens being changed too, but not the ones at the ends
#let changed-ranges(tokens, changed) = {
  let is-space(k) = tokens.at(k).text.trim() == ""
  let n = tokens.len()

  for k in range(n) {
    if not changed.at(k) and is-space(k) {
      let prev = k > 0 and changed.at(k - 1)
      let next = k < n - 1 and changed.at(k + 1)
      if prev and next { changed.at(k) = true }
    }
  }

  let ranges = ()
  let k = 0
  while k < n {
    if changed.at(k) {
      let e = k
      while e + 1 < n and changed.at(e + 1) { e += 1 }
      let (s2, e2) = (k, e)
      while s2 <= e2 and is-space(s2) { s2 += 1 }
      while e2 >= s2 and is-space(e2) { e2 -= 1 }
      if s2 <= e2 { ranges.push((tokens.at(s2).start, tokens.at(e2).end)) }
      k = e + 1
    } else {
      k += 1
    }
  }
  ranges
}

// The changed ranges of two lines replacing each other, `none` if they are too different
#let line-diff(old-text, new-text) = {
  let (a, b) = (tokenize(old-text), tokenize(new-text))
  let ops = lcs-ops(a.map(t => t.text), b.map(t => t.text))

  // The similarity of the lines, on the characters which are not spaces
  let size(t) = ct.text-len(t.text.replace(regex("\s"), ""))
  let common = ops
    .filter(op => op.at(0) == "=")
    .map(op => size(a.at(op.at(1))))
    .sum(default: 0)
  let total = a.map(size).sum(default: 0) + b.map(size).sum(default: 0)
  if total == 0 or 2 * common / total < .5 { return none }

  let old-changed = a.map(_ => true)
  let new-changed = b.map(_ => true)
  for op in ops.filter(op => op.at(0) == "=") {
    old-changed.at(op.at(1)) = false
    new-changed.at(op.at(2)) = false
  }

  (old: changed-ranges(a, old-changed), new: changed-ranges(b, new-changed))
}

// The difference between two codes: the `items` (`(kind: "same", old: i, new: j)` or `(kind: "hunk", dels: .., adds: ..)`), for each version the `status` of its lines (`"same"`, `"mod"` or `"whole"`) and the changed `ranges` of the modified lines
#let compute-diff(old-texts, new-texts) = {
  let items = ()
  let (dels, adds) = ((), ())
  for op in lcs-ops(old-texts, new-texts) {
    if op.at(0) == "=" {
      if dels.len() + adds.len() > 0 {
        items.push((kind: "hunk", dels: dels, adds: adds))
        (dels, adds) = ((), ())
      }
      items.push((kind: "same", old: op.at(1), new: op.at(2)))
    } else if op.at(0) == "-" {
      dels.push(op.at(1))
    } else {
      adds.push(op.at(2))
    }
  }
  if dels.len() + adds.len() > 0 {
    items.push((kind: "hunk", dels: dels, adds: adds))
  }

  let diff = (
    items: items,
    old: (status: old-texts.map(_ => "same"), ranges: old-texts.map(_ => ())),
    new: (status: new-texts.map(_ => "same"), ranges: new-texts.map(_ => ())),
  )

  for item in items {
    if item.kind == "same" { continue }
    for i in item.dels { diff.old.status.at(i) = "whole" }
    for j in item.adds { diff.new.status.at(j) = "whole" }

    // The lines replacing each other are compared
    for k in range(calc.min(item.dels.len(), item.adds.len())) {
      let (i, j) = (item.dels.at(k), item.adds.at(k))
      let d = line-diff(old-texts.at(i), new-texts.at(j))
      if d != none {
        diff.old.status.at(i) = "mod"
        diff.new.status.at(j) = "mod"
        diff.old.ranges.at(i) = d.old
        diff.new.ranges.at(j) = d.new
      }
    }
  }

  diff
}

// The columns of a diff: an array of one (merged codes) or two (separated codes) widths
#let diff-columns(columns) = {
  let columns = if type(columns) == int {
    assert(
      columns in (1, 2),
      message: "The `columns` of a diff must be 1 or 2, or an array of one or two widths.",
    )
    range(columns).map(_ => auto)
  } else if type(columns) == array { columns } else { (columns,) }
  assert(
    columns.len() in (1, 2)
      and columns.all(c => (
        c == auto or type(c) in (length, ratio, relative, fraction)
      )),
    message: "The `columns` of a diff must be 1 or 2, or an array of one or two widths (auto, relative or fraction).",
  )
  columns
}

// The entries of a diff (comments, jumps, markers, highlights) with their version: arrays `(version, ..keys)` or dictionaries with a `version`, or a dictionary grouping them by version (`(old: ..., new: ...)`, without their version); a single entry can be given instead of an array
#let versioned(entries, keys) = {
  let versions = ("old", "new")
  let as-array(entries) = if (
    type(entries) == dictionary
      or (entries.len() > 0 and type(entries.first()) in (int, str, alignment))
  ) { (entries,) } else { entries }
  let entry(e, version) = {
    let n = keys.len() + if version == none { 1 } else { 0 }
    if type(e) == array {
      assert(
        e.len() == n,
        message: "An entry of a diff given as an array must be of the form `("
          + (if version == none { ("version",) } else { () } + keys).join(", ")
          + ")`.",
      )
      if version == none { version = e.remove(0) }
      e = keys.zip(e).to-dict()
    } else if version == none {
      assert(
        "version" in e,
        message: "An entry of a diff must have a `version` (`\"old\"` or `\"new\"`).",
      )
      version = e.remove("version")
    } else {
      assert(
        "version" not in e,
        message: "An entry of a diff grouped by version must not have a `version`.",
      )
    }
    assert(
      version in versions,
      message: "The version of an entry of a diff must be `\"old\"` or `\"new\"`.",
    )
    e + (version: version)
  }

  if (
    type(entries) == dictionary
      and entries.len() > 0
      and entries.keys().all(k => k in versions)
  ) {
    entries
      .pairs()
      .map(((v, es)) => as-array(es).map(e => entry(e, v)))
      .flatten()
  } else {
    as-array(entries).map(e => entry(e, none))
  }
}

#let of-version(entries, version) = (
  entries
    .filter(e => e.version == version)
    .map(e => {
      let _ = e.remove("version")
      e
    })
)

// A setting of diffs given for both versions, or by version as `(old: ..., new: ...)` (`default` for a missing one)
#let by-version(value, default) = if type(value) == dictionary {
  (
    old: value.at("old", default: default),
    new: value.at("new", default: default),
  )
} else { (old: value, new: value) }

// The numbers of both versions, each with its jumps (and its `start` and `end`)
#let diff-numbers(
  diff-number,
  diff-jumps,
  nbr-lines,
  first-lines,
  with-dst,
) = {
  let numbers-of(version, version-jumps) = {
    // The numbers start by default at the first line of the code (in its file)
    let diff-number = diff-number
    diff-number.start = diff-number.start.at(version)
    diff-number.end = diff-number.end.at(version)
    if diff-number.start == auto {
      diff-number.start = first-lines.at(version)
    }
    let (version-jumps, jumps-map) = jumps(
      version-jumps,
      diff-number,
      nbr-lines.at(version),
    )
    let version-number = number(
      diff-number,
      nbr-lines.at(version) - nbr-skipped(version-jumps),
      version-jumps,
      with-dst,
    )
    let (version-line-numbers, line-index, kept) = line-numbers(
      version-number,
      nbr-lines.at(version),
      version-jumps,
      jumps-map,
    )
    (
      number: version-number,
      jumps: version-jumps,
      line-numbers: version-line-numbers,
      line-index: line-index,
      kept: kept,
    )
  }

  (
    old: numbers-of("old", of-version(diff-jumps, "old")),
    new: numbers-of("new", of-version(diff-jumps, "new")),
  )
}

// The changed ranges of a version, as highlights (on all the lines of its code)
#let diff-changes(diff, version, conf, defaults, kept) = (
  diff
    .at(version)
    .ranges
    .enumerate()
    .map(((i, ranges)) => ranges.map(((s, e)) => hl.format-highlight(
      (
        start: (kept.at(i), s),
        end: (kept.at(i), e),
        expand: none,
        sticky: false,
        radius: 0mm,
        fill: conf.fill,
        stroke: none,
      ),
      defaults,
    )))
    .flatten()
)

// The rows of a diff: the lines (`(kind: "line", old: i, new: j)`, one of them being `none` for a line in one version only) and the comments (`(kind: "comment", old: c, new: c)`, one of them being `none` for a comment of one version only, both being set for separated codes)
#let diff-rows(diff, comments, same-code) = {
  let comment-rows(olds, news) = {
    let after(cs) = cs.filter(c => c.copy-before)
    let before(cs) = cs.filter(c => not c.copy-before)
    // The comments spanning over both separated codes are alone in their rows, the ones after the lines first
    let is-span(c) = c.span and not same-code
    let spans = (olds + news).filter(is-span)
    let (olds, news) = (olds, news).map(cs => cs.filter(c => not is-span(c)))
    let span-rows(cs) = cs.map(c => (
      kind: "comment",
      old: none,
      new: none,
      span: c,
    ))
    let single(version, cs) = cs.map(c => (
      kind: "comment",
      old: if version == "old" { c },
      new: if version == "new" { c },
    ))
    let pairs(olds, news) = olds
      .zip(news)
      .map(((o, n)) => (kind: "comment", old: o, new: n))

    if same-code {
      return (
        single("old", after(olds))
          + single("new", after(news))
          + single("old", before(olds))
          + single("new", before(news))
      )
    }
    let (spans-after, spans-before) = (after(spans), before(spans))

    // The comments of both versions are paired: the ones after the lines from the top, the ones before the lines from the bottom
    let (oa, ob, na, nb) = (
      after(olds),
      before(olds),
      after(news),
      before(news),
    )
    let top = pairs(oa, na)
    let bottom = pairs(ob.rev(), nb.rev()).rev()
    let (oa, na) = (oa.slice(top.len()), na.slice(top.len()))
    let (ob, nb) = (
      ob.slice(0, ob.len() - bottom.len()),
      nb.slice(0, nb.len() - bottom.len()),
    )

    // The remaining comments of one version after the lines are paired with the ones of the other version before the lines
    let (first, firsts) = if oa.len() > 0 { ("old", oa) } else { ("new", na) }
    let (second, seconds) = if ob.len() > 0 { ("old", ob) } else { ("new", nb) }
    let n = if first == second { 0 } else {
      calc.min(firsts.len(), seconds.len())
    }
    let middle = (
      single(first, firsts.slice(0, firsts.len() - n))
        + firsts
          .slice(firsts.len() - n)
          .zip(seconds.slice(0, n))
          .map(((a, b)) => (kind: "comment", (first): a, (second): b))
        + single(second, seconds.slice(n))
    )
    span-rows(spans-after) + top + middle + bottom + span-rows(spans-before)
  }

  let line-rows = ()
  for item in diff.items {
    if item.kind == "same" {
      line-rows.push((kind: "line", old: item.old, new: item.new))
    } else if same-code {
      line-rows += item.dels.map(i => (kind: "line", old: i, new: none))
      line-rows += item.adds.map(j => (kind: "line", old: none, new: j))
    } else {
      for k in range(calc.max(item.dels.len(), item.adds.len())) {
        line-rows.push((
          kind: "line",
          old: item.dels.at(k, default: none),
          new: item.adds.at(k, default: none),
        ))
      }
    }
  }
  // The comments between two rows (`none` at the start and the end): the ones after the lines of the first row, and the ones before the lines of the second row (of each version)
  let gap-rows(prev, next, last) = {
    let (after, before) = (
      cs => cs.filter(c => c.copy-before),
      cs => cs.filter(c => not c.copy-before),
    )
    let of(v) = (
      (
        if prev == none { after(comments.at(v).at(0)) } else if (
          prev.at(v) != none
        ) { after(comments.at(v).at(prev.at(v) + 1)) } else { () }
      )
        + if next == none {
          before(comments.at(v).at(last.at(v) + 1))
        } else if next.at(v) != none {
          before(comments.at(v).at(next.at(v)))
        } else {
          ()
        }
    )
    comment-rows(of("old"), of("new"))
  }
  // (the last line of each version, before the comments at the end)
  let last = (old: -1, new: -1)
  let rows = ()
  for (k, row) in line-rows.enumerate() {
    rows += gap-rows(if k > 0 { line-rows.at(k - 1) }, row, last)
    rows.push(row + (k: k))
    for v in ("old", "new") {
      if row.at(v) != none { last.at(v) = row.at(v) }
    }
  }
  rows + gap-rows(line-rows.at(-1, default: none), none, last)
}
