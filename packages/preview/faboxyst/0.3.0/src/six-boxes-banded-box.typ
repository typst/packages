// A single outlined horizontal box with an offset color layer and icon badge,
// adapted from SlideEgg's 6 Boxes Template (slide 6).
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "six-boxes-icons.typ": six-box-icon

/// One layered horizontal box with its own circular icon and caption.
///
/// Adapted from SlideEgg's *6 Boxes Template*, slide 6. The six-card row is
/// omitted. `badge-side` accepts `start`, `end`, `left`, or `right` and follows
/// `direction`; print groups turn the layered frame into grayscale.
#let six-boxes-banded-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  icon-style: 0,
  width: auto,
  height: 1.42cm,
  badge-size: 1.10cm,
  back-offset: 0.13cm,
  direction: auto,
  stroke-colour: auto,
  stroke-width: auto,
  badge-side: "end",
  text-align: "auto",
  colour: rgb("#9E2737"),
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.62cm,
  title-size: 10.8pt,
  body-size: 7.9pt,
  title-gap: 0.03cm,
  corner-radius: 0.14cm,
  padding: 0.22cm,
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
  if (badge-side != "start" and badge-side != "end" and badge-side != "left" and badge-side != "right") {
    panic("badge-side must be start, end, left, or right")
  }
  if (text-align != "auto" and text-align != "left" and text-align != "right" and text-align != "center") {
    panic("text-align must be auto, left, right, or center")
  }
  let badge-left = if badge-side == "left" { true }
    else if badge-side == "right" { false }
    else if badge-side == "start" { not rtl }
    else { rtl }
  let face-fill = white
  let edge-width = if stroke-width == auto { if print-mode { 1.3pt } else { 2.0pt } } else { stroke-width }
  let edge-ink = if print-mode { luma(65) } else if stroke-colour == auto { colour } else { stroke-colour }
  if edge-width <= 0pt { panic("stroke-width must be positive") }
  let face-edge = (paint: edge-ink, thickness: edge-width)
  let layer-fill = if print-mode { luma(205) } else { colour }
  let badge-fill = if print-mode { luma(205) } else { colour }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#303030") } else { title-colour }
  let body-ink = if print-mode { luma(45) }
    else if text-colour == auto { rgb("#555555") } else { text-colour }
  let icon-ink = if print-mode { luma(25) }
    else if icon-colour == auto { white } else { icon-colour }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let resolved-align = if text-align == "center" { center }
    else if text-align == "left" { left }
    else if text-align == "right" { right }
    else if rtl { right } else { left }
  let title-content = text(font: "DejaVu Serif", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.23em, spacing: 0.14em, justify: false)
    text(font: "DejaVu Serif", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }
  let symbol = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { six-box-icon(icon-size, icon-ink, icon-style) }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 7.1) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    let D = badge-size
    let offset = back-offset
    let face-w = w - offset
    let face-y = offset
    if w <= D + 1.0cm { panic("box width is too small for the icon badge and copy") }
    if D > H { panic("badge-size must not exceed box height") }
    let badge-x = if badge-left { 0.16cm } else { face-w - D - 0.16cm }
    let copy-x = if badge-left { D + 0.30cm } else { padding }
    let copy-w = face-w - D - 0.52cm
    let title-box = box(width: copy-w,
      align(resolved-align + horizon, title-content))
    let body-box = box(width: copy-w,
      align(resolved-align + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = title-h + gap + body-h
    let copy-y = face-y + (H - copy-h) / 2
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let icon-x = badge-x + (D - icon-size) / 2
    let icon-y = face-y + (H - D) / 2 + (D - icon-size) / 2
    let total-h = H + offset

    box(width: w, height: total-h, inset: 0pt, {
      // Offset colored backing peeks out above and along the far edge.
      place(top + left, dx: offset, dy: 0pt,
        rect(width: face-w, height: H, radius: corner-radius,
          fill: layer-fill, stroke: none))
      place(top + left, dx: 0pt, dy: face-y,
        rect(width: face-w, height: H, radius: corner-radius,
          fill: face-fill, stroke: face-edge))
      place(top + left, dx: badge-x, dy: face-y + (H - D) / 2,
        circle(radius: D / 2, fill: badge-fill,
          stroke: if print-mode { (paint: luma(65), thickness: edge-width * 0.25) } else { none }))
      place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
      place(top + left, dx: (copy-x) + title-offset-x, dy: (copy-y) + title-offset-y, title-box)
      if body-h > 0pt {
        place(top + left, dx: (copy-x) + body-offset-x, dy: (copy-y + title-h + gap) + body-offset-y, body-box)
      }
    })
  })
}
