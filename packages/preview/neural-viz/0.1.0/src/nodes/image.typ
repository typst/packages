#import "../internal/text.typ": truncate-title
#import "../internal/geometry.typ": resolve-node-center

#let resolve-node-size(image-size, image-width, image-height, default-size) = {
  let base = if image-size == none { default-size } else { image-size }
  let w = if image-width == none { base.at(0) } else { image-width }
  let h = if image-height == none { base.at(1) } else { image-height }
  (w, h)
}

#let fit-image-content(content, target-w, target-h, fit: "cover") = context {
  let m = measure(content)
  let cw = if m.width > 0pt { m.width } else { target-w }
  let ch = if m.height > 0pt { m.height } else { target-h }
  let sx = target-w / cw
  let sy = target-h / ch

  let (kx, ky, clip-image) = if fit == "stretch" {
    (sx, sy, true)
  } else if fit == "contain" {
    let k = calc.min(sx, sy)
    (k, k, false)
  } else {
    let k = calc.max(sx, sy)
    (k, k, true)
  }

  box(width: target-w, height: target-h, inset: 0pt, clip: clip-image)[
    #align(center + horizon)[#scale(x: kx * 100%, y: ky * 100%)[#content]]
  ]
}

#let resolve-image(src, img, w, h, unit: 0.72cm, fit: "cover", pad: 0.1) = {
  let iw = calc.max(0.01, w - 2 * pad)
  let ih = calc.max(0.01, h - 2 * pad)
  let target-w = iw * unit
  let target-h = ih * unit

  if src != none {
    // Native image fitting is more robust for file-backed images (jpg/png/svg).
    image(src, width: target-w, height: target-h, fit: fit)
  } else if img != none {
    fit-image-content(img, target-w, target-h, fit: fit)
  } else {
    none
  }
}

#let make-image-node(
  title,
  subtitle: none,
  legend: none,
  legend-position: "below",
  src: none,
  img: none,
  image-size: none,
  image-width: none,
  image-height: none,
  image-fit: "cover",
  image-pad: 0.1,
  unit: 0.72cm,
  title-truncate: false,
  max-title-chars: 18,
  title-position: "below",
  pos: none,
  after: none,
  gap: 1.0,
  y: none,
  color: rgb("#ffffff"),
  title-size: 0.58em,
  subtitle-size: 0.50em,
  legend-size: 0.48em,
  wrap-lines: 2,
) = {
  let (w, h) = resolve-node-size(image-size, image-width, image-height, (2.2, 2.2))
  let (cx, cy) = resolve-node-center(pos, after, w, gap: gap, y: y, default-x: 1.0)

  (
    kind: "image",
    cx: cx,
    cy: cy,
    w: w,
    h: h,
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
    image: resolve-image(src, img, w, h, unit: unit, fit: image-fit, pad: image-pad),
  )
}

#let make-image-dataset(
  title,
  subtitle: none,
  legend: none,
  legend-position: "below",
  src: none,
  img: none,
  images: 3,
  image-size: none,
  image-width: none,
  image-height: none,
  image-spacing: 0.22,
  image-fit: "cover",
  image-pad: 0.0,
  unit: 0.72cm,
  title-truncate: false,
  max-title-chars: 18,
  title-position: "below",
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
  let (w, h) = resolve-node-size(image-size, image-width, image-height, (1.9, 2.3))
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
    image: resolve-image(src, img, w, h, unit: unit, fit: image-fit, pad: image-pad),
  )
}
