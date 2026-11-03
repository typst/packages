// One clean horizontal information card with a vertical accent rule.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single wide information card with a slim edge accent and soft shadow.
/// Draws one box only, not the source's six-card grid.
#let two-column-information-card(
  title: [],
  body: [],
  width: 9.8cm,
  height: 2.3cm,
  direction: auto,
  accent-colour: rgb("#1AA1B2"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  title-size: 13pt,
  body-size: 8.4pt,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { std.ltr })

  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let accent-fill = if print-mode { luma(125) } else { accent-colour }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#142236") }
  let copy-ink = if print-mode { luma(32) }
    else if text-colour != auto { text-colour }
    else { rgb("#56616E") }

  let stripe-width = width * 0.027
  let stripe-x = if rtl { width - stripe-width } else { 0pt }
  let text-x = if rtl { width * 0.075 } else { width * 0.080 }
  let text-width = width * 0.86
  let heading-box = box(width: text-width, height: height * 0.26,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let body-box = box(width: text-width, height: height * 0.43,
    align((if rtl { right } else { left }) + top, {
      set par(justify: false)
      text(size: body-size, fill: copy-ink, body)
    }))

  let face = box(width: width, height: height, fill: face-fill, inset: 0pt,
    stroke: if print-mode { (paint: luma(185), thickness: 0.45pt) } else { none })
  let stripe = box(width: stripe-width, height: height, fill: accent-fill, inset: 0pt)
  let shadow-a = box(width: width, height: height,
    fill: rgb("#67727D").transparentize(90%), inset: 0pt)
  let shadow-b = box(width: width, height: height,
    fill: rgb("#67727D").transparentize(94%), inset: 0pt)

  box(width: width + 0.13cm, height: height + 0.15cm, inset: 0pt, {
    if shadow and not print-mode {
      place(top + left, dx: 0.045cm, dy: 0.055cm, shadow-b)
      place(top + left, dx: 0.075cm, dy: 0.095cm, shadow-a)
    }
    place(top + left, dx: 0pt, dy: 0pt, face)
    place(top + left, dx: stripe-x, dy: 0pt, stripe)
    place(top + left, dx: (text-x) + title-offset-x, dy: (height * 0.085) + title-offset-y, heading-box)
    place(top + left, dx: (text-x) + body-offset-x, dy: (height * 0.44) + body-offset-y, body-box)
  })
}
