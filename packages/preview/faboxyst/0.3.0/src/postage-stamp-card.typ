// One reusable perforated-edge note card, adapted from the supplied
// Postage Stamp Cards reference. The source's three-card row is omitted.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "six-boxes-icons.typ": six-box-icon

/// A single postage-stamp card with a colored title band, paper inset, and
/// optional pictogram above it. `perforation-colour` should match the page
/// behind the stamp; set `direction` to `"rtl"` for Arabic copy.
#let postage-stamp-card(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  icon-style: 3,
  show-icon: true,
  width: auto,
  height: 5.35cm,
  direction: auto,
  text-align: "auto",
  colour: rgb("#F05C4B"),
  paper: white,
  perforation-colour: white,
  stroke-colour: auto,
  stroke-width: 0.65pt,
  icon-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-size: 0.62cm,
  icon-gap: 0.20cm,
  header-height: 0.98cm,
  frame-width: 0.23cm,
  perforation-radius: 0.10cm,
  perforation-spacing: 0.34cm,
  title-size: 11.5pt,
  body-size: 8.5pt,
  title-gap: 0.12cm,
  body-padding: 0.19cm,
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
  if (text-align != "auto" and text-align != "left" and text-align != "right" and text-align != "center") {
    panic("text-align must be auto, left, right, or center")
  }
  if height <= 0pt { panic("height must be positive") }
  if stroke-width <= 0pt { panic("stroke-width must be positive") }
  if icon-size < 0pt or icon-gap < 0pt { panic("icon-size and icon-gap cannot be negative") }
  if perforation-radius <= 0pt or perforation-spacing <= 2 * perforation-radius {
    panic("perforation-spacing must be greater than twice perforation-radius")
  }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let resolved-align = if text-align == "center" { center }
    else if text-align == "left" { left }
    else if text-align == "right" { right }
    else if rtl { right } else { center }
  let stamp-colour = if print-mode { luma(202) } else { colour }
  let face-colour = if print-mode { white } else { paper }
  let ink = if print-mode { luma(64) }
    else if stroke-colour == auto { colour.darken(22%) } else { stroke-colour }
  let border = (paint: ink, thickness: stroke-width)
  let panel-ink = if print-mode { luma(118) } else { colour.darken(24%) }
  let panel-border = (paint: panel-ink, thickness: 0.55pt)
  let heading-ink = if print-mode { black }
    else if title-colour == auto { white } else { title-colour }
  let body-ink = if print-mode { luma(42) }
    else if text-colour == auto { rgb("#353535") } else { text-colour }
  let symbol-ink = if print-mode { luma(60) }
    else if icon-colour == auto { colour.darken(23%) } else { icon-colour }
  let title-content = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: heading-ink, title)
  let body-content = {
    set par(leading: 0.30em, spacing: 0.18em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir,
      size: body-size, fill: body-ink, body)
  }
  let symbol = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { six-box-icon(icon-size, symbol-ink, icon-style) }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 4.7) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    let R = perforation-radius
    let C = R + stroke-width / 2
    let M = C + stroke-width / 2
    let P = perforation-spacing
    let frame = frame-width
    let head-h = header-height
    let icon-h = if show-icon { icon-size } else { 0pt }
    let top-gap = if icon-h > 0pt { icon-gap } else { 0pt }
    let card-top = icon-h + top-gap
    let outer-w = w + 2 * R
    let outer-h = card-top + H + 2 * R
    let base-x = R
    let base-y = card-top + R
    let content-w = w - 2 * frame - 2 * body-padding
    let body-area-h = H - head-h - frame
    if w <= 2 * frame + 0.8cm { panic("postage-stamp-card width is too small for its frame") }
    if head-h <= title-size * 1.25 { panic("header-height is too small for the title") }
    if body-area-h <= 0pt or content-w <= 0pt { panic("increase height or reduce the frame and padding") }
    if perforation-radius * 2 >= frame-width { panic("frame-width must be wider than the perforation diameter") }
    if P <= 2 * C { panic("perforation-spacing must exceed the cutout diameter") }
    let title-box = box(width: w - 2 * frame,
      align(center + horizon, title-content))
    let body-box = box(width: content-w,
      align(resolved-align + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    if title-h > head-h - 0.10cm { panic("title is too tall for the colored header band") }
    if body-h > body-area-h - 2 * body-padding {
      panic("body does not fit; increase height or reduce the copy")
    }
    let title-y = base-y + (head-h - title-h) / 2
    let body-y = base-y + head-h + (body-area-h - body-h) / 2
    let n-x = calc.max(2, calc.floor((w - 4 * C) / P) + 1)
    let n-y = calc.max(2, calc.floor((H - 4 * C) / P) + 1)

    box(width: outer-w, height: outer-h, inset: 0pt, {
      if icon-h > 0pt {
        let icon-box = box(width: icon-size, height: icon-size,
          align(center + horizon, symbol))
        place(top + left, dx: (R + (w - icon-size) / 2) + icon-offset-x, dy: (0pt) + icon-offset-y, icon-box)
      }
      place(top + left, dx: base-x, dy: base-y,
        rect(width: w, height: H, fill: stamp-colour, stroke: border))
      place(top + left, dx: (base-x + frame) + body-offset-x, dy: (base-y + head-h) + body-offset-y, rect(width: w - 2 * frame, height: body-area-h,
          fill: face-colour, stroke: panel-border))
      place(top + left, dx: (base-x + frame) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
      place(top + left, dx: (base-x + frame + body-padding) + body-offset-x, dy: (body-y) + body-offset-y, body-box)

      // Circular cutouts over the four edges form the postage perforation.
      for i in range(n-x) {
        let cx = base-x + 2 * C + (w - 4 * C) * i / (n-x - 1)
        place(top + left, dx: cx - C, dy: base-y - C,
          circle(radius: C, fill: perforation-colour, stroke: none))
        place(top + left, dx: cx - C, dy: base-y + H - C,
          circle(radius: C, fill: perforation-colour, stroke: none))
      }
      for i in range(n-y) {
        let cy = base-y + 2 * C + (H - 4 * C) * i / (n-y - 1)
        place(top + left, dx: base-x - C, dy: cy - C,
          circle(radius: C, fill: perforation-colour, stroke: none))
        place(top + left, dx: base-x + w - C, dy: cy - C,
          circle(radius: C, fill: perforation-colour, stroke: none))
      }
      if print-mode {
        let perforation-edge = (paint: luma(72), thickness: stroke-width)
        // Draw the inner halves of the hole outlines, then mask every outside half.
        for i in range(n-x) {
          let cx = base-x + 2 * C + (w - 4 * C) * i / (n-x - 1)
          place(top + left, dx: cx - C, dy: base-y - C,
            circle(radius: C, fill: none, stroke: perforation-edge))
          place(top + left, dx: cx - C, dy: base-y + H - C,
            circle(radius: C, fill: none, stroke: perforation-edge))
        }
        for i in range(n-y) {
          let cy = base-y + 2 * C + (H - 4 * C) * i / (n-y - 1)
          place(top + left, dx: base-x - C, dy: cy - C,
            circle(radius: C, fill: none, stroke: perforation-edge))
          place(top + left, dx: base-x + w - C, dy: cy - C,
            circle(radius: C, fill: none, stroke: perforation-edge))
        }
        for i in range(n-x) {
          let cx = base-x + 2 * C + (w - 4 * C) * i / (n-x - 1)
          place(top + left, dx: cx - M, dy: base-y - M,
            rect(width: 2 * M, height: M, fill: perforation-colour, stroke: none))
          place(top + left, dx: cx - M, dy: base-y + H,
            rect(width: 2 * M, height: M, fill: perforation-colour, stroke: none))
        }
        for i in range(n-y) {
          let cy = base-y + 2 * C + (H - 4 * C) * i / (n-y - 1)
          place(top + left, dx: base-x - M, dy: cy - M,
            rect(width: M, height: 2 * M, fill: perforation-colour, stroke: none))
          place(top + left, dx: base-x + w, dy: cy - M,
            rect(width: M, height: 2 * M, fill: perforation-colour, stroke: none))
        }
      }
    })
  })
}
