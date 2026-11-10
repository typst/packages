// One reusable horizontal callout band adapted from Freepik's Business
// Brochure reference. The multi-band brochure layout is not reproduced.
// Free-license attribution for the supplied source: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "six-boxes-icons.typ": six-box-icon

#let _hdbc-art(width, height, colour, ink, stroke-width) = {
  let sw = stroke-width / 1cm * 500 / (width / 1cm)
  let main-path = "M 22 20 C 92 15 160 22 239 18 C 329 14 410 22 478 18 C 488 19 482 37 484 60 L 480 111 C 479 121 455 118 425 122 C 347 126 271 118 194 123 C 119 127 57 119 24 124 C 15 122 21 103 18 81 C 16 55 21 34 18 25 C 18 21 20 20 22 20 Z"
  let echo-path = "M 27 26 C 99 21 166 28 241 24 C 327 20 405 28 472 24 C 479 27 476 42 478 62 L 475 106 C 472 114 452 113 422 117 C 347 121 273 113 195 118 C 121 122 61 114 29 119 C 23 116 26 100 23 80 C 21 56 26 37 23 30 C 23 28 25 26 27 26 Z"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 500 150\" preserveAspectRatio=\"none\">"
    + "<path d=\"" + main-path + "\" transform=\"translate(0 5)\" fill=\"" + ink.lighten(28%).to-hex() + "\" opacity=\"0.28\"/>"
    + "<path d=\"" + echo-path + "\" fill=\"none\" stroke=\"" + ink.lighten(22%).to-hex() + "\" stroke-width=\"" + str(sw * 0.62) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.76\"/>"
    + "<path d=\"" + main-path + "\" fill=\"" + colour.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One editable hand-drawn business callout band with an optional icon.
///
/// Adapted from Freepik's *Business Brochure* vector; the source's brochure
/// page and repeated rows are omitted. For the supplied free-license reference,
/// retain the attribution “Designed by Freepik” in distributed documentation.
#let hand-drawn-business-callout(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  icon-style: 4,
  show-icon: true,
  width: auto,
  height: 2.05cm,
  direction: auto,
  icon-side: "start",
  text-align: "auto",
  colour: rgb("#F04D61"),
  paper: white,
  stroke-colour: auto,
  stroke-width: 1.55pt,
  icon-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-size: 0.60cm,
  icon-gap: 0.20cm,
  padding: 0.42cm,
  title-size: 11.4pt,
  body-size: 8.4pt,
  title-gap: 0.06cm,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if (icon-side != "start" and icon-side != "end" and icon-side != "left" and icon-side != "right") {
    panic("icon-side must be start, end, left, or right")
  }
  if (text-align != "auto" and text-align != "left" and text-align != "right" and text-align != "center") {
    panic("text-align must be auto, left, right, or center")
  }
  if height <= 0pt or stroke-width <= 0pt { panic("height and stroke-width must be positive") }
  if icon-size < 0pt or icon-gap < 0pt or padding < 0pt {
    panic("icon-size, icon-gap, and padding cannot be negative")
  }
  let icon-left = if icon-side == "left" { true }
    else if icon-side == "right" { false }
    else if icon-side == "start" { not rtl }
    else { rtl }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let align-x = if text-align == "center" { center }
    else if text-align == "left" { left }
    else if text-align == "right" { right }
    else if rtl { right } else { left }
  let fill-ink = if print-mode { luma(226) } else { colour }
  let edge-ink = if print-mode { luma(54) }
    else if stroke-colour == auto { rgb("#242222") } else { stroke-colour }
  let icon-ink = if print-mode { luma(48) }
    else if icon-colour == auto { edge-ink } else { icon-colour }
  let heading-ink = if print-mode { black }
    else if title-colour == auto { rgb("#171717") } else { title-colour }
  let body-ink = if print-mode { luma(42) }
    else if text-colour == auto { rgb("#242424") } else { text-colour }
  let symbol = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { six-box-icon(icon-size, icon-ink, icon-style) }
  let title-content = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: heading-ink, title)
  let body-content = {
    set par(leading: 0.24em, spacing: 0.12em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 8.0) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    let symbol-size = if show-icon { icon-size } else { 0pt }
    let copy-x = padding + if show-icon and icon-left { icon-size + icon-gap } else { 0pt }
    let copy-w = w - 2 * padding - (if show-icon { icon-size + icon-gap } else { 0pt })
    if copy-w <= 1cm { panic("callout width is too small for the icon and text") }
    let title-box = box(width: copy-w,
      align(align-x + horizon, title-content))
    let body-box = box(width: copy-w,
      align(align-x + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt and title-h > 0pt { title-gap } else { 0pt }
    let copy-h = title-h + gap + body-h
    if copy-h > H - 2 * padding {
      panic("callout copy is too tall; increase height or shorten the text")
    }
    let copy-y = (H - copy-h) / 2
    let art = _hdbc-art(w, H, fill-ink, edge-ink, stroke-width)
    let icon-x = if icon-left { padding } else { w - padding - icon-size }
    let content-x = if icon-left { copy-x } else { padding }

    box(width: w, height: H, fill: if print-mode { white } else { paper }, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      if show-icon {
        place(top + left, dx: icon-x + icon-offset-x, dy: (H - icon-size) / 2 + icon-offset-y,
          box(width: icon-size, height: icon-size, align(center + horizon, symbol)))
      }
      if title-h > 0pt { place(top + left, dx: content-x + title-offset-x, dy: copy-y + title-offset-y, title-box) }
      if body-h > 0pt {
        place(top + left, dx: content-x + body-offset-x, dy: copy-y + title-h + gap + body-offset-y, body-box)
      }
    })
  })
}
