// The look of a graph. Everything here can be overridden per graph with
// `graph(style: (grid: 0.4pt + gray))`, or for a whole document with
// `#let graph = graph.with(style: (...))`.

// Series colors, assigned in this order (never cycled randomly). The order is
// chosen so neighbours stay distinguishable with color-vision deficiencies.
#let palette = (
  rgb("#2a78d6"), // blue
  rgb("#eb6834"), // orange
  rgb("#1baf7a"), // aqua
  rgb("#eda100"), // yellow
  rgb("#e87ba4"), // magenta
  rgb("#008300"), // green
  rgb("#4a3aa7"), // violet
  rgb("#e34948"), // red
)

#let default-style = (
  palette: palette,
  ink: luma(20),                  // axes, helper lines, text
  line: 1.3pt,                    // thickness of curves and connecting lines
  helper: 0.8pt,                  // thickness of segment / arrow / hline / vline
  axis: 0.8pt,                    // thickness of the axes
  grid: 0.5pt + luma(205),        // major grid lines
  minor-grid: 0.3pt + luma(230),  // minor grid lines
  tick: 3pt,                      // length of the tick marks on the axes
  tick-label: 0.8em,              // size of the numbers on the axes
  axis-label: 1em,                // size of x-label / y-label
  arrow: 5pt,                     // length of arrowheads (axes and `vector`)
  overhang: 6pt,                  // how far the axes stick out past the grid
  mark: 6pt,                      // diameter of point marks
  area: 85%,                      // how transparent `area` fills are
  gap: 3pt,                       // distance between a text and what it names
  halo: white,                    // background behind texts on the graph (none: no background)
)
