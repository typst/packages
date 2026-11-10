// One white card with an overlapping rising diagonal title ribbon.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _dbc-banner-points(w, h, rtl: false) = {
  let p = (
    (0.718 * w, 0pt), (w, 0pt), (w, 0.168 * h),
    (0pt, 0.365 * h), (-0.102 * w, 0.385 * h),
    (-0.218 * w, 0.184 * h), (0pt, 0.141 * h),
  )
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

/// One Diagonal Banner Card with a number, icon, tilted title, and three text points.
/// This draws one box only, not the source's four-card row.
#let diagonal-banner-card-box(
  title: [],
  items: (),
  number: "01",
  icon: none,
  print-icon: none,
  width: 4.8cm,
  height: 6.8cm,
  direction: auto,
  colour: rgb("#EF604C"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  number-colour: auto,
  title-size: 13pt,
  body-size: 8.3pt,
  number-size: 12pt,
  icon-size: 0.82cm,
  banner-tilt: 19deg,
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
  set text(dir: if rtl { std.rtl } else { std.ltr })

  let ribbon-fill = if print-mode { luma(176) } else { colour }
  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#151515") }
  let body-ink = if print-mode { luma(38) }
    else if text-colour != auto { text-colour }
    else { rgb("#5A5A5A") }
  let number-ink = if print-mode { black }
    else if number-colour != auto { number-colour }
    else { rgb("#1B1B1B") }

  let stage-width = width * 1.44
  let stage-height = height + 0.14cm
  let card-x = if rtl { width * 0.11 } else { width * 0.33 }
  let face = box(width: width, height: height, fill: face-fill, inset: 0pt,
    stroke: if print-mode { (paint: luma(180), thickness: 0.45pt) } else { none })
  let shadow = box(width: width, height: height,
    fill: rgb("#68727B").transparentize(82%), inset: 0pt)
  let banner-points = _dbc-banner-points(width, height, rtl: rtl)
  let banner-shadow-points = banner-points.map(((x, y)) => (x, y + height * 0.012))
  let banner-shadow = polygon(fill: if print-mode { luma(140) } else { colour.darken(28%) },
    stroke: none, ..banner-shadow-points)
  let banner = polygon(fill: ribbon-fill, stroke: none, ..banner-points)

  let number-x = if rtl { width * 0.78 } else { width * 0.035 }
  let number-box = box(width: width * 0.18, height: height * 0.095,
    align((if rtl { right } else { left }) + horizon,
      text(size: number-size, weight: "bold", fill: number-ink, number)))

  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: 18pt, weight: "bold", fill: number-ink, [✦]) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center, icon-content))
  let icon-x = if rtl { width * 0.105 } else { width * 0.745 }
  let icon-y = height * 0.010

  let title-box = box(width: width * 0.77, height: height * 0.13,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let title-x = if rtl { width * 0.275 } else { -width * 0.045 }
  let title-y = height * 0.145
  let title-angle = if rtl { banner-tilt } else { -banner-tilt }

  let bullet-rows = items.map(item => if rtl {
    grid(columns: (0.19cm, 1fr), column-gutter: 0.08cm,
      align(center + top, text(size: body-size, fill: body-ink, [•])),
      text(size: body-size, fill: body-ink, item))
  } else {
    grid(columns: (0.19cm, 1fr), column-gutter: 0.08cm,
      align(center + top, text(size: body-size, fill: body-ink, [•])),
      text(size: body-size, fill: body-ink, item))
  })
  let body-content = stack(dir: ttb, spacing: 0.15cm, ..bullet-rows)
  let body-box = box(width: width * 0.88, height: height * 0.52,
    align((if rtl { right } else { left }) + top, body-content))
  let body-x = if rtl { width * 0.06 } else { width * 0.055 }
  let body-y = height * 0.435

  box(width: stage-width, height: stage-height, inset: 0pt, {
    if not print-mode {
      place(top + left, dx: card-x + 0.07cm, dy: 0.10cm, shadow)
    }
    place(top + left, dx: card-x, dy: 0pt, face)
    place(top + left, dx: card-x, dy: 0pt, banner-shadow)
    place(top + left, dx: card-x, dy: 0pt, banner)
    place(top + left, dx: (card-x + number-x) + number-offset-x, dy: (height * 0.027) + number-offset-y, number-box)
    place(top + left, dx: (card-x + icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    place(top + left, dx: (card-x + title-x) + title-offset-x, dy: (title-y) + title-offset-y, rotate(title-angle, origin: center, reflow: false, title-box))
    place(top + left, dx: (card-x + body-x) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
  })
}
