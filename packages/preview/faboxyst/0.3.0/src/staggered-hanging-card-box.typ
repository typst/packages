// One rectangular information card suspended from a string and binder clip.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single hanging card with an inset white frame, top string, and clip.
/// Draws one card only; it does not reproduce the source's staggered four-card arrangement.
#let staggered-hanging-card-box(
  title: [],
  body: [],
  clip: none,
  print-clip: none,
  width: 5.4cm,
  height: 6.3cm,
  direction: auto,
  card-colour: rgb("#EF604C"),
  title-colour: auto,
  text-colour: auto,
  string-colour: rgb("#808184"),
  title-size: 15pt,
  body-size: 8.8pt,
  clip-width: 0.64cm,
  clip-height: 0.72cm,
  string-length: 1.05cm,
  frame-inset: 0.12cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { std.ltr })

  let fill = if print-mode { luma(210) } else { card-colour }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { white }
  let copy-ink = if print-mode { luma(28) }
    else if text-colour != auto { text-colour }
    else { white }
  let border-width = if print-mode { 0.14cm } else { frame-inset }
  let face-width = width - border-width * 2
  let face-height = height - border-width * 2
  let card-x = (width + 0.30cm - width) / 2
  let card-y = string-length + 0.42cm
  let clip-y = card-y - clip-height * 0.64
  let clip-x = (width - clip-width) / 2
  let overall-width = width + 0.30cm
  let overall-height = card-y + height + 0.10cm
  let center-x = overall-width / 2

  let card-shadow = box(width: width, height: height,
    fill: rgb("#52565A").transparentize(79%), inset: 0pt)
  let card-frame = box(width: width, height: height,
    fill: white, inset: 0pt,
    stroke: if print-mode { (paint: luma(165), thickness: 0.6pt) } else { none })
  let colored-face = box(width: face-width, height: face-height,
    fill: fill, inset: 0pt)
  let title-box = box(width: face-width * 0.82, height: height * 0.14,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let body-box = box(width: face-width * 0.82, height: height * 0.66,
    align((if rtl { right } else { left }) + top, {
      set par(justify: false)
      text(size: body-size, fill: copy-ink, body)
    }))

  let cord = line(start: (center-x, 0pt), end: (center-x, clip-y + clip-height * 0.30),
    stroke: (paint: if print-mode { luma(110) } else { string-colour }, thickness: 0.7pt))
  let clip-content = if print-mode and print-clip != none { print-clip }
    else if clip != none { clip }
    else {
      let dark = if print-mode { rgb("#353535") } else { rgb("#292A2D") }
      box(width: clip-width * 0.82, height: clip-height * 0.66,
        radius: 0.035cm, fill: dark)
    }
  let clip-box = box(width: clip-width, height: clip-height,
    align(center + horizon, clip-content))

  box(width: overall-width, height: overall-height, inset: 0pt, {
    place(top + left, dx: 0pt, dy: 0pt, cord)
    if not print-mode {
      place(top + left, dx: card-x + 0.07cm, dy: card-y + 0.10cm, card-shadow)
    }
    place(top + left, dx: card-x, dy: card-y, card-frame)
    place(top + left, dx: card-x + border-width, dy: card-y + border-width, colored-face)
    place(top + left, dx: (card-x + border-width + face-width * 0.09) + title-offset-x, dy: (card-y + border-width + face-height * 0.075) + title-offset-y, title-box)
    place(top + left, dx: (card-x + border-width + face-width * 0.09) + body-offset-x, dy: (card-y + border-width + face-height * 0.22) + body-offset-y, body-box)
    place(top + left, dx: clip-x, dy: clip-y, clip-box)
  })
}
