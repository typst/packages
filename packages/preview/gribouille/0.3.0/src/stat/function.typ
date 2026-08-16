///! Sample a callable across a range to produce `(x, fun(x))` rows.
///!
///! Stat-flavoured counterpart to \@geom-function. The framework runs stats
///! before training, so the sampling range comes from `xlim` rather than the
///! trained x-domain. The output rows can feed any geom that consumes `x`
///! and `y` (point, line, path, step).

#import "../utils/types.typ": parse-number
#import "../utils/errors.typ": fail

/// Sample `fun` at `n` points across `xlim` and emit `(x, y)` rows.
///
/// `xlim` defaults to `(0, 1)`. Pass `xlim: none` to fall back to the layer's own `data`: the min and max of the values referenced by `mapping.x` are used as sampling bounds. If neither `xlim` nor numeric data is available the stat panics with a helpful message.
///
/// - fun: Callable taking a numeric x and returning a numeric y.
/// - n: Number of samples taken uniformly across the range.
/// - xlim: Pair `(lo, hi)` bounding the sampling range, or `none` to derive from data.
///
/// Returns: Statistic object with `name: "function"`, consumed by geom layers.
///
/// See also: `geom-function`, `stat-smooth`.
///
/// Sine sampled across `xlim` and rendered as a line.
///
/// ```typst
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
/// The string form `stat: "function"` resolves to the constructor defaults (`fun: x => x`, `n: 101`, `xlim: (0, 1)`). In practice the constructor form is always required because `fun` must be supplied.
///
/// ```typst
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
#let stat-function(fun: x => x, n: 101, xlim: (0, 1)) = (
  kind: "stat",
  name: "function",
  params: (fun: fun, n: n, xlim: xlim),
)

#let _resolve-xlim(xlim, data, mapping) = {
  if xlim != none { return xlim }
  if data == none or data.len() == 0 {
    fail(
      "stat-function",
      "xlim is none and no data available",
      hint: "Pass xlim: (lo, hi) or supply numeric data for the x mapping.",
    )
  }
  let x-col = if mapping == none { none } else {
    mapping.at("x", default: none)
  }
  if x-col == none {
    fail(
      "stat-function",
      "xlim is none and mapping has no x column",
      hint: "Pass xlim: (lo, hi) or set an x mapping.",
    )
  }
  let nums = data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
  if nums.len() == 0 {
    fail(
      "stat-function",
      "xlim is none and data has no numeric x values",
      hint: "Pass xlim: (lo, hi) explicitly.",
    )
  }
  (calc.min(..nums), calc.max(..nums))
}

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "x", y: "y")
  let fun = params.at("fun", default: none)
  if fun == none {
    fail("stat-function", "fun must be a callable; got none")
  }
  let xlim = _resolve-xlim(
    params.at("xlim", default: (0, 1)),
    data,
    mapping,
  )
  let n = calc.max(2, int(params.at("n", default: 101)))
  let (lo, hi) = (float(xlim.at(0)), float(xlim.at(1)))
  if hi <= lo {
    fail("stat-function", "xlim must satisfy hi > lo; got " + repr((lo, hi)))
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
