#import "validation.typ": *
#import "dictionaries.typ": *
#import "geometry.typ": *
#import "corners.typ": *
#import "shape.typ": _draw-shape

/// Draws a rectangle with smoothly rounded corners.
///
/// Use `squircle` like `rect` when you want softer, more continuous corner
/// transitions. With `smoothing: 0%`, it has the same geometry as a rounded
/// `rect`.
///
/// -> content
#let squircle(
  /// The squircle's width, relative to its parent container.
  /// -> auto | length | ratio | relative
  width: auto,
  /// The squircle's height, relative to its parent container.
  /// -> auto | length | ratio | relative | fraction
  height: auto,
  /// How to fill the squircle.
  ///
  /// When setting a fill, the default stroke disappears. To create a squircle
  /// with both fill and stroke, you have to configure both.
  /// -> none | color | gradient | tiling
  fill: none,
  /// How to stroke the squircle. This can be:
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
  /// How much to round the squircle's corners, relative to the minimum of the
  /// width and height divided by two. This can be:
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
  /// How much to pad the squircle's content. See `box`'s `inset` parameter for
  /// more details.
  /// -> length | ratio | relative | dictionary
  inset: 5pt,
  /// How much to expand the squircle's size without affecting the layout. See
  /// `box`'s `outset` parameter for more details.
  /// -> length | ratio | relative | dictionary
  outset: 0pt,
  /// How strongly to smooth the squircle's corners. Smoothing replaces the
  /// ends of each circular corner arc with Bézier transitions whose curvature
  /// gradually changes between the straight edges and the arc. This can be:
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
  /// `100%`, it is two Bézier transitions with no circular arc.
  ///
  /// A corner's two edges normally share one available space, the smaller of
  /// the two. See `per-edge-smoothing` to change that.
  /// -> length | ratio | relative | dictionary
  smoothing: 60%,
  /// Whether to preserve the requested smoothing when it exceeds available
  /// edge space. This has no effect when smoothing already fits.
  ///
  /// If `false`, smoothing scales down to fit. If `true`, both the requested
  /// radius and smoothing are retained by compressing the Bézier transitions.
  /// -> bool
  preserve-smoothing: false,
  /// Whether each half of a corner can use all the space available on its edge
  /// when requested smoothing exceeds available room along one or both edges.
  ///
  /// If `false`, each corner's two transition angles stay symmetric and share
  /// the tighter edge limit. If `true`, both halves smooth independently.
  /// -> bool
  per-edge-smoothing: false,
  /// The content to place into the squircle. Strings and symbols are converted
  /// to content.
  ///
  /// When this is omitted, the squircle takes on a default size of at most
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
  _expect("preserve-smoothing", preserve-smoothing, (bool,), "boolean")
  _expect("per-edge-smoothing", per-edge-smoothing, (bool,), "boolean")
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
    _piece(
      corner,
      pt,
      r,
      _corner-params(
        r-fit,
        smoothings.at(corner),
        budget.ccw,
        preserve-smoothing,
      ),
      _corner-params(
        r-fit,
        smoothings.at(corner),
        budget.cw,
        preserve-smoothing,
      ),
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
    per-edge-smoothing: per-edge-smoothing,
    _piece-for,
    body: body,
  )
}
