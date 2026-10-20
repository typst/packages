#import "_draw.typ": *
#import "style.typ": *
#import "header.typ": epsilon-for-algo
#import "format/format.typ": panic-fmt

/// This function avoids zero-length `std.curve.line`.
/// It can be removed once #link("https://github.com/typst/typst/issues/8894")[#8894] is fixed.
///
/// The reproduction condition is not yet clear.
#let _offset(pair) = {
  let (x, y) = pair
  return (x + epsilon-for-algo, y)
  // return (x, y)
}


/// Draw a parametric curve.
/// -> Element
#let _parametric-curve-2d(
  /// A univariate $RR^2$-valued function, namely $f: RR -> RR^2$.
  /// -> function
  vector-fn: t => { (t, t * t) },

  /// The parameter range of `vector-fn`.
  /// -> array
  t-range: (-5, 5),

  /// Clipping rect in Cartesian coordinates. `none` means no clipping (equivalent to `Axes(x: none, y: none)`).
  ///
  /// Each axis of `Axes` can be `none` or an array containing two real numbers.
  /// -> none | Axes
  clip-box: Axes(x: (-5, 5), y: (-5, 5)),

  /// See #link("https://typst.app/docs/reference/visualize/curve/#parameters-stroke").
  ///
  /// `default-base-stroke` is defined as:
  /// #extract-def("style.typ", id: "default-base-stroke")
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: default-base-stroke,

  /// A dictionary containing exactly `stroke-mode` and `base-stroke`.
  ///
  /// `stroke-mode` is either #highlight("merge") or #highlight("cover").
  ///
  /// `base-stroke` is the underlying stroke used for merging when `stroke-mode` is #highlight("merge"). When `stroke-mode` is #highlight("cover"), `base-stroke` has no effect.
  ///
  /// The default `stroke-config` is defined as
  /// #extract-def("style.typ", id: "default-stroke-config")
  /// -> Stroke-config
  stroke-config: default-stroke-config,

  /// See #link("https://typst.app/docs/reference/visualize/curve/#parameters-fill").
  /// -> none | color | gradient | tiling
  fill: none,

  /// See #link("https://typst.app/docs/reference/visualize/curve/#parameters-fill-rule").
  /// -> str
  fill-rule: "non-zero",

  /// Geometry granularity control for `geom-sampler`.
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
) = {
  import "curve-process.typ": *
  assert.ne(t-range, none)
  assert(init-samples > 1)
  let stroke = resolve-stroke(stroke, stroke-config: stroke-config)
  if geom-granularity == geom-presets.pointwise {
    // To draw a point, `cap` must not be `"butt"`.
    // With `"butt"`, the zero-length segment renders as nothing.
    // Since this is a point, `"round"` is typically used.
    if stroke.cap == "butt" {
      panic-fmt(
        "When using `discrete-geom-granularity`, the `cap` of `stroke` cannot be `butt`. Please use `round` or `square` instead.",
      )
    }
    let samples = init-samples * calc.pow(2, max-depth)
    let max-samples = 20 * calc.pow(2, 8)
    if samples >= max-samples {
      panic-fmt(
        "Too many samples for `geom-presets.pointwise`. Got {}, exceeding the maximum of {}. Consider reducing `init-samples` or `max-depth`.",
        str(samples),
        str(max-samples),
      )
    }
  }
  clip-box = resolve-clip-box(clip-box)

  let (pieces, sentinels) = get-curve-components(
    vector-fn: vector-fn,
    t-range: t-range,
    clip-box: clip-box,
    geom-granularity: geom-granularity,
    max-depth: max-depth,
    init-samples: init-samples,
    detect-edge: detect-edge,
  )

  let render = ctx => {
    let sentinels = sentinels
    let (viewport, length) = ctx
    let components = ()
    for piece in pieces {
      let sentinel = sentinels.pop()
      components.push(std.curve.move(cartesian-to-screen(
        _offset(dict-to-pair(sentinel)),
        viewport: viewport,
        scale: (
          length,
          -length,
        ),
      )))
      for point in piece {
        components.push(std.curve.line(cartesian-to-screen(
          dict-to-pair(point),
          viewport: viewport,
          scale: (
            length,
            -length,
          ),
        )))
      }
    }
    std.curve(..components, stroke: stroke, fill: fill, fill-rule: fill-rule)
  }
  // type Element
  return Element(
    render: render,
    bounds: get-aabb(..pieces.flatten().map(dict-to-pair)),
  )
}
