///! Sample a callable across a range to produce `(x, fun(x))` rows.
///!
///! Stat-flavoured counterpart to \@geom-function. The framework runs stats
///! before training, so the sampling range comes from `xlim` rather than the
///! trained x-domain. The output rows can feed any geom that consumes `x`
///! and `y` (point, line, path, step).

#import "../utils/types.typ": parse-number

/// Sample `fun` at `n` points across `xlim` and emit `(x, y)` rows.
///
/// `xlim` defaults to `(0, 1)`. Pass `xlim: none` to fall back to the layer's
/// own `data`: the min and max of the values referenced by `mapping.x` are
/// used as sampling bounds. If neither `xlim` nor numeric data is available
/// the stat panics with a helpful message.
///
/// \@category Stats
/// \@subcategory Functions and helpers
/// \@stability stable
/// \@since 0.0.1
///
/// \@param fun Callable taking a numeric x and returning a numeric y.
///
/// \@param n Number of samples taken uniformly across the range.
///
/// \@param xlim Pair `(lo, hi)` bounding the sampling range, or `none` to derive from data.
///
/// \@returns Statistic object with `name: "function"`, consumed by geom layers.
///
/// \@examples Sine sampled across `xlim` and rendered as a line.
/// ```
/// //| alt: "Line chart with x on the horizontal axis from minus pi to pi and y on the vertical axis, tracing the sine function sampled across the xlim range."
/// #let frame = ((x: -calc.pi, y: -1), (x: calc.pi, y: 1))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-blank(),
///     geom-line(stat: stat-function(
///       fun: x => calc.sin(x),
///       xlim: (-calc.pi, calc.pi),
///     )),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples The string form `stat: "function"` resolves to the constructor
/// defaults (`fun: x => x`, `n: 101`, `xlim: (0, 1)`). In practice the
/// constructor form is always required because `fun` must be supplied.
/// ```
/// //| alt: "Line chart with x on the horizontal axis from zero to two pi and y on the vertical axis, plotting the cosine function as a dense line overlaid with 13 sampled points."
/// #let frame = ((x: 0, y: 0), (x: 6.28, y: 1))
/// #plot(
///   data: frame,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-blank(),
///     geom-point(
///       size: 2pt,
///       stat: stat-function(fun: x => calc.cos(x), n: 13, xlim: (0, 6.28)),
///     ),
///     geom-line(stat: stat-function(fun: x => calc.cos(x), n: 201, xlim: (0, 6.28))),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-function, \@stat-smooth
#let stat-function(fun: x => x, n: 101, xlim: (0, 1)) = (
  kind: "stat",
  name: "function",
  params: (fun: fun, n: n, xlim: xlim),
)

#let _resolve-xlim(xlim, data, mapping) = {
  if xlim != none { return xlim }
  if data == none or data.len() == 0 {
    panic(
      "stat-function: xlim is none and no data available; "
        + "pass xlim: (lo, hi) or supply numeric data for the x mapping.",
    )
  }
  let x-col = if mapping == none { none } else {
    mapping.at("x", default: none)
  }
  if x-col == none {
    panic(
      "stat-function: xlim is none and mapping has no x column; "
        + "pass xlim: (lo, hi) or set an x mapping.",
    )
  }
  let nums = data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  if nums.len() == 0 {
    panic(
      "stat-function: xlim is none and data has no numeric x values; "
        + "pass xlim: (lo, hi) explicitly.",
    )
  }
  (calc.min(..nums), calc.max(..nums))
}

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "x", y: "y")
  let fun = params.at("fun", default: none)
  if fun == none {
    panic("stat-function: fun must be a callable; got none.")
  }
  let xlim = _resolve-xlim(
    params.at("xlim", default: (0, 1)),
    data,
    mapping,
  )
  let n = calc.max(2, int(params.at("n", default: 101)))
  let (lo, hi) = (float(xlim.at(0)), float(xlim.at(1)))
  if hi <= lo {
    panic(
      "stat-function: xlim must satisfy hi > lo; got " + repr((lo, hi)),
    )
  }
  let step = (hi - lo) / (n - 1)
  let rows = ()
  for i in range(0, n) {
    let x = lo + i * step
    let y = fun(x)
    if y == none { continue }
    rows.push((x: x, y: float(y)))
  }
  (data: rows, mapping: base-mapping)
}
