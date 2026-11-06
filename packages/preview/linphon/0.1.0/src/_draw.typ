/// Drawing functionality for the `linphon` package.

/// Default stroke used for drawing
#let _default-stroke = 0.06em

/// Draw a bracket of a given height
/// 
/// Draws a simple constant-width stroke bracket of a specified height.
/// The width can be either specified or set to `auto` (the default), in which
/// case it is calculated to be an appropriate percentage at smaller bracket
/// sizes but limited to a maximal width of 10pt.
/// 
/// Returns a bare `curve` for opening or single-sided brackets, and a `scale`
/// (mirroring the curve) for closing brackets.
/// 
/// -> curve | scale
#let bracket(
  /// The type of bracket to draw.
  /// One of `"{"`, `"}"`, `"<"`, `">"`, `"["`, `"]"`,
  /// `"("`, `")"`, `"|"`, `"/"`.
  /// -> str
  bracket,
  /// The height to which the bracket should be drawn.
  /// -> length
  height,
  /// The widith to which the bracket should be drawn. Default: `auto`.
  /// -> length
  width: auto,
  /// The stroke with which the bracket should be drawn.
  /// -> stroke
  stroke: _default-stroke
) = {
  let target-height = height
  let target-width = width
  let result = none
  if width == auto {
    // Is height relative or absolute?
    if height.em == 0 {
      // Assume absolute, calculate in pt
      target-width = calc.max(target-height.pt() * 0.15, 3) * 1pt
      if target-width > 10pt { target-width = 10pt }
    } else {
      // Assume relative, calculate in em
      target-width = calc.max(target-height.em * 0.15, 0.25) * 1em
      if target-width > 0.833em { target-width = 0.833em }
    }
  }
  set curve(stroke: stroke)
  if bracket in ("{", "}") {
    result = curve(
      curve.move((target-width, 0pt)),
      curve.cubic(
        (0pt, 0pt),                         // control-start
        (target-width, target-height / 2),  // control-end
        (0pt, target-height / 2 )           // endpoint
      ),
      curve.cubic(
        (target-width, target-height / 2),  // control-start
        (0pt, target-height),               // control-end
        (target-width, target-height)       // endpoint
      )
    )
  } else if bracket in ("<", ">", str(sym.angle.l), str(sym.angle.r), sym.angle.l, sym.angle.r) {
    result = curve(
      curve.move((target-width, 0em)),
      curve.line((0em, target-height / 2)),
      curve.line((target-width, target-height))
    )
  } else if bracket in ("[", "]") {
    result = curve(
      curve.move((target-width, 0pt)),
      curve.line((0pt, 0pt)),
      curve.line((0pt, target-height / 2)),
      curve.line((0pt, target-height)),
      curve.line((target-width, target-height))
    )
  } else if bracket in ("(", ")") {
    result = curve(
      curve.move((target-width, 0pt)),
      curve.cubic(
        (0pt, 0pt),                         // control-start
        none,  // control-end
        (0pt, target-height / 2 )           // endpoint
      ),
      curve.cubic(
        none,  // control-start
        (0pt, target-height),               // control-end
        (target-width, target-height)       // endpoint
      )
    )
  } else if bracket == "|" {
    result = curve(
      curve.move((target-width / 2, 0pt)),
      curve.line((target-width / 2, target-height)),
      curve.move((target-width, target-height)),
    )
  } else if bracket == "/" {
    result = curve(
      curve.move((target-width, 0pt)),
      curve.line((0pt, target-height)),
    )
  }

  if bracket in ("}", "]", ")", ">", str(sym.angle.r), sym.angle.r) {
    result = scale(-100%, result)
  }
  result
}

/// Draw a contextual placeholder dash
/// 
/// Draws a dash to use as a placeholder for a phonological context
/// specification.
/// 
/// -> box
#let dash(
  /// The length the dash should be. Default: `2em`.
  /// -> length
  length: 2em,
  /// The vertical alignment of the resulting dash relative to the line.
  /// One of `top | bottom | horizon`.
  /// -> alignment
  valign: bottom,
  /// The stroke with which the dash should be drawn.
  /// -> stroke
  stroke: _default-stroke
) = {
  box(
    baseline: 0% + 0.225em,
    height: 1em,
    inset: (left: 0.1em, right: 0.1em,),
    align(
      valign,
      line(length: length, stroke: stroke)
    )
  )
}

#let dash-top = dash.with(valign: top)
#let dash-horizon = dash.with(valign: horizon)
#let dash-bottom = dash.with(valign: bottom)
