#import "header.typ": *
#import "draw.typ"
#import "utils.typ": *
#import "curve-process.typ": *
#import "style.typ": *
#import "elements.typ": *


#let get-length(arr) = arr.last() - arr.first()
#let _gen-ctx(viewport: Rect, length: Length) = {
  assert.ne(viewport, Rect)
  assert.ne(length, Length)
  return (
    viewport: viewport,
    length: length,
  )
}

/// Draw a parametric curve.
/// -> content
#let parametric-curve-2d(
  /// A univariate $RR^2$-valued function, namely $f: RR -> RR^2$.
  /// -> function
  vector-fn: t => { (t, t * t) },

  /// The parameter range of `vector-fn`.
  /// -> Range
  t-range: (-5, 5),

  /// Clipping rect in Cartesian coordinates. `none` means no clipping (equivalent to `Axes(x: none, y: none)`).
  ///
  /// Each axis of `Axes` can be `none` or an array containing two real numbers.
  /// -> none | Axes
  clip-box: Axes(x: (-5, 5), y: (-5, 5)),

  /// See @stroke.
  /// #ret stroke
  stroke: default-base-stroke,

  /// See @stroke-config.
  /// -> Stroke-config.
  stroke-config: default-stroke-config,

  /// See @fill.
  /// #ret fill
  fill: none,

  /// See @fill-rule.
  /// -> str
  fill-rule: "non-zero",

  /// Geometry granularity control for `geom-sampler`.
  ///
  /// `max-dist` and `min-dist` should be non-negative extended real numbers (namely $[0, +oo]$), and `max-angle` should be an acute angle or a zero angle (namely $0 degree <= #raw("max-angle") < 90 degree$).
  ///
  /// `dist` is the distance between the two endpoints of the current segment.
  /// `angle` is the angle between the vector of the current segment and that of the previous segment. If there is no previous segment, the angle check is skipped.
  ///
  /// A segment is acceptable if any of the following conditions holds, checked in order, where `dist` and `angle` refer to the corresponding values of the current segment:
  /// 1. $#raw("dist") <= #raw("min-dist")$
  /// 2. $(#raw("dist") > #raw("min-dist")) and (#raw("dist") <= #raw("max-dist")) and (#raw("angle") <= #raw("max-angle"))$
  ///
  /// Since the conditions are checked in order, `min-dist` and `max-dist` do not need to satisfy any strict ordering relationship.
  ///
  /// All available geometry granularity presets are listed as follows:
  /// #extract-def("header.typ", id: "geom-presets")
  /// -> Geom-granularity
  geom-granularity: geom-presets.balanced,

  /// Maximum recursion depth for `geom-sampler`.
  /// -> int
  max-depth: 12,

  /// Sample count for `uniform-sampler`.
  /// -> int
  init-samples: 150,

  /// Whether to detect jump discontinuities.
  ///
  /// Uses #link("https://doi.org/10.1137/S0036142903435259")[minmod edge detection]. It is expensive and this implementation is not very stable. Do not set this parameter to `true` for oscillatory curves (including infinite winding), as it causes very high cost and may even cause runtime errors.
  /// -> bool
  detect-edge: false,

  /// Screen length corresponding to 1 unit in Cartesian coordinates. Don't use #link("https://typst.app/docs/reference/layout/ratio/")[`ratio`] or #link("https://typst.app/docs/reference/layout/relative/")[`relative`].
  /// -> length
  length: 1em,

  /// Viewport in Cartesian coordinates. If `auto`, use the automatically detected bounding box of the curve. If `Axes`, use the specified `Axes`.
  /// -> auto | Axes
  viewport: auto,
) = {
  let clip-box = resolve-clip-box(clip-box)
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  let (render, bounds) = _parametric-curve-2d(
    vector-fn: vector-fn,
    t-range: t-range,
    clip-box: clip-box,
    fill: fill,
    fill-rule: fill-rule,
    stroke: stroke,
    geom-granularity: geom-granularity,
    max-depth: max-depth,
    init-samples: init-samples,
    detect-edge: detect-edge,
  )
  viewport = resolve-viewport(viewport, bounds: bounds)
  let drawable = render(_gen-ctx(viewport: viewport, length: length))
  block(
    breakable: false,
    width: get-length(viewport.x) * length,
    height: get-length(viewport.y) * length,
    place(top + left, drawable),
  )
}


/// A canvas for drawing.
#let canvas(
  /// A viewport determines how large the `block` containing this canvas is. Since `clip == false`, the content outside the `block` is visible but not in flow.
  ///
  /// Each axis of `Axes` can be `auto` or an array containing two real numbers.
  /// -> auto | Axes
  viewport: Axes(x: (-5, 5), y: (-5, 5)),

  /// Screen length corresponding to 1 unit in Cartesian coordinates. Don't use #link("https://typst.app/docs/reference/layout/ratio/")[`ratio`] or #link("https://typst.app/docs/reference/layout/relative/")[`relative`].
  /// -> length
  length: 1em,

  /// The `inset` parameter of the `block`. See #link("https://typst.app/docs/reference/layout/block/#parameters-inset").
  ///
  /// There is one difference, however: here `inset` only accepts #link("https://typst.app/docs/reference/layout/length/")[`length`], not #link("https://typst.app/docs/reference/layout/ratio/")[`ratio`] or #link("https://typst.app/docs/reference/layout/relative/")[`relative`].
  /// -> length
  inset: 0pt,

  /// An array each element is of type `Element`. All `Element`s are generated by functions in the `draw` module.
  /// -> array
  elements,
) = {
  let bounds-rects = elements.map(element => element.bounds)
  let x-bounds = range-union(..bounds-rects.map(rect => rect.x))
  let y-bounds = range-union(..bounds-rects.map(pair => pair.y))
  let bounds = axes-to-rect(Axes(x: x-bounds, y: y-bounds))
  viewport = resolve-viewport(viewport, bounds: bounds)
  let resolved-inset = resolve-sides(inset)
  let delta-x = resolved-inset.left + resolved-inset.right
  let delta-y = resolved-inset.top + resolved-inset.bottom
  let resolved-elements = elements
    .map(element => (element.render)(_gen-ctx(viewport: viewport, length: length)))
    .flatten()
  block(
    width: get-length(viewport.x) * length + delta-x,
    height: get-length(viewport.y) * length + delta-y,
    // clip: true,
    breakable: false,
    inset: inset,
    for resolved-element in resolved-elements {
      place(top + left, resolved-element)
    },
  )
}


