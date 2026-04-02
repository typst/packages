#import "../internal/geometry.typ": resolve-node-center

#let make-box(
  title,
  subtitle: none,
  legend: none,
  legend-position: "below",
  size: none,
  pos: none,
  after: none,
  gap: 1.0,
  y: none,
  color: rgb("#a0b8f5"),
  title-size: 0.62em,
  subtitle-size: 0.52em,
  legend-size: 0.48em,
  wrap-lines: 2,
  pad-x: 0.65,
  min-w: 2.3,
  min-h: 1.7,
) = {
  let l1 = title.clusters().len()
  let l2 = if subtitle == none { 0 } else { subtitle.clusters().len() }
  let longest = calc.max(l1, l2)
  let auto-w = calc.max(min-w, longest * 0.17 + 2 * pad-x)
  let auto-h = if subtitle == none { min-h } else { min-h + 0.65 }
  let (w, h) = if size == none { (auto-w, auto-h) } else { size }

  let (cx, cy) = resolve-node-center(pos, after, w, gap: gap, y: y, default-x: 8.0)

  (
    kind: "box",
    cx: cx,
    cy: cy,
    w: w,
    h: h,
    color: color,
    title: title,
    subtitle: subtitle,
    legend: legend,
    legend-position: legend-position,
    title-size: title-size,
    subtitle-size: subtitle-size,
    legend-size: legend-size,
    wrap-lines: wrap-lines,
  )
}
