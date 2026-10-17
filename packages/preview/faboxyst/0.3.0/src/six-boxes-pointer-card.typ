// A single rounded icon tile with a top tab, bottom pointer, and caption,
// adapted from SlideEgg's 6 Boxes Template (slide 7).
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "six-boxes-icons.typ": six-box-icon

/// One square icon card with a small top tab, bottom pointer, and caption below.
///
/// Adapted from SlideEgg's *6 Boxes Template*, slide 7. This component returns
/// one card and its own title/body only, never a row of six.
#let six-boxes-pointer-card(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  icon-style: 0,
  width: 2.8cm,
  height: auto,                 // alias for the square card's `box-size`
  box-size: 1.76cm,
  tab-size: 0.46cm,
  tail-width: 0.42cm,
  tail-height: 0.24cm,
  direction: auto,
  stroke-colour: auto,
  stroke-width: auto,
  colour: rgb("#F1840B"),
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.74cm,
  title-size: 10.8pt,
  body-size: 7.4pt,
  title-gap: 0.07cm,
  caption-gap: 0.30cm,
  corner-radius: 0.18cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let edge-width = if stroke-width == auto { if print-mode { 1.25pt } else { 2.0pt } } else { stroke-width }
  let edge-ink = if print-mode { luma(70) } else if stroke-colour == auto { colour } else { stroke-colour }
  if edge-width <= 0pt { panic("stroke-width must be positive") }
  let edge = (paint: edge-ink, thickness: edge-width)
  let tab-fill = if print-mode { luma(205) } else { colour }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#303030") } else { title-colour }
  let body-ink = if print-mode { luma(45) }
    else if text-colour == auto { rgb("#555555") } else { text-colour }
  let icon-ink = if print-mode { luma(25) }
    else if icon-colour == auto { luma(25) } else { icon-colour }
  let title-content = text(font: "DejaVu Serif", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.23em, spacing: 0.16em, justify: false)
    text(font: "DejaVu Serif", dir: text-dir, size: body-size, fill: body-ink, body)
  }
  let symbol = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { six-box-icon(icon-size, icon-ink, icon-style) }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 2.8) }
      else { width / 1cm }
    let w = W * 1cm
    let D = if height == auto { box-size } else { height }
    let T = tab-size
    if w < D { panic("pointer-card width must be at least box-size") }
    if D <= icon-size or T <= 0pt { panic("box-size and tab-size must exceed their icon sizes") }
    let card-x = (w - D) / 2
    let card-y = T / 2
    let tail-top = card-y + D - 0.02cm
    let center-x = card-x + D / 2
    let tail-points = (
      (center-x - tail-width / 2, tail-top),
      (center-x, tail-top + tail-height),
      (center-x + tail-width / 2, tail-top),
    )
    let title-box = box(width: w,
      align(center + horizon, title-content))
    let body-box = box(width: w,
      align(center + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let caption-y = card-y + D + tail-height + caption-gap
    let body-y = caption-y + title-h + gap
    let total-h = body-y + body-h
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let icon-x = card-x + (D - icon-size) / 2
    let icon-y = card-y + (D - icon-size) / 2
    let tab-x = card-x + (D - T) / 2

    box(width: w, height: total-h, inset: 0pt, {
      // Backing shapes are laid down first so their joining edges disappear under the card.
      place(top + left, polygon(fill: white, stroke: edge, ..tail-points))
      place(top + left, dx: tab-x, dy: 0pt,
        circle(radius: T / 2, fill: tab-fill, stroke: none))
      place(top + left, dx: card-x, dy: card-y,
        rect(width: D, height: D, radius: corner-radius,
          fill: white, stroke: edge))
      place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
      place(top + left, dx: (0pt) + title-offset-x, dy: (caption-y) + title-offset-y, title-box)
      if body-h > 0pt {
        place(top + left, dx: (0pt) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
      }
    })
  })
}
