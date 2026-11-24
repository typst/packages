// annotations.typ - Overlay annotations for cartesian charts

#import "../theme.typ": *
#import "fonts.typ": spread-labels

// Whether two `(x, y, w, h)` boxes overlap.
#let _hit(a, b) = a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h

// A full line of text of `size` (ascender to descender).
#let _line-h(size) = measure(text(size: size, top-edge: "ascender", bottom-edge: "descender")[Ag]).height

/// Room annotations need outside the plot: `right` for the labels beside
/// horizontal lines, `top` for those above vertical lines (a line of text and a
/// little air, so the label stays clear of the chart title above the plot).
///
/// - annotations (none, array): Annotation descriptors
/// - theme (dictionary): Resolved theme
/// -> dictionary
#let annotation-reserve(annotations, theme) = {
  let (right, top) = (0pt, 0pt)
  let size = theme.axis-label-size * 0.85
  if annotations != none {
    for ann in annotations {
      let label = ann.at("label", default: none)
      let kind = ann.at("type", default: "h-line")
      if kind == "h-line" and label != none {
        right = calc.max(right, measure(text(size: size)[#label]).width + 5pt)
      } else if kind == "v-line" and label != none {
        top = calc.max(top, _line-h(size) + 3pt)
      }
    }
  }
  (right: right, top: top)
}

// Draw annotations on a cartesian chart.
// Annotations are drawn relative to the chart coordinate system.
// Text that would land on other text moves aside: the labels of horizontal lines
// slide along the plot's edge, those of vertical lines along its top, and `label` and
// `content` annotations shift up or down to the nearest free spot (a `label` keeps a
// leader line to its dot).
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

  let small = theme.axis-label-size * 0.85
  let kind-of(ann) = ann.at("type", default: "h-line")
  let color-of(ann) = ann.at("color", default: theme.text-color-light)
  let small-label(ann, key: "label") = text(size: small, fill: color-of(ann))[#ann.at(key)]
  let right-edge = x-start + chart-width

  // ── Where each piece of text goes, before anything is drawn ─────────────────
  // Labels beside horizontal lines: spread along the edge so neighbours keep clear
  let h-idx = annotations.enumerate().filter(((_, a)) => kind-of(a) == "h-line" and a.at("label", default: none) != none).map(((i, _)) => i)
  let h-top = (:)  // annotation index -> top of its label
  if h-idx.len() > 0 {
    let heights = h-idx.map(i => _line-h(small))
    let cap = h-idx.map(i => measure(small-label(annotations.at(i))).height)
    let centres = h-idx.enumerate().map(((k, i)) => to-px(0, annotations.at(i).value).at(1) - 5pt + cap.at(k) / 2)
    let spread = spread-labels(centres, sizes: heights, lo: y-start - 3pt, hi: y-start + chart-height + 3pt)
    for (k, i) in h-idx.enumerate() { if spread.at(k) != none { h-top.insert(str(i), spread.at(k) - cap.at(k) / 2) } }
  }
  // Labels above vertical lines: spread along the top, kept inside the plot's width
  let v-idx = annotations.enumerate().filter(((_, a)) => kind-of(a) == "v-line" and a.at("label", default: none) != none).map(((i, _)) => i)
  let v-left = (:)  // annotation index -> left edge of its label
  if v-idx.len() > 0 {
    let widths = v-idx.map(i => measure(small-label(annotations.at(i))).width)
    let centres = v-idx.enumerate().map(((k, i)) => {
      let px = to-px(annotations.at(i).value, 0).at(0)
      calc.max(x-start + widths.at(k) / 2, calc.min(px, right-edge - widths.at(k) / 2))
    })
    let spread = spread-labels(centres, sizes: widths, gap: 3pt, lo: x-start, hi: right-edge)
    for (k, i) in v-idx.enumerate() { if spread.at(k) != none { v-left.insert(str(i), spread.at(k) - widths.at(k) / 2) } }
  }

  // Free-standing text (`label`, `content`): boxes as first placed, then moved up or
  // down, nearest spot first, to a place clear of the other text and inside the plot
  let box-of(ann) = {
    let kind = kind-of(ann)
    if kind == "label" {
      let (px, py) = to-px(ann.x, ann.y)
      let lbl = text(size: theme.axis-label-size, weight: "bold")[#ann.text]
      let (w, h) = (measure(lbl).width, measure(lbl).height * 1.45)
      let flip = px + 3pt + w > right-edge and px - 3pt - w >= x-start
      (x: if flip { px - 3pt - w } else { px + 3pt }, y: py - 8pt, w: w, h: h, flip: flip)
    } else if kind == "content" {
      let (px, py) = to-px(ann.x, ann.y)
      let sz = measure(ann.at("body", default: []))
      let anchor = ann.at("anchor", default: "center")
      let adjust-x = if anchor.ends-with("right") { -sz.width }
        else if anchor == "top" or anchor == "center" or anchor == "bottom" { -sz.width / 2 }
        else { 0pt }
      let adjust-y = if anchor.starts-with("bottom") { -sz.height }
        else if anchor == "left" or anchor == "center" or anchor == "right" { -sz.height / 2 }
        else { 0pt }
      (x: px + ann.at("dx", default: 0pt) + adjust-x, y: py + ann.at("dy", default: 0pt) + adjust-y, w: sz.width, h: sz.height, flip: false)
    }
  }
  let fixed = ()  // text that stays where it is: labels of points, bands and rectangles
  for ann in annotations {
    let kind = kind-of(ann)
    if ann.at("label", default: none) == none { continue }
    let lbl = small-label(ann)
    let (w, h) = (measure(lbl).width, measure(lbl).height * 1.45)
    if kind == "point" {
      let (px, py) = to-px(ann.x, ann.y)
      let radius = ann.at("radius", default: 3pt)
      let flip = px + radius + 2pt + w > right-edge and px - radius - 2pt - w >= x-start
      fixed.push((x: if flip { px - radius - 2pt - w } else { px + radius + 2pt }, y: py - 6pt, w: w, h: h))
    } else if kind == "h-band" {
      let band-y = calc.min(to-px(0, ann.from).at(1), to-px(0, ann.to).at(1))
      fixed.push((x: x-start + 3pt, y: band-y + 2pt, w: w, h: h))
    } else if kind == "rect" {
      let (px1, py1) = to-px(ann.x1, ann.y1)
      let (px2, py2) = to-px(ann.x2, ann.y2)
      fixed.push((x: calc.min(px1, px2) + 3pt, y: calc.min(py1, py2) + 2pt, w: w, h: h))
    }
  }
  let shift = (:)  // annotation index -> vertical shift of its text
  let placed = fixed
  for (i, ann) in annotations.enumerate() {
    if kind-of(ann) not in ("label", "content") { continue }
    let b = box-of(ann)
    let step = b.h + 1.5pt
    let best = (cost: 1000000, dy: 0pt)
    for (c, k) in (0, 1, -1, 2, -2, 3, -3).enumerate() {
      let r = (x: b.x, y: b.y + k * step, w: b.w, h: b.h)
      if r.y < y-start - 6pt or r.y + r.h > y-start + chart-height + 6pt { continue }
      let cost = 100 * placed.filter(o => _hit(o, r)).len() + c
      if cost < best.cost { best = (cost: cost, dy: k * step) }
      if cost < 100 { break }
    }
    placed.push((x: b.x, y: b.y + best.dy, w: b.w, h: b.h))
    shift.insert(str(i), best.dy)
  }

  // ── Drawing ─────────────────────────────────────────────────────────────────
  for (idx, ann) in annotations.enumerate() {
    let ann-type = kind-of(ann)
    let ann-color = color-of(ann)
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
      if ann-label != none and str(idx) in h-top {
        let lbl-top = h-top.at(str(idx))
        // A label that had to move off its line keeps a leader to it
        if calc.abs(lbl-top - (py - 5pt)) > 1.5pt {
          place(left + top, line(start: (right-edge, py), end: (right-edge + 3pt, lbl-top + measure(small-label(ann)).height / 2),
            stroke: 0.5pt + ann-color))
        }
        place(left + top, dx: right-edge + 3pt, dy: lbl-top, small-label(ann))
      }
    } else if ann-type == "v-line" {
      let value = ann.value
      let (px, _) = to-px(value, 0)
      place(left + top,
        line(start: (px, y-start), end: (px, y-start + chart-height), stroke: stroke-style)
      )
      if ann-label != none and str(idx) in v-left {
        // Over the line (or as near as its neighbours allow), in the room above the plot
        let lbl = text(size: small, fill: ann-color, top-edge: "ascender", bottom-edge: "descender")[#ann-label]
        let (w, lh) = (measure(lbl).width, measure(lbl).height)
        let x0 = v-left.at(str(idx))
        if calc.abs(x0 + w / 2 - px) > 2pt {
          place(left + top, line(start: (px, y-start), end: (calc.max(x0, calc.min(px, x0 + w)), y-start - 2pt),
            stroke: 0.5pt + ann-color))
        }
        place(left + top, dx: x0, dy: y-start - lh - 2pt, lbl)
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
        place(left + top, dx: x-start + 3pt, dy: band-y + 2pt, small-label(ann))
      }
    } else if ann-type == "label" {
      let (px, py) = to-px(ann.x, ann.y)
      let lbl = text(size: theme.axis-label-size, fill: ann-color, weight: "bold")[#ann.text]
      let b = box-of(ann)
      let dy = shift.at(str(idx))
      // Beside the dot, on its left when it would run past the plot's right edge; a
      // label moved clear of other text keeps a leader line to its dot
      if dy != 0pt {
        place(left + top, line(
          start: (px, py), end: (if b.flip { b.x + b.w + 1pt } else { b.x - 1pt }, b.y + dy + measure(lbl).height / 2 + 1pt),
          stroke: 0.5pt + ann-color))
      }
      place(left + top, dx: b.x, dy: b.y + dy, lbl)
      // Small dot at the point
      place(left + top, dx: px - 2pt, dy: py - 2pt,
        circle(radius: 2pt, fill: ann-color)
      )
    } else if ann-type == "content" {
      // Place arbitrary Typst content at data coordinates (x, y).
      // Anchor defaults to center; supported: top-left, top, top-right,
      // left, center, right, bottom-left, bottom, bottom-right.
      // The anchor names the content's own anchor point that lands on (x, y).
      let b = box-of(ann)
      place(left + top, dx: b.x, dy: b.y + shift.at(str(idx)), ann.at("body", default: []))
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
        let lbl = small-label(ann)
        let w = measure(lbl).width
        let flip = px + radius + 2pt + w > right-edge and px - radius - 2pt - w >= x-start
        place(left + top, dx: if flip { px - radius - 2pt - w } else { px + radius + 2pt }, dy: py - 6pt, lbl)
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
        place(left + top, dx: rx + 3pt, dy: ry + 2pt, small-label(ann))
      }
    }
  }
}
