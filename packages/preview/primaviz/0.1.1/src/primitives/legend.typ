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

      if swatch-type == "line" {
        box(width: 15pt, height: 2pt, fill: color, baseline: -2pt)
      } else if swatch-type == "circle" {
        circle(radius: swatch-size / 2, fill: color, stroke: white + 0.5pt)
      } else {
        box(width: swatch-size, height: swatch-size, fill: color, baseline: 2pt, radius: 2pt)
      }
      h(3pt)
      text(size: theme.legend-size, fill: theme.text-color)[#name]
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

// Right-positioned legend (vertical, for use in grid layout)
#let draw-legend-right(entries, theme, width: 100pt) = {
  draw-legend-vertical(entries, theme, width: width)
}
