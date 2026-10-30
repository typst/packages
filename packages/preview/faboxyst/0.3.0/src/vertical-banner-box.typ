// One vertical banner box with its pointed ribbon header and folded edge.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _vbl-arrow-outline(w, h, rtl: false) = {
  let p = (
    (0.8198 * w, 0pt), (0.6587 * w, 0.0021 * h),
    (0.3345 * w, 0.0103 * h), (0.2788 * w, 0.0117 * h),
    (0.2515 * w, 0.0096 * h), (0.2041 * w, 0.0130 * h),
    (0.1625 * w, 0.0192 * h), (0.1270 * w, 0.0288 * h),
    (0.0973 * w, 0.0419 * h), (0.0727 * w, 0.0570 * h),
    (0.0526 * w, 0.0741 * h), (0.0365 * w, 0.0933 * h),
    (0.0242 * w, 0.1112 * h), (0.0150 * w, 0.1297 * h),
    (0.0058 * w, 0.1551 * h), (0pt, 0.1956 * h),
    (0.0003 * w, 0.2018 * h), (0.0003 * w, 0.9869 * h),
    (0.0007 * w, 0.9931 * h), (0.0010 * w, h),
    (0.0031 * w, 0.9801 * h), (0.0106 * w, 0.9451 * h),
    (0.0229 * w, 0.9135 * h), (0.0386 * w, 0.8888 * h),
    (0.0577 * w, 0.8675 * h), (0.0795 * w, 0.8511 * h),
    (0.1147 * w, 0.8325 * h), (0.1396 * w, 0.8250 * h),
    (0.1727 * w, 0.8174 * h), (0.2345 * w, 0.8119 * h),
    (0.2577 * w, 0.8119 * h), (0.4590 * w, 0.8126 * h),
    (0.8198 * w, 0.8133 * h), (w, 0.3878 * h),
  )
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _vbl-fold-outline(w, h, rtl: false) = {
  let p = (
    (0pt, 0.4512 * h), (0.0123 * w, 0.4938 * h),
    (0.0443 * w, 0.5702 * h), (0.0961 * w, 0.6377 * h),
    (0.1576 * w, 0.7016 * h), (0.2685 * w, 0.7798 * h),
    (0.4433 * w, 0.8632 * h), (0.6207 * w, 0.9236 * h),
    (0.7882 * w, 0.9645 * h), (0.9704 * w, 0.9982 * h),
    (w, h), (w, 0pt), (0.8202 * w, 0.0195 * h),
    (0.5665 * w, 0.0675 * h), (0.4089 * w, 0.1101 * h),
    (0.2710 * w, 0.1634 * h), (0.1576 * w, 0.2274 * h),
    (0.0690 * w, 0.3073 * h), (0.0148 * w, 0.3979 * h),
  )
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _vbl-banner-outline(w, h) = (
  (w, 0pt), (w, 0.9055 * h), (0.5 * w, h), (0pt, 0.9055 * h), (0pt, 0pt),
)

/// A single vertical banner: pointed tail, lighter arrow ribbon, number/icon, title and copy.
/// The original five-banner row is intentionally not included; call this once per component.
#let vertical-banner-box(
  title: [],
  body: [],
  number: [01],
  icon: none,
  print-icon: none,
  width: 4cm,
  height: 8cm,
  direction: auto,
  colour: rgb("#F7931F"),
  title-colour: auto,
  text-colour: auto,
  number-colour: auto,
  title-size: 11pt,
  body-size: 7.5pt,
  number-size: 23pt,
  icon-size: 1cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let banner-fill = if print-mode { luma(218) } else { colour }
  let ribbon-fill = if print-mode { luma(245) } else { colour.lighten(40%) }
  let fold-fill = if print-mode { luma(118) } else { colour.darken(50%) }
  let edge = if print-mode { luma(38) } else { none }
  let title-ink = if print-mode { luma(16) }
    else if title-colour != auto { title-colour }
    else { white }
  let body-ink = if print-mode { luma(28) }
    else if text-colour != auto { text-colour }
    else { white }
  let number-ink = if print-mode { luma(12) }
    else if number-colour != auto { number-colour }
    else { colour.darken(40%) }

  let body-origin = if rtl { 0pt } else { width * 0.153 }
  let panel-width = width * 1.096
  let panel-height = height * 0.216
  let panel-x = if rtl { width * 0.057 } else { -width * 0.153 }
  let panel-y = height * 0.042
  let fold-width = width * 0.153
  let fold-height = height * 0.084
  let fold-x = if rtl { width } else { 0pt }
  let fold-y = height * 0.222

  let banner-points = _vbl-banner-outline(width, height)
  let banner = polygon(
    fill: banner-fill,
    stroke: if print-mode { 0.6pt + edge } else { none },
    ..banner-points,
  )
  let panel-points = _vbl-arrow-outline(panel-width, panel-height, rtl: rtl)
  let panel = polygon(
    fill: ribbon-fill,
    stroke: if print-mode { 0.7pt + edge } else { none },
    ..panel-points,
  )
  let fold-points = _vbl-fold-outline(fold-width, fold-height, rtl: rtl)
  let fold = polygon(fill: fold-fill, stroke: none, ..fold-points)

  let badge-width = width * 0.49
  let badge-height = height * 0.25
  let badge-x = body-origin + (if rtl { width * 0.357 } else { width * 0.153 })
  let badge-y = height * 0.008
  let badge-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: number-size, weight: "bold", fill: number-ink, number) }
  let badge = box(width: badge-width, height: badge-height,
    align(center + horizon, badge-content))

  let copy-x = body-origin + width * 0.075
  let copy-width = width * 0.85
  let heading-y = height * 0.300
  let heading = box(width: copy-width, height: height * 0.115,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)))
  let copy = box(width: copy-width, height: height * 0.405,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: body-ink, body)))

  box(width: width * 1.153, height: height, inset: 0pt, {
    place(top + left, dx: body-origin, banner)
    place(top + left, dx: fold-x, dy: fold-y, fold)
    place(top + left, dx: body-origin + panel-x, dy: panel-y, panel)
    place(top + left, dx: badge-x, dy: badge-y, badge)
    place(top + left, dx: (copy-x) + title-offset-x, dy: (heading-y) + title-offset-y, heading)
    place(top + left, dx: (copy-x) + body-offset-x, dy: (height * 0.455) + body-offset-y, copy)
  })
}
