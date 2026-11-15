// One reusable interlocking abstract textbox adapted from PresentationGO.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _iat-cubic(p0, p1, p2, p3, n: 14) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _iat-panel-points(width, height, rtl: false) = {
  // Curved side interlock and rounded base from one source textbox.
  let p = ((width * 0.97745, height * 0.23730),)
  p.push((width * 0.44523, height * 0.00557))
  p += _iat-cubic(
    (width * 0.44523, height * 0.00557),
    (width * 0.42815, height * -0.00158),
    (width * 0.40639, height * -0.00209),
    (width * 0.38926, height * 0.00557),
  )
  p.push((width * 0.02329, height * 0.15964))
  p += _iat-cubic(
    (width * 0.02329, height * 0.15964),
    (width * 0.00931, height * 0.16576),
    (width * 0.00079, height * 0.17600),
    (width * 0.0, height * 0.18700),
  )
  p.push((width * 0.0, height * 0.34240))
  p.push((width * 0.0, height * 0.96530))
  p += _iat-cubic(
    (width * 0.0, height * 0.96530),
    (width * 0.0, height * 0.98460),
    (width * 0.02407, height),
    (width * 0.05282, height),
  )
  p.push((width * 0.72806, height))
  p += _iat-cubic(
    (width * 0.72806, height),
    (width * 0.75759, height),
    (width * 0.78088, height * 0.98410),
    (width * 0.78088, height * 0.96530),
  )
  p.push((width * 0.78088, height * 0.40600))
  p += _iat-cubic(
    (width * 0.78088, height * 0.40600),
    (width * 0.78088, height * 0.38770),
    (width * 0.79407, height * 0.37140),
    (width * 0.81662, height * 0.36170),
  )
  p.push((width * 0.97745, height * 0.29330))
  p += _iat-cubic(
    (width * 0.97745, height * 0.29330),
    (width * 0.99143, height * 0.28720),
    (width, height * 0.27690),
    (width, height * 0.26500),
  )
  p += _iat-cubic(
    (width, height * 0.26500),
    (width, height * 0.25310),
    (width * 0.99143, height * 0.24200),
    (width * 0.97745, height * 0.23730),
  )
  if rtl { p.map(((x, y)) => (width - x, y)) } else { p }
}

#let _iat-banner-points(width, height, rtl: false) = {
  let p = ((width * 0.8100, height),)
  p.push((width * 0.0, height * 0.20140))
  p.push((width * 0.1962, height * 0.01096))
  p += _iat-cubic(
    (width * 0.1962, height * 0.01096),
    (width * 0.2114, height * -0.00367),
    (width * 0.2310, height * -0.00367),
    (width * 0.2451, height * 0.01096),
  )
  p.push((width * 0.9829, height * 0.73795))
  p += _iat-cubic(
    (width * 0.9829, height * 0.73795),
    (width, height * 0.76070),
    (width, height * 0.80950),
    (width * 0.9829, height * 0.83225),
  )
  p.push((width * 0.8100, height))
  if rtl { p.map(((x, y)) => (width - x, y)) } else { p }
}

#let _iat-traffic-icon(size, ink) = {
  let housing = rect(width: size * 0.44, height: size * 0.82,
    radius: size * 0.07, fill: ink.transparentize(36%),
    stroke: (paint: ink, thickness: 0.8pt))
  let bulb = size * 0.15
  let light-a = ellipse(width: bulb, height: bulb, fill: ink)
  let light-b = ellipse(width: bulb, height: bulb, fill: ink.lighten(22%))
  let light-c = ellipse(width: bulb, height: bulb, fill: ink.lighten(38%))
  box(width: size, height: size, {
    place(top + left, dx: size * 0.28, dy: size * 0.08, housing)
    place(top + left, dx: size * 0.425, dy: size * 0.18, light-a)
    place(top + left, dx: size * 0.425, dy: size * 0.42, light-b)
    place(top + left, dx: size * 0.425, dy: size * 0.66, light-c)
  })
}

/// Draw one interlocking textbox with a diagonal title banner, icon, and copy.
/// Only one of the source's five boxes is emitted; the full row/slide is omitted.
#let interlocked-abstract-textbox(
  title: [LOREM IPSUM],
  body: [],
  icon: none,
  print-icon: none,
  width: 6.2cm,
  height: auto,
  min-height: 9.5cm,
  direction: auto,
  body-direction: auto,
  colour: rgb("#E44724"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  shadow-colour: auto,
  title-size: 12pt,
  body-size: 8.4pt,
  body-width: 0.72,
  body-start: 0.37,
  bottom-padding: 0.42cm,
  banner-angle: 32deg,
  shadow-offset: 0.08cm,
  shadow: false,
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
  let title-dir = if rtl { std.rtl } else { std.ltr }
  let body-dir = if body-rtl { std.rtl } else { std.ltr }

  let panel-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { rgb("#07384F") }
  let panel-edge = if print-mode { (paint: luma(75), thickness: 0.8pt) } else { none }
  let banner-fill = if print-mode { luma(205) } else { colour }
  let title-ink = if print-mode { luma(18) }
    else if title-colour != auto { title-colour }
    else { rgb("#152A34") }
  let body-ink = if print-mode { luma(35) }
    else if text-colour != auto { text-colour }
    else { white }
  let icon-ink = if print-mode { luma(75) }
    else if icon-colour != auto { icon-colour }
    else { rgb("#D3DEE1") }
  let shadow-ink = if shadow-colour != auto { shadow-colour } else { rgb("#14242C") }
  let shadow-fill = if print-mode { luma(226) } else { shadow-ink.transparentize(82%) }

  let body-content = {
    set par(leading: 0.35em, spacing: 0.48em, justify: false)
    text(dir: body-dir, size: body-size, fill: body-ink, body)
  }
  let body-content-width = width * body-width
  let body-measure = measure(body-content, width: body-content-width)
  let available-ratio = 1 - body-start
  let measured-height = (body-measure.height + bottom-padding) / available-ratio
  let final-height = if height == auto { calc.max(min-height, measured-height) }
    else { calc.max(height, measured-height) }

  let panel-points = _iat-panel-points(width, final-height, rtl: rtl)
  let panel = polygon(fill: panel-fill, stroke: panel-edge, ..panel-points)
  let panel-shadow = polygon(fill: shadow-fill, stroke: none, ..panel-points)
  let banner-width = width * 0.72
  let banner-height = final-height * 0.315
  let banner-x = if rtl { width * 0.02 } else { width * 0.26 }
  let banner-y = final-height * 0.02
  let banner = polygon(fill: banner-fill, stroke: none,
    .._iat-banner-points(banner-width, banner-height, rtl: rtl))
  let title-box = box(width: banner-width * 0.94, height: 0.48cm,
    align(center + horizon,
      text(dir: title-dir, size: title-size, weight: "bold", fill: title-ink, title)))
  let rotated-title = rotate(if rtl { -banner-angle } else { banner-angle },
    origin: center + horizon, title-box)
  let title-x = banner-x + banner-width * 0.03
  let title-y = banner-y + banner-height * 0.42

  let icon-size = width * 0.25
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { _iat-traffic-icon(icon-size * 0.70, icon-ink) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center + horizon, icon-content))
  let icon-x = if rtl { width * 0.63 } else { width * 0.06 }
  let icon-y = final-height * 0.14
  let text-width = body-content-width
  let body-x = if rtl { width - text-width } else { 0pt }
  let body-y = final-height * body-start
  let body-box = box(width: text-width,
    height: final-height - body-y - bottom-padding,
    align(center + top, body-content))

  box(width: width + shadow-offset, height: final-height + shadow-offset,
    inset: 0pt, {
      if shadow {
        place(top + left, dx: shadow-offset, dy: shadow-offset, panel-shadow)
      }
      place(top + left, dx: 0pt, dy: 0pt, panel)
      place(top + left, dx: banner-x, dy: banner-y, banner)
      place(top + left, dx: (title-x) + title-offset-x, dy: (title-y) + title-offset-y, rotated-title)
      place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
      place(top + left, dx: (body-x) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
    })
}
