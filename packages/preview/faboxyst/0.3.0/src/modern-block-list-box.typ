// One abstract colored block with an offset icon-and-number tab.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _mbl-cubic(p0, p1, p2, p3, n: 20) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _mbl-main-outline(w, h, rtl: false) = {
  let p = ((0.9596 * w, 0pt), (0.0404 * w, 0pt))
  p += _mbl-cubic(
    (0.0404 * w, 0pt), (0.0181 * w, 0pt),
    (0pt, 0.0624 * h), (0pt, 0.1391 * h),
  ).slice(1)
  p += _mbl-cubic(
    (0pt, 0.1391 * h), (0pt, 0.2168 * h),
    (0.0181 * w, 0.2782 * h), (0.0404 * w, 0.2782 * h),
  ).slice(1)
  p.push((0.2499 * w, 0.2782 * h))
  p += _mbl-cubic(
    (0.2499 * w, 0.2782 * h), (0.2607 * w, 0.2782 * h),
    (0.2710 * w, 0.2930 * h), (0.2785 * w, 0.3191 * h),
  ).slice(1)
  p.push((0.4643 * w, 0.9582 * h))
  p += _mbl-cubic(
    (0.4643 * w, 0.9582 * h), (0.4719 * w, 0.9843 * h),
    (0.4822 * w, h), (0.4928 * w, h),
  ).slice(1)
  p.push((0.9596 * w, h))
  p += _mbl-cubic(
    (0.9596 * w, h), (0.9820 * w, h),
    (w, 0.9376 * h), (w, 0.8610 * h),
  ).slice(1)
  p.push((w, 0.1391 * h))
  p += _mbl-cubic(
    (w, 0.1391 * h), (w, 0.0624 * h),
    (0.9820 * w, 0pt), (0.9596 * w, 0pt),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _mbl-tab-outline(w, h, rtl: false) = {
  let p = ((0pt, 0pt), (0pt, 0.8180 * h))
  p += _mbl-cubic(
    (0pt, 0.8180 * h), (0pt, 0.9191 * h),
    (0.0406 * w, h), (0.0905 * w, h),
  ).slice(1)
  p.push((w, h))
  p.push((w, 0pt))
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

/// One Modern Block List item: a colored text body joined to an offset number-and-icon tab.
/// Draws one editable box only; it does not recreate the source slide's six-item layout.
#let modern-block-list-box(
  title: [],
  body: [],
  number: "01",
  icon: none,
  print-icon: none,
  width: 10cm,
  height: 2.9cm,
  direction: auto,
  colour: rgb("#F9C947"),
  support-colour: auto,
  text-colour: auto,
  number-colour: auto,
  title-size: 13.5pt,
  body-size: 8.4pt,
  number-size: 13pt,
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

  let body-fill = if print-mode { luma(174) } else { colour }
  let tab-fill = if print-mode { luma(218) }
    else if support-colour != auto { support-colour }
    else { rgb("#BFC3C7") }
  let heading-ink = if print-mode { black }
    else if text-colour != auto { text-colour }
    else { rgb("#161616") }
  let copy-ink = if print-mode { luma(28) }
    else if text-colour != auto { text-colour }
    else { rgb("#3D3D3D") }
  let number-ink = if print-mode { black }
    else if number-colour != auto { number-colour }
    else { rgb("#252525") }

  let main-points = _mbl-main-outline(width, height, rtl: rtl)
  let tab-width = width * 0.447
  let tab-height = height * 0.764
  let tab-x = if rtl { width * 0.499 } else { width * 0.054 }
  let tab-y = height * 0.118
  let tab-points = _mbl-tab-outline(tab-width, tab-height, rtl: rtl)
  let tab = polygon(fill: tab-fill, stroke: none, ..tab-points)
  let main = polygon(fill: body-fill, stroke: none, ..main-points)

  let title-x = if rtl { width * 0.045 } else { width * 0.455 }
  let title-width = width * 0.50
  let title-box = box(width: title-width, height: height * 0.31,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let body-box = box(width: title-width, height: height * 0.39,
    align((if rtl { right } else { left }) + top, {
      if rtl { set par(justify: false) } else { set par(justify: false) }
      text(size: body-size, fill: copy-ink, body)
    }))

  let number-x = if rtl { width * 0.815 } else { width * 0.055 }
  let number-box = box(width: width * 0.14, height: height * 0.26,
    align(center + horizon,
      text(size: number-size, weight: "bold", fill: number-ink, number)))
  let icon-width = width * 0.14
  let icon-height = height * 0.46
  let icon-x = if rtl { width * 0.655 } else { width * 0.185 }
  let icon-y = height * 0.49
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: 17pt, weight: "bold", fill: number-ink, [✦]) }
  let icon-box = box(width: icon-width, height: icon-height,
    align(center + horizon, icon-content))

  box(width: width * 1.02, height: height * 1.04, inset: 0pt, {
    place(top + left, dx: tab-x, dy: tab-y, tab)
    place(top + left, dx: 0pt, dy: 0pt, main)
    place(top + left, dx: (title-x) + title-offset-x, dy: (height * 0.135) + title-offset-y, title-box)
    place(top + left, dx: (title-x) + body-offset-x, dy: (height * 0.525) + body-offset-y, body-box)
    place(top + left, dx: (number-x) + number-offset-x, dy: (height * 0.605) + number-offset-y, number-box)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
  })
}
