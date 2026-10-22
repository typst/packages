// One reusable side-ribbon infographic text card adapted from the supplied
// Freepik vector. A separate stack helper can overlap several individual cards.
// Free-license attribution: Designed by Alvaro_cabrera / Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _tcic-art(width, height, fill-colour, shade, highlight, spine-colour, shadow, ink, stroke-width, spine-width, mirror, show-spine) = {
  let sw = stroke-width / 1cm * 520 / (width / 1cm)
  let spine-units = spine-width / width * 520
  let spine-left = 78
  let spine-right = spine-left + spine-units
  let spine-path = "M " + str(spine-left) + " 0 L " + str(spine-right) + " 0 L " + str(spine-right + 4) + " 290 L " + str(spine-left + 4) + " 290 Z"
  let spine-edge = "M " + str(spine-right - 6) + " 2 L " + str(spine-right) + " 2 L " + str(spine-right + 4) + " 288 L " + str(spine-right - 2) + " 288 Z"
  let band = "M 12 34 L 506 12 L 510 248 L 19 270 Z"
  let mirror-group = if mirror { "<g transform=\"translate(520 0) scale(-1 1)\">" } else { "<g>" }
  let spine-layer = if show-spine {
    (
      "<path d=\"" + spine-path + "\" transform=\"translate(7 4)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.48\"/>"
      + "<path d=\"" + spine-path + "\" fill=\"" + spine-colour.to-hex() + "\" stroke=\"" + ink.lighten(38%).to-hex() + "\" stroke-width=\"" + str(sw * 0.24) + "\"/>"
      + "<path d=\"" + spine-edge + "\" fill=\"" + ink.to-hex() + "\" opacity=\"0.10\"/>"
    )
  } else { "" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 520 290\" preserveAspectRatio=\"none\">"
    + "<defs><linearGradient id=\"panel\" x1=\"0%\" y1=\"0%\" x2=\"100%\" y2=\"0%\"><stop offset=\"0%\" stop-color=\"" + shade.to-hex() + "\"/><stop offset=\"100%\" stop-color=\"" + highlight.to-hex() + "\"/></linearGradient></defs>"
    + mirror-group
    + "<path d=\"" + band + "\" transform=\"translate(7 8)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.55\"/>"
    + "<path d=\"" + band + "\" fill=\"url(#panel)\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.44) + "\" stroke-linejoin=\"round\"/>"
    + spine-layer
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

#let _tcic-spine(width, height, fill, shadow, mirror) = {
  let mirror-group = if mirror { "<g transform=\"translate(100 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 1000\" preserveAspectRatio=\"none\">"
    + mirror-group
    + "<path d=\"M 0 0 L 98 0 L 100 1000 L 2 1000 Z\" transform=\"translate(5 0)\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.6\"/>"
    + "<path d=\"M 0 0 L 94 0 L 96 1000 L 2 1000 Z\" fill=\"" + fill.to-hex() + "\" stroke=\"" + shadow.to-hex() + "\" stroke-width=\"1.2\"/>"
    + "<path d=\"M 84 0 L 94 0 L 96 1000 L 86 1000 Z\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.24\"/>"
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One landscape infographic text card with an adjustable vertical paper ribbon.
/// Use `show-spine: false` only when the card is placed under a shared stack ribbon.
#let three-color-infographic-card(
  title: [YOUR TEXT HERE],
  body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.],
  width: auto,
  height: 4.0cm,
  direction: auto,
  spine-side: "start",
  spine-width: 1.1cm,
  show-spine: true,
  colour: rgb("#4B84BE"),
  shade-colour: auto,
  highlight-colour: auto,
  spine-colour: rgb("#F5F3EF"),
  shadow-colour: auto,
  stroke-colour: auto,
  stroke-width: 0.8pt,
  title-colour: auto,
  text-colour: auto,
  title-size: 13pt,
  body-size: 9.2pt,
  title-gap: 0.12cm,
  padding: 0.16cm,
  title-width: auto,
  body-width: auto,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
) = context {
  let grayscale = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if spine-side != "start" and spine-side != "end" {
    panic("spine-side must be start or end")
  }
  if height <= 0pt or stroke-width < 0pt or title-size <= 0pt or body-size <= 0pt {
    panic("height and text sizes must be positive; stroke-width cannot be negative")
  }
  if padding < 0pt or title-gap < 0pt { panic("padding and title-gap cannot be negative") }
  if spine-width <= 0pt { panic("spine-width must be positive") }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let mirror = if spine-side == "start" { rtl } else { not rtl }
  let ink = if grayscale { luma(70) }
    else if stroke-colour == auto { colour.darken(24%) } else { stroke-colour }
  let fill-colour = if grayscale { luma(220) } else { colour }
  let shade = if grayscale { luma(198) }
    else if shade-colour == auto { fill-colour.darken(14%) } else { shade-colour }
  let highlight = if grayscale { luma(235) }
    else if highlight-colour == auto { fill-colour.lighten(12%) } else { highlight-colour }
  let shadow = if grayscale { luma(175) }
    else if shadow-colour == auto { rgb("#979797") } else { shadow-colour }
  let spine = if grayscale { white } else { spine-colour }
  let heading-ink = if grayscale { black }
    else if title-colour == auto { white } else { title-colour }
  let body-ink = if grayscale { luma(28) }
    else if text-colour == auto { white } else { text-colour }
  let heading = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: heading-ink, title)
  let paragraph = {
    set par(leading: 0.26em, spacing: 0.08em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 9.2) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 5.6cm { panic("three-color-infographic-card needs at least 5.6 cm of width") }
    if spine-width >= w / 3 { panic("spine-width must be less than one third of card width") }
    let default-text-width = w * 0.59 - 2 * padding
    let title-column-width = if title-width == auto { default-text-width } else { title-width }
    let body-column-width = if body-width == auto { default-text-width } else { body-width }
    if title-column-width <= 0pt or body-column-width <= 0pt { panic("title-width and body-width must be positive") }
    let text-align = if rtl { right } else { left }
    let title-box = box(width: title-column-width, align(text-align, heading))
    let body-box = box(width: body-column-width, align(text-align, paragraph))
    let art = _tcic-art(w, h, fill-colour, shade, highlight, spine,
      shadow, ink, stroke-width, spine-width, mirror, show-spine)
    let text-x = if mirror { w * 0.06 } else { w * 0.35 }
    let body-y = h * 0.24 + measure(title-box).height + title-gap

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: text-x + padding + title-offset-x, dy: h * 0.24 + title-offset-y, title-box)
      place(top + left, dx: text-x + padding + body-offset-x, dy: body-y + body-offset-y, body-box)
    })
  })
}

/// Stack two or more individual infographic cards under one continuous
/// light-gray spine. Panels overlap slightly; the spine overhangs the stack
/// above and below. This is a reusable infographic group, not a slide layout.
#let three-color-infographic-stack(
  cards: (
    (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#4B84BE")),
    (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#CA5209")),
    (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#C78D00")),
  ),
  width: auto,
  card-height: 3.7cm,
  overlap: 0.66cm,
  spine-overhang: 0.28cm,
  spine-width: 1.1cm,
  spine-side: "start",
  direction: auto,
  spine-colour: rgb("#E3E1DE"),
  spine-shadow: rgb("#AAA9A7"),
  colours: (rgb("#4B84BE"), rgb("#CA5209"), rgb("#C78D00")),
  title-size: 13pt,
  body-size: 9.2pt,
  padding: 0.16cm,
  title-gap: 0.12cm,
  title-width: auto,
  body-width: auto,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
) = context {
  let grayscale = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if cards.len() < 2 { panic("three-color-infographic-stack needs at least two cards") }
  if card-height <= 0pt or spine-overhang < 0pt or overlap < 0pt or spine-width <= 0pt {
    panic("card-height and spine-width must be positive; overlap and overhang cannot be negative")
  }
  if spine-side != "start" and spine-side != "end" { panic("spine-side must be start or end") }
  if colours.len() == 0 { panic("colours must contain at least one palette colour") }
  let mirror = if spine-side == "start" { rtl } else { not rtl }
  let strip-fill = if grayscale { white } else { spine-colour }
  let strip-shadow = if grayscale { luma(175) } else { spine-shadow }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 9.2) }
      else { width / 1cm }
    let w = W * 1cm
    if w < 5.6cm { panic("three-color-infographic-stack needs at least 5.6 cm of width") }
    if spine-width >= w / 3 { panic("spine-width must be less than one third of card width") }
    let panel-width = w
    let panels = range(cards.len()).map(index => {
      let item = cards.at(index)
      if type(item) != dictionary { panic("each card entry must be a dictionary") }
      let title = if "title" in item { item.at("title") } else { [YOUR TEXT HERE] }
      let body = if "body" in item { item.at("body") } else { [] }
      let fill = if "colour" in item { item.at("colour") }
        else { colours.at(calc.rem(index, colours.len())) }
      three-color-infographic-card(
        title: title,
        body: body,
        width: panel-width,
        height: card-height,
        direction: direction,
        spine-side: spine-side,
        spine-width: spine-width,
        show-spine: false,
        colour: fill,
        title-size: title-size,
        body-size: body-size,
        title-gap: title-gap,
        padding: padding,
        title-width: title-width,
        body-width: body-width,
        title-offset-x: title-offset-x,
        title-offset-y: title-offset-y,
        body-offset-x: body-offset-x,
        body-offset-y: body-offset-y,
      )
    })
    let content-height = cards.len() * card-height - (cards.len() - 1) * overlap
    let total-height = content-height + 2 * spine-overhang
    let panel-stack = stack(spacing: -overlap, ..panels)
    let spine-x = if mirror { w - w * 0.15 - spine-width } else { w * 0.15 }
    let spine-art = _tcic-spine(spine-width, total-height, strip-fill, strip-shadow, mirror)
    box(width: w, height: total-height, inset: 0pt, {
      place(top + left, dx: 0pt, dy: spine-overhang, panel-stack)
      if grayscale {
        for index in range(cards.len() - 1) {
          let y = spine-overhang + (index + 1) * (card-height - overlap)
          place(top + left, dx: w * 0.024, dy: y,
            line(length: w * 0.952, stroke: (paint: luma(125), thickness: 0.6pt)))
        }
      }
      place(top + left, dx: spine-x, dy: 0pt, spine-art)
    })
  })
}
