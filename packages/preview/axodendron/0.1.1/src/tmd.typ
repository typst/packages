// Topological Morphology Descriptor computation and persistence plots.

#import "protocol.typ": _plugin, _request, _required, _unwrap, _require-payload
#import "analysis.typ": _selection

/// Compute a Topological Morphology Descriptor persistence barcode.
///
/// - cell (dictionary): Morphology to analyze.
/// - filtration (str): `"radial-distance"` or `"root-path-length"`.
/// - center (auto, none, str): Radial origin, `"soma"` or `"root"`; not applicable to root-path filtration.
/// - domain (str): Selection domain.
/// - kinds (array): Optional SWC kind filter.
/// - roots (array): Optional subtree roots.
/// - nodes (array): Optional explicit node IDs.
/// -> dictionary
#let tmd(
  cell,
  filtration: "radial-distance",
  center: auto,
  domain: "neurites",
  kinds: (),
  roots: (),
  nodes: (),
) = {
  let center = if center == auto {
    if filtration == "radial-distance" { "soma" } else { none }
  } else {
    center
  }
  if filtration == "root-path-length" and center != none {
    panic("Axodendron: `center` is not applicable to root-path-length TMD; each selected arbor root has path distance zero")
  }
  _unwrap(_plugin.tmd(
    _require-payload(cell),
    _request((
      selection: _selection(domain: domain, kinds: kinds, roots: roots, nodes: nodes),
      filtration: filtration,
      center: center,
    )),
  ))
}

/// Construct a physical filtration scale shared by barcode and diagram plots.
///
/// Explicit bounds must contain every birth and death value so plots never
/// discard persistence pairs silently.
///
/// - descriptor (dictionary): Result returned by `tmd`.
/// - min (none, int, float): Optional shared lower bound.
/// - max (none, int, float): Optional shared upper bound.
/// -> dictionary
#let persistence-scale(descriptor, min: none, max: none) = {
  if type(descriptor) != dictionary or descriptor.at("pairs", default: ()) == () {
    panic("Axodendron: persistence scale requires a non-empty TMD descriptor")
  }
  let values = descriptor.at("pairs").map(pair => (pair.at("birth"), pair.at("death"))).flatten()
  let data-min = values.fold(calc.inf, calc.min)
  let data-max = values.fold(-calc.inf, calc.max)
  let minimum = if min == none { data-min } else { min }
  let maximum = if max == none { data-max } else { max }
  if (type(minimum) != int and type(minimum) != float) or (type(maximum) != int and type(maximum) != float) {
    panic("Axodendron: persistence scale bounds must be numbers")
  }
  if minimum > data-min or maximum < data-max {
    panic("Axodendron: persistence scale bounds must contain every birth and death value")
  }
  if maximum < minimum {
    panic("Axodendron: persistence scale max must not be below min")
  }
  (
    min: minimum,
    max: maximum,
    units: descriptor.at("units"),
    filtration: descriptor.at("filtration"),
  )
}

#let _resolved-persistence-scale(descriptor, scale) = {
  let scale = if scale == none { persistence-scale(descriptor) } else { scale }
  if type(scale) != dictionary or not "min" in scale or not "max" in scale {
    panic("Axodendron: persistence plot scale must come from `persistence-scale`")
  }
  if scale.at("units", default: descriptor.at("units")) != descriptor.at("units") or scale.at("filtration", default: descriptor.at("filtration")) != descriptor.at("filtration") {
    panic("Axodendron: persistence plot scale units and filtration must match its descriptor")
  }
  persistence-scale(descriptor, min: scale.at("min"), max: scale.at("max"))
}

#let _persistence-axis-number(value) = {
  let magnitude = calc.abs(value)
  let digits = if magnitude >= 100 { 0 } else if magnitude >= 10 { 1 } else if magnitude >= 1 { 2 } else { 3 }
  str(calc.round(value, digits: digits))
}

#let _persistence-unit(unit) = if unit == "um" { [µm] } else { unit }

#let _filtration-axis-label(descriptor) = {
  let name = if descriptor.at("filtration") == "root-path-length" { [Root path length] } else { [Radial distance] }
  [#name (#_persistence-unit(descriptor.at("units")))]
}

/// Render the shared color semantics used by persistence plots.
///
/// Blue denotes ordinary terminal-to-merge pairs. Red denotes the essential
/// survivor retained once for every selected arbor.
///
/// - ordinary-fill (color): Color used for ordinary pairs.
/// - essential-fill (color): Color used for essential survivors.
/// -> content
#let persistence-legend(
  ordinary-fill: rgb("#0072b2"),
  essential-fill: rgb("#d62728"),
) = {
  let key(color, body) = grid(
    columns: (auto, auto),
    gutter: 3pt,
    align: horizon,
    circle(radius: 2.1pt, fill: color),
    text(size: 7pt, body),
  )
  grid(
    columns: (auto, auto),
    gutter: 5mm,
    key(ordinary-fill, [ordinary pair]),
    key(essential-fill, [essential survivor (one per selected arbor)]),
  )
}

/// Render a TMD persistence barcode as native Typst geometry.
///
/// Rows follow the deterministic order recorded in descriptor provenance.
///
/// - descriptor (dictionary): Result returned by `tmd`.
/// - width (length): Total barcode width.
/// - height (length): Total height, including the filtration axis, when `row-height` is omitted.
/// - row-height (none, length): Optional fixed allocation per persistence pair.
/// - scale (none, dictionary): Optional shared value returned by `persistence-scale`.
/// - padding (length): Horizontal plot padding that keeps endpoint strokes unclipped.
/// - axis (bool): Whether to draw numeric ticks and the filtration label.
/// - axis-height (length): Height reserved below the bars for their axis.
/// - axis-label (auto, content, str): Filtration label; `auto` includes physical units.
/// - stroke (any): Stroke for ordinary pairs.
/// - essential-stroke (any): Stroke for the essential survivor of each selected arbor.
/// - labels (bool): Whether to show terminal node IDs.
/// -> content
#let persistence-barcode(
  descriptor,
  width: 80mm,
  height: 70mm,
  row-height: none,
  scale: none,
  padding: 1.5pt,
  axis: true,
  axis-height: 9mm,
  axis-label: auto,
  stroke: 0.8pt + rgb("#0072b2"),
  essential-stroke: 1.2pt + rgb("#d62728"),
  labels: false,
) = {
  let pairs = descriptor.at("pairs")
  if pairs == () {
    panic("Axodendron: persistence barcode contains no pairs")
  }
  if width <= 0pt or height <= 0pt {
    panic("Axodendron: persistence barcode width and height must be positive")
  }
  if row-height != none and row-height <= 0pt {
    panic("Axodendron: persistence barcode row-height must be positive")
  }
  if padding < 0pt or axis-height < 0pt {
    panic("Axodendron: persistence barcode padding and axis-height must be non-negative")
  }
  if axis and axis-height < 8mm {
    panic("Axodendron: persistence barcode axis-height must be at least 8mm when its axis is visible")
  }
  let axis-band = if axis { axis-height } else { 0pt }
  let plot-height = if row-height == none { height - axis-band } else { row-height * pairs.len() }
  if plot-height <= 0pt {
    panic("Axodendron: persistence barcode axis leaves no height for bars")
  }
  let row-height = plot-height / pairs.len()
  let total-height = plot-height + axis-band
  let scale = _resolved-persistence-scale(descriptor, scale)
  let minimum = scale.at("min")
  let maximum = scale.at("max")
  let span = maximum - minimum
  let label-width = if labels { 12mm } else { 0mm }
  let axis-width = width - label-width
  let plot-width = axis-width - 2 * padding
  if plot-width <= 0pt {
    panic("Axodendron: persistence barcode padding leaves no plot width")
  }
  let x = value => padding + if span == 0 { plot-width / 2 } else { plot-width * (value - minimum) / span }
  let axis-label = if axis-label == auto { _filtration-axis-label(descriptor) } else { axis-label }
  block(width: width, height: total-height, clip: true)[
    #for ((index, pair)) in pairs.enumerate() {
      let start = x(pair.at("start"))
      let finish = x(pair.at("end"))
      let y = row-height * (index + 0.5)
      if labels {
        place(top + left, dx: 0pt, dy: y - 3pt, text(size: 7pt, str(pair.at("terminal_node"))))
      }
      place(
        top + left,
        dx: label-width + start,
        dy: y,
        line(
          length: calc.max(finish - start, 0.4pt),
          stroke: if pair.at("essential") { essential-stroke } else { stroke },
        ),
      )
    }
    #if axis {
      place(top + left, dx: label-width + padding, dy: plot-height, line(length: plot-width, stroke: 0.7pt))
      place(top + left, dx: label-width + padding, dy: plot-height - 2pt, line(start: (0pt, 0pt), end: (0pt, 4pt), stroke: 0.7pt))
      place(top + left, dx: label-width + padding + plot-width, dy: plot-height - 2pt, line(start: (0pt, 0pt), end: (0pt, 4pt), stroke: 0.7pt))
      place(top + left, dx: label-width + padding, dy: plot-height + 2pt, text(size: 6.5pt, _persistence-axis-number(minimum)))
      place(top + right, dx: -padding, dy: plot-height + 2pt, text(size: 6.5pt, _persistence-axis-number(maximum)))
      place(
        top + left,
        dx: label-width + padding,
        dy: plot-height + 11pt,
        box(width: plot-width)[#align(center, text(size: 7pt, axis-label))],
      )
    }
  ]
}

/// Render a TMD birth/death persistence diagram as native Typst geometry.
///
/// Birth is horizontal and death is vertical, matching the original TMD
/// publication. `non_monotone` pairs remain visible across the diagonal.
///
/// - descriptor (dictionary): Result returned by `tmd`.
/// - size (length): Total square plot size, including labels and ticks.
/// - scale (none, dictionary): Optional shared value returned by `persistence-scale`.
/// - radius (length): Point radius.
/// - padding (length): Outer right/top padding; it must be at least `radius`.
/// - axis-margin (length): Left and bottom space reserved for ticks and labels.
/// - axis-labels (bool): Whether to show Birth and Death labels with units.
/// - birth-label (auto, content, str): Horizontal label; `auto` includes units.
/// - death-label (auto, content, str): Vertical label; `auto` includes units.
/// - fill (color): Fill for ordinary pairs.
/// - essential-fill (color): Fill for essential survivors.
/// -> content
#let persistence-diagram(
  descriptor,
  size: 70mm,
  scale: none,
  radius: 1.4pt,
  padding: 3pt,
  axis-margin: 12mm,
  axis-labels: true,
  birth-label: auto,
  death-label: auto,
  fill: rgb("#0072b2"),
  essential-fill: rgb("#d62728"),
) = {
  let pairs = descriptor.at("pairs")
  if pairs == () {
    panic("Axodendron: persistence diagram contains no pairs")
  }
  if size <= 0pt or radius <= 0pt {
    panic("Axodendron: persistence diagram size and radius must be positive")
  }
  if padding < radius {
    panic("Axodendron: persistence diagram padding must be at least its point radius")
  }
  if axis-margin < 10mm {
    panic("Axodendron: persistence diagram axis-margin must be at least 10mm")
  }
  let plot-size = size - axis-margin - padding
  if plot-size <= 0pt {
    panic("Axodendron: persistence diagram margins leave no plot area")
  }
  let scale = _resolved-persistence-scale(descriptor, scale)
  let minimum = scale.at("min")
  let maximum = scale.at("max")
  let span = maximum - minimum
  let plot-left = axis-margin
  let plot-top = padding
  let plot-bottom = plot-top + plot-size
  let coordinate = value => if span == 0 { plot-size / 2 } else { plot-size * (value - minimum) / span }
  let birth-label = if birth-label == auto { [Birth (#_persistence-unit(descriptor.at("units")))] } else { birth-label }
  let death-label = if death-label == auto { [Death (#_persistence-unit(descriptor.at("units")))] } else { death-label }
  block(width: size, height: size, clip: true)[
    #place(top + left, line(start: (plot-left, plot-bottom), end: (plot-left + plot-size, plot-top), stroke: 0.4pt + luma(65%)))
    #place(top + left, line(start: (plot-left, plot-bottom), end: (plot-left + plot-size, plot-bottom), stroke: 0.7pt))
    #place(top + left, line(start: (plot-left, plot-bottom), end: (plot-left, plot-top), stroke: 0.7pt))
    #place(top + left, dx: plot-left, dy: plot-bottom - 2pt, line(start: (0pt, 0pt), end: (0pt, 4pt), stroke: 0.7pt))
    #place(top + left, dx: plot-left + plot-size, dy: plot-bottom - 2pt, line(start: (0pt, 0pt), end: (0pt, 4pt), stroke: 0.7pt))
    #place(top + left, dx: plot-left - 2pt, dy: plot-bottom, line(start: (0pt, 0pt), end: (4pt, 0pt), stroke: 0.7pt))
    #place(top + left, dx: plot-left - 2pt, dy: plot-top, line(start: (0pt, 0pt), end: (4pt, 0pt), stroke: 0.7pt))
    #place(top + left, dx: plot-left, dy: plot-bottom + 2pt, text(size: 6.5pt, _persistence-axis-number(minimum)))
    #place(top + right, dx: -padding, dy: plot-bottom + 2pt, text(size: 6.5pt, _persistence-axis-number(maximum)))
    #place(top + left, dy: plot-bottom - 3pt, box(width: axis-margin - 4pt)[#align(right, text(size: 6.5pt, _persistence-axis-number(minimum)))])
    #place(top + left, dy: plot-top - 3pt, box(width: axis-margin - 4pt)[#align(right, text(size: 6.5pt, _persistence-axis-number(maximum)))])
    #if axis-labels {
      place(top + left, dx: plot-left, dy: plot-bottom + 11pt, box(width: plot-size)[#align(center, text(size: 7pt, birth-label))])
      place(
        top + left,
        dy: plot-top,
        box(width: axis-margin - 4pt, height: plot-size)[#align(center + horizon, rotate(-90deg, text(size: 7pt, death-label)))],
      )
    }
    #for pair in pairs {
      place(
        top + left,
        dx: plot-left + coordinate(pair.at("birth")) - radius,
        dy: plot-bottom - coordinate(pair.at("death")) - radius,
        circle(
          radius: radius,
          fill: if pair.at("essential") { essential-fill } else { fill },
        ),
      )
    }
  ]
}
