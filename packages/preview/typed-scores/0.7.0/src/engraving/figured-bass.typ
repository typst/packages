#import "primitives.typ": _bravura-bounding-box, _bravura-width, _draw-bravura-glyph
#import "../foundation/diagnostics.typ": _score-error
#import "../foundation/meter.typ": _format-rational, _harmony-duration-values, _parse-time-rational, _rational, _rational-add, _rational-eq

// Figured bass: a bar's `figures` field is a duration-bearing sequence, like
// harmony, whose stacks are engraved with Bravura's figured-bass glyphs in a
// band below the bottom staff.

#let _figure-accidental-glyphs = (
  "##": "figbass-double-sharp",
  "#": "figbass-sharp",
  "bb": "figbass-double-flat",
  "b": "figbass-flat",
  "n": "figbass-natural",
)
#let _figure-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
#let _figure-scale = 1.0
// Distance between the baselines of stacked figures, in staff spaces.
#let _figure-row-step = 1.3
#let _figure-glyph-gap = 0.06

#let _figure-syntax-error(value, bar-number) = {
  _score-error(
    "figures in bar " + str(bar-number),
    "figure has invalid syntax",
    value: value,
    expected: "a number with an optional accidental before or after it (6, #6, 6b, 4+), an accidental or + alone (#, b, n, +), or _ for an empty row",
    fix: "write stacks as (6 4):q and single figures as 6:q",
  )
}

#let _leading-accidental(text) = {
  for candidate in ("##", "#", "bb", "b", "n") {
    if text.starts-with(candidate) { return candidate }
  }
  none
}

// One row of a stack: an optional accidental or + before or after a number,
// or either of them alone. `_` keeps an empty row so later figures stay in
// place.
#let _parse-figure(text, bar-number) = {
  if text == "_" { return (prefix: none, number: none, suffix: none) }
  if text == "+" { return (prefix: none, number: none, suffix: "+") }
  let prefix = _leading-accidental(text)
  let rest = if prefix == none { text } else { text.slice(prefix.len()) }
  let number = ""
  while rest.len() > 0 and rest.first() in _figure-digits {
    number += rest.first()
    rest = rest.slice(1)
  }
  let suffix = if rest == "+" { "+" } else { _leading-accidental(rest) }
  if (
    (suffix != none and suffix.len() != rest.len())
      or (suffix == none and rest != "")
      or (number == "" and suffix != none)
      or (number == "" and prefix == none)
      or (prefix != none and suffix != none)
      or number.len() > 2
      or number.starts-with("0")
  ) {
    _figure-syntax-error(text, bar-number)
  }
  (prefix: prefix, number: if number == "" { none } else { number }, suffix: suffix)
}

// Split on spaces outside parentheses so a stack stays one token.
#let _figure-tokens(sequence, bar-number) = {
  let tokens = ()
  let current = ""
  let depth = 0
  for character in sequence.clusters() {
    if character == "(" {
      if depth > 0 { _figure-syntax-error(sequence, bar-number) }
      depth += 1
    } else if character == ")" {
      if depth == 0 { _figure-syntax-error(sequence, bar-number) }
      depth -= 1
    }
    if character == " " and depth == 0 {
      if current != "" { tokens.push(current) }
      current = ""
    } else {
      current += character
    }
  }
  if depth != 0 {
    _score-error(
      "figures in bar " + str(bar-number),
      "figure stack is missing its closing parenthesis",
      value: sequence,
      fix: "close every ( with ) before the duration, as in (6 4):q",
    )
  }
  if current != "" { tokens.push(current) }
  tokens
}

#let _glyph-advance(glyph) = _bravura-width(glyph) * _figure-scale + _figure-glyph-gap

// Glyphs of one row in reading order, with the number's glyphs flagged so
// the row can center its number on the bass note while accidentals hang.
#let _figure-glyphs(figure) = {
  let glyphs = ()
  if figure.prefix != none {
    glyphs.push((name: _figure-accidental-glyphs.at(figure.prefix), number: false))
  }
  if figure.number != none {
    for digit in figure.number.clusters() {
      glyphs.push((name: "figbass-" + digit, number: true))
    }
  }
  if figure.suffix == "+" {
    glyphs.push((name: "figbass-plus", number: false))
  } else if figure.suffix != none {
    glyphs.push((name: _figure-accidental-glyphs.at(figure.suffix), number: false))
  }
  glyphs
}

#let _layout-figures(sequence, time, bar-number) = {
  if sequence == none { return () }
  if type(sequence) != str or sequence.trim() == "" {
    _score-error(
      "figures in bar " + str(bar-number),
      "figures must be a non-empty string",
      value: sequence,
      expected: "space-separated figure:duration tokens such as \"6:q (6 4):q 5:h\"",
      fix: "provide timed figures or remove the figures field",
    )
  }
  if time == none {
    _score-error(
      "figures in bar " + str(bar-number),
      "timed figures require an active meter",
      value: sequence,
      expected: "a bar time or partial value",
      fix: "set time for the score or partial for this bar",
    )
  }
  let layouts = ()
  let onset = _rational(0, 1)
  for token in _figure-tokens(sequence.trim(), bar-number) {
    let separator = token.position(":")
    let duration-code = if separator == none { none } else { token.slice(separator + 1) }
    if separator == none or duration-code not in _harmony-duration-values {
      _score-error(
        "figures in bar " + str(bar-number),
        "figure token has invalid syntax",
        value: token,
        expected: "one figure or stack, one colon, and a duration such as 6:q or (6 4):h",
        fix: "add the missing colon or supported duration code",
      )
    }
    let stack = token.slice(0, separator)
    let rows = if stack.starts-with("(") and stack.ends-with(")") {
      stack.slice(1, -1).split(" ").filter(row => row != "")
    } else {
      (stack,)
    }
    if rows.len() == 0 { _figure-syntax-error(stack, bar-number) }
    let figures = rows.map(row => _parse-figure(row, bar-number))
    // A stack of nothing but placeholders only lets time pass.
    if figures.any(figure => _figure-glyphs(figure).len() > 0) {
      layouts.push((rows: figures, onset: onset))
    }
    onset = _rational-add(onset, _harmony-duration-values.at(duration-code))
  }
  let expected = _parse-time-rational(time, label: "figures bar " + str(bar-number) + " meter")
  if not _rational-eq(onset, expected) {
    _score-error(
      "figures bar " + str(bar-number),
      "durations sum to " + _format-rational(onset),
      expected: time,
      fix: "change the figure durations so they fill the active bar or partial",
    )
  }
  layouts
}

// Horizontal extents of one row about its onset column: the number is
// centered there and its accidentals hang outside, while an accidental alone
// is centered itself.
#let _figure-row-extent(figure) = {
  let glyphs = _figure-glyphs(figure)
  if glyphs.len() == 0 { return (left: 0, right: 0) }
  let advances = glyphs.map(glyph => _glyph-advance(glyph.name))
  let total = advances.sum() - _figure-glyph-gap
  if not glyphs.any(glyph => glyph.number) {
    return (left: total / 2, right: total / 2)
  }
  let before = 0
  let number-width = 0
  for (glyph, advance) in glyphs.zip(advances) {
    if glyph.number { number-width += advance } else if number-width == 0 { before += advance }
  }
  let left = before + (number-width - _figure-glyph-gap) / 2
  (left: left, right: total - left)
}

#let _figure-stack-extent(layout) = {
  let left = 0
  let right = 0
  for figure in layout.rows {
    let extent = _figure-row-extent(figure)
    left = calc.max(left, extent.left)
    right = calc.max(right, extent.right)
  }
  (left: left, right: right)
}

#let _figure-rows(figure-layouts) = {
  let rows = 0
  for layout in figure-layouts { rows = calc.max(rows, layout.rows.len()) }
  rows
}

// Draw one stack whose first row's glyphs stand on `top-baseline`.
#let _draw-figure-stack(layout, x, top-baseline, unit: 8pt, paint: black) = {
  for (row-index, figure) in layout.rows.enumerate() {
    let baseline = top-baseline - row-index * _figure-row-step
    let cursor = x - _figure-row-extent(figure).left
    for glyph in _figure-glyphs(figure) {
      let bounds = _bravura-bounding-box(glyph.name)
      _draw-bravura-glyph(
        glyph.name,
        cursor - bounds.sw.at(0) * _figure-scale,
        baseline,
        unit: unit,
        origin: true,
        glyph-scale: _figure-scale,
        paint: paint,
      )
      cursor += _glyph-advance(glyph.name)
    }
  }
}
