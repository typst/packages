// One reusable arrow-header text box, adapted from PresentationGO's Text Box Process.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _tbp-arrow-points(width, height, tip, rtl: false) = if rtl {
  ((tip, 0pt), (width, 0pt), (width, height), (tip, height), (0pt, height / 2))
} else {
  ((0pt, 0pt), (width - tip, 0pt), (width, height / 2),
   (width - tip, height), (0pt, height))
}

#let _tbp-tail-points(width, height, rtl: false) = if rtl {
  ((width, 0pt), (0pt, 0pt), (0pt, height))
} else {
  ((0pt, 0pt), (width, 0pt), (width, height))
}

#let _tbp-depth-points(width, height, skew, rtl: false) = if rtl {
  ((0pt, 0pt), (width - skew, 0pt), (width, height), (skew, height))
} else {
  ((skew, 0pt), (width, 0pt), (width - skew, height), (0pt, height))
}

/// A single Text Box Process card: layered arrow banner, raised number badge, and spacious body.
/// Only the reusable box is drawn; the source's three-card slide row is not reproduced.
#let text-box-process-box(
  title: [LOREM IPSUM],
  number: [01],
  body: [],
  width: 6.4cm,
  height: auto,
  direction: auto,
  body-direction: auto,
  colour: rgb("#41658A"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  number-fill: auto,
  number-colour: auto,
  shadow-colour: auto,
  min-body-height: 4.20cm,
  min-banner-height: 1.55cm,
  banner-overhang: 0.95cm,
  banner-padding: 0.18cm,
  header-overlap: 0.40cm,
  body-padding-x: 0.42cm,
  body-padding-top: 1.08cm,
  body-padding-bottom: 0.32cm,
  shadow-offset: 0.16cm,
  fold: true,
  depth-shadow: true,
  title-size: 18pt,
  number-size: 17pt,
  body-size: 11pt,
  corner-radius: 0pt,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let body-rtl = if body-direction == auto { rtl }
    else { body-direction == "rtl" or body-direction == std.rtl }
  let body-dir = if body-rtl { std.rtl } else { std.ltr }

  let banner-fill = if print-mode { luma(176) } else { colour }
  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let banner-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else if luma(colour).components().first() > 55% { colour.darken(62%) }
    else { white }
  let badge-fill = if print-mode { luma(92) }
    else if number-fill != auto { number-fill }
    else { colour.darken(23%) }
  let badge-ink = if print-mode { white }
    else if number-colour != auto { number-colour }
    else { white }
  let body-ink = if print-mode { luma(48) }
    else if text-colour != auto { text-colour }
    else { rgb("#73777A") }
  let shadow-tone = if shadow-colour != auto { shadow-colour } else { rgb("#555B60") }
  let shadow-fill = if print-mode { luma(224) } else { shadow-tone.transparentize(48%) }
  let depth-fill = if print-mode {
    gradient.linear(
      (white.transparentize(100%), 0%),
      (luma(145).transparentize(18%), 100%),
      angle: 90deg,
    )
  } else {
    gradient.linear(
      (shadow-tone.transparentize(100%), 0%),
      (shadow-tone.transparentize(42%), 100%),
      angle: 90deg,
    )
  }
  let fold-fill = if print-mode { luma(132) } else { colour.darken(48%) }
  let badge-edge = if print-mode { luma(55) } else { colour.darken(42%) }
  let card-edge = if print-mode { (paint: luma(155), thickness: 2pt) }
    else { (paint: luma(170), thickness: 2pt) }

  let title-dir = if rtl { std.rtl } else { std.ltr }
  let title-content = text(dir: title-dir, size: title-size, weight: "bold", fill: banner-ink, title)
  let flat-overhang = banner-overhang
  let tip-overhang = banner-overhang * 1.6
  let banner-width = width + flat-overhang + tip-overhang
  let tip-width = banner-width * 0.105
  let title-width = banner-width - flat-overhang - 1.95cm
  let title-measure = measure(title-content, width: title-width)
  let banner-height = calc.max(min-banner-height, title-measure.height + 2 * banner-padding)
  let badge-size = calc.min(1.12cm, banner-height * 0.72)
  let depth-extension = width * 0.30
  let banner-x = shadow-offset + (if rtl { depth-extension } else { 0pt })
  let card-x = banner-x + (if rtl { tip-overhang } else { flat-overhang })
  let card-y = banner-height - header-overlap
  let stage-width = banner-width + 2 * shadow-offset + depth-extension

  let body-width = width
  let inner-width = body-width - 2 * body-padding-x
  let body-content = if body-direction == auto {
    {
      set par(leading: 1.12em, spacing: 1.10em, justify: true)
      text(size: body-size, fill: body-ink, body)
    }
  } else {
    {
      set par(leading: 1.12em, spacing: 1.10em, justify: true)
      text(dir: body-dir, size: body-size, fill: body-ink, body)
    }
  }
  let body-measure = measure(body-content, width: inner-width)
  let natural-body-height = calc.max(
    min-body-height,
    body-padding-top + body-measure.height + body-padding-bottom,
  )
  let measured-total-height = card-y + natural-body-height + shadow-offset
  let final-height = if height == auto { measured-total-height }
    else { calc.max(height, measured-total-height) }
  let panel-height = final-height - card-y - shadow-offset
  let body-content-height = panel-height - body-padding-top - body-padding-bottom

  let card-shadow = box(width: body-width, height: panel-height,
    radius: corner-radius, fill: shadow-fill, inset: 0pt)
  let card = box(width: body-width, height: panel-height,
    radius: corner-radius, fill: face-fill, stroke: card-edge, inset: 0pt)
  let body-block = box(width: inner-width, height: body-content-height,
    align((if body-rtl { right } else { left }) + top, body-content))

  let arrow = polygon(fill: banner-fill, stroke: none,
    .._tbp-arrow-points(banner-width, banner-height, tip-width, rtl: rtl))
  let tail-width = flat-overhang
  let tail-height = banner-height * 0.42
  let tail-x = if rtl { banner-x + banner-width - tail-width } else { banner-x }
  let tail = polygon(fill: fold-fill, stroke: none,
    .._tbp-tail-points(tail-width, tail-height, rtl: rtl))
  let fold-band-width = body-width * 0.68
  let fold-band-height = banner-height * 0.30
  let fold-band-x = if rtl { card-x } else { card-x + body-width - fold-band-width }
  let fold-band-y = banner-height - 0.12cm
  let fold-band = polygon(fill: fold-fill, stroke: none,
    .._tbp-tail-points(fold-band-width, fold-band-height, rtl: rtl))

  let badge = box(width: badge-size, height: badge-size, fill: badge-fill,
    stroke: (paint: badge-edge, thickness: 0.6pt),
    align(center + horizon,
      text(dir: title-dir, size: number-size, weight: "bold", fill: badge-ink, number)))
  let badge-x = if rtl { banner-width - flat-overhang - badge-size - 0.16cm }
    else { flat-overhang + 0.16cm }
  let badge-y = (banner-height - badge-size) / 2
  let badge-shadow = box(width: badge-size, height: badge-size, fill: badge-edge)
  let title-x = if rtl { 0.24cm } else { flat-overhang + badge-size + 0.30cm }
  let title-box-width = if rtl {
    banner-width - flat-overhang - badge-size - 0.54cm
  } else {
    banner-width - title-x - tip-width * 0.55
  }
  let title-box = box(width: title-box-width, height: banner-height,
    align((if rtl { right } else { left }) + horizon,
      text(dir: title-dir, size: title-size, weight: "bold", fill: banner-ink, title)))
  let shadow-x = if rtl { card-x - shadow-offset } else { card-x + shadow-offset }
  let depth-width = body-width + depth-extension
  let depth-height = panel-height * 0.50
  let depth-skew = depth-width * 0.40
  let depth-x = if rtl { card-x - depth-extension } else { card-x }
  let depth-y = card-y + panel-height * 0.50
  let depth = polygon(fill: depth-fill, stroke: none,
    .._tbp-depth-points(depth-width, depth-height, depth-skew, rtl: rtl))

  box(width: stage-width, height: final-height, inset: 0pt, {
    if depth-shadow {
      place(top + left, dx: depth-x, dy: depth-y, depth)
    }
    if shadow {
      place(top + left, dx: shadow-x, dy: card-y + shadow-offset, card-shadow)
    }
    if fold {
      place(top + left, dx: tail-x, dy: banner-height, tail)
    }
    place(top + left, dx: card-x, dy: card-y, card)
    if fold {
      place(top + left, dx: fold-band-x, dy: fold-band-y, fold-band)
    }
    place(top + left, dx: banner-x, dy: 0pt, arrow)
    place(top + left, dx: banner-x + badge-x + 0.05cm, dy: badge-y + 0.05cm, badge-shadow)
    place(top + left, dx: banner-x + badge-x, dy: badge-y, badge)
    place(top + left, dx: (banner-x + title-x) + title-offset-x, dy: (0pt) + title-offset-y, title-box)
    place(top + left, dx: (card-x + body-padding-x) + body-offset-x, dy: (card-y + body-padding-top) + body-offset-y, body-block)
  })
}
