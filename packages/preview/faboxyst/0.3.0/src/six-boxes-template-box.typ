// A single colored band and circular icon medallion, adapted from SlideEgg's
// 6 Boxes Template (slide 2). This renders one reusable box, never a row/grid.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _sxb-icon(size, ink, kind) = {
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

/// One horizontal colored box with a circular icon badge overlapping one end.
///
/// Adapted from SlideEgg's *6 Boxes Template*, slide 2. The six-card row is
/// intentionally omitted: this component draws only one reusable box.
/// `icon-side` accepts `start`, `end`, `left`, or `right`; logical sides follow
/// `direction`. Pass custom `icon`/`print-icon` content or choose one of six
/// simple built-in symbols with `icon-style` (briefcase, gears, target, growth,
/// profit, trophy). Print groups switch the panel and badge to grayscale.
#let six-boxes-template-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  icon-style: 0,
  width: auto,
  height: 1.48cm,
  badge-size: 1.74cm,
  direction: auto,
  icon-side: "end",
  text-align: "auto",
  colour: rgb("#F1840B"),
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.82cm,
  title-size: 11.2pt,
  body-size: 8pt,
  title-gap: 0.04cm,
  corner-radius: 0.20cm,
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
  if (icon-side != "start" and icon-side != "end" and icon-side != "left" and icon-side != "right") {
    panic("icon-side must be start, end, left, or right")
  }
  if (text-align != "auto" and text-align != "left" and text-align != "right" and text-align != "center") {
    panic("text-align must be auto, left, right, or center")
  }

  let badge-left = if icon-side == "left" { true }
    else if icon-side == "right" { false }
    else if icon-side == "start" { not rtl }
    else { rtl }
  let band-fill = if print-mode { luma(235) } else { colour }
  let band-edge = if print-mode { (paint: luma(65), thickness: 0.65pt) } else { none }
  let outer-edge = if print-mode { (paint: luma(70), thickness: 0.5pt) }
    else { (paint: colour.darken(18%), thickness: 0.3pt) }
  let medallion-fill = if print-mode { luma(202) } else { colour }
  let title-ink = if print-mode { black }
    else if title-colour == auto { white } else { title-colour }
  let body-ink = if print-mode { luma(35) }
    else if text-colour == auto { white } else { text-colour }
  let icon-ink = if print-mode { luma(25) }
    else if icon-colour == auto { white } else { icon-colour }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let resolved-align = if text-align == "center" { center }
    else if text-align == "left" { left }
    else if text-align == "right" { right }
    else if badge-left { if rtl { right } else { left } }
    else if rtl { left } else { right }
  let title-content = text(font: "DejaVu Serif", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.23em, spacing: 0.15em, justify: false)
    text(font: "DejaVu Serif", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }
  let symbol = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { _sxb-icon(icon-size, icon-ink, icon-style) }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 7.0) }
      else { width / 1cm }
    let H = height
    let D = badge-size
    if W * 1cm <= D + 0.55cm {
      panic("six-boxes-template-box width must exceed badge-size by at least 0.55cm")
    }
    let panel-w = W * 1cm - D / 2
    let panel-x = if badge-left { D / 2 } else { 0pt }
    let panel-y = (D - H) / 2
    let pad = padding
    let copy-w = W * 1cm - D - 2 * pad
    let copy-x = if badge-left { D + pad } else { pad }
    let text-title = box(width: copy-w,
      align(resolved-align + horizon, title-content))
    let text-body = box(width: copy-w,
      align(resolved-align + horizon, body-content))
    let title-h = measure(text-title).height
    let body-h = measure(text-body).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = title-h + gap + body-h
    let copy-y = (D - copy-h) / 2
    let badge-x = if badge-left { 0pt } else { W * 1cm - D }
    let inner-size = D * 0.77
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let icon-x = badge-x + (D - icon-size) / 2
    let icon-y = (D - icon-size) / 2

    box(width: W * 1cm, height: D, inset: 0pt, {
      place(top + left, dx: panel-x, dy: panel-y,
        box(width: panel-w, height: H, radius: corner-radius,
          fill: band-fill, stroke: band-edge, inset: 0pt))
      place(top + left, dx: badge-x, dy: 0pt,
        circle(radius: D / 2, fill: white, stroke: outer-edge))
      place(top + left, dx: badge-x + (D - inner-size) / 2,
        dy: (D - inner-size) / 2,
        circle(radius: inner-size / 2, fill: medallion-fill,
          stroke: (paint: white, thickness: if print-mode { 1.7pt } else { 2.8pt })))
      place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
      place(top + left, dx: (copy-x) + title-offset-x, dy: (copy-y) + title-offset-y, text-title)
      if body-h > 0pt {
        place(top + left, dx: (copy-x) + body-offset-x, dy: (copy-y + title-h + gap) + body-offset-y, text-body)
      }
    })
  })
}
