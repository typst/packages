// One numbered hand-drawn text-box style adapted from the supplied Freepik
// Kinds Text Boxes reference. Free-license attribution: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ktb1-art(width, height, colour, shadow-colour, ink, stroke-width, mirror) = {
  let sw = stroke-width / 1cm * 520 / (width / 1cm)
  let frame = "M 15 15 C 164 11 357 18 504 13 L 507 509 C 358 515 162 508 14 513 C 11 362 17 164 11 23 C 11 19 12 16 15 15 Z"
  let echo = "M 23 23 C 169 19 358 26 496 21 L 499 501 C 355 507 167 500 22 505 C 19 358 25 166 19 30 C 19 27 20 24 23 23 Z"
  let rules = "M 137 47 C 136 175 139 344 137 492 M 117 48 L 117 157"
  let mirror-group = if mirror { "<g transform=\"translate(520 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 520 540\" preserveAspectRatio=\"none\">"
    + mirror-group
    + "<path d=\"" + frame + "\" transform=\"translate(8 8)\" fill=\"" + shadow-colour.to-hex() + "\"/>"
    + "<path d=\"" + frame + "\" fill=\"" + colour.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "<path d=\"" + echo + "\" fill=\"none\" stroke=\"" + ink.lighten(24%).to-hex() + "\" stroke-width=\"" + str(sw * 0.52) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.65\"/>"
    + "<path d=\"" + rules + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.85) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// A single numbered text box with a tall twin-rule divider, editable title
/// and body. Variants 1 and 6 share this layout; color/number parameters style either.
#let kinds-text-box-1(
  number: [1],
  title: [Your title],
  body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.],
  width: auto,
  height: 6.8cm,
  direction: auto,
  colour: rgb("#FFF2A8"),
  shadow-colour: auto,
  stroke-colour: auto,
  stroke-width: 1.6pt,
  number-colour: rgb("#68A1D5"),
  title-colour: auto,
  text-colour: auto,
  number-size: 36pt,
  title-size: 13.5pt,
  body-size: 9.2pt,
  title-width: auto,
  body-width: auto,
  title-body-gap: auto,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
) = context {
  let grayscale = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if title-body-gap != auto and title-body-gap < 0pt { panic("title-body-gap cannot be negative") }
  if height <= 0pt or stroke-width <= 0pt or number-size <= 0pt or title-size <= 0pt or body-size <= 0pt {
    panic("height and stroke/text sizes must be positive")
  }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let ink = if grayscale { luma(45) }
    else if stroke-colour == auto { rgb("#211F1D") } else { stroke-colour }
  let fill-colour = if grayscale { luma(231) } else { colour }
  let offset-colour = if grayscale { luma(212) }
    else if shadow-colour == auto { colour.darken(9%) } else { shadow-colour }
  let number-ink = if grayscale { luma(122) } else { number-colour }
  let heading-ink = if grayscale { black }
    else if title-colour == auto { rgb("#141414") } else { title-colour }
  let body-ink = if grayscale { luma(48) }
    else if text-colour == auto { rgb("#292929") } else { text-colour }
  let heading = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: heading-ink, title)
  let paragraph = {
    set par(leading: 0.25em, spacing: 0.1em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }
  let numeral = text(font: "DejaVu Sans", dir: text-dir,
    size: number-size, weight: "bold", fill: number-ink, number)

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 6.8) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    let number-width = w * 0.17
    let text-left = w * 0.35
    let text-width = w * 0.57
    if w < 4cm { panic("kinds-text-box-1 needs at least 4 cm of width") }
    let number-box = box(width: number-width, numeral)
    let title-column-width = if title-width == auto { text-width } else { title-width }
    let body-column-width = if body-width == auto { text-width } else { body-width }
    if title-column-width <= 0pt or body-column-width <= 0pt { panic("title-width and body-width must be positive") }
    let title-box = box(width: title-column-width, heading)
    let body-box = box(width: body-column-width, paragraph)
    let mirror = rtl
    let art = _ktb1-art(w, h, fill-colour, offset-colour, ink, stroke-width, mirror)
    let top-y = h * 0.095 + number-offset-y
    let title-y = h * 0.105 + title-offset-y
    let title-h = measure(title-box).height
    let default-gap = h * 0.31 - (h * 0.105 + title-h)
    let gap = if title-body-gap == auto { default-gap } else { title-body-gap }
    let body-y = h * 0.105 + title-h + gap + body-offset-y

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      if rtl {
        place(top + right, dx: -w * 0.055 + number-offset-x, dy: top-y, align(right, number-box))
        place(top + right, dx: -text-left + title-offset-x, dy: title-y, align(right, title-box))
        place(top + right, dx: -text-left + body-offset-x, dy: body-y, align(right, body-box))
      } else {
        place(top + left, dx: w * 0.055 + number-offset-x, dy: top-y, number-box)
        place(top + left, dx: text-left + title-offset-x, dy: title-y, align(left, title-box))
        place(top + left, dx: text-left + body-offset-x, dy: body-y, align(left, body-box))
      }
    })
  })
}
