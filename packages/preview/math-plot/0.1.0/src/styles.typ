// Styles, defaults, and marker definitions.

#let _plot-defaults = state("simple-plot-defaults", (:))

#let _plot-default-keys = (
  "xmin", "xmax", "ymin", "ymax", "width", "height", "scale",
  "xlabel", "ylabel", "xlabel-pos", "ylabel-pos",
  "xlabel-anchor", "ylabel-anchor", "xlabel-offset", "ylabel-offset",
  "xtick", "ytick", "xtick-step", "ytick-step",
  "xtick-labels", "ytick-labels", "xtick-label-step", "ytick-label-step",
  "show-grid", "minor-grid-step", "grid-label-break", "unit-label-only",
  "axis-x-pos", "axis-y-pos", "axis-x-extend", "axis-y-extend",
  "show-origin", "origin-label-offset", "origin-label-anchor",
  "origin-leader", "origin-leader-stroke", "origin-leader-gap",
  "origin-leader-end-gap",
  "tick-label-size", "axis-label-size", "label-bg", "tick-label-bg",
  "font", "label-sizing",
  "show-end-ticks", "min-tick-spacing", "hide-crossed-tick-labels",
  "samples",
  "style",
)

/// Override global defaults for `plot()`. Any named argument accepted by
/// `plot()` can be passed here; it will be used as the default until
/// `reset-plot-defaults()` is called.
#let set-plot-defaults(..args) = {
  for key in args.named().keys() {
    assert(key in _plot-default-keys,
      message: "set-plot-defaults: unknown plot option: " + key)
  }
  _plot-defaults.update(current => {
    let new = current
    for (key, value) in args.named() {
      new.insert(key, value)
    }
    new
  })
}

/// Clear all global plot defaults set via `set-plot-defaults()`, restoring
/// every parameter to its built-in value.
#let reset-plot-defaults() = {
  _plot-defaults.update(_ => (:))
}

#let marker-types = (
  "o",        // circle (hollow)
  "*",        // circle (filled)
  "square",   // square (hollow)
  "square*",  // square (filled)
  "triangle", // triangle (hollow)
  "triangle*",// triangle (filled)
  "diamond",  // diamond (hollow)
  "diamond*", // diamond (filled)
  "star",     // star (hollow)
  "star*",    // star (filled)
  "+",        // plus
  "x",        // cross
  "|",        // vertical bar
  "-",        // horizontal bar
  "none",     // no marker
)

#let default-style = (
  background: (
    fill: none,
    stroke: none,
  ),
  axis: (
    stroke: black + 0.8pt,
    arrow: (symbol: "stealth", fill: black, scale: 0.55),
  ),
  grid: (
    major: (stroke: luma(200) + 0.5pt),
    minor: (stroke: luma(230) + 0.3pt),
  ),
  ticks: (
    length: 0.1,
    stroke: black + 0.6pt,
    label-offset: 0.15,
    label-size: 10pt,
    label-fill: black,
    label-bg: white,
  ),
  origin: (
    label-offset: (-0.11, -0.11),
    label-anchor: "north-east",
    leader: true,
    leader-stroke: black + 0.6pt,
    leader-gap: 0.025,
    leader-end-gap: 0.025,
  ),
  plot: (
    stroke: blue + 1.2pt,
    samples: 100,
  ),
  marker: (
    size: 0.12,
    stroke: black + 0.8pt,
    fill: black,
  ),
  labels: (
    size: 10pt,
    fill: black,
    offset: 0.3,
    bg: white,
  ),
  xlabel-style: (
    anchor: "west",
    offset: (0.3, 0),
  ),
  ylabel-style: (
    anchor: "south",
    offset: (0, 0.3),
  ),
)

#let merge-styles(..styles) = {
  let result = default-style
  for user-style in styles.pos() {
    if user-style != none {
      for (key, value) in user-style {
        if key in result and type(value) == dictionary {
          for (k, v) in value {
            result.at(key).insert(k, v)
          }
        } else {
          result.insert(key, value)
        }
      }
    }
  }
  result
}
