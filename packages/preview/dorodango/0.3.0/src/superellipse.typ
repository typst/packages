#import "validation.typ": *
#import "dictionaries.typ": *
#import "geometry.typ": *
#import "corners.typ": *
#import "shape.typ": _draw-shape

/// Draws a rectangle with superellipse (Lamé curve) corners.
///
/// Use `superellipse` like `rect` when you want cubic approximations of Lamé
/// curve corners parameterized by a power exponent. For exponents above 2, the
/// ideal Lamé curve has zero curvature where it meets the straight edges. At
/// `exponent: 2`, the corners are circular arcs matching a rounded `rect`.
/// Higher exponents make the corners squarer.
///
/// -> content
#let superellipse(
  /// The superellipse's width, relative to its parent container.
  /// -> auto | length | ratio | relative
  width: auto,
  /// The superellipse's height, relative to its parent container.
  /// -> auto | length | ratio | relative | fraction
  height: auto,
  /// How to fill the superellipse.
  ///
  /// When setting a fill, the default stroke disappears. To create a
  /// superellipse with both fill and stroke, you have to configure both.
  /// -> none | color | gradient | tiling
  fill: none,
  /// How to stroke the superellipse. This can be:
  ///
  /// - `none` to disable stroking.
  /// - `auto` for a stroke of `1pt + black` if and only if no fill is given.
  /// - Any kind of stroke.
  /// - A dictionary describing the stroke for each side individually. The
  ///   dictionary can contain the following keys in order of precedence:
  ///   - `top`: The top stroke.
  ///   - `right`: The right stroke.
  ///   - `bottom`: The bottom stroke.
  ///   - `left`: The left stroke.
  ///   - `x`: The left and right stroke.
  ///   - `y`: The top and bottom stroke.
  ///   - `rest`: The stroke on all sides except those for which the dictionary
  ///     explicitly sets a stroke.
  ///
  /// All keys are optional. Omitted sides are not stroked.
  /// -> auto | none | length | color | gradient | tiling | stroke | dictionary
  stroke: auto,
  /// How much to round the superellipse's corners, relative to the minimum of
  /// the width and height divided by two. This can be:
  ///
  /// - A relative length for a uniform corner radius.
  /// - A dictionary describing the radius for each corner individually. The
  ///   dictionary can contain the following keys in order of precedence:
  ///   - `top-left`: The top-left corner radius.
  ///   - `top-right`: The top-right corner radius.
  ///   - `bottom-right`: The bottom-right corner radius.
  ///   - `bottom-left`: The bottom-left corner radius.
  ///   - `left`: The top-left and bottom-left corner radii.
  ///   - `top`: The top-left and top-right corner radii.
  ///   - `right`: The top-right and bottom-right corner radii.
  ///   - `bottom`: The bottom-left and bottom-right corner radii.
  ///   - `rest`: The radii for all corners except those for which the
  ///     dictionary explicitly sets a radius.
  /// -> length | ratio | relative | dictionary
  radius: 0pt,
  /// How much to pad the superellipse's content. See `box`'s `inset`
  /// parameter for more details.
  /// -> length | ratio | relative | dictionary
  inset: 5pt,
  /// How much to expand the superellipse's size without affecting the layout.
  /// See `box`'s `outset` parameter for more details.
  /// -> length | ratio | relative | dictionary
  outset: 0pt,
  /// The Lamé curve exponent $n$ in $|x/p|^n + |y/p|^n = 1$.
  ///
  /// Controls the corner shape profile. Values must be finite and are clamped
  /// into $[2, 12]$. Below 2 the curve would bulge inward, while above 12
  /// the three-cubic fit degrades and control points can leave the corner's
  /// footprint. Near the upper bound the fit trades fidelity for containment.
  /// At 2 the curve is a circle, and the corner drawn is the circular arc `rect`
  /// draws rather than an approximation.
  /// -> int | float
  exponent: 5,
  /// The content to place into the superellipse. Strings and symbols are
  /// converted to content.
  ///
  /// When this is omitted, the superellipse takes on a default size of at most
  /// `45pt` by `30pt`.
  /// -> none | content | str | symbol
  ..body,
) = {
  _validate-size("width", width)
  _validate-size("height", height, fraction-ok: true)
  _validate-fill(fill)
  stroke = _validate-stroke(stroke)
  _validate-relative-or-dict("radius", radius, _corner-keys)
  _validate-relative-or-dict("inset", inset, _side-keys)
  _validate-relative-or-dict("outset", outset, _side-keys)
  _validate-number("exponent", exponent)
  body = _validate-body(body)

  let _piece-for(corner, pt, r, r-fit, budget, split) = {
    _superellipse-piece(
      corner,
      pt,
      r,
      r-fit,
      budget,
      exponent,
      split: split,
    )
  }

  _draw-shape(
    width: width,
    height: height,
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: inset,
    outset: outset,
    _piece-for,
    body: body,
  )
}
