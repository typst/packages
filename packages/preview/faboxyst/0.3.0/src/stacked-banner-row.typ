// One reusable horizontal stepped banner row, adapted from the supplied
// four-row Stacked Banners reference. This file draws one row only.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _sbr-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4.5\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if kind == 0 {
    "<circle cx=\"32\" cy=\"31\" r=\"11\"/><circle cx=\"64\" cy=\"32\" r=\"10\"/><path d=\"M8 69c0-16 10-25 24-25s24 9 24 25v8H8V69ZM53 51c4-5 8-7 14-7 13 0 21 9 21 22v11H64\"/>"
  } else if kind == 1 {
    "<circle cx=\"48\" cy=\"48\" r=\"34\"/><path d=\"M48 27v25M48 66v2\"/>"
  } else if kind == 2 {
    "<circle cx=\"36\" cy=\"55\" r=\"23\"/><circle cx=\"36\" cy=\"55\" r=\"7\"/><path d=\"M36 13v9M36 88v-9M4 55h9M59 55h9M13 32l7 7M52 71l7 7M13 78l7-7M52 39l7-7M70 33a14 14 0 1 1-2 26M69 31l8 2-2 8\"/>"
  } else {
    "<path d=\"M12 78h72M20 73V53h12v20M42 73V37h12v36M64 73V20h12v53M18 40l21-15 14 7 26-21M68 11h11v11\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

#let _sbr-art(width, height, body-fill, icon-fill, fold-fill, stripe-fill, shadow, edge, mirror) = {
  let flip = if mirror { "<g transform=\"translate(1000 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1000 160\" preserveAspectRatio=\"none\">"
    + "<defs><clipPath id=\"clip\"><rect x=\"0\" y=\"0\" width=\"1000\" height=\"160\" rx=\"28\"/></clipPath></defs>"
    + "<rect x=\"6\" y=\"9\" width=\"988\" height=\"146\" rx=\"28\" fill=\"" + shadow.to-hex() + "\"/>"
    + flip + "<g clip-path=\"url(#clip)\">"
    + "<rect x=\"0\" y=\"0\" width=\"1000\" height=\"145\" rx=\"28\" fill=\"" + body-fill.to-hex() + "\" stroke=\"" + edge.to-hex() + "\" stroke-width=\"1.5\"/>"
    + "<path d=\"M 0 0 H 205 V 144 H 0 Z\" fill=\"" + icon-fill.to-hex() + "\"/>"
    + "<path d=\"M 205 0 L 260 22 V 124 L 205 145 Z\" fill=\"" + fold-fill.to-hex() + "\"/>"
    + "<path d=\"M 0 136 H 205 L 260 156 L 305 136 H 1000 V 160 H 0 Z\" fill=\"" + stripe-fill.to-hex() + "\"/>"
    + "</g></g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One horizontal stacked-banner row with a left/right icon block, folded
/// divider, title, copy, and lower accent stripe. Compose several calls to make
/// a list; this helper intentionally emits only one row, not the four-row slide.
#let stacked-banner-row(
  title: [Lorem Ipsum],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
  icon: none,
  icon-style: 0,
  width: auto,
  height: 1.7cm,
  direction: auto,
  icon-side: "start",
  colour: rgb("#E2B917"),
  body-colour: rgb("#C9C9C9"),
  icon-panel-colour: rgb("#858585"),
  fold-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.88cm,
  title-size: 10pt,
  body-size: 6pt,
  padding: 0.08cm,
  content-width: auto,
  title-body-gap: auto,
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
  if title-body-gap != auto and title-body-gap < 0pt { panic("title-body-gap cannot be negative") }
  if icon-side != "start" and icon-side != "end" { panic("icon-side must be start or end") }
  if icon-style < 0 or icon-style > 3 { panic("icon-style must be between 0 and 3") }
  if width != auto and width < 8.5cm { panic("stacked-banner-row needs at least 8.5 cm of width") }
  if height <= 0pt or icon-size <= 0pt or title-size <= 0pt or body-size <= 0pt or padding < 0pt {
    panic("height and all text/icon sizes must be positive; padding cannot be negative")
  }
  let mirror = if icon-side == "start" { rtl } else { not rtl }
  let strip = if print-mode { luma(130) } else { colour }
  let body-fill = if print-mode { luma(224) } else { body-colour }
  let icon-fill = if print-mode { luma(150) } else { icon-panel-colour }
  let fold-fill = if print-mode { luma(78) }
    else if fold-colour == auto { icon-panel-colour.darken(24%) } else { fold-colour }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#17191A") } else { title-colour }
  let body-ink = if print-mode { luma(38) }
    else if text-colour == auto { rgb("#65676A") } else { text-colour }
  let symbol-ink = if print-mode { white }
    else if icon-colour == auto { white } else { icon-colour }
  let symbol = if icon != none { icon } else { _sbr-icon(icon-size, symbol-ink, icon-style) }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let text-align = if rtl { right } else { left }
  let heading = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let paragraph = {
    set par(leading: 0.24em, spacing: 0.05em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 10.8) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 8.5cm { panic("stacked-banner-row needs at least 8.5 cm of width") }
    if icon-size + 2 * padding > h { panic("icon-size and padding do not fit within the row height") }
    let art = _sbr-art(w, h, body-fill, icon-fill, fold-fill, strip,
      rgb("#777777").transparentize(76%), luma(210), mirror)
    // Treat padding as an inset within the existing text column. Subtract its
    // original default so calls using the old default retain the exact layout.
    let default-padding = 0.08cm
    let pad-delta = padding - default-padding
    let default-text-width = if mirror { w * 0.62 } else { w * 0.66 }
    let text-width = if content-width == auto { default-text-width - 2 * pad-delta } else { content-width }
    if text-width <= 0pt { panic("content-width must be positive") }
    let text-x = (if mirror { w * 0.05 } else { w * 0.30 }) + pad-delta
    let icon-x = (if mirror { w * 0.90 - icon-size / 2 } else { w * 0.10 - icon-size / 2 }) + icon-offset-x
    let title-box = box(width: text-width, height: h * 0.25,
      align(text-align + horizon, heading))
    let body-box = box(width: text-width, height: h * 0.45,
      align(text-align + top, paragraph))
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let title-y = h * 0.10 + title-offset-y
    let default-title-body-gap = h * 0.36 - (h * 0.10 + h * 0.25)
    let title-body-gap-value = if title-body-gap == auto { default-title-body-gap } else { title-body-gap }
    let body-y = title-y + h * 0.25 + title-body-gap-value + body-offset-y
    if measure(heading).height > h * 0.25 { panic("title does not fit; increase row height or reduce title-size") }
    if measure(paragraph).height > h * 0.45 { panic("body does not fit; increase row height or reduce the copy") }

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: icon-x, dy: (h - icon-size) / 2 + icon-offset-y, icon-box)
      place(top + left, dx: text-x + title-offset-x, dy: title-y, title-box)
      place(top + left, dx: text-x + body-offset-x, dy: body-y, body-box)
    })
  })
}
