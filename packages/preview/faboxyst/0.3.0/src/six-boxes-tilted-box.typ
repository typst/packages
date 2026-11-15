// A single inclined outline card with a solid parallelogram icon tab,
// adapted from SlideEgg's 6 Boxes Template (slide 4).
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _stb-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let k = calc.rem(kind, 6)
  let art = if k == 0 {
    "<rect x=\"18\" y=\"34\" width=\"60\" height=\"43\" rx=\"5\"/><path d=\"M35 34v-8q0-5 5-5h16q5 0 5 5v8M18 51h60M42 49v8h12v-8\"/>"
  } else if k == 1 {
    "<circle cx=\"38\" cy=\"39\" r=\"17\"/><circle cx=\"64\" cy=\"61\" r=\"12\"/><circle cx=\"38\" cy=\"39\" r=\"6\"/><circle cx=\"64\" cy=\"61\" r=\"4\"/><path d=\"M38 14v8M38 56v8M13 39h8M55 39h8M20 21l6 6M50 51l6 6M20 57l6-6M50 27l6-6M64 42v7M64 73v7M45 61h7M76 61h7\"/>"
  } else if k == 2 {
    "<circle cx=\"43\" cy=\"56\" r=\"25\"/><circle cx=\"43\" cy=\"56\" r=\"14\"/><circle cx=\"43\" cy=\"56\" r=\"4\"/><path d=\"M44 55 75 24M61 24h14v14M67 31l7 7\"/>"
  } else if k == 3 {
    "<path d=\"M15 78h67M23 74V54h12v20M43 74V40h12v34M63 74V27h12v47M18 43l20-16 14 7 25-21M66 13h11v11\"/>"
  } else if k == 4 {
    "<circle cx=\"62\" cy=\"30\" r=\"16\"/><path d=\"M62 20v20M56 25c0-5 12-5 12 1s-12 4-12 10 12 6 12 0M14 71c8-10 17-15 27-15h12l10 4h13c5 0 7 5 3 8L61 81H34l-9-5h-8M42 56v-7c0-6 9-6 9 0v7\"/>"
  } else {
    "<path d=\"M29 18h38v8l-5 19 17 20H17l17-20-5-19v-8ZM29 26h38M43 41l5-7 5 7 8 2-6 6 1 8-8-4-8 4 1-8-6-6 8-2Z M38 65l-8 15M58 65l8 15\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// One trapezoidal outline card with a colored slanted icon panel.
///
/// Adapted from SlideEgg's *6 Boxes Template*, slide 4. The six-box row is
/// omitted. `badge-side` accepts `start`, `end`, `left`, or `right`; logical
/// sides follow `direction`. Use custom `icon` and optional `print-icon`, or
/// select one of six built-in icons. In print mode the fill and outline turn
/// grayscale while the outlined-card silhouette remains clear.
#let six-boxes-tilted-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  icon-style: 0,
  width: auto,
  height: 2.20cm,
  badge-width: 2.22cm,
  badge-height: 1.76cm,
  slant: 0.52cm,
  badge-slant: 0.42cm,
  direction: auto,
  stroke-colour: auto,
  stroke-width: auto,
  badge-side: "start",
  text-align: "auto",
  colour: rgb("#F1840B"),
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.82cm,
  title-size: 11.5pt,
  body-size: 8.1pt,
  title-gap: 0.05cm,
  padding: 0.25cm,
  badge-lift: 0.18cm,
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
  let card-fill = white
  let edge-width = if stroke-width == auto { if print-mode { 0.8pt } else { 1.45pt } } else { stroke-width }
  let edge-ink = if print-mode { luma(65) } else if stroke-colour == auto { colour } else { stroke-colour }
  if edge-width <= 0pt { panic("stroke-width must be positive") }
  let card-edge = (paint: edge-ink, thickness: edge-width)
  let badge-fill = if print-mode { luma(205) } else { colour }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#303030") } else { title-colour }
  let body-ink = if print-mode { luma(42) }
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
    set par(leading: 0.25em, spacing: 0.17em, justify: false)
    text(font: "DejaVu Serif", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }
  let symbol = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { _stb-icon(icon-size, icon-ink, icon-style) }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 7.5) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    let BW = badge-width
    let BH = badge-height
    let S = slant
    let BS = badge-slant
    let badge-y = 0pt
    let card-y = badge-lift
    if w <= BW + 1.2cm {
      panic("six-boxes-tilted-box width must exceed badge-width by at least 1.2cm")
    }
    if BH > H + card-y {
      panic("badge-height must fit within height plus badge-lift")
    }
    let card-points = if badge-left {
      ((S, card-y), (w, card-y), (w - S, card-y + H), (0pt, card-y + H))
    } else {
      ((0pt, card-y), (w - S, card-y), (w, card-y + H), (S, card-y + H))
    }
    let badge-x = if badge-left { 0pt } else { w - BW }
    let badge-points = if badge-left {
      ((badge-x, badge-y), (badge-x + BW - BS, badge-y),
       (badge-x + BW, badge-y + BH), (badge-x + BS, badge-y + BH))
    } else {
      ((badge-x + BS, badge-y), (badge-x + BW, badge-y),
       (badge-x + BW - BS, badge-y + BH), (badge-x, badge-y + BH))
    }
    let content-x = if badge-left { BW + padding } else { padding }
    let content-w = w - BW - 2 * padding
    let title-box = box(width: content-w,
      align(resolved-align + horizon, title-content))
    let body-box = box(width: content-w,
      align(resolved-align + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = title-h + gap + body-h
    let copy-y = card-y + (H - copy-h) / 2
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let icon-x = badge-x + (BW - icon-size) / 2
    let icon-y = badge-y + (BH - icon-size) / 2
    let total-h = card-y + H

    box(width: w, height: total-h, inset: 0pt, {
      place(top + left, polygon(fill: card-fill, stroke: card-edge, ..card-points))
      place(top + left, polygon(fill: badge-fill,
        stroke: if print-mode { (paint: luma(65), thickness: edge-width * 0.38) } else { none },
        ..badge-points))
      place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
      place(top + left, dx: (content-x) + title-offset-x, dy: (copy-y) + title-offset-y, title-box)
      if body-h > 0pt {
        place(top + left, dx: (content-x) + body-offset-x, dy: (copy-y + title-h + gap) + body-offset-y, body-box)
      }
    })
  })
}
