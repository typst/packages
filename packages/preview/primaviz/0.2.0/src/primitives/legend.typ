// legend.typ - Legend rendering primitives

#import "../theme.typ": *

// Horizontal legend (for bar, line, area charts).
#let draw-legend(entries, theme, swatch-type: "box") = {
  let swatch-size = theme.legend-swatch-size
  v(5pt)
  align(center)[
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
            circle(radius: swatch-size / 2, fill: color, stroke: white + 0.5pt))
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
#let draw-legend-vertical(entries, theme, width: 130pt) = {
  let swatch-size = theme.legend-swatch-size
  box(width: width)[
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
/// -> content, none
#let draw-legend-auto(entries, theme, show-legend: true, swatch-type: "box") = {
  if not show-legend { return }
  if theme.legend-position == "none" { return }
  if entries.len() == 0 { return }

  if theme.legend-position == "right" or theme.legend-position == "left" {
    draw-legend-vertical(entries, theme)
  } else {
    draw-legend(entries, theme, swatch-type: swatch-type)
  }
}
