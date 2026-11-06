// One Side Banner Card: a rounded white panel with a sculpted vertical ribbon.
// Visual reference: https://www.presentationgo.com/presentation/side-banner-cards-diagram-powerpoint/
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _sbc-cubic(p0, p1, p2, p3, n: 18) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _sbc-ribbon-points(w, h, rtl: false) = {
  // DrawingML's ribbon uses a narrow sculpted path inside a slightly wider box.
  let path-w = w * 0.78
  let points = ((0pt, 0pt),)
  points += _sbc-cubic((0pt, 0pt),
    (path-w * 0.045, h * 0.005),
    (path-w * -0.069, h * 0.041),
    (path-w * 0.275, h * 0.078))
  points += _sbc-cubic((path-w * 0.275, h * 0.078),
    (path-w * 0.592, h * 0.099),
    (path-w, h * 0.133),
    (path-w, h * 0.223))
  points.push((path-w, h * 0.777))
  points += _sbc-cubic((path-w, h * 0.777),
    (path-w, h * 0.867),
    (path-w * 0.592, h * 0.901),
    (path-w * 0.275, h * 0.922))
  points += _sbc-cubic((path-w * 0.275, h * 0.922),
    (path-w * -0.069, h * 0.959),
    (path-w * 0.045, h * 0.995),
    (0pt, h))
  points.push((0pt, 0pt))
  if rtl { points.map(((x, y)) => (w - x, y)).rev() } else { points }
}

/// Draw one Side Banner Card with a vertical label, heading, body copy, and bottom icon.
/// This is a single box only, adapted from the source's three-card row.
#let side-banner-card-box(
  title: [],
  label: [STEP 01],
  body: [],
  icon: none,
  print-icon: none,
  width: 6.2cm,
  height: 8.8cm,
  direction: auto,
  colour: rgb("#F15F47"),
  panel-colour: auto,
  title-colour: auto,
  label-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  title-size: 14pt,
  label-size: 14pt,
  body-size: 8.7pt,
  icon-size: 0.94cm,
  corner-radius: 0.72cm,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { std.ltr })

  let accent = if print-mode { luma(174) } else { colour }
  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#171717") }
  let ribbon-ink = if print-mode { black }
    else if label-colour != auto { label-colour }
    else { rgb("#171717") }
  let body-ink = if print-mode { luma(45) }
    else if text-colour != auto { text-colour }
    else { rgb("#5F6265") }
  let shadow-fill = if print-mode { luma(224) }
    else if shadow-colour != auto { shadow-colour }
    else { rgb("#737D82").transparentize(76%) }
  let edge = if print-mode { (paint: luma(150), thickness: 0.65pt) } else { none }

  let overhang = width * 0.05
  let shadow-offset = 0.22cm
  // Mirror the shadow along with the card: LTR casts right, RTL casts left.
  let card-x = if rtl { shadow-offset } else { overhang }
  let stage-width = width + overhang + shadow-offset
  let stage-height = height + shadow-offset
  let card-radius = calc.min(corner-radius, width * 0.15, height * 0.14)
  let card-shadow = box(width: width, height: height,
    radius: card-radius, fill: shadow-fill, inset: 0pt)
  let card-face = box(width: width, height: height,
    radius: card-radius, fill: face-fill, stroke: edge, inset: 0pt)

  let ribbon-width = width * 0.28
  let ribbon-height = height * 0.66
  let ribbon-y = height * 0.17
  let ribbon-x = if rtl {
    card-x + width + overhang - ribbon-width
  } else { 0pt }
  let ribbon-points = _sbc-ribbon-points(ribbon-width, ribbon-height, rtl: rtl)
  let ribbon = polygon(fill: accent, stroke: none, ..ribbon-points)

  let label-content = text(size: label-size, weight: "bold",
    fill: ribbon-ink, label)
  let label-measure = measure(label-content)
  let label-width = label-measure.width
  let label-height = label-measure.height
  let label-turn = if rtl { 90deg } else { -90deg }
  let label-x = ribbon-x + ribbon-width / 2 - label-width / 2
  let label-y = ribbon-y + ribbon-height / 2 - label-height / 2

  let title-x = card-x + width * 0.10
  let heading = box(width: width * 0.80, height: height * 0.12,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let heading-y = height * 0.055

  let body-x = card-x + if rtl { width * 0.10 } else { width * 0.255 }
  let body-width = width * 0.66
  let body-copy = box(width: body-width, height: height * 0.45,
    align((if rtl { right } else { left }) + top, {
      set par(justify: false, leading: 1.16em)
      text(size: body-size, fill: body-ink, body)
    }))
  let body-y = height * 0.295

  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: 24pt, weight: "bold", fill: heading-ink, [✦]) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center, icon-content))
  let icon-center-x = if rtl { width * 0.40 } else { width * 0.60 }
  let icon-x = card-x + icon-center-x - icon-size / 2
  let icon-y = height * 0.82

  box(width: stage-width, height: stage-height, inset: 0pt, {
    if shadow and not print-mode {
      let shadow-x = if rtl { card-x - shadow-offset } else { card-x + shadow-offset }
      place(top + left, dx: shadow-x, dy: shadow-offset, card-shadow)
    }
    place(top + left, dx: card-x, dy: 0pt, card-face)
    place(top + left, dx: ribbon-x, dy: ribbon-y, ribbon)
    place(top + left, dx: (title-x) + title-offset-x, dy: (heading-y) + title-offset-y, heading)
    place(top + left,
      dx: label-x, dy: label-y,
      rotate(label-turn, origin: center + horizon, reflow: false, label-content))
    place(top + left, dx: (body-x) + body-offset-x, dy: (body-y) + body-offset-y, body-copy)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
  })
}
