#import "validation.typ": *
#import "dictionaries.typ": *
#import "geometry.typ": *
#import "corners.typ": *
#import "shape.typ": _draw-shape

/// Draws a rectangle with clothoid (Euler-spiral) blend corners.
///
/// Use `clothoid` like `rect` when you want cubic approximations of Euler-spiral
/// corner transitions, whose ideal curvature ramps linearly along arc length.
/// At `smoothing: 0%`, it has the same geometry as a rounded `rect`.
///
/// -> content
#let clothoid(
  /// The clothoid's width, relative to its parent container.
  /// -> auto | length | ratio | relative
  width: auto,
  /// The clothoid's height, relative to its parent container.
  /// -> auto | length | ratio | relative | fraction
  height: auto,
  /// How to fill the clothoid.
  ///
  /// When setting a fill, the default stroke disappears. To create a
  /// clothoid with both fill and stroke, you have to configure both.
  /// -> none | color | gradient | tiling
  fill: none,
  /// How to stroke the clothoid. This can be:
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
  /// How much to round the clothoid's corners, relative to the minimum of
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
  /// How much to pad the clothoid's content. See `box`'s `inset`
  /// parameter for more details.
  /// -> length | ratio | relative | dictionary
  inset: 5pt,
  /// How much to expand the clothoid's size without affecting the layout.
  /// See `box`'s `outset` parameter for more details.
  /// -> length | ratio | relative | dictionary
  outset: 0pt,
  /// How strongly to smooth the clothoid's corners. Smoothing splits the
  /// 90-degree corner rotation into clothoid spiral transitions (where curvature
  /// ramps linearly) and a central circular arc. This can be:
  ///
  /// - A relative length for uniform corner smoothing.
  /// - A dictionary describing the smoothing for each corner individually. The
  ///   dictionary can contain the following keys in order of precedence:
  ///   - `top-left`: The top-left corner smoothing.
  ///   - `top-right`: The top-right corner smoothing.
  ///   - `bottom-right`: The bottom-right corner smoothing.
  ///   - `bottom-left`: The bottom-left corner smoothing.
  ///   - `left`: The top-left and bottom-left corner smoothing.
  ///   - `top`: The top-left and top-right corner smoothing.
  ///   - `right`: The top-right and bottom-right corner smoothing.
  ///   - `bottom`: The bottom-left and bottom-right corner smoothing.
  ///   - `rest`: The smoothing for all corners except those for which the
  ///     dictionary explicitly sets smoothing.
  ///
  /// At `0%`, the corner is a quarter circle matching a rounded `rect`. At
  /// `100%`, it is two clothoid transitions meeting with no circular arc.
  ///
  /// When the natural blend does not fit the tighter adjacent-edge budget, its
  /// clothoid lengths and effective circular radius scale down together. This
  /// keeps the angular smoothing proportions unchanged.
  /// -> length | ratio | relative | dictionary
  smoothing: 60%,
  /// The content to place into the clothoid. Strings and symbols are converted
  /// to content.
  ///
  /// When this is omitted, the clothoid takes on a default size of at most
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
  _validate-relative-or-dict("smoothing", smoothing, _corner-keys)
  body = _validate-body(body)

  let smoothing-corners = _resolve-corners(smoothing, default: 60%)
  let smoothings = _corner-order
    .map(c => (
      c,
      calc.max(
        0.0,
        calc.min(1.0, _resolve-scalar(smoothing-corners.at(c), 1pt) / 1pt),
      ),
    ))
    .to-dict()

  let _piece-for(corner, pt, r, r-fit, budget, split) = {
    _clothoid-piece(
      corner,
      pt,
      r,
      r-fit,
      budget,
      smoothings.at(corner),
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
