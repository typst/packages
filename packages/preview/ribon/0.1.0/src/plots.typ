#import "protocol.typ": data, result-data, analysis-model, execution-policy
#import "analysis.typ": analyze, validate
#import "annotations.typ": pair-annotation, interaction-annotation, color-scale, color-legend, with-legend, scale-color
#import "render.typ": draw
#import "chart.typ": plot-theme, axis-style, plot-layout, legend-style, centered-at, nice-axis, resolve-axis, scientific-frame, matrix-frame, legend-panel, categorical-legend, compose-legend, is-inner-legend, place-inner-legend

#let _pair-key(i, j) = str(calc.min(i, j)) + ":" + str(calc.max(i, j))
#let _sequence-chars(sequence) = sequence.clusters().filter(char => char != "&" and char != " " and char != "\n")

#let _legend-config(value, fallback-position) = {
  if type(value) == dictionary { value }
  else if value == false or value == none { legend-style(position: none) }
  else { legend-style(position: fallback-position) }
}

#let _legend-theme(theme, style) = theme + (
  legend-fill: if style.fill == auto { theme.legend-fill } else { style.fill },
  legend-stroke: if style.stroke == auto { theme.legend-stroke } else { style.stroke },
  legend-radius: if style.radius == auto { theme.legend-radius } else { style.radius },
  legend-inset: if style.inset == auto { theme.legend-inset } else { style.inset },
)
#let structure-difference(sequence, reference, alternative, execution: execution-policy()) = {
  let first = data(validate(sequence, reference, execution: execution)).pairs
  let second = data(validate(sequence, alternative, execution: execution)).pairs
  let first-keys = first.map(pair => _pair-key(pair.i, pair.j))
  let second-keys = second.map(pair => _pair-key(pair.i, pair.j))
  (
    common: first.filter(pair => _pair-key(pair.i, pair.j) in second-keys),
    reference-only: first.filter(pair => _pair-key(pair.i, pair.j) not in second-keys),
    alternative-only: second.filter(pair => _pair-key(pair.i, pair.j) not in first-keys),
  )
}

#let _comparison-legend(common-color, reference-color, alternative-color, theme, style) = categorical-legend((
  (label: [Shared], stroke: common-color + 1pt),
  (label: [Reference only], stroke: reference-color + 1pt),
  (label: [Alternative only], stroke: alternative-color + 1pt),
), theme: theme, style: style)

/// Overlay an alternative structure on coordinates computed for a reference
/// structure. Shared, removed, and added pairs remain visually comparable.
#let compare-structures(
  sequence,
  reference,
  alternative,
  method: "naview",
  common-color: luma(58%),
  reference-color: rgb("#d73027"),
  alternative-color: rgb("#1a9850"),
  legend: true,
  legend-position: "bottom",
  legend-theme: plot-theme(),
  execution: execution-policy(),
  ..args
) = {
  let difference = structure-difference(sequence, reference, alternative, execution: execution)
  let annotations = difference.common.map(pair => pair-annotation(
    pair.i, pair.j, stroke: (paint: common-color, thickness: 0.75pt, cap: "round"),
  )) + difference.reference-only.map(pair => pair-annotation(
    pair.i, pair.j, stroke: (paint: reference-color, thickness: 1.05pt, cap: "round"),
  )) + difference.alternative-only.map(pair => interaction-annotation(
    pair.i, pair.j,
    stroke: (paint: alternative-color, thickness: 1.05pt, cap: "round"),
    bend: if method == "linear" { -0.18 } else { 0.0 },
  ))
  let drawing = draw(
    sequence,
    structure: reference,
    method: method,
    execution: execution,
    annotations: annotations,
    ..args,
  )
  let legend-config = _legend-config(legend, legend-position)
  if legend-config.position == none { drawing } else {
    compose-legend(
      drawing,
      _comparison-legend(common-color, reference-color, alternative-color, legend-theme, legend-config),
      style: legend-config,
    )
  }
}

/// Draw a base-pair probability dot plot from an analysis response.
#let dot-plot(
  sequence,
  probabilities: auto,
  comparison: none,
  reference-structure: auto,
  width: 8cm,
  height: auto,
  threshold: 0.01,
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  scale: color-scale(colors: (rgb("#dbe9f6"), rgb("#315eaa")), label: [Pair probability]),
  comparison-scale: color-scale(colors: (rgb("#fee8c8"), rgb("#d7301f")), label: [Comparison probability]),
  legend: true,
  legend-position: "bottom",
  x-label: [Position $j$],
  y-label: [Position $i$],
  x-axis: axis-style(),
  y-axis: axis-style(),
  layout: plot-layout(),
  theme: plot-theme(),
  grid-stroke: auto,
  frame-stroke: auto,
) = {
  let result = if probabilities == auto {
    data(analyze(sequence, model: model, constraints: constraints, execution: execution))
  } else { result-data(probabilities) }
  let entries = if type(result) == dictionary { result.at("pair_probabilities", default: result.at("pairs", default: ())) } else { result }
  let comparison-result = if comparison == none { none } else { result-data(comparison) }
  let comparison-entries = if comparison-result == none { () }
  else if type(comparison-result) == dictionary {
    comparison-result.at("pair_probabilities", default: comparison-result.at("pairs", default: ()))
  } else { comparison-result }
  let resolved-structure = if reference-structure == auto and type(result) == dictionary {
    result.at("mfe_structure", default: none)
  } else { reference-structure }
  let structure-pairs = if resolved-structure == none or resolved-structure == auto { () }
  else { data(validate(sequence, resolved-structure, execution: execution)).pairs }
  let n = _sequence-chars(sequence).len()
  if n == 0 { panic("dot-plot requires a non-empty sequence") }
  let resolved-theme = theme + (
    grid-stroke: if grid-stroke == auto { theme.grid-stroke } else { grid-stroke },
    frame-stroke: if frame-stroke == auto { theme.frame-stroke } else { frame-stroke },
  )
  let interval = if n <= 50 { 5 } else if n <= 200 { 10 } else { 50 }
  let ticks = ()
  for position in range(1, n + 1) {
    if position == 1 or position == n or calc.rem(position, interval) == 0 {
      ticks.push(position)
    }
  }
  let resolved-x-axis = resolve-axis(
    x-axis,
    (0.5, n + 0.5),
    fallback-ticks: ticks,
    fallback-label: x-label,
  )
  let resolved-y-axis = resolve-axis(
    y-axis,
    (n + 0.5, 0.5),
    fallback-ticks: ticks,
    fallback-label: y-label,
  )
  let plot-height = if height == auto { width } else { height }
  let legend-config = _legend-config(legend, legend-position)
  let legend-body = none
  if legend-config.position != none {
    let legend-theme = _legend-theme(resolved-theme, legend-config)
    let supplied-width = legend-config.width
    let available = if supplied-width != auto { supplied-width }
    else if legend-config.position in ("left", "right") or is-inner-legend(legend-config.position) { 2.8cm }
    else { width }
    let content-width = calc.max(20pt, available - 10pt)
    let bare-theme = legend-theme + (
      legend-fill: none,
      legend-stroke: none,
      legend-radius: 0pt,
      legend-inset: (x: 0pt, y: 0pt),
    )
    let content = if comparison-entries.len() > 0 {
      grid(
        columns: if legend-config.direction == "column" { (auto,) } else { (auto, auto) },
        column-gutter: 6pt,
        row-gutter: legend-config.row-gap,
        color-legend(scale, width: if legend-config.direction == "column" { content-width } else { (content-width - 6pt) / 2 }, theme: bare-theme),
        color-legend(comparison-scale, width: if legend-config.direction == "column" { content-width } else { (content-width - 6pt) / 2 }, theme: bare-theme),
      )
    } else {
      grid(
        columns: if structure-pairs.len() == 0 or legend-config.direction == "column" { (auto,) } else { (auto, auto) },
        column-gutter: 6pt,
        row-gutter: legend-config.row-gap,
        color-legend(
          scale,
          width: if structure-pairs.len() == 0 or legend-config.direction == "column" { content-width } else { content-width - 46pt },
          theme: bare-theme,
        ),
        if structure-pairs.len() == 0 { none } else {
          grid(
            columns: (5pt, auto),
            column-gutter: legend-theme.legend-swatch-gap,
            align(horizon, rect(width: 5pt, height: 5pt, fill: luma(18%), stroke: none)),
            text(size: legend-theme.text-size, fill: legend-theme.label-fill, [Reference pair]),
          )
        },
      )
    }
    legend-body = legend-panel(
      content,
      style: legend-config + (width: available),
      theme: legend-theme,
    )
  }
  let plot = matrix-frame(
    width,
    plot-height,
    resolved-x-axis,
    resolved-y-axis,
    theme: resolved-theme,
    layout: layout,
    geometry => {
      let cell = geometry.width / n
      place(top + left, line(
        start: (geometry.left, geometry.top),
        end: (geometry.left + geometry.width, geometry.top + geometry.height),
        stroke: resolved-theme.grid-stroke,
      ))
      for entry in entries {
        if entry.probability >= threshold {
          centered-at(
            ((geometry.x)(entry.j), (geometry.y)(entry.i)),
            circle(
              radius: calc.sqrt(entry.probability) * cell * 0.44,
              fill: scale-color(scale, entry.probability),
              stroke: none,
            ),
          )
        }
      }
      for entry in comparison-entries {
        if entry.probability >= threshold {
          centered-at(
            ((geometry.x)(entry.i), (geometry.y)(entry.j)),
            circle(
              radius: calc.sqrt(entry.probability) * cell * 0.44,
              fill: scale-color(comparison-scale, entry.probability),
              stroke: none,
            ),
          )
        }
      }
      if comparison-entries.len() == 0 {
        for pair in structure-pairs {
          centered-at(
            ((geometry.x)(pair.i), (geometry.y)(pair.j)),
            rect(
              width: cell * 0.54,
              height: cell * 0.54,
              fill: luma(18%),
              stroke: none,
            ),
          )
        }
      }
      if is-inner-legend(legend-config.position) {
        place-inner-legend(geometry, legend-body, style: legend-config)
      }
    },
  )
  if legend-config.position == none or is-inner-legend(legend-config.position) { plot } else {
    compose-legend(plot, legend-body, style: legend-config)
  }
}

/// Compute the expected and discrete mountain profiles used by `mountain-plot`.
#let mountain-profile(
  sequence,
  probabilities: auto,
  reference-structures: auto,
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
) = {
  let result = if probabilities == auto {
    data(analyze(sequence, model: model, constraints: constraints, execution: execution))
  } else { result-data(probabilities) }
  let entries = if type(result) == dictionary {
    result.at("pair_probabilities", default: result.at("pairs", default: ()))
  } else { result }
  let n = _sequence-chars(sequence).len()
  if n == 0 { panic("mountain-profile requires a non-empty sequence") }
  let expected-values = range(0, n).map(index => {
    let value = 0.0
    for entry in entries {
      if entry.i <= index + 1 and index + 1 < entry.j { value += entry.probability }
    }
    value
  })
  let inferred = if type(result) == dictionary { result.at("mfe_structure", default: none) } else { none }
  let references = if reference-structures == auto {
    if inferred == none { () } else { ((label: [MFE], structure: inferred),) }
  } else {
    reference-structures.enumerate().map(((index, entry)) => if type(entry) == dictionary {
      entry
    } else {
      (label: [Structure #(index + 1)], structure: entry)
    })
  }
  let reference-series = references.enumerate().map(((series-index, reference)) => {
    let pairs = data(validate(sequence, reference.structure, execution: execution)).pairs
    (
      label: reference.at("label", default: [Structure #(series-index + 1)]),
      stroke: reference.at("stroke", default: none),
      axes: reference.at("axes", default: ("x", "y")),
      values: range(0, n).map(index => pairs.filter(
        pair => pair.i <= index + 1 and index + 1 < pair.j,
      ).len()),
    )
  })
  (
    length: n,
    expected: expected-values,
    references: reference-series,
  )
}

/// Draw the expected mountain profile derived from base-pair probabilities.
#let mountain-plot(
  sequence,
  probabilities: auto,
  reference-structures: auto,
  width: 10cm,
  height: 3.8cm,
  model: analysis-model(),
  constraints: none,
  execution: execution-policy(),
  stroke: (paint: rgb("#315eaa"), thickness: 1pt, cap: "round", join: "round"),
  reference-strokes: (
    (paint: rgb("#d73027"), thickness: 0.8pt, dash: "dashed", cap: "round"),
    (paint: rgb("#1a9850"), thickness: 0.8pt, dash: "dotted", cap: "round"),
  ),
  y-ticks: 4,
  legend: true,
  legend-position: "bottom",
  x-label: [Sequence position (5′ → 3′)],
  y-label: [Enclosing base pairs],
  expected-axes: ("x", "y"),
  x-axis: axis-style(),
  y-axis: axis-style(),
  x2-axis: none,
  y2-axis: none,
  layout: plot-layout(),
  theme: plot-theme(),
) = {
  let profile = mountain-profile(
    sequence,
    probabilities: probabilities,
    reference-structures: reference-structures,
    model: model,
    constraints: constraints,
    execution: execution,
  )
  let n = profile.length
  let reference-series = profile.references.enumerate().map(((index, series)) => series + (
    stroke: if series.stroke == none or series.stroke == auto {
      reference-strokes.at(calc.rem(index, reference-strokes.len()))
    } else { series.stroke },
  ))
  let maxima = (calc.max(..profile.expected),) + reference-series.map(series => calc.max(..series.values))
  let maximum = calc.max(1.0, ..maxima)
  let y-range = nice-axis(maximum, count: calc.max(2, y-ticks))
  let x-interval = if n <= 50 { 5 } else if n <= 200 { 10 } else { 50 }
  let x-ticks = ()
  for position in range(1, n + 1) {
    if position == 1 or position == n or calc.rem(position, x-interval) == 0 {
      x-ticks.push(position)
    }
  }
  let resolved-x-axis = resolve-axis(
    x-axis,
    (1, n),
    fallback-ticks: x-ticks,
    fallback-label: x-label,
  )
  let resolved-y-axis = resolve-axis(
    y-axis,
    (0, y-range.maximum),
    fallback-ticks: y-range.ticks,
    fallback-label: y-label,
  )
  let resolved-x2-axis = if x2-axis == none { none } else { resolve-axis(
    x2-axis,
    resolved-x-axis.domain,
    fallback-ticks: resolved-x-axis.ticks,
  ) }
  let resolved-y2-axis = if y2-axis == none { none } else { resolve-axis(
    y2-axis,
    resolved-y-axis.domain,
    fallback-ticks: resolved-y-axis.ticks,
  ) }
  let draw-series = (values, series-stroke, geometry, axes) => {
    if axes.at(0) not in ("x", "x2") or axes.at(1) not in ("y", "y2") {
      panic("mountain series axes must be (\"x\"|\"x2\", \"y\"|\"y2\")")
    }
    if axes.at(0) == "x2" and geometry.x2 == none { panic("mountain series requires x2-axis") }
    if axes.at(1) == "y2" and geometry.y2 == none { panic("mountain series requires y2-axis") }
    let map-x = if axes.at(0) == "x2" { geometry.x2 } else { geometry.x }
    let map-y = if axes.at(1) == "y2" { geometry.y2 } else { geometry.y }
    let points = values.enumerate().map(((index, value)) => (
      map-x(index + 1),
      map-y(value),
    ))
    let parts = ()
    if points.len() > 0 {
      parts.push(curve.move(points.first()))
      for point in points.slice(1) { parts.push(curve.line(point)) }
    }
    if parts.len() > 0 { curve(stroke: series-stroke, ..parts) }
  }
  let legend-config = _legend-config(legend, legend-position)
  let legend-items = ((label: [Expected], stroke: stroke),)
  for series in reference-series {
    legend-items.push((label: series.label, stroke: series.stroke))
  }
  let legend-body = if legend-config.position == none { none } else {
    categorical-legend(
      legend-items,
      theme: _legend-theme(theme, legend-config),
      style: legend-config,
    )
  }
  let plot = scientific-frame(
    width,
    height,
    resolved-x-axis,
    resolved-y-axis,
    x2-axis: resolved-x2-axis,
    y2-axis: resolved-y2-axis,
    layout: layout,
    theme: theme,
    geometry => {
      place(top + left, draw-series(profile.expected, stroke, geometry, expected-axes))
      for series in reference-series {
        place(top + left, draw-series(series.values, series.stroke, geometry, series.axes))
      }
      if is-inner-legend(legend-config.position) {
        place-inner-legend(geometry, legend-body, style: legend-config)
      }
    },
  )
  if legend-config.position == none or is-inner-legend(legend-config.position) { plot }
  else { compose-legend(plot, legend-body, style: legend-config) }
}

/// Render a protocol response as native Typst vector geometry.
///
/// `which` selects `"mfe"`, `"centroid"`, or `"mea"` for an analysis
/// response. Specialized results (pseudoknot, cofold, circular, G-quadruplex,
/// modified bases) are recognized by their stable result kind.
