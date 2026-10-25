// One standalone soft-relief text panel with a top medallion, adapted from
// the supplied Neumorphic Text Panels slide reference.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ntp-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"5\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if kind == 0 {
    "<path d=\"M48 16c-16 0-28 12-28 27 0 9 4 15 11 20 4 3 6 8 6 13h22c0-5 2-10 6-13 7-5 11-12 11-21 0-14-12-26-28-26Z M39 80h18M42 87h12\"/><circle cx=\"40\" cy=\"42\" r=\"5\"/><circle cx=\"57\" cy=\"50\" r=\"5\"/><path d=\"M44 44l9 4\"/>"
  } else if kind == 1 {
    "<path d=\"M8 48s15-24 40-24 40 24 40 24-15 24-40 24S8 48 8 48Z\"/><circle cx=\"48\" cy=\"48\" r=\"15\"/><circle cx=\"48\" cy=\"48\" r=\"5\"/>"
  } else if kind == 2 {
    "<circle cx=\"43\" cy=\"54\" r=\"28\"/><circle cx=\"43\" cy=\"54\" r=\"16\"/><circle cx=\"43\" cy=\"54\" r=\"4\"/><path d=\"M43 54 77 20M61 20h16v16\"/>"
  } else {
    "<path d=\"M48 14a24 24 0 0 0-14 44c4 3 6 8 7 13h14c1-5 3-10 7-13a24 24 0 0 0-14-44Z M41 78h14M43 85h10M48 4v5M15 18l7 7M81 18l-7 7M6 47h10M80 47h10M23 76l6-6M73 76l-6-6\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

#let _ntp-art(width, height, panel, medallion, edge, shadow, highlight) = {
  let panel-shape = "M 36 188 H 139 C 139 188 140 193 140 200 C 140 235 166 258 200 258 C 234 258 260 235 260 200 C 260 193 261 188 261 188 H 364 V 482 C 364 523 330 555 289 555 H 111 C 70 555 36 523 36 482 Z"
  let badge-shape = "M 96 56 Q 96 28 124 28 H 276 Q 304 28 304 56 V 158 C 304 210 263 245 200 245 C 137 245 96 210 96 158 Z"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 400 600\" preserveAspectRatio=\"none\">"
    + "<defs><linearGradient id=\"panel\" x1=\"0\" y1=\"0\" x2=\"1\" y2=\"1\"><stop offset=\"0\" stop-color=\"" + highlight.to-hex() + "\"/><stop offset=\"1\" stop-color=\"" + panel.to-hex() + "\"/></linearGradient><linearGradient id=\"badge\" x1=\"0\" y1=\"0\" x2=\"1\" y2=\"1\"><stop offset=\"0\" stop-color=\"" + highlight.to-hex() + "\"/><stop offset=\"1\" stop-color=\"" + medallion.to-hex() + "\"/></linearGradient></defs>"
    + "<path d=\"" + panel-shape + "\" transform=\"translate(17 19)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.12\"/>"
    + "<path d=\"" + panel-shape + "\" transform=\"translate(12 14)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.16\"/>"
    + "<path d=\"" + panel-shape + "\" transform=\"translate(7 8)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.20\"/>"
    + "<path d=\"" + panel-shape + "\" transform=\"translate(-12 -12)\" fill=\"" + highlight.to-hex() + "\" opacity=\"0.72\"/>"
    + "<path d=\"" + panel-shape + "\" transform=\"translate(-7 -7)\" fill=\"" + highlight.to-hex() + "\" opacity=\"0.52\"/>"
    + "<path d=\"" + panel-shape + "\" fill=\"url(#panel)\" stroke=\"" + edge.to-hex() + "\" stroke-width=\"1.2\"/>"
    + "<path d=\"" + badge-shape + "\" transform=\"translate(15 17)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.12\"/>"
    + "<path d=\"" + badge-shape + "\" transform=\"translate(10 12)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.18\"/>"
    + "<path d=\"" + badge-shape + "\" transform=\"translate(6 7)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.20\"/>"
    + "<path d=\"" + badge-shape + "\" transform=\"translate(-10 -10)\" fill=\"" + highlight.to-hex() + "\" opacity=\"0.74\"/>"
    + "<path d=\"" + badge-shape + "\" transform=\"translate(-5 -5)\" fill=\"" + highlight.to-hex() + "\" opacity=\"0.52\"/>"
    + "<path d=\"" + badge-shape + "\" fill=\"url(#badge)\" stroke=\"" + edge.to-hex() + "\" stroke-width=\"1.2\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One portrait neumorphic text panel with a softly raised top medallion.
///
/// Use `accent: true` for the colored medallion and matching title treatment.
/// The reference's four-panel row is intentionally represented as individual
/// reusable panels, not as a complete slide or row layout. In RTL the copy
/// direction follows the active context while the panel silhouette stays fixed.
#let neumorphic-text-panel(
  title: [Lorem Ipsum],
  body: [A short description goes here. Keep the supporting copy concise and easy to scan.],
  icon: none,
  icon-style: 0,
  width: auto,
  height: 6cm,
  direction: auto,
  accent: false,
  accent-colour: rgb("#35B5E5"),
  panel-colour: rgb("#F1EFF1"),
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.92cm,
  title-size: 12pt,
  body-size: 8.8pt,
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
  if icon-style < 0 or icon-style > 3 { panic("icon-style must be between 0 and 3") }
  if title-body-gap != auto and title-body-gap < 0pt { panic("title-body-gap cannot be negative") }
  if height <= 0pt or icon-size <= 0pt or title-size <= 0pt or body-size <= 0pt {
    panic("height, icon-size, title-size, and body-size must be positive")
  }
  let card = if print-mode { white } else { panel-colour }
  let accent-fill = if print-mode { luma(222) } else if accent { accent-colour } else { panel-colour }
  let edge = if print-mode { luma(212) } else { panel-colour.darken(3%) }
  let shadow = if print-mode { luma(190) } else { rgb("#D0CDD0") }
  let highlight = if print-mode { white } else { white }
  let ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else if accent { accent-colour.darken(5%) }
    else { rgb("#171719") }
  let body-ink = if print-mode { luma(45) }
    else if text-colour != auto { text-colour }
    else { rgb("#202124") }
  let symbol-ink = if print-mode { luma(45) }
    else if icon-colour != auto { icon-colour }
    else if accent { white }
    else { luma(165) }
  let symbol = if icon != none { icon }
    else { _ntp-icon(icon-size, symbol-ink, icon-style) }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let title-content = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: ink, title)
  let body-content = {
    set par(leading: 0.29em, spacing: 0.16em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 4.8) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 3.8cm { panic("neumorphic-text-panel needs at least 3.8 cm of width") }
    let text-width = if content-width == auto { w * 0.77 } else { content-width }
    if text-width <= 0pt { panic("content-width must be positive") }
    let title-box = box(width: text-width, align(center + horizon, title-content))
    let body-box = box(width: text-width, align(center + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let title-y = h * 0.535 + title-offset-y
    let default-body-gap = h * 0.62 - (h * 0.535 + title-h)
    let body-gap = if title-body-gap == auto { default-body-gap } else { title-body-gap }
    let body-y = title-y + title-h + body-gap + body-offset-y
    if title-h > h * 0.075 { panic("title is too tall; increase height or reduce title-size") }
    if body-y + body-h > h * 0.89 { panic("body does not fit; increase height or reduce the copy") }
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let icon-y = h * 0.30 - icon-size / 2
    let art = _ntp-art(w, h, card, accent-fill, edge, shadow, highlight)

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: (w - icon-size) / 2 + icon-offset-x, dy: icon-y + icon-offset-y, icon-box)
      place(top + left, dx: (w - text-width) / 2 + title-offset-x, dy: title-y, title-box)
      place(top + left, dx: (w - text-width) / 2 + body-offset-x, dy: body-y, body-box)
    })
  })
}
