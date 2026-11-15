// One upright rounded card layered over a tilted, colored backplate.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single Card List item with a tilted colored deck behind the front card.
/// This draws one box only, not the source's four-card comparison row.
#let card-list-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 4.8cm,
  height: 6.8cm,
  direction: auto,
  backplate-colour: rgb("#FFC943"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  title-size: 13.5pt,
  body-size: 7.8pt,
  icon-size: 1.65cm,
  corner-radius: 0.30cm,
  tilt: 12deg,
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

  let deck-fill = if print-mode { luma(184) } else { backplate-colour }
  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#171717") }
  let copy-ink = if print-mode { luma(35) }
    else if text-colour != auto { text-colour }
    else { rgb("#595959") }

  let stage-width = width * 1.35
  let stage-height = height * 1.16
  let deck-width = width * 0.93
  let deck-height = height * 0.965
  let deck-x = (stage-width - deck-width) / 2
  let deck-y = (stage-height - deck-height) / 2
  let card-x = (stage-width - width) / 2
  let card-y = (stage-height - height) / 2

  let deck = box(width: deck-width, height: deck-height,
    radius: corner-radius * 0.8, fill: deck-fill, inset: 0pt)
  let face-shadow = box(width: width, height: height,
    radius: corner-radius, fill: rgb("#66717C").transparentize(77%), inset: 0pt)
  let face = box(width: width, height: height,
    radius: corner-radius, fill: face-fill, inset: 0pt,
    stroke: if print-mode { (paint: luma(180), thickness: 0.5pt) } else { none })

  let title-box = box(width: width * 0.84, height: height * 0.15,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let body-box = box(width: width * 0.80, height: height * 0.47,
    align((if rtl { right } else { left }) + top, {
      set par(justify: false)
      text(size: body-size, fill: copy-ink, body)
    }))
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: 20pt, weight: "bold", fill: deck-fill, [✦]) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center, icon-content))

  let deck-tilt = if rtl { tilt } else { -tilt }
  let card-body-x = card-x + width * 0.08
  let card-body-y = card-y + height * 0.20
  let card-icon-x = card-x + (width - icon-size) / 2
  let card-icon-y = card-y + height * 0.715

  box(width: stage-width, height: stage-height, inset: 0pt, {
    place(top + left, dx: deck-x, dy: deck-y,
      rotate(deck-tilt, origin: center, reflow: false, deck))
    if not print-mode {
      place(top + left, dx: card-x + 0.055cm, dy: card-y + 0.085cm, face-shadow)
    }
    place(top + left, dx: card-x, dy: card-y, face)
    place(top + left, dx: (card-x + width * 0.08) + title-offset-x, dy: (card-y + height * 0.035) + title-offset-y, title-box)
    place(top + left, dx: (card-body-x) + body-offset-x, dy: (card-body-y) + body-offset-y, body-box)
    place(top + left, dx: (card-icon-x) + icon-offset-x, dy: (card-icon-y) + icon-offset-y, icon-box)
  })
}
