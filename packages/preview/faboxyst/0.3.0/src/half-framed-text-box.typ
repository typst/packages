// One content card with opposing upper-left and lower-right half-frames.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hft-cubic(p0, p1, p2, p3, n: 10) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _hft-upper-frame(w, h, rtl: false) = {
  let p = ((0.8157 * w, 0.2045 * h), (0.2338 * w, 0.2045 * h),
    (0.2338 * w, 0.0571 * h))
  p += _hft-cubic(
    (0.2338 * w, 0.0571 * h), (0.2338 * w, 0.0254 * h),
    (0.2133 * w, 0pt), (0.1877 * w, 0pt),
  ).slice(1)
  p.push((0.0461 * w, 0pt))
  p += _hft-cubic(
    (0.0461 * w, 0pt), (0.0205 * w, 0pt),
    (0pt, 0.0254 * h), (0pt, 0.0571 * h),
  ).slice(1)
  p.push((0pt, 0.2327 * h))
  p += _hft-cubic(
    (0pt, 0.2327 * h), (0pt, 0.2644 * h),
    (0.0205 * w, 0.2899 * h), (0.0461 * w, 0.2899 * h),
  ).slice(1)
  p += ((0.0853 * w, 0.2899 * h), (0.0853 * w, 0.9407 * h))
  p += _hft-cubic(
    (0.0853 * w, 0.9407 * h), (0.0853 * w, 0.9730 * h),
    (0.1069 * w, h), (0.1331 * w, h),
  ).slice(1)
  p += ((w, h), (w, 0.4323 * h))
  p += _hft-cubic(
    (w, 0.4323 * h), (w, 0.3068 * h),
    (0.9175 * w, 0.2045 * h), (0.8157 * w, 0.2045 * h),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

/// One half-framed text box: top icon/title, white content card and opposite corner frames.
/// Mirror the corner treatment automatically for RTL, but never composes the reference row of three.
#let half-framed-text-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 4.9cm,
  height: 7.5cm,
  direction: auto,
  colour: rgb("#FFCC4C"),
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  title-size: 13pt,
  body-size: 7.8pt,
  icon-size: 0.48cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let accent = if print-mode { luma(158) } else { colour }
  let card-fill = if print-mode { luma(252) } else { white }
  let title-ink = if print-mode { luma(12) }
    else if title-colour != auto { title-colour }
    else { rgb("#111111") }
  let copy-ink = if print-mode { luma(30) }
    else if text-colour != auto { text-colour }
    else { rgb("#666666") }
  let frame-edge = if print-mode { luma(30) } else { colour }
  let shadow-ink = if print-mode { luma(225) }
    else if shadow-colour != auto { shadow-colour }
    else { rgb("#525252").transparentize(84%) }

  let body-origin = if rtl { width * 0.055 } else { width * 0.150 }
  let pad-y = height * 0.258
  let top-width = width * 1.026
  let top-height = height * 0.540
  let top-x = if rtl { body-origin + width * 0.124 }
    else { body-origin - width * 0.150 }
  let top-points = _hft-upper-frame(top-width, top-height, rtl: rtl)
  let top-frame = polygon(fill: accent, stroke: none, ..top-points)

  let corner-size = width * 0.604
  let corner-x = body-origin + (if rtl { -width * 0.054 } else { width * 0.450 })
  let corner-y = pad-y + height * 0.640
  let corner = box(width: corner-size, height: height * 0.394,
    radius: width * 0.092, fill: accent, inset: 0pt)

  let card-radius = width * 0.047
  let card-shadow = box(width: width, height: height,
    radius: card-radius, fill: shadow-ink, inset: 0pt)
  let card = box(width: width, height: height,
    radius: card-radius,
    fill: card-fill,
    stroke: if print-mode { 0.6pt + frame-edge } else { none },
    inset: 0pt)

  let tile-size = width * 0.157
  let tile-x = body-origin + (if rtl { width * 0.953 } else { -width * 0.110 })
  let tile-y = pad-y - height * 0.229
  let tile = box(width: tile-size, height: tile-size,
    radius: tile-size * 0.20,
    fill: white,
    stroke: 1.6pt + frame-edge,
    inset: 0pt)
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: icon-size, weight: "bold", fill: if print-mode { black } else { colour.darken(30%) }, [✦]) }
  let icon-box = box(width: tile-size * 0.70, height: tile-size * 0.70,
    align(center + horizon, icon-content))

  let title-x = body-origin + (if rtl { width * 0.118 } else { width * 0.062 })
  let title-width = width * 0.820
  let heading = box(width: title-width, height: height * 0.119,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)))
  let copy-x = body-origin + (if rtl { width * 0.127 } else { width * 0.103 })
  let copy-width = width * 0.770
  let copy = box(width: copy-width, height: height * 0.880,
    align((if rtl { right } else { left }) + top, {
      if rtl { set par(justify: false, spacing: 0.12cm) }
      else { set par(justify: true, spacing: 0.12cm) }
      text(size: body-size, fill: copy-ink, body)
    }))

  box(width: width * 1.205, height: height * 1.292, inset: 0pt, {
    place(top + left, dx: top-x, top-frame)
    place(top + left, dx: corner-x, dy: corner-y, corner)
    place(top + left, dx: body-origin + 0.08cm, dy: pad-y + 0.10cm, card-shadow)
    place(top + left, dx: body-origin, dy: pad-y, card)
    place(top + left, dx: tile-x, dy: tile-y, tile)
    place(top + left, dx: (tile-x + tile-size * 0.15) + icon-offset-x, dy: (tile-y + tile-size * 0.15) + icon-offset-y, icon-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (pad-y - height * 0.131) + title-offset-y, heading)
    place(top + left, dx: (copy-x) + body-offset-x, dy: (pad-y + height * 0.050) + body-offset-y, copy)
  })
}
