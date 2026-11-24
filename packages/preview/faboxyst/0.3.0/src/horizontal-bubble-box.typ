// One abstract bubble header with an open, rounded text frame and a swept lower corner.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hbl-cubic(p0, p1, p2, p3, n: 22) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _hbl-bubble-outline(w, h, rtl: false) = {
  let p = ((0.8905 * w, 0.0994 * h), (0.8905 * w, 0.0994 * h))
  p += _hbl-cubic(
    (0.8905 * w, 0.0994 * h), (0.868 * w, 0.0836 * h),
    (0.843 * w, 0.0721 * h), (0.8175 * w, 0.0635 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.8175 * w, 0.0635 * h), (0.669 * w, 0.0104 * h),
    (0.488 * w, -0.0025 * h), (0.332 * w, 0.0004 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.332 * w, 0.0004 * h), (0.204 * w, 0.0018 * h),
    (0.0418 * w, 0.0319 * h), (0.004 * w, 0.1956 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.004 * w, 0.1956 * h), (-0.0213 * w, 0.306 * h),
    (0.0796 * w, 0.3433 * h), (0.1427 * w, 0.3962 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.1427 * w, 0.3962 * h), (0.2082 * w, 0.451 * h),
    (0.2461 * w, 0.5386 * h), (0.2347 * w, 0.6321 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.2347 * w, 0.6321 * h), (0.221 * w, 0.7539 * h),
    (0.1263 * w, 0.9532 * h), (0.2901 * w, 0.9938 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.2901 * w, 0.9938 * h), (0.3964 * w, 1.0196 * h),
    (0.5049 * w, 0.9605 * h), (0.5932 * w, 0.8981 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.5932 * w, 0.8981 * h), (0.6886 * w, 0.828 * h),
    (0.7748 * w, 0.7395 * h), (0.845 * w, 0.636 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.845 * w, 0.636 * h), (0.918 * w, 0.5312 * h),
    (1.015 * w, 0.330 * h), (0.9928 * w, 0.2385 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.9928 * w, 0.2385 * h), (0.9777 * w, 0.1753 * h),
    (0.9395 * w, 0.1309 * h), (0.8905 * w, 0.0994 * h),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _hbl-frame-outline(w, h, rtl: false) = {
  let p = ((0.4543 * w, h), (0.1292 * w, h))
  p += _hbl-cubic(
    (0.1292 * w, h), (0.0574 * w, h),
    (0pt, 0.9729 * h), (0pt, 0.9403 * h),
  ).slice(1)
  p.push((0pt, 0.0030 * h))
  p += _hbl-cubic(
    (0pt, 0.0030 * h), (0pt, 0.0012 * h),
    (0.0026 * w, 0pt), (0.0065 * w, 0pt),
  ).slice(1)
  p += _hbl-cubic(
    (0.0065 * w, 0pt), (0.0104 * w, 0pt),
    (0.0131 * w, 0.0012 * h), (0.0131 * w, 0.0030 * h),
  ).slice(1)
  p.push((0.0131 * w, 0.9403 * h))
  p += _hbl-cubic(
    (0.0131 * w, 0.9403 * h), (0.0131 * w, 0.9699 * h),
    (0.0653 * w, 0.9935 * h), (0.1292 * w, 0.9935 * h),
  ).slice(1)
  p.push((0.4543 * w, 0.9935 * h))
  p += _hbl-cubic(
    (0.4543 * w, 0.9935 * h), (0.7472 * w, 0.9935 * h),
    (0.9869 * w, 0.8837 * h), (0.9869 * w, 0.7481 * h),
  ).slice(1)
  p.push((0.9869 * w, 0.0452 * h))
  p += _hbl-cubic(
    (0.9869 * w, 0.0452 * h), (0.9869 * w, 0.0434 * h),
    (0.9896 * w, 0.0422 * h), (0.9935 * w, 0.0422 * h),
  ).slice(1)
  p += _hbl-cubic(
    (0.9935 * w, 0.0422 * h), (0.9974 * w, 0.0422 * h),
    (w, 0.0434 * h), (w, 0.0452 * h),
  ).slice(1)
  p.push((w, 0.7470 * h))
  p += _hbl-cubic(
    (w, 0.7470 * h), (w, 0.8867 * h),
    (0.755 * w, h), (0.4543 * w, h),
  ).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

#let _hbl-tail-outline(w, h, rtl: false) = {
  let p = ((0pt, h), (0pt, h))
  p += _hbl-cubic(
    (0pt, h), (0pt, h), (0.6101 * w, 0.8202 * h), (w, 0pt),
  ).slice(1)
  p.push((w, 0.4358 * h))
  p += _hbl-cubic(
    (w, 0.4358 * h), (w, 0.7477 * h),
    (0.7477 * w, h), (0.4358 * w, h),
  ).slice(1)
  p.push((0pt, h))
  if rtl { p.map(((x, y)) => (w - x, y)).rev() } else { p }
}

/// One abstract bubble header with a slim open text frame and a swept corner accent.
/// This function draws one box only, not the original four-item horizontal list.
#let horizontal-bubble-box(
  bubble-title: [],
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 4.4cm,
  height: 8.9cm,
  direction: auto,
  colour: rgb("#4CC1EF"),
  bubble-title-colour: auto,
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  tail-colour: auto,
  bubble-title-size: 13.5pt,
  title-size: 14pt,
  body-size: 8.2pt,
  icon-size: 1cm,
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

  let blob-fill = if print-mode { luma(210) } else { colour }
  let frame-fill = if print-mode { luma(148) } else { colour }
  let tail-fill = if print-mode { luma(176) }
    else if tail-colour != auto { tail-colour }
    else { colour.darken(25%) }
  let shadow-fill = if print-mode { luma(122) }
    else if shadow-colour != auto { shadow-colour }
    else { colour.darken(50%) }
  let bubble-heading-ink = if print-mode { luma(12) }
    else if bubble-title-colour != auto { bubble-title-colour }
    else { rgb("#111111") }
  let heading-ink = if print-mode { luma(12) }
    else if title-colour != auto { title-colour }
    else { rgb("#171717") }
  let copy-ink = if print-mode { luma(28) }
    else if text-colour != auto { text-colour }
    else { rgb("#5D6062") }

  let body-origin = if rtl { width * 0.015 } else { width * 0.075 }
  let bubble-width = width * 1.034
  let bubble-height = height * 0.421
  let bubble-x = body-origin + (if rtl { width * 0.018 } else { -width * 0.052 })
  let bubble-y = height * 0.002
  let bubble-points = _hbl-bubble-outline(bubble-width, bubble-height, rtl: rtl)
  let shadow = polygon(fill: shadow-fill, stroke: none, ..bubble-points)
  let blob = polygon(fill: blob-fill, stroke: none, ..bubble-points)

  let frame-points = _hbl-frame-outline(width, height, rtl: rtl)
  let frame = polygon(fill: frame-fill, stroke: none, ..frame-points)
  let tail-width = width * 0.286
  let tail-height = height * 0.132
  let tail-x = body-origin + (if rtl { -width * 0.005 } else { width * 0.719 })
  let tail-y = height * 0.874
  let tail = polygon(fill: tail-fill, stroke: none,
    .._hbl-tail-outline(tail-width, tail-height, rtl: rtl))

  let bubble-title-x = bubble-x + bubble-width * 0.060
  let bubble-title-width = bubble-width * 0.920
  let bubble-title-box = box(width: bubble-title-width, height: bubble-height * 0.27,
    align(center + horizon,
      text(size: bubble-title-size, weight: "bold", fill: bubble-heading-ink, bubble-title)))

  let icon-width = bubble-width * 0.286
  let icon-height = bubble-height * 0.31
  let icon-x = bubble-x + (if rtl { bubble-width * 0.425 } else { bubble-width * 0.295 })
  let icon-y = bubble-y + bubble-height * 0.58
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: icon-size, weight: "bold", fill: if print-mode { black } else { white }, [✦]) }
  let icon-box = box(width: icon-width, height: icon-height,
    align(center + horizon, icon-content))

  let title-x = body-origin + (if rtl { width * 0.07 } else { width * 0.07 })
  let title-width = width * 0.86
  let title-box = box(width: title-width, height: height * 0.12,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy-x = body-origin + width * 0.08
  let copy-width = width * 0.84
  let copy-box = box(width: copy-width, height: height * 0.46,
    align((if rtl { right } else { left }) + top, {
      if rtl { set par(justify: false) } else { set par(justify: true) }
      text(size: body-size, fill: copy-ink, body)
    }))

  box(width: width * 1.09, height: height * 1.194, inset: 0pt, {
    place(top + left, dx: body-origin, dy: height * 0.194, frame)
    place(top + left, dx: tail-x, dy: height * 0.194 + tail-y, tail)
    place(top + left, dx: bubble-x + (if rtl { 0pt } else { -width * 0.006 }),
      dy: bubble-y + bubble-height * 0.058, shadow)
    place(top + left, dx: bubble-x, dy: bubble-y, blob)
    place(top + left, dx: (bubble-title-x) + title-offset-x, dy: (bubble-y + bubble-height * 0.095) + title-offset-y, bubble-title-box)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (height * 0.194 + height * 0.345) + title-offset-y, title-box)
    place(top + left, dx: (copy-x) + body-offset-x, dy: (height * 0.194 + height * 0.490) + body-offset-y, copy-box)
  })
}
