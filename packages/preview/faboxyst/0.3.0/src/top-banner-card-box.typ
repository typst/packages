// One Top Banner Card: a hanging sculpted tab on a rounded card.
// Visual reference: https://www.presentationgo.com/presentation/top-banner-cards-diagram-powerpoint/
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _tbc-cubic(p0, p1, p2, p3, n: 16) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _tbc-tab-points(w, h) = {
  let p = ((w * 0.12, 0pt), (w * 0.88, 0pt))
  p += _tbc-cubic((w * 0.88, 0pt), (w * 0.95, 0pt),
    (w * 0.96, h * 0.07), (w * 0.93, h * 0.18))
  p += _tbc-cubic((w * 0.93, h * 0.18), (w * 0.86, h * 0.48),
    (w * 0.78, h * 0.81), (w * 0.69, h * 0.92))
  p += _tbc-cubic((w * 0.69, h * 0.92), (w * 0.66, h * 0.98),
    (w * 0.63, h), (w * 0.59, h))
  p.push((w * 0.41, h))
  p += _tbc-cubic((w * 0.41, h), (w * 0.37, h),
    (w * 0.34, h * 0.98), (w * 0.31, h * 0.92))
  p += _tbc-cubic((w * 0.31, h * 0.92), (w * 0.22, h * 0.81),
    (w * 0.14, h * 0.48), (w * 0.07, h * 0.18))
  p += _tbc-cubic((w * 0.07, h * 0.18), (w * 0.04, h * 0.07),
    (w * 0.05, 0pt), (w * 0.12, 0pt))
  p
}

/// Draw one Top Banner Card with a hanging label tab, heading, body, and icon.
/// This is a single reusable box, adapted from the source's three-card row.
#let top-banner-card-box(
  title: [],
  label: [TITLE 01],
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
  label-size: 12.5pt,
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
  let heading-ink = if print-mode { luma(55) }
    else if title-colour != auto { title-colour }
    else { colour.darken(12%) }
  let label-ink = if print-mode { black }
    else if label-colour != auto { label-colour }
    else { rgb("#151515") }
  let body-ink = if print-mode { luma(45) }
    else if text-colour != auto { text-colour }
    else { rgb("#5F6265") }
  let shadow-fill = if print-mode { luma(225) }
    else if shadow-colour != auto { shadow-colour }
    else { rgb("#727B80").transparentize(77%) }
  let card-edge = if print-mode { (paint: luma(150), thickness: 0.65pt) } else { none }
  let shadow-offset = 0.22cm
  let tab-overhang = height * 0.055
  // Mirror the shadow placement in RTL, while the top tab stays centered.
  let card-x = if rtl { shadow-offset } else { 0pt }
  let card-y = tab-overhang
  let stage-width = width + shadow-offset
  let stage-height = tab-overhang + height + shadow-offset
  let radius = calc.min(corner-radius, width * 0.15, height * 0.14)
  let shadow-card = box(width: width, height: height,
    radius: radius, fill: shadow-fill, inset: 0pt)
  let card = box(width: width, height: height,
    radius: radius, fill: face-fill, stroke: card-edge, inset: 0pt)

  let tab-width = width * 0.76
  let tab-height = height * 0.205
  let tab-x = card-x + (width - tab-width) / 2
  let tab-y = 0pt
  let tab = polygon(fill: accent, stroke: none,
    .._tbc-tab-points(tab-width, tab-height))

  // Small shaded shoulders peek from behind the banner at its upper corners.
  let shoulder-fill = if print-mode { luma(126) } else { colour.darken(34%) }
  let shoulder-size = 0.48cm
  let shoulder-y = card-y - shoulder-size * 0.72
  let shoulder-left = ellipse(width: shoulder-size, height: shoulder-size,
    fill: shoulder-fill, inset: 0pt)
  let shoulder-right = ellipse(width: shoulder-size, height: shoulder-size,
    fill: shoulder-fill, inset: 0pt)

  let label-box = box(width: tab-width * 0.78, height: tab-height * 0.32,
    align(center, text(size: label-size, weight: "bold", fill: label-ink, label)))
  let label-x = card-x + (width - tab-width * 0.78) / 2
  let label-y = tab-y + tab-height * 0.20

  let title-box = box(width: width * 0.84, height: height * 0.12,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let title-x = card-x + width * 0.08
  let title-y = card-y + height * 0.20
  let body-box = box(width: width * 0.80, height: height * 0.36,
    align((if rtl { right } else { left }) + top, {
      set par(justify: false, leading: 1.16em)
      text(size: body-size, fill: body-ink, body)
    }))
  let body-x = card-x + width * 0.10
  let body-y = card-y + height * 0.34

  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: 24pt, weight: "bold", fill: heading-ink, [✦]) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center, icon-content))
  let icon-x = card-x + (width - icon-size) / 2
  let icon-y = card-y + height * 0.80

  box(width: stage-width, height: stage-height, inset: 0pt, {
    if shadow and not print-mode {
      let shadow-x = if rtl { card-x - shadow-offset } else { card-x + shadow-offset }
      place(top + left, dx: shadow-x, dy: shadow-offset, shadow-card)
    }
    // Behind the card so only the upper halves of the end-caps show.
    place(top + left, dx: card-x + width * 0.10, dy: shoulder-y, shoulder-left)
    place(top + left, dx: card-x + width * 0.82, dy: shoulder-y, shoulder-right)
    place(top + left, dx: card-x, dy: card-y, card)
    place(top + left, dx: tab-x, dy: tab-y, tab)
    place(top + left, dx: (label-x) + title-offset-x, dy: (label-y) + title-offset-y, label-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
    place(top + left, dx: (body-x) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
  })
}
