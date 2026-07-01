// legend.typ - Legend rendering primitives

#import "../theme.typ": *
#import "../util.typ": heat-color

// Optional legend title rendered above entries.
#let _legend-title(title, theme) = {
  if title != none {
    text(size: theme.legend-size, weight: "bold", fill: theme.text-color)[#title]
    v(3pt)
  }
}

// Horizontal legend (for bar, line, area charts).
#let draw-legend(entries, theme, swatch-type: "box", title: none) = {
  let swatch-size = theme.legend-swatch-size
  v(5pt)
  align(center)[
    #_legend-title(title, theme)
    #for (i, entry) in entries.enumerate() {
      let name = if type(entry) == str { entry } else { entry.name }
      let color = if type(entry) == dictionary and "color" in entry {
        entry.color
      } else {
        get-color(theme, i)
      }

      // Wrap each swatch+label as an atomic unit to prevent mid-entry line breaks
      box(baseline: 2pt)[
        #if swatch-type == "line" {
          box(width: 15pt, height: 2pt, fill: color, baseline: -2pt)
        } else if swatch-type == "circle" {
          box(width: swatch-size, height: swatch-size, baseline: 2pt,
            circle(radius: swatch-size / 2, fill: color, stroke: theme.marker-stroke))
        } else {
          box(width: swatch-size, height: swatch-size, fill: color, baseline: 2pt, radius: 2pt)
        }
        #h(3pt)
        #text(size: theme.legend-size, fill: theme.text-color)[#name]
      ]
      h(theme.legend-gap)
    }
  ]
}

// Vertical legend (for pie, radar, side panels).
#let draw-legend-vertical(entries, theme, width: 130pt, title: none) = {
  let swatch-size = theme.legend-swatch-size
  box(width: width)[
    #_legend-title(title, theme)
    #for (i, entry) in entries.enumerate() {
      let name = if type(entry) == str { entry } else { entry.name }
      let color = if type(entry) == dictionary and "color" in entry {
        entry.color
      } else {
        get-color(theme, i)
      }

      box(width: swatch-size, height: swatch-size, fill: color, baseline: 2pt, radius: 2pt)
      h(3pt)
      text(size: theme.legend-size, fill: theme.text-color)[#name]
      if i < entries.len() - 1 {
        linebreak()
        v(2pt)
      }
    }
  ]
}

/// Automatically picks horizontal or vertical legend based on
/// `theme.legend-position`.  Returns `none` when the legend is
/// suppressed (`show-legend` is false or position is `"none"`).
///
/// - entries (array): Legend entries — strings or dicts with `name` (and optional `color`)
/// - theme (dictionary): Resolved theme
/// - show-legend (bool): Master toggle; when false nothing is rendered
/// - swatch-type (str): `"box"`, `"line"`, or `"circle"`
/// - title (none, str): Optional legend title displayed above entries
/// -> content, none
#let draw-legend-auto(entries, theme, show-legend: true, swatch-type: "box", title: none) = {
  if not show-legend { return }
  if theme.legend-position == "none" { return }
  if entries.len() == 0 { return }

  if theme.legend-position == "right" or theme.legend-position == "left" {
    draw-legend-vertical(entries, theme, title: title)
  } else {
    draw-legend(entries, theme, swatch-type: swatch-type, title: title)
  }
}

/// Gradient color bar legend for heatmaps and color-mapped charts.
///
/// Renders a vertical gradient bar with min/max labels. Can be placed
/// inline or absolutely positioned by the caller.
///
/// - min-val (number): Minimum data value (label at bottom)
/// - max-val (number): Maximum data value (label at top)
/// - palette (str, array): Palette name or color stop array
/// - theme (dictionary): Resolved theme
/// - bar-width (length): Width of the gradient bar
/// - bar-height (length): Height of the gradient bar
/// - steps (int): Number of discrete color segments
/// - reverse (bool): Reverse palette direction
/// -> content
#let draw-gradient-legend(min-val, max-val, palette, theme, bar-width: 15pt, bar-height: auto, steps: 30, reverse: false) = {
  let h = if bar-height == auto { 80pt } else { bar-height }
  let step-h = h / steps
  box(width: bar-width + 8pt, height: h + 4pt)[
    // Gradient bar
    #for i in array.range(steps) {
      let normalized = 1 - i / steps
      let cell-color = heat-color(normalized, palette: palette, reverse: reverse)
      place(left + top,
        dx: 0pt,
        dy: (i / steps) * h,
        rect(width: bar-width, height: step-h + 0.5pt, fill: cell-color, stroke: none))
    }
    // Max label (above bar)
    #place(left + top, dx: 0pt, dy: -1.2em,
      box(width: bar-width, align(center, text(size: theme.axis-label-size, fill: theme.text-color)[#calc.round(max-val, digits: 1)])))
    // Min label (below bar)
    #place(left + top, dx: 0pt, dy: h + 2pt,
      box(width: bar-width, align(center, text(size: theme.axis-label-size, fill: theme.text-color)[#calc.round(min-val, digits: 1)])))
  ]
}

/// Size legend for bubble charts — shows 2-3 reference circles with labels.
///
/// - sizes (array): Array of (value, label) pairs for reference bubbles
/// - max-radius (length): Maximum bubble radius (for scaling)
/// - max-value (number): Maximum data value (for scaling)
/// - theme (dictionary): Resolved theme
/// - title (none, str): Optional title (e.g., "Market Value (£M)")
/// -> content
#let draw-size-legend(sizes, max-radius, max-value, theme, title: none, max-legend-radius: 12pt) = {
  let cap = calc.min(max-radius, max-legend-radius)
  v(3pt)
  align(center)[
    #if title != none {
      text(size: theme.legend-size, fill: theme.text-color)[#title]
      h(6pt)
    }
    #for (val, lbl) in sizes {
      let r = calc.max(2pt, cap * calc.sqrt(val / calc.max(1, max-value)))
      let d = r * 2
      box(baseline: r - 1pt)[
        #box(width: d, height: d,
          circle(radius: r, fill: none, stroke: theme.text-color-light + 0.75pt))
      ]
      h(2pt)
      text(size: theme.legend-size, fill: theme.text-color)[#lbl]
      h(8pt)
    }
  ]
}
