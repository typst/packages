// annotations.typ - Overlay annotations for cartesian charts

#import "../theme.typ": *

// Draw annotations on a cartesian chart.
// Annotations are drawn relative to the chart coordinate system.
// Parameters:
//   annotations: array of annotation dicts
//   x-start: pixel x of chart area left edge
//   y-start: pixel y of chart area top edge
//   chart-width: pixel width of chart area
//   chart-height: pixel height of chart area
//   x-min, x-max: data range for x axis (for numeric) or 0..n-1 for categories
//   y-min, y-max: data range for y axis
//   theme: resolved theme
#let draw-annotations(annotations, x-start, y-start, chart-width, chart-height, x-min, x-max, y-min, y-max, theme) = {
  if annotations == none { return }

  let x-range = x-max - x-min
  let y-range = y-max - y-min
  if x-range == 0 { x-range = 1 }
  if y-range == 0 { y-range = 1 }

  // Helper: data coords to pixel coords
  let to-px(data-x, data-y) = {
    let px = x-start + ((data-x - x-min) / x-range) * chart-width
    let py = y-start + chart-height - ((data-y - y-min) / y-range) * chart-height
    (px, py)
  }

  for ann in annotations {
    let ann-type = ann.at("type", default: "h-line")
    let ann-color = ann.at("color", default: theme.text-color-light)
    let ann-stroke-width = ann.at("stroke", default: 1pt)
    let ann-dash = ann.at("dash", default: none)
    let ann-label = ann.at("label", default: none)

    let stroke-style = if ann-dash == "dashed" {
      (paint: ann-color, thickness: ann-stroke-width, dash: "dashed")
    } else if ann-dash == "dotted" {
      (paint: ann-color, thickness: ann-stroke-width, dash: "dotted")
    } else {
      ann-stroke-width + ann-color
    }

    if ann-type == "h-line" {
      let value = ann.value
      let (_, py) = to-px(0, value)
      place(left + top,
        line(start: (x-start, py), end: (x-start + chart-width, py), stroke: stroke-style)
      )
      if ann-label != none {
        place(left + top, dx: x-start + chart-width + 3pt, dy: py - 5pt,
          text(size: 6pt, fill: ann-color)[#ann-label]
        )
      }
    } else if ann-type == "v-line" {
      let value = ann.value
      let (px, _) = to-px(value, 0)
      place(left + top,
        line(start: (px, y-start), end: (px, y-start + chart-height), stroke: stroke-style)
      )
      if ann-label != none {
        place(left + top, dx: px - 10pt, dy: y-start - 12pt,
          text(size: 6pt, fill: ann-color)[#ann-label]
        )
      }
    } else if ann-type == "h-band" {
      let from-val = ann.from
      let to-val = ann.to
      let opacity = ann.at("opacity", default: 15%)
      let (_, py-from) = to-px(0, from-val)
      let (_, py-to) = to-px(0, to-val)
      let band-y = calc.min(py-from, py-to)
      let band-h = calc.abs(py-from - py-to)
      place(left + top, dx: x-start, dy: band-y,
        rect(width: chart-width, height: band-h, fill: ann-color.transparentize(100% - opacity), stroke: none)
      )
      if ann-label != none {
        place(left + top, dx: x-start + 3pt, dy: band-y + 2pt,
          text(size: 6pt, fill: ann-color)[#ann-label]
        )
      }
    } else if ann-type == "label" {
      let (px, py) = to-px(ann.x, ann.y)
      let label-text = ann.text
      place(left + top, dx: px + 3pt, dy: py - 8pt,
        text(size: 7pt, fill: ann-color, weight: "bold")[#label-text]
      )
      // Small dot at the point
      place(left + top, dx: px - 2pt, dy: py - 2pt,
        circle(radius: 2pt, fill: ann-color)
      )
    }
  }
}
