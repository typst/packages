///! Break generators for continuous scales.
///!
///! Each helper returns a closure that a `scale-*` call passes to `breaks:` or
///! `minor-breaks:`. The closure is called with the vector of values the scale
///! trained on, in data space, once per panel, and returns the break positions.
///! Writing the closure by hand works just as well; these cover the common
///! placements.

#import "../utils/errors.typ": check, fail-type
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
