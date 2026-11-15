// One reusable card adapted from PresentationGO's 4-Step Corner Ribbon Process.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _crp-cubic(p0, p1, p2, p3, n: 18) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _crp-wave-points(width, height, rtl: false) = {
  let curve = _crp-cubic((0pt, 0pt), (width * 0.20, height * 0.08),
    (width * 0.35, height * 0.72), (width, height))
  if rtl {
    ((width, 0pt),) + curve.map(((x, y)) => (width - x, y)) + ((width, height),)
  } else {
    ((0pt, 0pt),) + curve + ((0pt, height),)
  }
}

#let _crp-tab-points(width, height, rtl: false) = if rtl {
  ((width, 0pt), (width * 0.34, 0pt), (0pt, height / 2),
   (width * 0.34, height), (width, height))
} else {
  ((0pt, 0pt), (width * 0.66, 0pt), (width, height / 2),
   (width * 0.66, height), (0pt, height))
}

#let _crp-fold-triangle(width, corner, rtl: false) = if rtl {
  ((0pt, 0pt), (corner, 0pt), (0pt, corner))
} else {
  ((width - corner, 0pt), (width, 0pt), (width, corner))
}

#let _crp-fold-band(width, corner, offset, thickness, rtl: false) = if rtl {
  ((0pt, offset), (0pt, offset + thickness),
   (offset + thickness, 0pt), (offset, 0pt))
} else {
  ((width - corner + offset, 0pt), (width - corner + offset + thickness, 0pt),
   (width, offset + thickness), (width, offset))
}

#let _crp-magnifier(size, colour) = {
  let glass-size = size * 0.46
  let glass = ellipse(width: glass-size, height: glass-size,
    fill: none, stroke: (paint: colour, thickness: 0.105cm))
  let handle = rect(width: size * 0.31, height: size * 0.115,
    radius: 0.06cm, fill: colour)
  box(width: size, height: size, {
    place(top + left, dx: size * 0.18, dy: size * 0.16, glass)
    place(top + left, dx: size * 0.55, dy: size * 0.57,
      rotate(45deg, origin: center + horizon, handle))
  })
}

/// Draw one Corner Ribbon Process card with corner folds, a number tab, icon, and copy.
/// Only one reusable box is drawn; the source's four-card process is not reproduced.
#let corner-ribbon-process-box(
  title: [LOREM IPSUM],
  number: [01],
  body: [],
  icon: none,
  print-icon: none,
  width: 6.2cm,
  height: auto,
  min-height: 9.9cm,
  direction: auto,
  body-direction: auto,
  colour: rgb("#F15B4A"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  number-colour: auto,
  icon-colour: auto,
  shadow-colour: auto,
  corner-radius: 0.48cm,
  icon-size: 3.30cm,
  title-size: 16pt,
  number-size: 13pt,
  body-size: 8pt,
  tab-width: 1.30cm,
  tab-height: 1.28cm,
  tab-overhang: 0.48cm,
  body-padding-x: 0.70cm,
  body-start: 5.75cm,
  body-to-dots-gap: 1.20cm,
  wave-height: 0.19,
  shadow-offset: 0.14cm,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let body-rtl = if body-direction == auto { rtl }
    else { body-direction == "rtl" or body-direction == std.rtl }
  let body-dir = if body-rtl { std.rtl } else { std.ltr }

  let accent = if print-mode { luma(168) } else { colour }
  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { colour.darken(5%) }
  let body-ink = if print-mode { luma(48) }
    else if text-colour != auto { text-colour }
    else { rgb("#616468") }
  let number-ink = if print-mode { white }
    else if number-colour != auto { number-colour }
    else { white }
  let icon-ink = if print-mode { luma(70) }
    else if icon-colour != auto { icon-colour }
    else { colour }
  let shadow-tone = if shadow-colour != auto { shadow-colour } else { rgb("#72797E") }
  let shadow-fill = if print-mode { luma(225) } else { shadow-tone.transparentize(78%) }
  let edge = if print-mode { (paint: luma(145), thickness: 0.9pt) }
    else { (paint: colour, thickness: 0.75pt) }
  let pale-accent = if print-mode { luma(232) } else { colour.lighten(62%) }
  let muted-accent = if print-mode { luma(196) } else { colour.lighten(38%) }
  let fold-main = if print-mode { luma(168) } else { colour.lighten(12%) }
  let fold-mid = if print-mode { luma(132) } else { colour }
  let fold-dark = if print-mode { luma(105) } else { colour.darken(18%) }

  let title-dir = if rtl { std.rtl } else { std.ltr }
  let body-content = if body-direction == auto {
    {
      set par(leading: 0.55em, spacing: 0.42em, justify: false)
      text(size: body-size, fill: body-ink, body)
    }
  } else {
    {
      set par(leading: 0.55em, spacing: 0.42em, justify: false)
      text(dir: body-dir, size: body-size, fill: body-ink, body)
    }
  }
  let body-width = width - 2 * body-padding-x
  let body-measure = measure(body-content, width: body-width)
  let measured-height = body-start + body-measure.height + body-to-dots-gap + 0.95cm
  let final-height = if height == auto { calc.max(min-height, measured-height) }
    else { calc.max(height, measured-height) }

  let outer-pad = tab-overhang
  let card-x = outer-pad
  let stage-width = width + 2 * outer-pad + shadow-offset
  let stage-height = final-height + shadow-offset
  let card = box(width: width, height: final-height, radius: corner-radius,
    fill: face-fill, stroke: edge, inset: 0pt)
  let card-shadow = box(width: width, height: final-height,
    radius: corner-radius, fill: shadow-fill, inset: 0pt)

  let corner-size = width * 0.31
  let corner-base = polygon(fill: fold-main, stroke: none,
    .._crp-fold-triangle(width, corner-size, rtl: rtl))
  let corner-band-light = polygon(fill: pale-accent, stroke: none,
    .._crp-fold-band(width, corner-size, corner-size * 0.12,
      corner-size * 0.18, rtl: rtl))
  let corner-band-mid = polygon(fill: fold-mid, stroke: none,
    .._crp-fold-band(width, corner-size, corner-size * 0.34,
      corner-size * 0.20, rtl: rtl))
  let corner-band-dark = polygon(fill: fold-dark, stroke: none,
    .._crp-fold-band(width, corner-size, corner-size * 0.57,
      corner-size * 0.18, rtl: rtl))

  let wave-w = width * 0.40
  let wave-h = final-height * wave-height
  let wave-x = if rtl { card-x + width - wave-w } else { card-x }
  let wave = polygon(fill: accent, stroke: none,
    .._crp-wave-points(wave-w, wave-h, rtl: rtl))
  let tab = polygon(fill: accent, stroke: none,
    .._crp-tab-points(tab-width, tab-height, rtl: rtl))
  let tab-x = if rtl { card-x + width - tab-width + tab-overhang }
    else { card-x - tab-overhang }
  let tab-y = final-height * 0.16
  let tab-label = box(width: tab-width * 0.70, height: tab-height,
    align(center + horizon,
      text(dir: std.ltr, size: number-size, weight: "bold", fill: number-ink, number)))
  let tab-label-x = if rtl { tab-x + tab-width * 0.12 } else { tab-x + tab-width * 0.02 }

  let circle-fill = if print-mode { white } else { pale-accent }
  let circle-stroke = if print-mode { luma(90) } else { colour }
  let icon-disc = ellipse(width: icon-size, height: icon-size,
    fill: circle-fill, stroke: (paint: circle-stroke, thickness: 0.8pt))
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { _crp-magnifier(icon-size * 0.72, icon-ink) }
  let icon-box = box(width: icon-size * 0.74, height: icon-size * 0.74,
    align(center + horizon, icon-content))
  let icon-x = card-x + (width - icon-size) / 2
  let icon-y = 0.54cm

  let title-y = 4.30cm
  let title-box = box(width: body-width, height: 0.58cm,
    align(center + horizon,
      text(dir: title-dir, size: title-size, weight: "bold", fill: title-ink, title)))
  let title-x = card-x + body-padding-x
  let rule-width = width * 0.58
  let rule-y = 5.39cm
  let rule = rect(width: rule-width, height: 0.025cm, fill: accent)
  let rule-dot = ellipse(width: 0.14cm, height: 0.14cm, fill: accent)
  let rule-x = card-x + (width - rule-width) / 2
  let rule-dot-x = card-x + (width - 0.14cm) / 2
  let body-y = body-start
  let body-box = box(width: body-width,
    height: final-height - body-y - body-to-dots-gap - 0.95cm,
    align(center + top, body-content))
  let body-x = card-x + body-padding-x

  let dot-size = 0.14cm
  let dot-gap = 0.25cm
  let dots-width = dot-size * 3 + dot-gap * 2
  let dots-x = card-x + (width - dots-width) / 2
  let dots-y = final-height - 0.75cm
  let dot-1 = ellipse(width: dot-size, height: dot-size,
    fill: if print-mode { luma(72) } else { colour })
  let dot-2 = ellipse(width: dot-size, height: dot-size,
    fill: if print-mode { luma(190) } else { colour.lighten(45%) })
  let dot-3 = ellipse(width: dot-size, height: dot-size,
    fill: if print-mode { luma(210) } else { colour.lighten(56%) })
  let shadow-x = card-x + shadow-offset

  box(width: stage-width, height: stage-height, inset: 0pt, {
    if shadow {
      place(top + left, dx: shadow-x, dy: shadow-offset, card-shadow)
    }
    place(top + left, dx: card-x, dy: 0pt, card)
    place(top + left, dx: wave-x, dy: final-height - wave-h, wave)
    place(top + left, dx: card-x, dy: 0pt, corner-base)
    place(top + left, dx: card-x, dy: 0pt, corner-band-light)
    place(top + left, dx: card-x, dy: 0pt, corner-band-mid)
    place(top + left, dx: card-x, dy: 0pt, corner-band-dark)
    place(top + left, dx: tab-x, dy: tab-y, tab)
    place(top + left, dx: tab-label-x, dy: tab-y, tab-label)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-disc)
    place(top + left, dx: (icon-x + (icon-size - icon-size * 0.74) / 2) + icon-offset-x, dy: (icon-y + (icon-size - icon-size * 0.74) / 2) + icon-offset-y, icon-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
    place(top + left, dx: rule-x, dy: rule-y, rule)
    place(top + left, dx: rule-dot-x, dy: rule-y - 0.055cm, rule-dot)
    place(top + left, dx: (body-x) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
    place(top + left, dx: dots-x, dy: dots-y, dot-1)
    place(top + left, dx: dots-x + dot-size + dot-gap, dy: dots-y, dot-2)
    place(top + left, dx: dots-x + 2 * (dot-size + dot-gap), dy: dots-y, dot-3)
  })
}
