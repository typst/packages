// One reusable vertical card from PresentationGO's Text Box Displays row.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _tbd-icon(size, ink, style) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"5\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if calc.rem(style, 4) == 0 {
    "<circle cx=\"23\" cy=\"70\" r=\"15\"/><circle cx=\"73\" cy=\"70\" r=\"15\"/><circle cx=\"49\" cy=\"20\" r=\"6\" fill=\"" + ink.to-hex() + "\"/><path d=\"M48 28 37 45 53 54 64 38 75 44M37 45 23 70h30L37 45l-5 25M49 29l16 4 8 11\"/>"
  } else if calc.rem(style, 4) == 1 {
    "<circle cx=\"53\" cy=\"18\" r=\"6\" fill=\"" + ink.to-hex() + "\"/><path d=\"M50 27 40 43 55 51 64 39M40 43l-9 18M55 51l-9 22M64 39l10 15M10 80h76M20 75l21-3 25 4M38 72l13-19\"/>"
  } else if calc.rem(style, 4) == 2 {
    "<circle cx=\"53\" cy=\"18\" r=\"6\" fill=\"" + ink.to-hex() + "\"/><path d=\"M49 27 39 42l16 8 12-9M39 42 22 32M55 50l-7 21-16 8M55 50l17 15 8 13M21 32l-8-8M73 65l10-2\"/>"
  } else {
    "<circle cx=\"27\" cy=\"43\" r=\"7\" fill=\"" + ink.to-hex() + "\"/><path d=\"M37 45 56 39l16 6M11 58q9-8 18 0t18 0 18 0 20 0M11 70q9-8 18 0t18 0 18 0 20 0M11 82q9-8 18 0t18 0 18 0 20 0\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

#let _tbd-art(width, height, face, tab, footer, facet, shade, print-mode) = {
  let stroke = if print-mode { " stroke=\"#555555\" stroke-width=\"2\"" } else { "" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1000 1200\" preserveAspectRatio=\"none\">"
    + "<rect x=\"16\" y=\"156\" width=\"968\" height=\"888\" rx=\"92\" fill=\"" + shade.to-hex() + "\" opacity=\"0.72\"/>"
    + "<rect x=\"0\" y=\"140\" width=\"1000\" height=\"900\" rx=\"92\" fill=\"" + face.to-hex() + "\"" + stroke + "/>"
    + "<path d=\"M 188 142 H 303 V 313 L 127 250 Z M 812 142 H 697 V 313 L 873 250 Z\" fill=\"" + facet.to-hex() + "\"/>"
    + "<path d=\"M 0 909 L 198 909 L 273 675 H 727 L 802 909 H 1000 V 1170 H 0 Z\" fill=\"" + facet.to-hex() + "\"/>"
    + "<path d=\"M 0 925 L 211 925 L 286 735 H 714 L 789 925 H 1000 V 1138 H 0 Z\" fill=\"" + footer.to-hex() + "\"" + stroke + "/>"
    + "<rect x=\"306\" y=\"15\" width=\"400\" height=\"354\" rx=\"76\" fill=\"" + shade.to-hex() + "\" opacity=\"0.64\"/>"
    + "<rect x=\"300\" y=\"0\" width=\"400\" height=\"350\" rx=\"76\" fill=\"" + tab.to-hex() + "\"" + stroke + "/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One vertical Text Box Display card with an overlapping icon tile and a
/// faceted footer. Compose several calls to create a row; this function emits
/// a single reusable card, not the four-card slide.
#let text-box-display-card(
  title: [LOREM IPSUM],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
  icon: none,
  print-icon: none,
  icon-style: 0,
  width: 4.8cm,
  height: 6.8cm,
  direction: auto,
  colour: rgb("#F68C1F"),
  tab-colour: auto,
  footer-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  icon-size: 0.88cm,
  title-size: 10pt,
  body-size: 7.4pt,
  padding: 0.12cm,
  body-width: auto,
  title-width: auto,
  body-title-gap: auto,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if body-title-gap != auto and body-title-gap < 0pt { panic("body-title-gap cannot be negative") }
  if icon-style < 0 or icon-style > 3 { panic("icon-style must be between 0 and 3") }
  if width < 3.8cm or height < 5.5cm { panic("text-box-display-card needs at least 3.8 cm width and 5.5 cm height") }
  if icon-size <= 0pt or title-size <= 0pt or body-size <= 0pt or padding < 0pt {
    panic("icon and text sizes must be positive; padding cannot be negative")
  }
  if icon-size + 2 * padding > height * 0.28 { panic("icon-size and padding do not fit within the top badge") }

  let face = if print-mode { luma(224) } else { colour }
  let tab-fill = if print-mode { luma(190) }
    else if tab-colour == auto { colour.lighten(24%) } else { tab-colour }
  let footer-fill = if print-mode { luma(112) }
    else if footer-colour == auto { colour.darken(24%) } else { footer-colour }
  let facet-fill = if print-mode { luma(92) } else { colour.darken(38%) }
  let shade-fill = if print-mode { luma(170) } else { colour.darken(34%) }
  let copy-ink = if print-mode { black }
    else if text-colour != auto { text-colour }
    else { rgb("#353535") }
  let heading-ink = if print-mode { white }
    else if title-colour == auto { white } else { title-colour }
  let glyph-ink = if print-mode { black }
    else if icon-colour == auto { black } else { icon-colour }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let text-align = if rtl { right } else { left }
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { _tbd-icon(icon-size, glyph-ink, icon-style) }
  let body-content = {
    set par(leading: 0.20em, spacing: 0.04em, justify: true)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: copy-ink, body)
  }
  let heading-content = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: heading-ink, title)

  layout(avail => {
    let w = width
    let h = height
    let art = _tbd-art(w, h, face, tab-fill, footer-fill, facet-fill,
      shade-fill, print-mode)
    let body-column-width = if body-width == auto { w * 0.84 - 2 * padding } else { body-width }
    let title-column-width = if title-width == auto { w * 0.82 } else { title-width }
    if body-column-width <= 0pt or title-column-width <= 0pt { panic("body-width and title-width must be positive") }
    let body-box = box(width: body-column-width, height: h * 0.29,
      align(text-align + top, body-content))
    let title-box = box(width: title-column-width, height: h * 0.11,
      align(center + horizon, heading-content))
    let badge-center-y = h * (175 / 1200)
    let icon-x = (w - icon-size) / 2
    let icon-y = badge-center-y - icon-size / 2
    let body-y = h * 0.315 + body-offset-y
    let default-body-title-gap = h * 0.785 - (h * 0.315 + h * 0.29)
    let body-title-gap-value = if body-title-gap == auto { default-body-title-gap } else { body-title-gap }
    let title-y = body-y + h * 0.29 + body-title-gap-value + title-offset-y
    if measure(heading-content).height > h * 0.11 { panic("title does not fit; increase height or reduce title-size") }
    if measure(body-content).height > h * 0.29 { panic("body does not fit; increase height or reduce the copy") }

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: icon-x + icon-offset-x, dy: icon-y + icon-offset-y, box(width: icon-size, height: icon-size,
        align(center, icon-content)))
      place(top + left, dx: padding + w * 0.08 + body-offset-x, dy: body-y, body-box)
      place(top + left, dx: w * 0.09 + title-offset-x, dy: title-y, title-box)
    })
  })
}
