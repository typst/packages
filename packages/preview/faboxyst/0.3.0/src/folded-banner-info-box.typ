// Single reusable card adapted from PresentationGO's Four-Step Boxes.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _fbib-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if calc.rem(kind, 5) == 0 {
    "<path d=\"M48 16l8 3 7-3 7 7-3 7 3 8 8 3v9l-8 3-3 8 3 7-7 7-7-3-8 3-3 8h-9l-3-8-8-3-7 3-7-7 3-7-3-8-8-3v-9l8-3 3-8-3-7 7-7 7 3 8-3 3-8h9z\"/><circle cx=\"48\" cy=\"47\" r=\"11\"/><circle cx=\"69\" cy=\"70\" r=\"6\"/>"
  } else if calc.rem(kind, 5) == 1 {
    "<path d=\"M48 15a22 22 0 0 0-13 40c4 3 6 7 7 12h12c1-5 3-9 7-12A22 22 0 0 0 48 15Z M42 73h12M44 80h8M48 5v5M16 22l7 5M80 22l-7 5M12 48h8M76 48h8\"/>"
  } else if calc.rem(kind, 5) == 2 {
    "<path d=\"M24 72l35-35M53 25l18 18M19 68l9 9M57 29l8-8 12 12-8 8M16 77l-3 6 6-3M35 54l-6-6 9-9 6 6M64 56l16 16M61 59l-9 9 7 7 9-9\"/>"
  } else if calc.rem(kind, 5) == 3 {
    "<path d=\"M16 76h64M23 70V49h12v21M43 70V27h12v43M63 70V40h12v30M21 38l17-12 13 6 22-18M65 14h10v10\"/>"
  } else {
    "<circle cx=\"48\" cy=\"48\" r=\"31\"/><circle cx=\"48\" cy=\"48\" r=\"19\"/><circle cx=\"48\" cy=\"48\" r=\"7\"/><path d=\"M48 8v10M48 78v10M8 48h10M78 48h10M20 20l7 7M69 69l7 7M76 20l-7 7M27 69l-7 7\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// A single information card with an overhanging folded-color title banner.
///
/// The source is a four-card 2×2 slide; this component draws only one reusable
/// card. RTL mirrors the banner, number, icon/body columns, and text direction.
///
/// - `number` is content, so it can be localized (for example, Arabic numerals).
/// - `icon` accepts arbitrary Typst content; otherwise `icon-style` selects a
///   built-in vector symbol (0–4).
/// - `width` defaults to the available measure; `height` controls the gray body
///   panel, which grows when needed to fit the text.
#let folded-banner-info-box(
  title: [],
  body: [],
  number: [01],
  icon: none,
  icon-style: 0,
  width: auto,
  height: auto,
  min-height: 3.3cm,
  direction: auto,
  colour: rgb("#F35D49"),
  body-fill: auto,
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.82cm,
  title-size: 12pt,
  body-size: 8.2pt,
  number-size: 11pt,
  banner-width: 0.56,
  banner-height: 0.96cm,
  corner-radius: 0.32cm,
  panel-inset: 0.58cm,
  icon-column: 1.72cm,
  body-gap: 0.22cm,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let face-fill = if print-mode { white }
    else if body-fill == auto { rgb("#D9D9D9") } else { body-fill }
  let banner-fill = if print-mode { white } else { colour }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#182D38") }
  let body-ink = if print-mode { luma(35) }
    else if text-colour != auto { text-colour } else { rgb("#4A4A4A") }
  let icon-ink = if print-mode { luma(55) }
    else if icon-colour != auto { icon-colour } else { colour.darken(34%) }
  let edge = if print-mode { (paint: luma(75), thickness: 0.75pt) } else { none }
  let card-shadow = if print-mode { luma(242) }
    else { rgb("#1B2A30").transparentize(92%) }
  let title-content = text(dir: if rtl { std.rtl } else { std.ltr },
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.34em, spacing: 0.28em, justify: false)
    text(dir: if rtl { std.rtl } else { std.ltr },
      size: body-size, fill: body-ink, body)
  }
  let icon-content = if icon == none { _fbib-icon(icon-size, icon-ink, icon-style) }
    else { icon }

  layout(avail => {
    let W = if width == auto { avail.width / 1cm }
      else { width / 1cm }
    let min-panel-h = min-height / 1cm
    let inset = panel-inset / 1cm
    let body-x = if rtl { 0.0 } else { inset }
    let body-w = W - inset
    let content-pad = 0.34cm / 1cm
    let icon-w = icon-column / 1cm
    let gap = body-gap / 1cm
    let copy-w = calc.max(1.2, body-w - 2 * content-pad - icon-w - gap)
    let copy = box(width: copy-w * 1cm, body-content)
    let copy-h = measure(copy).height / 1cm
    let measured-panel-h = calc.max(min-panel-h, copy-h + 0.86)
    let panel-h = if height == auto { measured-panel-h }
      else { calc.max(height / 1cm, measured-panel-h) }
    let panel-y = 0.66
    let total-h = panel-y + panel-h + 0.18
    let ribbon-w = calc.min(W * banner-width, W - 2.2)
    let ribbon-x = if rtl { W - ribbon-w } else { 0.0 }
    let tab-w = 1.04
    let tab-x = if rtl { W - tab-w } else { 0.0 }
    let number-w = 1.05
    let number-x = if rtl { body-x + 0.22 } else { W - number-w - 0.38 }
    let number-y = panel-y + 0.06
    let copy-x = if rtl {
      body-x + content-pad
    } else {
      body-x + content-pad + icon-w + gap
    }
    let icon-x = if rtl {
      body-x + body-w - content-pad - icon-w
    } else {
      body-x + content-pad
    }
    let content-y = panel-y + 0.84
    let content-h = calc.max(0.6, panel-h - 1.02)
    let banner-title-w = ribbon-w - 0.50
    let banner-title = box(width: banner-title-w * 1cm,
      height: banner-height, align(center + horizon, title-content))
    let body-copy = box(width: copy-w * 1cm, height: content-h * 1cm,
      align(if rtl { right + horizon } else { left + horizon }, copy))
    let icon-box = box(width: icon-w * 1cm, height: content-h * 1cm,
      align(center + horizon, icon-content))
    let number-box = box(width: number-w * 1cm, height: 0.44cm,
      align(if rtl { left + horizon } else { right + horizon },
        text(dir: if rtl { std.rtl } else { std.ltr },
          size: number-size, weight: "bold",
          fill: if print-mode { black } else { luma(112) }, number)))
    let tab-colour = if print-mode { luma(218) } else { colour.darken(27%) }

    box(width: W * 1cm, height: total-h * 1cm, inset: 0pt, {
      // Soft card shadow and the folded color tab beneath the banner.
      if shadow {
        place(top + left, dx: ((body-x + 0.08) * 1cm) + body-offset-x, dy: ((panel-y + 0.10) * 1cm) + body-offset-y, rect(width: body-w * 1cm, height: panel-h * 1cm,
            fill: card-shadow, stroke: none))
      }
      place(top + left, dx: tab-x * 1cm, dy: (panel-y + 0.25) * 1cm,
        rect(width: tab-w * 1cm, height: 0.38cm, radius: 0.08cm,
          fill: tab-colour, stroke: none))
      place(top + left, dx: (body-x * 1cm) + body-offset-x, dy: (panel-y * 1cm) + body-offset-y, rect(width: body-w * 1cm, height: panel-h * 1cm,
          fill: face-fill, stroke: edge))
      place(top + left, dx: ribbon-x * 1cm, dy: 0pt,
        rect(width: ribbon-w * 1cm, height: banner-height,
          radius: corner-radius, fill: banner-fill, stroke: edge))
      place(top + left, dx: ((ribbon-x * 1cm) + 0.25cm) + title-offset-x, dy: (0pt) + title-offset-y, banner-title)
      place(top + left, dx: (number-x * 1cm) + number-offset-x, dy: (number-y * 1cm) + number-offset-y, number-box)
      place(top + left, dx: (icon-x * 1cm) + icon-offset-x, dy: (content-y * 1cm) + icon-offset-y, icon-box)
      place(top + left, dx: (copy-x * 1cm) + body-offset-x, dy: (content-y * 1cm) + body-offset-y, body-copy)
    })
  })
}
