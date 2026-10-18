///! Per-x summary statistic backing \@geom-pointrange and friends.
///!
///! For every distinct x level in the input data, reduces the y values to a
///! single `(x, y, ymin, ymax)` row using one of the summary helpers in
///! `src/utils/summaries.typ`.

#import "../utils/types.typ": parse-number
#import "../utils/summaries.typ": summarise
#import "../utils/errors.typ": fail-enum

/// Per-axis reduction to a central value and an uncertainty band.
///
/// The output shape is controlled by `axis`:
///
/// - `"y"` — bucket rows by their raw `x` value and emit one `(x, y, ymin, ymax)` row per bucket.
/// - `"x"` — transpose: bucket rows by their raw `y` value and emit one `(x, xmin, xmax, y)` row per bucket.
/// - `"both"` (default) — when a grouping aesthetic is set with a continuous `x` (the data has been pre-partitioned upstream and bucketing would yield one row per observation), collapse the partition to a single bivariate row `(x, y, xmin, xmax, ymin, ymax)`. Otherwise the per-x bucket path is used and `xmin = xmax` is set to the bucket's parsed `x` whenever it is numeric, so horizontal-error geoms still find valid keys.
///
/// `fun` accepts a string name dispatched through `summarise` (`"mean-se"`, `"mean-cl-normal"`, `"mean-cl-boot"`, `"mean-sd"`, `"median-hilow"`, `"mean"`, `"median"`, `"quantile"`, `"quantiles"`) or a Typst callable of the form `(values, ..fun-args) -> (y, ymin, ymax)`.
///
/// - fun: Summary helper name or callable returning `(y, ymin, ymax)`.
/// - fun-args: Keyword arguments forwarded to the helper or callable, for example `(multiplier: 2)` for `mean-se` or `(conf: 0.5)` for `median-hilow`.
/// - axis: Output axis: `"both"` (default), `"x"`, or `"y"`.
///
/// Returns: Statistic object with `name: "summary"`, consumed by geom layers.
///
/// See also: `stat-summary-bin`, `stat-boxplot`.
///
/// Mean and standard-error summary per group, drawn as a line and ribbon stack.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(20) {
///     d.push((grp: grp, y: calc.sin(i) + i / 10))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (
///     geom-line(stat: stat-summary(fun: "mean-se")),
///     geom-ribbon(stat: stat-summary(fun: "mean-se")),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// `stat: "summary"` is equivalent to `stat: stat-summary()` with defaults (`fun: "mean-se"`). Use the constructor to choose a different reducer or pass `fun-args`.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(20) {
///     d.push((grp: grp, y: calc.sin(i) + i / 10))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (
///     geom-pointrange(
///       size: 3pt,
///       stat: stat-summary(fun: "median-hilow", fun-args: (conf: 0.5)),
///     ),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let stat-summary(fun: "mean-se", fun-args: (:), axis: "both") = (
  kind: "stat",
  name: "summary",
  params: (fun: fun, "fun-args": fun-args, axis: axis),
)

#let _group-aesthetics = ("group", "colour", "fill", "linetype", "shape")
#let _pass-aesthetics = _group-aesthetics + ("label",)

#let _weights-of(data, weight-col) = {
  if weight-col == none { return none }
  data.map(r => r.at(weight-col, default: none))
}

#let _bivariate-row(data, x-col, y-col, fun, fun-args, mapping, weight-col) = {
  let xs = data.map(r => r.at(x-col, default: none))
  let ys = data.map(r => r.at(y-col, default: none))
  let weights = _weights-of(data, weight-col)
  let sx = summarise(fun, xs, fun-args: fun-args, weights: weights)
  let sy = summarise(fun, ys, fun-args: fun-args, weights: weights)
  if sx.y == none or sy.y == none {
    return (data: (), mapping: (x: "x", y: "y", ymin: "ymin", ymax: "ymax"))
  }
  let bmap = (
    x: "x",
    y: "y",
    xmin: "xmin",
    xmax: "xmax",
    ymin: "ymin",
    ymax: "ymax",
  )
  for aes in _pass-aesthetics {
    let col = mapping.at(aes, default: none)
    if col != none { bmap.insert(aes, col) }
  }
  (
    data: (
      (
        x: sx.y,
        y: sy.y,
        xmin: sx.ymin,
        xmax: sx.ymax,
        ymin: sy.ymin,
        ymax: sy.ymax,
      ),
    ),
    mapping: bmap,
  )
}

#let _bucket-by(data, key-col) = {
  let buckets = (:)
  let order = ()
  for row in data {
    let key = str(row.at(key-col, default: ""))
    if key == "" { continue }
    if key in buckets {
      let bucket = buckets.at(key)
      bucket.push(row)
      buckets.insert(key, bucket)
    } else {
      buckets.insert(key, (row,))
      order.push(key)
    }
  }
  (buckets: buckets, order: order)
}

#let apply(data, mapping, params: (:)) = {
  let base-mapping = (x: "x", y: "y", ymin: "ymin", ymax: "ymax")
  if mapping == none { return (data: (), mapping: base-mapping) }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none {
    return (data: (), mapping: base-mapping)
  }
  if data.len() == 0 { return (data: (), mapping: base-mapping) }

  let fun = params.at("fun", default: "mean-se")
  let fun-args = params.at("fun-args", default: (:))
  let axis = params.at("axis", default: "both")
  if not ("both", "x", "y").contains(axis) {
    fail-enum("stat-summary", "axis", axis, ("both", "x", "y"))
  }
  let weight-col = mapping.at("weight", default: none)

  let has-grouping = _group-aesthetics.any(a => (
    mapping.at(a, default: none) != none
  ))

  // Bivariate collapse: under axis "both" with a grouping aesthetic and
  // continuous x, the data is pre-partitioned upstream so per-x bucketing
  // would yield one row per observation. Emit a single bivariate row instead.
  if axis == "both" and has-grouping {
    let x-nonnull = data
      .map(r => r.at(x-col, default: none))
      .filter(v => v != none)
    let x-continuous = (
      x-nonnull.len() > 0 and x-nonnull.all(v => parse-number(v) != none)
    )
    if x-continuous {
      return _bivariate-row(
        data,
        x-col,
        y-col,
        fun,
        fun-args,
        mapping,
        weight-col,
      )
    }
  }

  if axis == "x" {
    let xmap = (x: "x", y: "y", xmin: "xmin", xmax: "xmax")
    for aes in _pass-aesthetics {
      let col = mapping.at(aes, default: none)
      if col != none { xmap.insert(aes, col) }
    }
    let bucketed = _bucket-by(data, y-col)
    let out = ()
    for key in bucketed.order {
      let rows = bucketed.buckets.at(key)
      let xs = rows.map(r => r.at(x-col, default: none))
      let weights = _weights-of(rows, weight-col)
      let summary = summarise(fun, xs, fun-args: fun-args, weights: weights)
      if summary.y == none { continue }
      let raw-y = rows.first().at(y-col, default: none)
      let parsed-y = parse-number(raw-y)
      let y-value = if parsed-y != none { parsed-y } else { raw-y }
      out.push((
        x: summary.y,
        xmin: summary.ymin,
        xmax: summary.ymax,
        y: y-value,
      ))
    }
    return (data: out, mapping: xmap)
  }

  // Per-x bucket path. Buckets are emitted in first-appearance order so the
  // downstream x scale keeps the input's level ordering.
  let out-mapping = base-mapping
  for aes in _pass-aesthetics {
    let col = mapping.at(aes, default: none)
    if col != none { out-mapping.insert(aes, col) }
  }
  let emit-x-band = axis == "both"
  if emit-x-band {
    out-mapping.insert("xmin", "xmin")
    out-mapping.insert("xmax", "xmax")
  }
  let bucketed = _bucket-by(data, x-col)
  let out = ()
  for key in bucketed.order {
    let rows = bucketed.buckets.at(key)
    let ys = rows.map(r => r.at(y-col, default: none))
    let weights = _weights-of(rows, weight-col)
    let summary = summarise(fun, ys, fun-args: fun-args, weights: weights)
    if summary.y == none { continue }

    let raw-x = rows.first().at(x-col, default: none)
    let parsed-x = parse-number(raw-x)
    let x-value = if parsed-x != none { parsed-x } else { raw-x }

    let row = (
      x: x-value,
      y: summary.y,
      ymin: summary.ymin,
      ymax: summary.ymax,
    )
    if emit-x-band and parsed-x != none {
      row.insert("xmin", parsed-x)
      row.insert("xmax", parsed-x)
    }
    out.push(row)
  }

  (data: out, mapping: out-mapping)
}
