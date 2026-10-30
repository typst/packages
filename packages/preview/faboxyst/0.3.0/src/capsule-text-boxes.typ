// Floating capsule cards with a swept gray header and custom curved seam.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ctb-cubic(p0, p1, p2, p3, n: 24) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _ctb-top-art(width, height, left-depth, right-depth, face-colour,
                  seam-width, print-mode) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = height / 1cm
  let r = calc.min(1.02, w / 2, h / 2)
  // Use the preferred sweep direction in both layouts; RTL mirrors the cards
  // and text flow but keeps this curve orientation for visual consistency.
  let left = right-depth
  let right = left-depth
  let start = (0, -left)
  let p1 = (w * 0.30, -left + 0.42)
  let p2 = (w * 0.72, -right - 0.18)
  let end = (w, -right)
  let curve = (start,) + _ctb-cubic(start, p1, p2, end)
  let points = ((r, 0), (w - r, 0))
  points += _ctb-cubic((w - r, 0), (w - r * 0.45, 0),
    (w, -r * 0.45), (w, -r)).slice(1)
  points.push((w, -right))
  points += curve.rev().slice(1)
  points.push((0, -r))
  points += _ctb-cubic((0, -r), (0, -r * 0.45),
    (r * 0.45, 0), (r, 0)).slice(1)
  draw.line(..points, close: true, fill: face-colour, stroke: none)
  if print-mode {
    let offset = (seam-width / 1cm) / 2 + 0.018
    let cap-edge = curve.map(((x, y)) => (x, y + offset))
    let body-edge = curve.map(((x, y)) => (x, y - offset))
    draw.line(..cap-edge,
      stroke: (paint: rgb("#707070"), thickness: 0.55pt, cap: "round", join: "round"))
    draw.line(..body-edge,
      stroke: (paint: rgb("#707070"), thickness: 0.55pt, cap: "round", join: "round"))
  }
  draw.line(..curve,
    stroke: (paint: white, thickness: seam-width, cap: "round", join: "round"))
})

#let _ctb-card(
  step, index, card-width, height, rtl, print-mode, colours,
  title-size, body-size, number-size, icon-size, seam-width,
) = {
  let pair = colours.at(calc.rem(index, colours.len()))
  let face-colour = if "colour" in step { step.at("colour") } else { pair.at(0) }
  let default-title = pair.at(1)
  let background = if print-mode { white } else { face-colour }
  let top-fill = if print-mode { luma(224) } else { rgb("#BDBDBD") }
  let text-ink = if print-mode { black }
    else if "text-colour" in step { step.at("text-colour") }
    else { default-title }
  let title-ink = if print-mode { black }
    else if "title-colour" in step { step.at("title-colour") }
    else { text-ink }
  let body-ink = if print-mode { black }
    else if "body-colour" in step { step.at("body-colour") }
    else { text-ink }
  let edge = if print-mode { (paint: rgb("#707070"), thickness: 0.75pt) } else { none }
  let shadow-ink = rgb("#666666").transparentize(if print-mode { 89% } else { 82% })
  let card-radius = 1.02cm
  let left-depth = 2.44
  let right-depth = 1.78

  let card = box(width: card-width, height: height,
    radius: card-radius, fill: background, stroke: edge, inset: 0pt)
  let top-art = _ctb-top-art(
    card-width, height, left-depth, right-depth, top-fill,
    seam-width, print-mode,
  )
  let number = if "number" in step {
    step.at("number")
  } else if index + 1 < 10 {
    [0#(index + 1)]
  } else { [#(index + 1)] }
  let number-box = box(width: 1.45cm, height: 0.90cm,
    align(center + horizon,
      text(size: number-size, weight: "bold",
        fill: if print-mode { rgb("#505050") } else { white }, number)))
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let icon-box = if icon == none { none } else {
    box(width: icon-size, height: icon-size, align(center, icon))
  }
  let top-x = if rtl { card-width - 1.62cm } else { 0.17cm }
  let icon-x = if rtl { 0.30cm } else { card-width - icon-size - 0.30cm }
  let top-y = 0.43cm
  let title-y = 2.82cm
  let title-box = box(width: card-width - 0.70cm, height: 0.52cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
  let body-box = box(width: card-width - 0.74cm, height: height - 3.82cm,
    align(center + top,
      text(size: body-size, fill: body-ink, step.at("body"))))
  let body-y = 3.44cm
  let shadow = box(width: card-width * 0.72, height: 0.16cm,
    radius: 0.08cm, fill: shadow-ink, inset: 0pt)
  let shadow-x = (card-width - card-width * 0.72) / 2

  box(width: card-width, height: height + 0.11cm, inset: 0pt, {
    place(top + left, dx: shadow-x, dy: height - 0.015cm, shadow)
    place(top + left, card)
    place(top + left, top-art)
    place(top + left, dx: top-x, dy: top-y, number-box)
    if icon != none { place(top + left, dx: icon-x, dy: 0.48cm, icon-box) }
    place(top + left, dy: title-y, title-box)
    place(top + left, dx: 0.37cm, dy: body-y, body-box)
  })
}

/// A row or grid of floating capsule-shaped text cards.
///
/// Each step requires `title` and `body`; `icon`, `number`, and per-step text
/// colors are optional. The gray header sweeps into the colored body with a
/// curved white seam. RTL mirrors card order and number/icon placement while
/// keeping the same curve orientation; print mode uses white bodies and gray outlines.
///
/// ```typ
/// #capsule-text-boxes(steps: (
///   (title: [Lorem Ipsum], body: [A short description.], icon: [⚙]),
///   (title: [Lorem Ipsum], body: [Another description.], icon: [◷]),
/// ))
/// ```
#let capsule-text-boxes(
  steps: (),
  width: auto,
  columns: 3,
  gap: 0.62cm,
  row-gap: 0.78cm,
  height: 6.15cm,
  direction: auto,
  colours: (
    (rgb("#FFCB4A"), rgb("#292929")),
    (rgb("#BF2B1B"), white),
    (rgb("#49BCE5"), rgb("#292929")),
  ),
  title-size: 12pt,
  body-size: 8.1pt,
  number-size: 26pt,
  icon-size: 0.72cm,
  seam-width: 0.15cm,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  layout(avail => {
    let count = steps.len()
    if count == 0 { none } else {
      let total-width = if width == auto { avail.width }
        else if type(width) == ratio { avail.width * width }
        else { width }
      let total-cm = total-width / 1cm
      let gap-cm = gap / 1cm
      let row-gap-cm = row-gap / 1cm
      let columns = calc.max(1, columns)
      let tile-cm = calc.max(3.3, (total-cm - (columns - 1) * gap-cm) / columns)
      let height-cm = height / 1cm
      let rows = calc.ceil(count / columns)
      let total-height = (rows * (height-cm + 0.11) + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left, dx: ((visual-col * (tile-cm + gap-cm)) * 1cm) + icon-offset-x, dy: ((row * (height-cm + row-gap-cm)) * 1cm) + icon-offset-y, _ctb-card(
              steps.at(index), index, tile-cm * 1cm, height, rtl, print-mode,
              colours, title-size, body-size, number-size, icon-size, seam-width,
            ))
        }
      })
    }
  })
}
