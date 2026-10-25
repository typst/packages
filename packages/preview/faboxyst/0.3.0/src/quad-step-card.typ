// One reusable portrait step card from PresentationGO's Quad Step Cards row.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _qsc-icon(size, ink, style) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if calc.rem(style, 4) == 0 {
    "<path d=\"M48 13c-13 0-23 10-23 22 0 9 4 14 10 20 3 3 5 7 5 12h16c0-5 2-9 5-12 6-6 10-11 10-20 0-12-10-22-23-22ZM40 72h16M42 80h12M48 6v3M17 19l5 5M79 19l-5 5M9 47h7M80 47h7\"/>"
  } else if calc.rem(style, 4) == 1 {
    "<path d=\"M49 13 55 19 64 18 67 27 74 31 71 40 75 48 68 54 68 63 58 65 53 72 44 68 35 71 31 62 23 58 26 49 22 41 29 35 30 26 39 24 44 16Z M49 32a10 10 0 1 0 0 20 10 10 0 0 0 0-20ZM68 70l4 4M77 65l4 4\"/>"
  } else if calc.rem(style, 4) == 2 {
    "<circle cx=\"45\" cy=\"51\" r=\"27\"/><circle cx=\"45\" cy=\"51\" r=\"15\"/><circle cx=\"45\" cy=\"51\" r=\"4\"/><path d=\"M48 48 76 20M64 20h12v12M71 27l7 7\"/>"
  } else {
    "<path d=\"M15 75V25M15 75h67M25 70V52h12v18M46 70V40h12v30M67 70V29h11v41M21 43l19-17 14 8 23-20M67 14h10v10\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// One portrait Quad Step Card with an upper icon medallion, colored halo,
/// white text panel, and lower numbered medallion. It emits one step only;
/// compose several calls to create a row.
#let quad-step-card(
  number: [01],
  title: [Lorem Ipsum],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.],
  icon: none,
  print-icon: none,
  icon-style: 0,
  width: 4.6cm,
  height: 4.6cm,
  direction: auto,
  colour: rgb("#F4A51C"),
  panel-colour: white,
  badge-colour: rgb("#303030"),
  title-colour: auto,
  text-colour: auto,
  icon-colour: white,
  number-colour: white,
  ring-size: 2.30cm,
  badge-size: 1.92cm,
  icon-size: 0.92cm,
  title-size: 12.5pt,
  body-size: 8.4pt,
  corner-radius: 0.38cm,
  title-width: auto,
  body-width: auto,
  title-body-gap: auto,
  number-size: 13pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  top-ring-offset-x: 0pt,
  top-ring-offset-y: 0pt,
  bottom-ring-offset-x: 0pt,
  bottom-ring-offset-y: 0pt,
  top-badge-offset-x: 0pt,
  top-badge-offset-y: 0pt,
  bottom-badge-offset-x: 0pt,
  bottom-badge-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if title-body-gap != auto and title-body-gap < 0pt { panic("title-body-gap cannot be negative") }
  if number-size <= 0pt { panic("number-size must be positive") }
  if icon-style < 0 or icon-style > 3 { panic("icon-style must be between 0 and 3") }
  if width < 3.8cm or height < 4.0cm { panic("quad-step-card needs at least 3.8 cm width and 4 cm height") }
  if ring-size <= badge-size or badge-size <= 0pt or icon-size <= 0pt {
    panic("ring-size must exceed badge-size; badge and icon sizes must be positive")
  }
  if title-size <= 0pt or body-size <= 0pt or corner-radius < 0pt {
    panic("text sizes must be positive and corner-radius cannot be negative")
  }

  let accent = if print-mode { luma(178) } else { colour }
  let face = if print-mode { white } else { panel-colour }
  let dark-face = if print-mode { luma(48) } else { badge-colour }
  let heading-ink = if print-mode { black }
    else if title-colour == auto { colour.darken(9%) } else { title-colour }
  let copy-ink = if print-mode { luma(40) }
    else if text-colour == auto { rgb("#555A60") } else { text-colour }
  let icon-ink = if print-mode { white } else { icon-colour }
  let number-ink = if print-mode { white } else { number-colour }
  let dir = if rtl { std.rtl } else { std.ltr }
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { _qsc-icon(icon-size, icon-ink, icon-style) }
  let title-content = text(font: "DejaVu Sans", dir: dir,
    size: title-size, weight: "bold", fill: heading-ink, title)
  let body-content = {
    set par(leading: 0.24em, spacing: 0.04em, justify: false)
    text(font: "DejaVu Sans", dir: dir, size: body-size,
      fill: copy-ink, body)
  }

  let top-overhang = ring-size / 2
  let card-y = top-overhang
  let card-bottom = card-y + height
  let total-height = height + ring-size
  let ring-x = (width - ring-size) / 2
  let badge-x = (width - badge-size) / 2
  let top-badge-y = (ring-size - badge-size) / 2
  let title-column-width = if title-width == auto { width * 0.94 } else { title-width }
  let body-column-width = if body-width == auto { width * 0.84 } else { body-width }
  if title-column-width <= 0pt or body-column-width <= 0pt { panic("title-width and body-width must be positive") }
  let title-box = box(width: title-column-width, height: 0.46cm,
    align(center + horizon, title-content))
  let body-box = box(width: body-column-width, height: height - 2.65cm,
    align(center + top, body-content))
  let shadow-fill = if print-mode { luma(225) }
    else { rgb("#5B626A").transparentize(84%) }
  let edge = if print-mode { (paint: luma(205), thickness: 0.65pt) } else { none }
  let card = box(width: width, height: height,
    radius: corner-radius, fill: face, stroke: edge, inset: 0pt)
  let shadow = box(width: width, height: height,
    radius: corner-radius, fill: shadow-fill, inset: 0pt)
  let bottom-ring-y = height
  let bottom-badge-y = bottom-ring-y + (ring-size - badge-size) / 2
  let badge-fill = box(width: badge-size, height: badge-size,
    radius: 50%, fill: dark-face, inset: 0pt)
  let ring-fill = box(width: ring-size, height: ring-size,
    radius: 50%, fill: accent, inset: 0pt)
  let icon-box = box(width: icon-size, height: icon-size,
    align(center + horizon, icon-content))
  let number-box = box(width: badge-size * 0.76, height: 0.42cm,
    align(center + horizon,
      text(font: "DejaVu Sans", dir: ltr, size: number-size,
        weight: "bold", fill: number-ink, number)))

  box(width: width, height: total-height, inset: 0pt, {
    // The lower medallion sits behind the white card; only its lower half shows.
    place(top + left, dx: ring-x + bottom-ring-offset-x, dy: bottom-ring-y + bottom-ring-offset-y, ring-fill)
    place(top + left, dx: badge-x + bottom-badge-offset-x, dy: bottom-badge-y + bottom-badge-offset-y, badge-fill)
    place(top + left, dx: 0pt, dy: card-y + 0.07cm, shadow)
    place(top + left, dx: 0pt, dy: card-y, card)
    let title-y = card-y + 1.50cm + title-offset-y
    let default-title-body-gap = 2.22cm - (1.50cm + 0.46cm)
    let title-body-gap-value = if title-body-gap == auto { default-title-body-gap } else { title-body-gap }
    let body-y = title-y + 0.46cm + title-body-gap-value + body-offset-y
    place(top + left, dx: width * 0.03 + title-offset-x, dy: title-y, title-box)
    place(top + left, dx: width * 0.08 + body-offset-x, dy: body-y, body-box)
    place(top + left, dx: badge-x + (badge-size - badge-size * 0.76) / 2 + number-offset-x, dy: card-bottom + 0.03cm + number-offset-y, number-box)
    // The upper medallion overlaps the panel edge and remains completely visible.
    place(top + left, dx: ring-x + top-ring-offset-x, dy: top-ring-offset-y, ring-fill)
    place(top + left, dx: badge-x + top-badge-offset-x, dy: top-badge-y + top-badge-offset-y, badge-fill)
    place(top + left, dx: badge-x + (badge-size - icon-size) / 2 + icon-offset-x, dy: (ring-size - icon-size) / 2 + icon-offset-y, icon-box)
  })
}
