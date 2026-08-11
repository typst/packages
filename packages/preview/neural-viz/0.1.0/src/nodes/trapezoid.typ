#import "../internal/geometry.typ": resolve-node-center

#let make-trapezoid(
  title,
  subtitle: none,
  legend: none,
  legend-position: "below",
  mode: "encoder",
  width: 2.8,
  big-half: 1.65,
  small-half: 0.80,
  pos: none,
  after: none,
  gap: 1.0,
  y: none,
  color: rgb("#b0dba0"),
  title-size: 0.66em,
  subtitle-size: 0.54em,
  legend-size: 0.48em,
  wrap-lines: 2,
) = {
  let (cx, cy) = resolve-node-center(pos, after, width, gap: gap, y: y, default-x: 4.5)

  let (hl, hr) = if mode == "decoder" {
    (small-half, big-half)
  } else {
    (big-half, small-half)
  }

  (
    kind: "trapezoid",
    cx: cx,
    cy: cy,
    w: width,
    h-left: hl,
    h-right: hr,
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
