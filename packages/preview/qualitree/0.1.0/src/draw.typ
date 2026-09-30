// Public rendering boundary: normalize once, measure once, then compose panels.
// The package does not set page size or load fonts. Dimensions below describe
// the natural figure; width controls a single final uniform scale.
#import "theme.typ": qfd-theme
#import "figure-data.typ": prepare-figure
#import "layout.typ": figure-layout, fit-figure
#import "legend.typ": _legend
#import "roof.typ": draw-roof
#import "matrix-panel.typ": draw-matrix, draw-basement, draw-grid
#import "comparison-panel.typ": draw-comparison

// Render one House of Quality. Plain arrays use one-based positional relations;
// qfd-stage/qfd-diff supply the same arguments plus stable IDs and change data.
// Explicit font/line arguments take precedence over theme; auto uses its default.
#let house-of-quality(
  whats: (), hows: (), relations: (), matrix: none, importance: none,
  correlations: (), targets: none, difficulty: none, directions: none, basement: auto,
  alternatives: (), score-range: (0, 5), legend-order: auto, labels: (:),
  row-ids: none, column-ids: none, changes: none,
  show-roof: true, show-importance: auto, show-basement: true,
  show-competitive: auto, show-legend: true,
  show-rel-legend: true, show-corr-legend: true, show-eval-legend: true,
  width: 100%, cell-size: 9mm, row-height: auto, what-width: 54mm,
  importance-width: 8mm, comparison-width: 38mm, header-height: auto,
  basement-height: auto, legend-width: 43mm, legend-gap: 5mm,
  cell-padding: 1mm, label-padding: 2mm, header-padding: 1.5mm,
  theme: (:), font: auto, serif-font: auto, font-size: auto,
  ink: auto, grid-thickness: auto, frame-thickness: auto, symbol-size: auto,
  correlation-style: "circled", marker-stagger: true, marker-spread: 0.30,
  relative-digits: 0, weight-digits: 1,
) = context {
  assert(type(theme) == dictionary, message: "qfd: theme must be a dictionary")
  for key in theme.keys() { assert(key in qfd-theme, message: "qfd: unknown theme key: " + key) }
  let style = qfd-theme + theme
  let overrides = (font: font, serif-font: serif-font, font-size: font-size,
    ink: ink, grid-thickness: grid-thickness, frame-thickness: frame-thickness, symbol-size: symbol-size)
  for (key, value) in overrides { if value != auto { style.insert(key, value) } }
  assert(type(style.ink) == color, message: "qfd: ink must be a Typst color")
  assert(correlation-style in ("circled", "text"), message: "qfd: correlation-style must be circled or text")
  assert(type(marker-stagger) == bool, message: "qfd: marker-stagger must be boolean")
  assert(type(marker-spread) in (int, float) and marker-spread >= 0 and marker-spread <= 0.30,
    message: "qfd: marker-spread must be between 0 and 0.30")
  assert(type(weight-digits) == int and weight-digits >= 0 and weight-digits <= 10,
    message: "qfd: weight-digits must be an integer from 0 to 10")
  style += (weight-digits: weight-digits, thin: (paint: style.ink, thickness: style.grid-thickness),
    frame: (paint: style.ink, thickness: style.frame-thickness), correlation-style: correlation-style,
    marker-stagger: marker-stagger, marker-spread: marker-spread)
  let data = prepare-figure(whats, hows, relations, matrix, importance, correlations,
    targets, difficulty, directions, basement, alternatives, score-range, legend-order,
    labels, show-roof, show-importance, show-basement, show-competitive, show-legend,
    show-rel-legend, show-corr-legend, show-eval-legend, relative-digits, changes)
  set text(font: style.font, size: style.font-size, fill: style.ink, weight: "regular", style: "normal", hyphenate: false)
  set par(justify: false, leading: 0.3em, spacing: 0pt, first-line-indent: 0pt)
  set block(above: 0pt, below: 0pt)
  set align(left)
  let legend = if data.show-legend {
    _legend(data.labels, data.alternatives, data.legend-order, data.score-range,
      legend-width, style.thin, style.frame, style.ink, style.symbol-size,
      symbol-thickness: style.symbol-thickness, correlation-style: correlation-style, changes: changes != none,
      change-fills: (added: style.added-fill, removed: style.removed-fill, changed: style.changed-fill),
      relation: data.show-rel-legend, correlation: data.show-roof and data.show-corr-legend,
      evaluation: data.show-competitive and data.show-eval-legend and data.alternatives.len() > 0)
  } else { none }
  let legend-size = if legend == none { (width: 0pt, height: 0pt) } else { measure(legend) }
  let g = figure-layout(data, style, cell-size, row-height, what-width, importance-width,
    comparison-width, header-height, basement-height, legend-width, legend-gap,
    cell-padding, label-padding, header-padding, legend-size)
  let drawing = box(width: g.width, height: g.height, {
    draw-roof(data, g, style)
    draw-matrix(data, g, style)
    draw-basement(data, g, style)
    draw-comparison(data, g, style)
    draw-grid(data, g, style)
    if legend != none { place(top + left, dx: g.legend-x, dy: g.roof-base, legend) }
  })
  fit-figure(drawing, g.width, width)
}
