#import "@preview/oxifmt:1.0.0": strfmt
#let heights = state("heights", ())
#let widths = state("widths", ())

///
/// Internal helper: measure a piece of content and draw an AABB rectangle
/// with width/height numeric labels (side effects: appends to `widths` & `heights`).
///
/// - unit (fn length -> length): Conversion function applied to measured pt value (default passed in by caller, usually length.pt).
/// - precision (int): Fractional digits to keep when formatting the number.
/// - c (content): Any content node to be measured & wrapped.
/// -> content: A boxed version of `c` with overlay labels; original flow preserved.
#let _aabb_internal(
  unit,
  precision,
  placements: (
    top + left,
    bottom + left,
    top + left,
    top + left,
  ),
  c,
) = context {
  let size = measure(c)
  widths.update(it => it + (size.width,))
  heights.update(it => it + (size.height,))
  let hstuff = text(
    bottom-edge: "baseline",
    top-edge: "cap-height",
    fill: color.mix(red, green),
    raw(strfmt("{:." + str(precision) + "}", unit(size.height))),
  )
  let wstuff = text(
    bottom-edge: "baseline",
    top-edge: "cap-height",
    fill: color.mix(green, blue),
    raw(strfmt("{:." + str(precision) + "}", unit(size.width))),
  )
  let hstuffs = measure(hstuff)
  let wstuffs = measure(wstuff)
  box(..size, stroke: .2pt + gray, {
    c
    place(placements.at(0), dy: -.1pt, place(
      placements.at(1),
      box(
        stroke: (left: .2pt + gray),
        fill: white.transparentize(60%),
        scale(
          reflow: true,
          x: calc.min(size.width / wstuffs.width * 100%, 20%),
          y: 20%,
          wstuff,
        ),
      ),
    ))
    place(placements.at(3), dx: .1pt, dy: .1pt, place(
      placements.at(3),
      rotate(-90deg, reflow: true, box(
        fill: white.transparentize(60%),
        scale(
          x: calc.min(size.height / hstuffs.width * 100%, 20%),
          y: 20%,
          reflow: true,
          hstuff,
        ),
      )),
    ))
  })
}

///
/// Character-by-character AABB visualization.
/// For each codepoint in the textual representation of the argument, draws an
/// individual measurement rectangle with labels. Good for inspecting glyph advance,
/// kerning and vertical metrics.
///
/// - c (content/text): Source whose `.text` will be iterated per character.
/// - unit (fn length -> length): Unit conversion (e.g. length.pt, length.mm).
/// - precision (int): Decimal places for numbers (default 3).
/// -> content: Original content returned after side-effectful rendering.
#let ccaabb(c, unit: length.pt, precision: 3) = {
  show regex(".+"): it => context {
    for c in it.text {
      _aabb_internal(unit, precision, c)
    }
  }
  c
}

///
/// Element-level AABB visualization.
/// Wraps the whole content block in a single measurement rectangle with width &
/// height labels. Non-destructive (returns original content) while drawing overlay.
///
/// - c (content): Content to visualize.
/// - unit (fn length -> length): Unit conversion (default length.pt).
/// - precision (int): Decimal places (default 3).
/// -> content: Original content after drawing the overlay.
#let eeaabb(c, unit: length.pt, precision: 3) = {
  show: _aabb_internal.with(unit, precision, placements: (
    bottom + right,
    top + right,
    bottom + right,
    bottom + right,
  ))
  c
}
