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
          text(size: theme.axis-label-size * 0.85, fill: ann-color)[#ann-label]
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
          text(size: theme.axis-label-size * 0.85, fill: ann-color)[#ann-label]
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
          text(size: theme.axis-label-size * 0.85, fill: ann-color)[#ann-label]
        )
      }
    } else if ann-type == "label" {
      let (px, py) = to-px(ann.x, ann.y)
      let label-text = ann.text
      place(left + top, dx: px + 3pt, dy: py - 8pt,
        text(size: theme.axis-label-size, fill: ann-color, weight: "bold")[#label-text]
      )
      // Small dot at the point
      place(left + top, dx: px - 2pt, dy: py - 2pt,
        circle(radius: 2pt, fill: ann-color)
      )
    } else if ann-type == "content" {
      // Place arbitrary Typst content at data coordinates (x, y).
      // Anchor defaults to center; supported: top-left, top, top-right,
      // left, center, right, bottom-left, bottom, bottom-right.
      // The anchor names the content's own anchor point that lands on (x, y).
      let (px, py) = to-px(ann.x, ann.y)
      let body = ann.at("body", default: [])
      let anchor = ann.at("anchor", default: "center")
      let dx-off = ann.at("dx", default: 0pt)
      let dy-off = ann.at("dy", default: 0pt)
      let sz = measure(body)
      // Shift the content so its named anchor point lands at (px, py).
      let adjust-x = if anchor.ends-with("right") { -sz.width }
        else if anchor == "top" or anchor == "center" or anchor == "bottom" { -sz.width / 2 }
        else { 0pt }
      let adjust-y = if anchor.starts-with("bottom") { -sz.height }
        else if anchor == "left" or anchor == "center" or anchor == "right" { -sz.height / 2 }
        else { 0pt }
      place(left + top, dx: px + dx-off + adjust-x, dy: py + dy-off + adjust-y, body)
    } else if ann-type == "point" {
      // Circle marker at data coordinates — useful for outliers, highlights.
      let (px, py) = to-px(ann.x, ann.y)
      let radius = ann.at("radius", default: 3pt)
      let fill-color = ann.at("fill", default: ann-color)
      let stroke-val = ann.at("stroke", default: none)
      place(left + top, dx: px - radius, dy: py - radius,
        circle(radius: radius, fill: fill-color, stroke: stroke-val)
      )
      if ann-label != none {
        place(left + top, dx: px + radius + 2pt, dy: py - 6pt,
          text(size: theme.axis-label-size * 0.85, fill: ann-color)[#ann-label]
        )
      }
    } else if ann-type == "errorbar" {
      // Error bar at anchor with cap lines at each end.
      // Vertical (default): anchor `x` in data space, `low`/`high` in y data space.
      // Horizontal (orientation: "h"): anchor `y`, `low`/`high` in x data space.
      let orientation = ann.at("orientation", default: "v")
      let cap-w = ann.at("cap-width", default: 6pt)
      if orientation == "h" {
        let (px-lo, py) = to-px(ann.low, ann.y)
        let (px-hi, _) = to-px(ann.high, ann.y)
        place(left + top,
          line(start: (px-lo, py), end: (px-hi, py), stroke: stroke-style)
        )
        place(left + top,
          line(start: (px-lo, py - cap-w / 2), end: (px-lo, py + cap-w / 2), stroke: stroke-style)
        )
        place(left + top,
          line(start: (px-hi, py - cap-w / 2), end: (px-hi, py + cap-w / 2), stroke: stroke-style)
        )
      } else {
        let (px, py-lo) = to-px(ann.x, ann.low)
        let (_, py-hi) = to-px(ann.x, ann.high)
        place(left + top,
          line(start: (px, py-lo), end: (px, py-hi), stroke: stroke-style)
        )
        place(left + top,
          line(start: (px - cap-w / 2, py-lo), end: (px + cap-w / 2, py-lo), stroke: stroke-style)
        )
        place(left + top,
          line(start: (px - cap-w / 2, py-hi), end: (px + cap-w / 2, py-hi), stroke: stroke-style)
        )
      }
    } else if ann-type == "rect" {
      // Rectangle in data coordinates from (x1, y1) to (x2, y2).
      let (px1, py1) = to-px(ann.x1, ann.y1)
      let (px2, py2) = to-px(ann.x2, ann.y2)
      let rx = calc.min(px1, px2)
      let ry = calc.min(py1, py2)
      let rw = calc.abs(px2 - px1)
      let rh = calc.abs(py2 - py1)
      let opacity = ann.at("opacity", default: 20%)
      let fill-color = ann.at("fill", default: ann-color.transparentize(100% - opacity))
      let stroke-val = ann.at("stroke", default: none)
      place(left + top, dx: rx, dy: ry,
        rect(width: rw, height: rh, fill: fill-color, stroke: stroke-val)
      )
      if ann-label != none {
        place(left + top, dx: rx + 3pt, dy: ry + 2pt,
          text(size: theme.axis-label-size * 0.85, fill: ann-color)[#ann-label]
        )
      }
    }
  }
}
