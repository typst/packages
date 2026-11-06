// One reusable text box with a raised folder shoulder and an S-shaped icon inset.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ftb-cubic(p0, p1, p2, p3, n: 12) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _ftb-folder-outline(w, h, rtl: false) = {
  let p = ((0.3686 * w, 0.1292 * h), (0.3244 * w, 0.0297 * h))
  p += _ftb-cubic(
    (0.3244 * w, 0.0297 * h),
    (0.3165 * w, 0.0111 * h),
    (0.3014 * w, 0pt),
    (0.2848 * w, 0pt),
  ).slice(1)
  p.push((0.0454 * w, 0pt))
  p += _ftb-cubic(
    (0.0454 * w, 0pt), (0.0202 * w, 0pt), (0pt, 0.0260 * h),
    (0pt, 0.0586 * h),
  ).slice(1)
  p.push((0pt, 0.9414 * h))
  p += _ftb-cubic(
    (0pt, 0.9414 * h), (0pt, 0.9731 * h),
    (0.0202 * w, h), (0.0454 * w, h),
  ).slice(1)
  p.push((0.9546 * w, h))
  p += _ftb-cubic(
    (0.9546 * w, h), (0.9798 * w, h),
    (w, 0.9731 * h), (w, 0.9414 * h),
  ).slice(1)
  p.push((w, 0.2184 * h))
  p += _ftb-cubic(
    (w, 0.2184 * h), (w, 0.1841 * h),
    (0.9798 * w, 0.1599 * h), (0.9546 * w, 0.1599 * h),
  ).slice(1)
  p.push((0.4074 * w, 0.1599 * h))
  p += _ftb-cubic(
    (0.4074 * w, 0.1599 * h), (0.3908 * w, 0.1589 * h),
    (0.3756 * w, 0.1478 * h), (0.3686 * w, 0.1292 * h),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _ftb-icon-outline(w, h, rtl: false) = {
  let p = ((0.7147 * w, 0.2294 * h), (0.5361 * w, 0.2105 * h))
  p += _ftb-cubic(
    (0.5361 * w, 0.2105 * h), (0.2100 * w, 0.1748 * h),
    (0pt, 0.0924 * h), (0pt, 0pt),
  ).slice(1)
  p.push((0pt, h))
  p += _ftb-cubic(
    (0pt, h), (0pt, 0.9076 * h),
    (0.2131 * w, 0.8252 * h), (0.5361 * w, 0.7895 * h),
  ).slice(1)
  p.push((0.7147 * w, 0.7706 * h))
  p += _ftb-cubic(
    (0.7147 * w, 0.7706 * h), (0.8871 * w, 0.7517 * h),
    (w, 0.7082 * h), (w, 0.6593 * h),
  ).slice(1)
  p.push((w, 0.3407 * h))
  p += _ftb-cubic(
    (w, 0.3407 * h), (0.9969 * w, 0.2930 * h),
    (0.8871 * w, 0.2483 * h), (0.7147 * w, 0.2294 * h),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

/// One folder text box with the source's raised tab, long side wave, number and copy.
/// Use several calls to compose a row; this function draws one component only.
#let folder-text-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  number: none,
  width: 7cm,
  height: 5.42cm,
  direction: auto,
  dark: false,
  colour: rgb("#F7931E"),
  icon-panel-colour: auto,
  title-colour: auto,
  number-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  icon-panel-width: auto,
  content-width: auto,
  content-start: auto,
  icon-size: 1.30cm,
  number-size: 18pt,
  title-size: 16pt,
  body-size: 7.5pt,
  title-y: auto,
  title-height: auto,
  body-y: auto,
  body-height: auto,
  number-y: auto,
  number-width: auto,
  number-height: auto,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let panel-width = if icon-panel-width == auto { width * 0.231 } else { icon-panel-width }
  let copy-width = if content-width == auto { width * 0.67 } else { content-width }
  let copy-x = if content-start != auto { content-start }
    else if rtl { width * 0.05 }
    else { width * 0.285 }
  let heading-y = if title-y == auto { height * 0.265 } else { title-y }
  let heading-h = if title-height == auto { height * 0.14 } else { title-height }
  let copy-y = if body-y == auto { height * 0.435 } else { body-y }
  let copy-h = if body-height == auto { height * 0.48 } else { body-height }
  let num-w = if number-width == auto { width * 0.20 } else { number-width }
  let num-h = if number-height == auto { height * 0.21 } else { number-height }
  let num-x = if rtl { width * 0.72 } else { width * 0.08 }
  let num-y = if number-y == auto { height * 0.015 } else { number-y }

  let card-fill = if print-mode { luma(216) } else { colour }
  let icon-fill = if print-mode { luma(239) }
    else if icon-panel-colour != auto { icon-panel-colour }
    else { colour.lighten(40%) }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#111111") }
  let number-ink = if print-mode { black }
    else if number-colour != auto { number-colour }
    else { rgb("#111111") }
  let copy-ink = if print-mode { luma(25) }
    else if text-colour != auto { text-colour }
    else { rgb("#4A4540") }
  let shadow-ink = if print-mode { luma(222) }
    else if shadow-colour != auto { shadow-colour }
    else if dark { rgb("#000000").transparentize(66%) }
    else { rgb("#28323A").transparentize(78%) }

  let outline-points = _ftb-folder-outline(width, height, rtl: rtl)
  let shadow-shape = polygon(fill: shadow-ink, stroke: none, ..outline-points)
  let card = polygon(fill: card-fill, stroke: none, ..outline-points)
  let icon-width = panel-width
  let icon-height = height * 0.836
  let icon-y = height * 0.102
  let icon-points = _ftb-icon-outline(icon-width, icon-height, rtl: rtl)
  let icon-shape = polygon(fill: icon-fill, stroke: none, ..icon-points)
  let icon-x = if rtl { width - icon-width } else { 0pt }
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: icon-size, weight: "bold", fill: if print-mode { black } else { rgb("#5A4A29") }, [✦]) }
  let icon-box = box(width: icon-width, height: icon-height,
    align(center + horizon, icon-content))
  let number-box = if number == none { none } else {
    box(width: num-w, height: num-h,
      align(center + horizon,
        text(size: number-size, weight: "bold", fill: number-ink, number)))
  }
  let heading = box(width: copy-width, height: heading-h,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)))
  let copy = box(width: copy-width, height: copy-h,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: copy-ink, body)))

  box(width: width + 0.13cm, height: height + 0.13cm, inset: 0pt, {
    place(top + left, dx: 0.08cm, dy: 0.10cm, shadow-shape)
    place(top + left, card)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-shape)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    if number-box != none {
      place(top + left, dx: (num-x) + number-offset-x, dy: (num-y) + number-offset-y, number-box)
    }
    place(top + left, dx: (copy-x) + title-offset-x, dy: (heading-y) + title-offset-y, heading)
    place(top + left, dx: (copy-x) + body-offset-x, dy: (copy-y) + body-offset-y, copy)
  })
}
