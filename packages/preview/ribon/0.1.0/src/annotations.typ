#import "chart.typ": plot-theme, legend-style, compose-legend

#let _rgb-components(value, name) = {
  if type(value) != color { panic(name + " must be a solid color") }
  let components = rgb(value).components()
  (
    red: components.at(0) / 100%,
    green: components.at(1) / 100%,
    blue: components.at(2) / 100%,
    alpha: components.at(3) / 100%,
  )
}

#let _opaque-background-components(value, behind: auto) = {
  let foreground = _rgb-components(value, "contrast background")
  if foreground.alpha >= 0.999999 { return foreground }
  if behind == auto {
    panic("a transparent node fill requires contrast-background for WCAG contrast calculation")
  }
  let background = _rgb-components(behind, "contrast-background")
  if background.alpha < 0.999999 {
    panic("contrast-background must be opaque")
  }
  (
    red: foreground.red * foreground.alpha + background.red * (1.0 - foreground.alpha),
    green: foreground.green * foreground.alpha + background.green * (1.0 - foreground.alpha),
    blue: foreground.blue * foreground.alpha + background.blue * (1.0 - foreground.alpha),
    alpha: 1.0,
  )
}

#let _linear-srgb(component) = if component <= 0.04045 {
  component / 12.92
} else {
  calc.pow((component + 0.055) / 1.055, 2.4)
}

#let _relative-luminance(components) = {
  0.2126 * _linear-srgb(components.red) + 0.7152 * _linear-srgb(components.green) + 0.0722 * _linear-srgb(components.blue)
}

#let _contrast-ratio-from-luminance(first, second) = {
  let lighter = calc.max(first, second)
  let darker = calc.min(first, second)
  (lighter + 0.05) / (darker + 0.05)
}

/// Return the WCAG 2.2 contrast ratio for an opaque text color over a solid
/// node fill. `background-behind` resolves a transparent node fill.
#let wcag-contrast-ratio(foreground, background, background-behind: auto) = {
  let foreground = _rgb-components(foreground, "contrast foreground")
  if foreground.alpha < 0.999999 { panic("contrast foreground must be opaque") }
  let background = _opaque-background-components(background, behind: background-behind)
  _contrast-ratio-from-luminance(
    _relative-luminance(foreground),
    _relative-luminance(background),
  )
}

#let _optimal-wcag-text(background, background-behind: auto) = {
  let background = _opaque-background-components(background, behind: background-behind)
  let luminance = _relative-luminance(background)
  let black-ratio = _contrast-ratio-from-luminance(0.0, luminance)
  let white-ratio = _contrast-ratio-from-luminance(1.0, luminance)
  if black-ratio >= white-ratio {
    (fill: black, ratio: black-ratio)
  } else {
    (fill: white, ratio: white-ratio)
  }
}

#let _contrast-threshold(level) = {
  if level == "aa" { 4.5 }
  else if level == "aaa" { 7.0 }
  else { panic("text contrast must be \"fixed\", \"aa\", or \"aaa\"") }
}

#let _contrast-level-label(level) = if level == "aa" { "AA" } else { "AAA" }

/// Choose black or white to maximize WCAG contrast against a node fill.
/// AAA is strict by default because some mid-luminance fills cannot reach 7:1.
#let wcag-text-fill(
  background,
  level: "aa",
  background-behind: auto,
  on-failure: "error",
) = {
  if level not in ("aa", "aaa") { panic("WCAG text level must be \"aa\" or \"aaa\"") }
  if on-failure not in ("error", "best") { panic("contrast on-failure must be \"error\" or \"best\"") }
  let result = _optimal-wcag-text(background, background-behind: background-behind)
  let threshold = _contrast-threshold(level)
  if result.ratio + 0.0000001 < threshold and on-failure == "error" {
    panic(
      "WCAG " + _contrast-level-label(level) + " node-text contrast is unattainable for "
      + repr(background) + "; best ratio is "
      + str(calc.round(result.ratio * 1000) / 1000) + ":1",
    )
  }
  result.fill
}

#let _node-wcag-text-fill(
  index,
  background,
  level,
  background-behind: auto,
  on-failure: "error",
) = {
  if level not in ("aa", "aaa") { panic("node text contrast must be \"fixed\", \"aa\", or \"aaa\"") }
  if on-failure not in ("error", "best") { panic("node contrast on-failure must be \"error\" or \"best\"") }
  let result = _optimal-wcag-text(background, background-behind: background-behind)
  let threshold = _contrast-threshold(level)
  if result.ratio + 0.0000001 < threshold and on-failure == "error" {
    panic(
      "node " + str(index) + " cannot attain WCAG " + _contrast-level-label(level)
      + " text contrast over " + repr(background) + "; best ratio is "
      + str(calc.round(result.ratio * 1000) / 1000) + ":1",
    )
  }
  result.fill
}

#let default-theme = (
  backbone-stroke: (paint: luma(46%), thickness: 0.55pt, cap: "round", join: "round"),
  pair-stroke: (paint: rgb("#4263a8"), thickness: 0.75pt, cap: "round"),
  noncanonical-stroke: (paint: rgb("#8c5a9f"), thickness: 0.65pt, dash: "dashed", cap: "round"),
  coaxial-stroke: (paint: rgb("#e67700"), thickness: 1.1pt, dash: "dashed", cap: "round"),
  interaction-stroke: (paint: rgb("#7b2cbf"), thickness: 0.75pt, dash: "dashed", cap: "round"),
  leader-stroke: (paint: luma(48%), thickness: 0.4pt, cap: "round"),
  direction-fill: luma(35%),
  node-fill: white,
  node-stroke: (paint: luma(28%), thickness: 0.55pt),
  text-fill: luma(12%),
  node-text-contrast: "aa",
  node-contrast-background: auto,
  node-contrast-on-failure: "error",
  label-fill: luma(38%),
  region-fill: rgb("#fff0a8").transparentize(45%),
  region-stroke: none,
  base-colors: none,
)

/// A VARNA-inspired nucleotide palette suitable for colored figures.
#let varna-theme = default-theme + (
  base-colors: (
    A: rgb("#f5c242"),
    C: rgb("#7bc8f6"),
    G: rgb("#8bd17c"),
    U: rgb("#f28e8e"),
    N: luma(88%),
  ),
  node-stroke: (paint: luma(25%), thickness: 0.45pt),
)

/// Build a region highlight annotation.
#let highlight(from, to, fill: auto, stroke: auto, radius: auto) = (
  kind: "region",
  from: from,
  to: to,
  fill: fill,
  stroke: stroke,
  radius: radius,
)

/// Highlight an arbitrary set of nucleotide positions.
#let highlight-positions(positions, fill: auto, stroke: auto, radius: auto) = (
  kind: "positions",
  positions: positions,
  fill: fill,
  stroke: stroke,
  radius: radius,
)

/// Override the appearance of one nucleotide.
#let base-annotation(
  at,
  fill: auto,
  stroke: auto,
  text-fill: auto,
  text-contrast: auto,
  contrast-background: auto,
  contrast-on-failure: auto,
) = (
  kind: "base",
  at: at,
  fill: fill,
  stroke: stroke,
  text-fill: text-fill,
  text-contrast: text-contrast,
  contrast-background: contrast-background,
  contrast-on-failure: contrast-on-failure,
)

/// Override the appearance of a base-pair edge.
#let pair-annotation(i, j, stroke: auto) = (
  kind: "pair",
  i: i,
  j: j,
  stroke: stroke,
)

/// Add an interaction that is not part of the supplied secondary structure.
/// `bend` is a signed fraction of the endpoint distance; zero draws a line.
#let interaction-annotation(
  i,
  j,
  stroke: auto,
  bend: 0.18,
  label: none,
  label-position: 0.5,
  label-dx: 0pt,
  label-dy: 0pt,
  label-fill: auto,
  label-size: auto,
  label-width: auto,
  label-align: center,
  label-box-fill: auto,
  label-box-stroke: none,
  label-box-inset: 1pt,
  label-box-radius: 1pt,
) = (
  kind: "interaction",
  i: i,
  j: j,
  stroke: stroke,
  bend: bend,
  label: label,
  label-position: label-position,
  label-dx: label-dx,
  label-dy: label-dy,
  label-fill: label-fill,
  label-size: label-size,
  label-width: label-width,
  label-align: label-align,
  label-box-fill: label-box-fill,
  label-box-stroke: label-box-stroke,
  label-box-inset: label-box-inset,
  label-box-radius: label-box-radius,
)

/// Mark two adjacent helices as coaxially stacked.
#let coaxial-annotation(first-i, first-j, second-i, second-j, stroke: auto) = (
  kind: "coaxial",
  first-i: first-i,
  first-j: first-j,
  second-i: second-i,
  second-j: second-j,
  stroke: stroke,
)

/// Convert selected coaxial interactions from `fold` or `evaluate` output
/// into renderer annotations.
#let coaxial-annotations(result, stroke: auto) = {
  let stacks = result.at(
    "coaxial_stacks",
    default: result.at("evaluated_coaxial_stacks", default: ()),
  )
  stacks.map(stack => coaxial-annotation(
    stack.first_i,
    stack.first_j,
    stack.second_i,
    stack.second_j,
    stroke: stroke,
  ))
}

/// Attach a free-form label to a nucleotide.
#let label-annotation(
  at,
  body,
  dx: auto,
  dy: auto,
  anchor: "auto",
  distance: 13pt,
  leader: true,
  leader-stroke: auto,
  leader-bend: 0.0,
  leader-start-gap: 1pt,
  leader-end-gap: 1pt,
  fill: auto,
  size: auto,
  width: auto,
  text-align: left,
  box-fill: none,
  box-stroke: none,
  box-inset: 0pt,
  box-radius: 0pt,
) = (
  kind: "label",
  at: at,
  body: body,
  dx: dx,
  dy: dy,
  anchor: anchor,
  distance: distance,
  leader: leader,
  leader-stroke: leader-stroke,
  leader-bend: leader-bend,
  leader-start-gap: leader-start-gap,
  leader-end-gap: leader-end-gap,
  fill: fill,
  size: size,
  width: width,
  text-align: text-align,
  box-fill: box-fill,
  box-stroke: box-stroke,
  box-inset: box-inset,
  box-radius: box-radius,
)

/// Attach a name to one strand of a multi-strand drawing.
#let strand-label(
  strand,
  body,
  at: "start",
  dx: auto,
  dy: auto,
  anchor: "auto",
  distance: 13pt,
  leader: true,
  leader-stroke: auto,
  leader-bend: 0.0,
  leader-start-gap: 1pt,
  leader-end-gap: 1pt,
  fill: auto,
  size: auto,
  width: auto,
  text-align: left,
  box-fill: none,
  box-stroke: none,
  box-inset: 0pt,
  box-radius: 0pt,
) = (
  kind: "strand-label",
  strand: strand,
  at: at,
  body: body,
  dx: dx,
  dy: dy,
  anchor: anchor,
  distance: distance,
  leader: leader,
  leader-stroke: leader-stroke,
  leader-bend: leader-bend,
  leader-start-gap: leader-start-gap,
  leader-end-gap: leader-end-gap,
  fill: fill,
  size: size,
  width: width,
  text-align: text-align,
  box-fill: box-fill,
  box-stroke: box-stroke,
  box-inset: box-inset,
  box-radius: box-radius,
)

/// Configure nucleotide numbering. Explicit `positions` are one-based.
#let numbering-style(
  every: 10,
  positions: (),
  per-strand: false,
  show-first: false,
  show-last: false,
  size: 5.3pt,
  fill: auto,
) = (
  every: every,
  positions: positions,
  per-strand: per-strand,
  show-first: show-first,
  show-last: show-last,
  size: size,
  fill: fill,
)

/// Define one reusable continuous value-to-color mapping.
#let color-scale(
  minimum: 0.0,
  maximum: 1.0,
  colors: (
    rgb("#313695"), rgb("#4575b4"), rgb("#74add1"),
    rgb("#f7f7f7"), rgb("#fdae61"), rgb("#d73027"),
  ),
  missing: luma(88%),
  label: none,
) = {
  if maximum <= minimum { panic("color-scale maximum must exceed minimum") }
  if colors.len() < 2 { panic("color-scale requires at least two colors") }
  (
    minimum: minimum,
    maximum: maximum,
    colors: colors,
    missing: missing,
    label: label,
  )
}

#let scale-color(scale, value) = if value == none {
  scale.missing
} else {
  let normalized = calc.max(0.0, calc.min(1.0, (value - scale.minimum) / (scale.maximum - scale.minimum)))
  gradient.linear(..scale.colors).sample(normalized * 100%)
}

/// Recursively extract renderer annotations from annotations and tracks.
#let annotation-items(value) = {
  if value == none { () }
  else if type(value) == array {
    let items = ()
    for entry in value { items += annotation-items(entry) }
    items
  } else if type(value) == dictionary and value.at("kind", default: "") == "annotation-track" {
    annotation-items(value.at("annotations", default: ()))
  } else { (value,) }
}

/// Recursively extract and deduplicate legend metadata from annotation tracks.
#let annotation-legends(value) = {
  let legends = ()
  if type(value) == array {
    for entry in value {
      for legend in annotation-legends(entry) {
        if not legends.any(existing => existing == legend) { legends.push(legend) }
      }
    }
  } else if type(value) == dictionary and value.at("kind", default: "") == "annotation-track" {
    for legend in value.at("legends", default: ()) {
      if not legends.any(existing => existing == legend) { legends.push(legend) }
    }
  }
  legends
}

#let _color-legend-metadata(scale, legend) = {
  let options = if legend == auto or legend == true { (:) }
  else if type(legend) == dictionary { legend }
  else { panic("value annotation legend must be auto, true, false, none, or a dictionary") }
  let allowed = ("width", "height", "ticks", "text-size", "orientation", "reverse", "format")
  for key in options.keys() {
    if key not in allowed { panic("unknown value annotation legend option: " + key) }
  }
  (
    kind: "color-scale",
    scale: scale,
    width: options.at("width", default: 3.2cm),
    height: options.at("height", default: 6pt),
    ticks: options.at("ticks", default: 3),
    text-size: options.at("text-size", default: auto),
    orientation: options.at("orientation", default: "horizontal"),
    reverse: options.at("reverse", default: false),
    format: options.at("format", default: auto),
  )
}

/// Convert one value per nucleotide into an annotation track. The track keeps
/// its scale so `draw` and `render` can construct an exact legend automatically.
#let value-annotations(values, scale: color-scale(), positions: auto, legend: auto) = {
  let positions = if positions == auto { range(1, values.len() + 1) } else { positions }
  if positions.len() != values.len() { panic("positions and values must have equal length") }
  let annotations = values.enumerate().map(((index, value)) => base-annotation(
    positions.at(index),
    fill: scale-color(scale, value),
  ))
  let legends = if legend == false or legend == none { () }
  else { (_color-legend-metadata(scale, legend),) }
  (kind: "annotation-track", annotations: annotations, legends: legends)
}

/// Draw the exact color scale used by one or more figures.
#let color-legend(
  scale,
  width: 3.2cm,
  height: 6pt,
  ticks: 3,
  text-size: auto,
  orientation: "horizontal",
  reverse: false,
  format: auto,
  theme: plot-theme(),
  inset: auto,
  fill: auto,
  stroke: auto,
  radius: auto,
) = {
  if orientation not in ("horizontal", "vertical") {
    panic("color legend orientation must be \"horizontal\" or \"vertical\"")
  }
  let tick-count = calc.max(2, ticks)
  let text-size = if text-size == auto { theme.text-size } else { text-size }
  let panel-inset = if inset == auto { theme.legend-inset } else { inset }
  let panel-fill = if fill == auto { theme.legend-fill } else { fill }
  let panel-stroke = if stroke == auto { theme.legend-stroke } else { stroke }
  let panel-radius = if radius == auto { theme.legend-radius } else { radius }
  let colors = if reverse { scale.colors.rev() } else { scale.colors }
  let value-at = fraction => {
    let fraction = if reverse { 1.0 - fraction } else { fraction }
    scale.minimum + fraction * (scale.maximum - scale.minimum)
  }
  let format-value = value => if type(format) == function { format(value) }
  else { str(calc.round(value * 1000) / 1000) }
  let title = if scale.label == none { none } else {
    text(size: text-size, weight: "medium", fill: theme.label-fill, scale.label)
  }
  let horizontal = grid(
    columns: (auto,),
    row-gutter: 2.5pt,
    title,
    block(width: width, height: height + 2pt, {
      rect(width: width, height: height, fill: gradient.linear(..colors), stroke: theme.frame-stroke)
      for index in range(0, tick-count) {
        let fraction = index / (tick-count - 1)
        place(top + left, dx: fraction * width,
          line(start: (0pt, height), end: (0pt, height + 2pt), stroke: theme.tick-stroke),
        )
      }
    }),
    box(width: width, height: text-size * 1.4, {
      for index in range(0, tick-count) {
        let fraction = index / (tick-count - 1)
        place(top + left, dx: fraction * width,
          box(width: 0pt, place(center + top,
            text(size: text-size, fill: theme.text-fill, format-value(value-at(fraction))),
          )),
        )
      }
    }),
  )
  let vertical = grid(
    columns: (auto,),
    row-gutter: 2.5pt,
    title,
    grid(
      columns: (height + 2pt, auto),
      column-gutter: 3pt,
      block(width: height + 2pt, height: width, {
        rect(width: height, height: width, fill: gradient.linear(angle: 90deg, ..colors), stroke: theme.frame-stroke)
        for index in range(0, tick-count) {
          let fraction = index / (tick-count - 1)
          place(top + left, dy: fraction * width,
            line(start: (height, 0pt), end: (height + 2pt, 0pt), stroke: theme.tick-stroke),
          )
        }
      }),
      box(height: width, width: 30pt, {
        for index in range(0, tick-count) {
          let fraction = index / (tick-count - 1)
          place(top + left, dy: fraction * width,
            box(width: 0pt, height: 0pt, place(left + horizon,
              text(size: text-size, fill: theme.text-fill, format-value(value-at(fraction))),
            )),
          )
        }
      }),
    ),
  )
  box(
    inset: panel-inset,
    fill: panel-fill,
    stroke: panel-stroke,
    radius: panel-radius,
    if orientation == "horizontal" { horizontal } else { vertical },
  )
}

/// Compose a drawing and legend without rasterization.
#let with-legend(body, legend, position: "bottom", gutter: 6pt, style: auto) = {
  let resolved = if style == auto { legend-style(position: position, gutter: gutter) } else { style }
  compose-legend(body, legend, style: resolved)
}

/// Construct a one-based base-pair entry for hard constraints.

#let reactivity-annotations(
  values,
  low: 0.0,
  high: 1.0,
  missing-fill: luma(88%),
  scale: auto,
  legend: auto,
) = {
  let reactivities = if type(values) == dictionary {
    values.at("constraints", default: (:)).at("probing_reactivities", default: ())
  } else { values }
  let resolved-scale = if scale == auto {
    color-scale(minimum: low, maximum: high, missing: missing-fill, label: [Reactivity])
  } else { scale }
  value-annotations(reactivities, scale: resolved-scale, legend: legend)
}
