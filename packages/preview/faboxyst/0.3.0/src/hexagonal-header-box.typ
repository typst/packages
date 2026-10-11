// One vertical content block with a notched top and overlapping hexagonal icon head.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hhb-block-outline(w, h) = (
  (0pt, 0pt),
  (0.1277 * w, 0pt),
  (0.1275 * w, 0.0002 * h),
  (0.3118 * w, 0.2206 * h),
  (0.6886 * w, 0.2206 * h),
  (0.8725 * w, 0.0002 * h),
  (0.8723 * w, 0pt),
  (w, 0pt),
  (w, h),
  (0pt, h),
)

#let _hhb-hex-outline(w, h) = (
  (0pt, 0.5005 * h),
  (0.2474 * w, 0pt),
  (0.7534 * w, 0pt),
  (w, 0.5005 * h),
  (0.7534 * w, h),
  (0.2474 * w, h),
)

/// One hexagonal-header block with its inset top notch, large number, heading, and description.
/// Call once for a single component; it does not generate the reference row of four.
#let hexagonal-header-box(
  title: [],
  body: [],
  number: [01],
  icon: none,
  print-icon: none,
  width: 5.2cm,
  height: 7.6cm,
  direction: auto,
  colour: rgb("#F15F47"),
  number-colour: auto,
  title-colour: auto,
  text-colour: auto,
  number-size: 30pt,
  title-size: 17pt,
  body-size: 8.6pt,
  icon-size: 1.25cm,
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

  let block-fill = if print-mode { luma(222) } else { colour }
  let hex-fill = if print-mode { luma(183) } else { colour.darken(25%) }
  let edge = if print-mode { luma(30) } else { none }
  let badge-ink = if print-mode { luma(35) }
    else if number-colour != auto { number-colour }
    else { colour.darken(50%) }
  let heading-ink = if print-mode { luma(15) }
    else if title-colour != auto { title-colour }
    else { white }
  let copy-ink = if print-mode { luma(28) }
    else if text-colour != auto { text-colour }
    else { white }

  let card = polygon(
    fill: block-fill,
    stroke: if print-mode { 0.6pt + edge } else { none },
    .._hhb-block-outline(width, height),
  )
  let hex-width = width * 0.618
  let hex-height = height * 0.368
  let hex-x = width * 0.191
  let hex-points = _hhb-hex-outline(hex-width, hex-height)
  let hexagon = polygon(
    fill: hex-fill,
    stroke: if print-mode { 0.6pt + edge } else { none },
    ..hex-points,
  )

  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: icon-size, weight: "bold", fill: if print-mode { black } else { white }, [✦]) }
  let icon-box = box(width: hex-width * 0.66, height: hex-height * 0.66,
    align(center + horizon, icon-content))

  let number-box = box(width: width * 0.86, height: height * 0.18,
    align(center + horizon,
      text(size: number-size, weight: "bold", fill: badge-ink, number)))
  let title-box = box(width: width * 0.90, height: height * 0.135,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let body-box = box(width: width * 0.84, height: height * 0.40,
    align((if rtl { right } else { left }) + top, {
      if rtl { set par(justify: false) } else { set par(justify: true) }
      text(size: body-size, fill: copy-ink, body)
    }))

  let card-y = height * 0.184
  box(width: width, height: height * 1.184, inset: 0pt, {
    place(top + left, dx: 0pt, dy: card-y, card)
    place(top + left, dx: hex-x, hexagon)
    place(top + left, dx: (hex-x + (hex-width - hex-width * 0.66) / 2) + icon-offset-x, dy: ((hex-height - hex-height * 0.66) / 2) + icon-offset-y, icon-box)
    place(top + left, dx: (width * 0.07) + number-offset-x, dy: (card-y + height * 0.235) + number-offset-y, number-box)
    place(top + left, dx: (width * 0.05) + title-offset-x, dy: (card-y + height * 0.405) + title-offset-y, title-box)
    place(top + left, dx: (width * 0.08) + body-offset-x, dy: (card-y + height * 0.550) + body-offset-y, body-box)
  })
}
