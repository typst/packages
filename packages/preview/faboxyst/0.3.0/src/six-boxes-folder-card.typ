// A single double-outline card with a centered semicircular icon tab,
// adapted from SlideEgg's 6 Boxes Template (slide 5).
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "six-boxes-icons.typ": six-box-icon

/// One portrait card with a rounded top icon tab and an offset back outline.
///
/// Adapted from SlideEgg's *6 Boxes Template*, slide 5. Only the reusable card
/// is rendered; the source's six-card layout is omitted.
#let six-boxes-folder-card(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  icon-style: 0,
  width: auto,
  height: 2.35cm,
  tab-size: 0.92cm,
  back-offset: 0.14cm,
  direction: auto,
  stroke-colour: auto,
  stroke-width: auto,
  colour: rgb("#F1840B"),
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.47cm,
  title-size: 11pt,
  body-size: 8pt,
  title-gap: 0.06cm,
  corner-radius: 0.18cm,
  padding: 0.24cm,
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
  let edge-width = if stroke-width == auto { if print-mode { 0.8pt } else { 1.25pt } } else { stroke-width }
  let edge-ink = if print-mode { luma(68) } else if stroke-colour == auto { colour } else { stroke-colour }
  if edge-width <= 0pt { panic("stroke-width must be positive") }
  let edge = (paint: edge-ink, thickness: edge-width)
  let tab-fill = if print-mode { luma(205) } else { colour }
  let heading-ink = if print-mode { black }
    else if title-colour == auto { rgb("#353535") } else { title-colour }
  let body-ink = if print-mode { luma(45) }
    else if text-colour == auto { rgb("#565656") } else { text-colour }
  let icon-ink = if print-mode { luma(25) }
    else if icon-colour == auto { white } else { icon-colour }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let title-content = text(font: "DejaVu Serif", dir: text-dir,
    size: title-size, weight: "bold", fill: heading-ink, title)
  let body-content = {
    set par(leading: 0.24em, spacing: 0.16em, justify: false)
    text(font: "DejaVu Serif", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }
  let symbol = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { six-box-icon(icon-size, icon-ink, icon-style) }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 4.8) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    let D = tab-size
    let offset = back-offset
    let card-w = w - offset
    let card-y = D / 2
    if w <= D + 1.1cm { panic("card width is too small for the icon tab and copy") }
    if D <= icon-size { panic("tab-size must be larger than icon-size") }
    let title-box = box(width: card-w - 2 * padding,
      align(center + horizon, title-content))
    let body-box = box(width: card-w - 2 * padding,
      align(center + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = title-h + gap + body-h
    let copy-y = card-y + (H - copy-h) / 2
    let tab-x = (card-w - D) / 2
    let tab-icon-x = tab-x + (D - icon-size) / 2
    let tab-icon-y = (D / 2 - icon-size) / 2
    let total-h = card-y + H

    box(width: w, height: total-h, inset: 0pt, {
      place(top + left, dx: offset, dy: card-y - offset,
        rect(width: card-w, height: H, radius: corner-radius,
          fill: white, stroke: edge))
      place(top + left, dx: tab-x, dy: 0pt,
        circle(radius: D / 2, fill: tab-fill, stroke: none))
      place(top + left, dx: 0pt, dy: card-y,
        rect(width: card-w, height: H, radius: corner-radius,
          fill: white, stroke: edge))
      place(top + left, dx: (tab-icon-x) + icon-offset-x, dy: (tab-icon-y) + icon-offset-y, box(width: icon-size, height: icon-size,
          align(center + horizon, symbol)))
      place(top + left, dx: (padding) + title-offset-x, dy: (copy-y) + title-offset-y, title-box)
      if body-h > 0pt {
        place(top + left, dx: (padding) + body-offset-x, dy: (copy-y + title-h + gap) + body-offset-y, body-box)
      }
    })
  })
}
