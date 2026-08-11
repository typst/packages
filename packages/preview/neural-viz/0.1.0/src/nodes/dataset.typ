#import "../internal/text.typ": truncate-title
#import "../internal/geometry.typ": resolve-node-center

#let make-dataset(
  title,
  subtitle: none,
  legend: none,
  legend-position: "below",
  images: 3,
  image-size: (1.9, 2.3),
  image-spacing: 0.22,
  title-truncate: false,
  max-title-chars: 18,
  title-position: "inside",
  pos: none,
  after: none,
  gap: 1.0,
  y: none,
  color: rgb("#a8c8e8"),
  title-size: 0.58em,
  subtitle-size: 0.50em,
  legend-size: 0.48em,
  wrap-lines: 2,
) = {
  let w = image-size.at(0)
  let h = image-size.at(1)
  let (cx, cy) = resolve-node-center(pos, after, w, gap: gap, y: y, default-x: 1.0)

  (
    kind: "stack",
    cx: cx,
    cy: cy,
    w: w,
    h: h,
    n: images,
    shift: image-spacing,
    color: color,
    title: truncate-title(title, enabled: title-truncate, max-chars: max-title-chars),
    subtitle: subtitle,
    legend: legend,
    legend-position: legend-position,
    title-size: title-size,
    subtitle-size: subtitle-size,
    legend-size: legend-size,
    wrap-lines: wrap-lines,
    title-position: title-position,
  )
}
