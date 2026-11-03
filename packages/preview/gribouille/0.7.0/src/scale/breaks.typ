///! Break generators for continuous scales.
///!
///! Each helper returns a closure that a `scale-*` call passes to `breaks:` or
///! `minor-breaks:`. The closure is called with the vector of values the scale
///! trained on, in data space, once per panel, and returns the break positions.
///! Writing the closure by hand works just as well; these cover the common
///! placements.

#import "../utils/errors.typ": check, fail, fail-type
#import "../utils/pretty.typ": pretty
#import "../utils/extended.typ": extended

// Data range of the trained values, or `none` when the vector is empty (an
// unmapped scale, or one whose every cell failed to parse as a number).
// Folded rather than spread through `calc.min`, which would push one argument
// per row onto the call stack for a large dataset.
#let _range-of(values) = {
  if values.len() == 0 { return none }
  let lo = values.first()
  let hi = lo
  for v in values {
    if v < lo { lo = v }
    if v > hi { hi = v }
  }
  (lo, hi)
}

/// Breaks spaced a fixed distance apart.
///
/// Covers the data range with positions `offset + k * width`, so the ticks stay on round multiples however the domain moves. The counterpart of `scales::breaks_width()`.
///
/// - width: Distance between consecutive breaks; must be positive.
/// - offset: Value the sequence is anchored on, i.e. every break is `offset` plus a whole multiple of `width`.
///
/// Returns: Closure taking the trained values and returning break positions.
///
/// See also: `breaks-pretty`, `breaks-quantile`, `scale-continuous`.
///
/// A tick every 2.5 miles per gallon, whatever the trained range.
///
/// ```typst
/// #plot(
///   data: mpg,
///   mapping: aes(x: "displ", y: "hwy"),
///   layers: (geom-point(),),
///   scales: scales(y: scale-continuous(breaks: breaks-width(2.5))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let breaks-width(width, offset: 0) = {
  check(
    type(width) == int or type(width) == float,
    "breaks-width",
    "width must be a number; got " + repr(width),
  )
  check(width > 0, "breaks-width", "width must be positive; got " + repr(width))
  check(
    type(offset) == int or type(offset) == float,
    "breaks-width",
    "offset must be a number; got " + repr(offset),
  )
  values => {
    let span = _range-of(values)
    if span == none { return () }
    let (lo, hi) = span
    let first = calc.ceil((lo - offset) / width)
    let last = calc.floor((hi - offset) / width)
    if last < first { return () }
    range(int(first), int(last) + 1).map(k => offset + k * width)
  }
}

/// Round breaks at roughly the requested count.
///
/// Picks positions of the form `c * 10^k` for `c` in 1, 2, 5, the same algorithm the automatic breaks use, so `n` is a target rather than a guarantee. Whole-number data keeps whole breaks. The counterpart of `scales::breaks_pretty()`.
///
/// - n: Target number of intervals; the tick count lands near `n + 1`.
///
/// Returns: Closure taking the trained values and returning break positions.
///
/// See also: `breaks-width`, `breaks-quantile`, `scale-continuous`.
///
/// Two intervals instead of the default five.
///
/// ```typst
/// #plot(
///   data: mpg,
///   mapping: aes(x: "displ", y: "hwy"),
///   layers: (geom-point(),),
///   scales: scales(x: scale-continuous(breaks: breaks-pretty(n: 2))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let breaks-pretty(n: 5) = {
  check(
    type(n) == int and n > 0,
    "breaks-pretty",
    "n must be a positive integer; got " + repr(n),
  )
  values => {
    let span = _range-of(values)
    if span == none { return () }
    let (lo, hi) = span
    pretty(lo, hi, n: n, integer: values.all(v => v == calc.round(v)))
  }
}

/// Round breaks from the extended Wilkinson search.
///
/// Scores candidate sequences on simplicity, coverage of the data, and how close the tick count lands to `n`, which is what the automatic breaks already do; call it to ask for a different `n`. The counterpart of `scales::breaks_extended()`.
///
/// - n: Target number of ticks; the search trades it off against the other criteria, so the result may hold one or two more or fewer.
///
/// Returns: Closure taking the trained values and returning break positions.
///
/// See also: `breaks-pretty`, `breaks-width`, `scale-continuous`.
///
/// Eight ticks where the default asks for five.
///
/// ```typst
/// #plot(
///   data: mpg,
///   mapping: aes(x: "displ", y: "hwy"),
///   layers: (geom-point(),),
///   scales: scales(y: scale-continuous(breaks: breaks-extended(n: 8))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let breaks-extended(n: 5) = {
  check(
    type(n) == int and n > 1,
    "breaks-extended",
    "n must be an integer above 1; got " + repr(n),
  )
  values => {
    let span = _range-of(values)
    if span == none { return () }
    let (lo, hi) = span
    extended(lo, hi, m: n, integer: values.all(v => v == calc.round(v)))
  }
}

// Exponent of `v` in `base`, snapped to a whole number when the logarithm lands
// within a whisker of one: `calc.log(1000, base: 10)` gives 2.9999999999999996,
// and an unsnapped `floor` would drop a whole decade.
#let _log-exponent(v, base) = {
  let e = calc.log(v, base: base)
  let rounded = calc.round(e)
  if calc.abs(e - rounded) < 1e-9 { rounded } else { e }
}

// Powers `base^k` for `k` walking `kmin` to `kmax` in steps of `by`.
#let _log-powers(kmin, kmax, by, base) = {
  range(kmin, kmax + 1, step: by).map(k => calc.pow(float(base), k))
}

// How many of `breaks` land inside the data range, with the same relative
// tolerance `pretty-log10` uses so a break sitting exactly on an endpoint counts.
#let _log-in-range(breaks, lo, hi) = {
  let tol-lo = lo * (1 - 1e-9)
  let tol-hi = hi * (1 + 1e-9)
  breaks.filter(b => b >= tol-lo and b <= tol-hi).len()
}

// Smallest gap, in log space, between consecutive entries of `steps`, `x`, and
// `base`. The candidate mantissa that maximises it is the one that best bisects
// the mantissas placed so far, which is how `scales` orders its fill-in.
#let _log-gap(x, steps, base) = {
  let points = (steps + (x, base)).map(v => calc.log(v, base: base)).sorted()
  let gap = points.at(1) - points.at(0)
  for i in range(2, points.len()) {
    let d = points.at(i) - points.at(i - 1)
    if d < gap { gap = d }
  }
  gap
}

// Sub-decade fill-in: add one mantissa at a time, best bisection first, until
// enough breaks land inside the data range. Mirrors `scales:::log_sub_breaks`,
// including the one break of padding either side; `_axis-breaks` clips the
// padding back off against the visible domain, so it never reaches an axis.
#let _log-sub-breaks(lo, hi, kmin, kmax, n, base) = {
  if base <= 2 { return _log-powers(kmin, kmax, 1, base) }
  let steps = (1,)
  let candidates = range(2, int(calc.floor(base)))
  let breaks = ()
  while candidates.len() > 0 {
    let best = 0
    let best-gap = _log-gap(candidates.first(), steps, base)
    for (i, c) in candidates.enumerate() {
      let gap = _log-gap(c, steps, base)
      if gap > best-gap {
        best-gap = gap
        best = i
      }
    }
    steps.push(candidates.at(best))
    let _ = candidates.remove(best)
    breaks = ()
    for k in range(kmin, kmax + 1) {
      let power = calc.pow(float(base), k)
      for s in steps { breaks.push(s * power) }
    }
    if _log-in-range(breaks, lo, hi) >= n - 2 { break }
  }
  if _log-in-range(breaks, lo, hi) < n - 2 { return extended(lo, hi, m: n) }
  breaks = breaks.sorted()
  let tol-lo = lo * (1 - 1e-9)
  let tol-hi = hi * (1 + 1e-9)
  let first = breaks.position(b => b >= tol-lo)
  if first == none { return breaks }
  let last = breaks.len() - 1 - breaks.rev().position(b => b <= tol-hi)
  breaks.slice(calc.max(first - 1, 0), calc.min(last + 2, breaks.len()))
}

/// Breaks at powers of a base.
///
/// Places a tick on each power of `base` that the data spans, thinning them when the span is wide. When too few powers fall inside the range, sub-decade steps fill in, best bisection first, the way `scales::breaks_log()` does. Pair it with `transform: "log10"`, where evenly spaced powers are what the axis draws.
///
/// A break is undefined at or below zero, so non-positive values drop out the way a log axis drops them. A scale that trained on values and kept none of them has no breaks to place and fails, rather than drawing an axis with no ticks and no reason given. A scale that trained on nothing at all is not that case, and answers no breaks as every other helper does.
///
/// - n: Target number of ticks; the fill-in stops once the count is near it, so the result may hold one or two more or fewer.
/// - base: Base of the powers; must be above 1. It is independent of the scale transform, so `base: 2` on a `"log10"` axis places its ticks at powers of two, spaced unevenly on screen.
///
/// Returns: Closure taking the trained values and returning break positions.
///
/// See also: `breaks-pretty`, `format-log`, `scale-log10`.
///
/// A tick on every decade of a log axis.
///
/// ```typst
/// #plot(
///   data: (
///     (x: 1, y: 3), (x: 2, y: 12), (x: 3, y: 60), (x: 4, y: 250),
///     (x: 5, y: 900), (x: 6, y: 4000), (x: 7, y: 20000),
///   ),
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(y: scale-log10(breaks: breaks-log())),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let breaks-log(n: 5, base: 10) = {
  check(
    type(n) == int and n > 0,
    "breaks-log",
    "n must be a positive integer; got " + repr(n),
  )
  if type(base) != int and type(base) != float {
    fail-type("breaks-log", "base", base, "a number")
  }
  check(base > 1, "breaks-log", "base must be above 1; got " + repr(base))
  values => {
    if values.len() == 0 { return () }
    // A log break is undefined at or below zero. Non-positive rows drop out
    // rather than fail, since a log axis discards them too, but a vector with
    // nothing positive left has no answer to give.
    let positive = values.filter(v => v > 0)
    if positive.len() == 0 {
      fail("breaks-log", "no positive values to place breaks on")
    }
    let (lo, hi) = _range-of(positive)
    let kmin = int(calc.floor(_log-exponent(lo, base)))
    let kmax = int(calc.ceil(_log-exponent(hi, base)))
    if kmax == kmin { return (calc.pow(float(base), kmin),) }
    let by = int(calc.floor((kmax - kmin) / n)) + 1
    while by >= 1 {
      let breaks = _log-powers(kmin, kmax, by, base)
      if _log-in-range(breaks, lo, hi) >= n - 2 { return breaks }
      by = by - 1
    }
    _log-sub-breaks(lo, hi, kmin, kmax, n, base)
  }
}

/// Breaks at sample quantiles of the data.
///
/// Places a tick at each requested probability, so the axis reports where the mass of the data sits rather than a regular grid. Quantiles interpolate linearly between the two neighbouring order statistics. The counterpart of `scales::breaks_quantile()`.
///
/// - probs: Array of probabilities in `[0, 1]`.
///
/// Returns: Closure taking the trained values and returning break positions.
///
/// See also: `breaks-width`, `breaks-pretty`, `scale-continuous`.
///
/// Quartile ticks on both axes.
///
/// ```typst
/// #plot(
///   data: penguins,
///   mapping: aes(x: "flipper-len", y: "body-mass"),
///   layers: (geom-point(),),
///   scales: scales(
///     x: scale-continuous(breaks: breaks-quantile()),
///     y: scale-continuous(breaks: breaks-quantile(probs: (0, 0.5, 1))),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let breaks-quantile(probs: (0, 0.25, 0.5, 0.75, 1)) = {
  for p in probs {
    if type(p) != int and type(p) != float {
      fail-type("breaks-quantile", "probs", p, "an array of numbers")
    }
    check(
      p >= 0 and p <= 1,
      "breaks-quantile",
      "probs must lie in [0, 1]; got " + repr(p),
    )
  }
  values => {
    if values.len() == 0 { return () }
    let sorted = values.sorted()
    let last = sorted.len() - 1
    probs.map(p => {
      let pos = p * last
      let below = int(calc.floor(pos))
      let above = int(calc.ceil(pos))
      if below == above { return sorted.at(below) }
      let weight = pos - below
      sorted.at(below) * (1 - weight) + sorted.at(above) * weight
    })
  }
}
