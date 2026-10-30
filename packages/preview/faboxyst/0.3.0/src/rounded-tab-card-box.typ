// One Rounded Tab Card: a diagonal-round header, icon disc, and outlined body.
// Visual reference: https://www.presentationgo.com/presentation/rounded-tab-cards-powerpoint/
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _rtc-cubic(p0, p1, p2, p3, n: 14) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _rtc-body-points(w, h, radius, rtl: false) = {
  let k = 0.55228475
  let top-depth = h * 0.085
  let top-end = w * 0.181
  let points = ((0pt, 0pt),)
  points += _rtc-cubic((0pt, 0pt), (w * 0.05, h * 0.056),
    (w * 0.112, top-depth), (top-end, top-depth))
  points.push((w, top-depth))
  points.push((w, h - radius))
  points += _rtc-cubic((w, h - radius),
    (w, h - radius + k * radius),
    (w - radius + k * radius, h),
    (w - radius, h))
  points.push((radius, h))
  points += _rtc-cubic((radius, h),
    (radius - k * radius, h),
    (0pt, h - radius + k * radius),
    (0pt, h - radius))
  points.push((0pt, 0pt))
  if rtl { points.map(((x, y)) => (w - x, y)).rev() } else { points }
}

/// Draw one Rounded Tab Card with an icon-bearing curved header and outlined copy panel.
/// This is a single reusable box, adapted from PresentationGO's three-card design.
#let rounded-tab-card-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 6cm,
  body-height: 5.0cm,
  header-height: 2.18cm,
  direction: auto,
  colour: rgb("#F15F47"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  title-size: 13pt,
  body-size: 9pt,
  icon-size: 0.72cm,
  icon-disc-size: 1.42cm,
  body-inset: 0.40cm,
  corner-radius: 0.48cm,
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

  let accent = if print-mode { luma(172) } else { colour }
  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { white }
  let body-ink = if print-mode { luma(48) }
    else if text-colour != auto { text-colour }
    else { rgb("#5D6064") }
  let disc-fill = if print-mode { luma(230) } else { colour.lighten(39%) }
  let edge = if print-mode { (paint: luma(100), thickness: 0.75pt) }
    else { (paint: accent, thickness: 1.25pt) }

  let radius = calc.min(corner-radius, body-height * 0.16, width * 0.12)
  let body-points = _rtc-body-points(width, body-height, radius, rtl: rtl)
  let body-panel = polygon(fill: face-fill, stroke: edge, ..body-points)
  let corner-pair = if rtl {
    (top-left: corner-radius, top-right: 0pt,
      bottom-left: 0pt, bottom-right: corner-radius)
  } else {
    (top-left: 0pt, top-right: corner-radius,
      bottom-left: corner-radius, bottom-right: 0pt)
  }
  let header = box(width: width, height: header-height,
    radius: corner-pair, fill: accent,
    stroke: if print-mode { edge } else { (paint: accent, thickness: 1.25pt) },
    inset: 0pt)

  let disc-size = icon-disc-size
  let disc-x = if rtl { width - disc-size - width * 0.06 } else { width * 0.06 }
  let disc-y = (header-height - disc-size) / 2
  let disc = ellipse(width: disc-size, height: disc-size,
    fill: disc-fill, inset: 0pt)
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: 22pt, weight: "bold", fill: title-ink, [✦]) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center, icon-content))
  let icon-x = disc-x + (disc-size - icon-size) / 2
  let icon-y = (header-height - icon-size) / 2

  let title-x = if rtl { width * 0.05 } else { width * 0.37 }
  let title-width = if rtl { width * 0.59 } else { width * 0.58 }
  let heading = box(width: title-width, height: header-height,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)))

  let copy = box(width: width - 2 * body-inset, height: body-height * 0.69,
    align(center, {
      set par(justify: false, leading: 1.18em)
      text(size: body-size, fill: body-ink, body)
    }))
  let body-y = header-height - 0.01cm
  let copy-y = header-height + body-height * 0.17

  box(width: width, height: header-height + body-height, inset: 0pt, {
    place(top + left, dx: (0pt) + body-offset-x, dy: (body-y) + body-offset-y, body-panel)
    place(top + left, dx: 0pt, dy: 0pt, header)
    place(top + left, dx: disc-x, dy: disc-y, disc)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (0pt) + title-offset-y, heading)
    place(top + left, dx: (body-inset) + body-offset-x, dy: (copy-y) + body-offset-y, copy)
  })
}
