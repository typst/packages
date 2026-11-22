/// A collection of styling functions and objects:
/// - coloring: `zebra`, `exact`, `focus`, `hatch`;
/// - numbers: `padded`;
/// - markers: `callout-marker`, `badge-marker`;
/// - jumps: `vdots-jump`;
/// - other: `window-header`, `icons`.

// -----------------------------------------------------------------------------
// Coloring
// -----------------------------------------------------------------------------

/// Return a coloring function alternating between two colors.
///
/// #example(````
/// #import "@preview/ultraw:0.0.1": uraw, style
/// #uraw(
///   code-fill: style.zebra(even: aqua, odd: yellow),
///   ```py
///   def greeting():
///       print("Hello world")
///   ```,
/// )
/// ````)
///
/// - odd (color, gradient, tiling, none): The color of odd lines.
/// - even (color, gradient, tiling, none): The color of even lines.
/// -> function
#let zebra(odd: none, even: none) = n => if calc.odd(n) { odd } else { even }

/// Return a coloring function that assigns precise colors to ranges of lines.
///
/// #example(````
/// #import "@preview/ultraw:0.0.1": uraw, style
/// #uraw(
///   code-fill: style.exact(((2, 4), teal), (3, aqua), rest: eastern),
///   ```py
///   def mysterious-greeting():
///       print("Hello ...")
///       print("...")
///       prin("... world")
///   ```,
/// )
/// ````)
///
/// - lines (arguments): Each positional argument must be a pair `(line, color)` where `line` is either an integer or a pair of integers `(from, to)` representing a range of lines and where `color` is the color used for the associated lines.
/// - rest (color, gradient, tiling, none): The color for the rest of the lines.
/// -> function
#let exact(..lines, rest: none) = {
  let read-lines(l) = if type(l) == int { (l, l) } else { l }
  let read-lines-col((l, c)) = (read-lines(l), c)

  let bin-find(l, n) = if l.len() == 0 { none } else if l.len() == 1 {
    if n == l.first() { 0 } else { none }
  } else {
    let h = int(l.len() / 2)
    let median = l.at(h)
    if n == median { h } else if n < median {
      bin-find(l.slice(0, h), n)
    } else {
      let r = bin-find(l.slice(h), n)
      if r != none { r + h }
    }
  }

  let lines = lines
    .pos()
    .map(read-lines-col)
    .map((((s, e), c)) => range(s, e + 1).map(i => (line: i, color: c)))
    .flatten()
  lines = lines
    .enumerate()
    .filter(((i, p)) => p.line not in lines.slice(i + 1).map(p => p.line))
    .map(((_, p)) => p)
    .sorted(key: lc => lc.line)
  let (lines, colors) = (lines.map(lc => lc.line), lines.map(lc => lc.color))
  return n => {
    let i = bin-find(lines, n)
    if i != none { colors.at(i) } else { rest }
  }
}

/// Return a coloring function that applies focus to the given lines with some color.
///
/// #example(````
/// #import "@preview/ultraw:0.0.1": uraw, style
/// #uraw(
///   numbers-color: style.focus((1, 2)),
///   ```py
///   def mysterious-greeting():
///       print("Hello ...")
///       print("...")
///       prin("... world")
///   ```,
/// )
/// ````)
///
/// - lines (arguments): Each positional argument is either an integer or a pair of integers `(from, to)` representing a range of lines.
/// - color (color): The color used for the specified lines.
/// - rest (ratio, color, gradient, tiling): Either a transparency ratio mitigating `color` or a color for the unfocused lines.
/// -> function
#let focus(..lines, color: black, rest: 70%) = {
  return exact(
    ..lines.pos().map(l => (l, color)),
    rest: if type(rest) == ratio { color.transparentize(rest) } else { rest },
  )
}

/// A hatching tiling.
///
/// - color (color, gradient, tiling): The color of the hatching.
/// -> tiling
#let hatch(color) = tiling(size: (4pt, 4pt), line(
  start: (0pt, 4pt),
  end: (4pt, 0pt),
  stroke: .3pt + color,
))

// -----------------------------------------------------------------------------
// Numbers
// -----------------------------------------------------------------------------

/// Return a function padding numbers with 0s.
///
/// #example(`
/// #padded(3)(1)
/// `)
///
/// - n-digits (int): The number of digits to pad to.
/// -> function
#let padded(n-digits) = n => {
  let s = str(n)
  if s.len() < n-digits { "0" * (n-digits - s.len()) + s } else { s }
}

// -----------------------------------------------------------------------------
// Markers
// -----------------------------------------------------------------------------

/// Create a marker made of encircled content.
///
/// #example(`
/// #callout-marker("!", color: red)
/// `)
///
/// - body (int, content): The encircled integer or content.
/// - color (color, gradient, tiling): The color of the marker.
/// -> content
#let callout-marker(body, color: black) = circle(
  radius: .6em,
  stroke: .5pt + color,
  place(center + horizon, text(color, .9em, if type(body) == int {
    str(body)
  } else { body })),
)

/// Create a dot marker.
///
/// #example(`
/// #badge-marker(color: purple)
/// `)
///
/// - color (color, gradient, tiling): The color of the badge marker.
/// -> content
#let badge-marker(color: black) = box(height: .8em, align(horizon, circle(
  radius: .3em,
  fill: color,
  stroke: none,
)))

// -----------------------------------------------------------------------------
// Jumps
// -----------------------------------------------------------------------------

/// Create a jump that displays a comment containing vertical dots.
///
/// #example(````
/// #import "@preview/ultraw:0.0.1": uraw, style
/// #uraw(
///   jumps: style.vdots-jump(1, 5),
///   ```py
///   def greeting():
///       print("Hello world")
///   ```,
/// )
/// ````)
///
/// - from (int): The starting line of the jump.
/// - to (int): The ending line of the jump.
/// - numbers (bool): Whether to show vertical dots in the numbers column.
/// - code (bool): Whether to show vertical dots in the code.
/// - comment (arguments): The styling parameters of the comment.
/// -> dictionary
#let vdots-jump(from, to, numbers: true, code: false, ..comment) = {
  let jump = comment.named() + (from: from, to: to)
  if numbers {
    jump += (
      marker: $dots.v$,
      marker-placement: "numbers",
      comment: jump.at("comment", default: []),
    )
  }
  if code {
    jump += (comment: $dots.v$, indent: jump.at("indent", default: true))
  }
  return jump
}

// -----------------------------------------------------------------------------
// Other
// -----------------------------------------------------------------------------

/// Create a header styled like a macOS window.
///
/// #example(````
/// #import "@preview/ultraw:0.0.1": uraw, themes, style
/// #uraw(
///   ..themes.window,
///   header: style.window-header[Python tutorial],
///   ```py
///   def greeting():
///       print("Hello world")
///   ```,
/// )
/// ````)
///
/// - body (content): The content of the header.
/// -> content
#let window-header(body) = stack(
  dir: ltr,
  spacing: 0pt,
  circle(radius: 4pt, fill: rgb("#FF5C5F")),
  h(3pt),
  circle(radius: 4pt, fill: rgb("#FAC800")),
  h(3pt),
  circle(radius: 4pt, fill: rgb("#34C759")),
  h(9pt),
  body,
)


/// A map from common languages to their icon. All available icons can be inspected in the Typst package directory at "./preview/ultraw/\$VERSION/styling/icons/".
#let icons = {
  import "../src/languages.typ": lang-tag-config
  // Tinymist documentation workaround:
  (:) + lang-tag-config.map(i => i.icon)
}
