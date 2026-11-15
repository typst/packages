// One reusable parchment-shaped process box with a raised title capsule.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _fpp-cubic(p0, p1, p2, p3, n: 12) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _fpp-outline(w, h, rtl: false) = {
  let p = ((0.9483 * w, 0pt), (0.4346 * w, 0pt))
  p += _fpp-cubic(
    (0.4346 * w, 0pt), (0.2904 * w, 0pt),
    (0.1681 * w, 0.0845 * h), (0.1240 * w, 0.2012 * h),
  ).slice(1)
  p.push((0.0897 * w, 0.2012 * h))
  p += _fpp-cubic(
    (0.0897 * w, 0.2012 * h), (0.0594 * w, 0.2012 * h),
    (0.0347 * w, 0.2236 * h), (0.0347 * w, 0.2509 * h),
  ).slice(1)
  p.push((0.0347 * w, 0.3044 * h))
  p += _fpp-cubic(
    (0.0347 * w, 0.3044 * h), (0.0347 * w, 0.3317 * h),
    (0.0594 * w, 0.3540 * h), (0.0897 * w, 0.3540 * h),
  ).slice(1)
  p += ((0.1062 * w, 0.3540 * h), (0.1062 * w, 0.7031 * h))
  p += _fpp-cubic(
    (0.1062 * w, 0.7031 * h), (0.1062 * w, 0.7874 * h),
    (0.0706 * w, 0.8649 * h), (0.0127 * w, 0.9230 * h),
  ).slice(1)
  p += _fpp-cubic(
    (0.0127 * w, 0.9230 * h), (-0.0161 * w, 0.9528 * h),
    (0.0072 * w, h), (0.0512 * w, h),
  ).slice(1)
  p.push((0.5655 * w, h))
  p += _fpp-cubic(
    (0.5655 * w, h), (0.7469 * w, h),
    (0.8938 * w, 0.8674 * h), (0.8938 * w, 0.7031 * h),
  ).slice(1)
  p += ((0.8938 * w, 0.3540 * h), (0.9104 * w, 0.3540 * h))
  p += _fpp-cubic(
    (0.9104 * w, 0.3540 * h), (0.9405 * w, 0.3540 * h),
    (0.9647 * w, 0.3317 * h), (0.9647 * w, 0.3044 * h),
  ).slice(1)
  p.push((0.9647 * w, 0.2509 * h))
  p += _fpp-cubic(
    (0.9647 * w, 0.2509 * h), (0.9647 * w, 0.2236 * h),
    (0.9405 * w, 0.2012 * h), (0.9104 * w, 0.2012 * h),
  ).slice(1)
  p.push((0.9104 * w, 0.2012 * h))
  p += _fpp-cubic(
    (0.9104 * w, 0.2012 * h), (0.9257 * w, 0.1553 * h),
    (0.9560 * w, 0.1118 * h), (0.9873 * w, 0.0770 * h),
  ).slice(1)
  p += _fpp-cubic(
    (0.9873 * w, 0.0770 * h), (1.0162 * w, 0.0472 * h),
    (0.9929 * w, 0pt), (0.9483 * w, 0pt),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

/// One parchment process box with a wavy silhouette, outlined title capsule, icon and body.
/// This draws a single component; repeat calls yourself if you need a multi-step composition.
#let four-step-parchment-process(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 6cm,
  height: 6.6cm,
  direction: auto,
  dark: false,
  colour: rgb("#F25544"),
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  icon-size: 0.90cm,
  title-size: 10pt,
  body-size: 7.5pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let edge = if print-mode { luma(28) } else { colour.darken(18%) }
  let card-fill = if print-mode { luma(218) } else { colour }
  let capsule-fill = if print-mode { luma(250) } else { white }
  let capsule-edge = if print-mode { luma(25) } else { colour }
  let title-ink = if print-mode { luma(12) }
    else if title-colour != auto { title-colour }
    else { rgb("#171717") }
  let copy-ink = if print-mode { luma(28) }
    else if text-colour != auto { text-colour }
    else { white }
  let shadow-ink = if print-mode { luma(224) }
    else if shadow-colour != auto { shadow-colour }
    else if dark { rgb("#000000").transparentize(62%) }
    else { rgb("#26333A").transparentize(80%) }

  let pad-x = 0.12cm
  let points = _fpp-outline(width, height, rtl: rtl)
  let shadow = polygon(fill: shadow-ink, stroke: none, ..points)
  let card = polygon(
    fill: card-fill,
    stroke: if print-mode { 0.6pt + edge } else { none },
    ..points,
  )

  let capsule-width = width * 0.90
  let capsule-height = height * 0.128
  let capsule = box(
    width: capsule-width,
    height: capsule-height,
    radius: capsule-height * 0.48,
    fill: capsule-fill,
    stroke: 1.5pt + capsule-edge,
    inset: 0pt,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)),
  )

  let icon-width = width * 0.15
  let icon-height = height * 0.15
  let icon-x = if rtl { width * 0.175 } else { width * 0.675 }
  let icon-y = height * 0.035
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: icon-size, weight: "bold", fill: if print-mode { black } else { edge }, [✦]) }
  let icon-box = box(width: icon-width, height: icon-height,
    align(center + horizon, icon-content))

  let copy-width = width * 0.64
  let copy-x = if rtl { width * 0.205 } else { width * 0.155 }
  let copy = box(width: copy-width, height: height * 0.53,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: copy-ink, body)))

  box(width: width + 0.24cm, height: height + 0.12cm, inset: 0pt, {
    place(top + left, dx: pad-x + 0.04cm, dy: 0.07cm, shadow)
    place(top + left, dx: pad-x, card)
    place(top + left, dx: pad-x + width * 0.05, dy: height * 0.215, capsule)
    place(top + left, dx: pad-x + icon-x, dy: icon-y, icon-box)
    place(top + left, dx: pad-x + copy-x, dy: height * 0.405, copy)
  })
}
