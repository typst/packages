// One tall centered numbered hand-drawn text-box style adapted from the
// supplied Freepik Kinds Text Boxes reference. Attribution: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ktb2-art(width, height, fill-colour, shadow-colour, ink, stroke-width, mirror) = {
  let sw = stroke-width / 1cm * 500 / (width / 1cm)
  let rules = "M 311 76 C 310 111 312 160 311 203 M 334 76 L 334 203"
  let mirror-group = if mirror { "<g transform=\"translate(500 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 500 820\" preserveAspectRatio=\"none\">"
    + mirror-group
    + "<rect x=\"30\" y=\"20\" width=\"440\" height=\"770\" transform=\"translate(8 8)\" fill=\"" + shadow-colour.to-hex() + "\"/>"
    + "<rect x=\"30\" y=\"20\" width=\"440\" height=\"770\" fill=\"" + fill-colour.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\"/>"
    + "<path d=\"M 30 20 L 30 790 M 470 20 L 470 790\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\"/>"
    + "<rect x=\"39\" y=\"29\" width=\"422\" height=\"752\" fill=\"none\" stroke=\"" + ink.lighten(24%).to-hex() + "\" stroke-width=\"" + str(sw * 0.52) + "\" opacity=\"0.64\"/>"
    + "<path d=\"" + rules + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.9) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// A single tall text box with a centered number/rule motif, title and body.
/// Variants 2 and 5 share this layout; use palette and size parameters to style either.
#let kinds-text-box-2(
  number: [2],
  title: [Your title],
  body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
  width: auto,
  height: 7.4cm,
  direction: auto,
  colour: white,
  shadow-colour: auto,
  stroke-colour: auto,
  stroke-width: 1.6pt,
  number-colour: rgb("#68A1D5"),
  title-colour: auto,
  text-colour: auto,
  number-size: 34pt,
  title-size: 13.5pt,
  body-size: 8.4pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-width: auto,
  body-width: auto,
  title-body-gap: auto,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
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
  let fill-colour = if grayscale { white } else { colour }
  let offset-colour = if grayscale { luma(215) }
    else if shadow-colour == auto { rgb("#C7E5F5") } else { shadow-colour }
  let number-ink = if grayscale { luma(120) } else { number-colour }
  let heading-ink = if grayscale { black }
    else if title-colour == auto { rgb("#141414") } else { title-colour }
  let body-ink = if grayscale { luma(48) }
    else if text-colour == auto { rgb("#292929") } else { text-colour }
  let numeral = text(font: "DejaVu Sans", dir: text-dir,
    size: number-size, weight: "bold", fill: number-ink, number)
  let heading = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: heading-ink, title)
  let paragraph = {
    set par(leading: 0.24em, spacing: 0.1em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 4.3) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 2.8cm { panic("kinds-text-box-2 needs at least 2.8 cm of width") }
    let art = _ktb2-art(w, h, fill-colour, offset-colour, ink, stroke-width, rtl)
    let number-box = box(width: w * 0.34, align(center, numeral))
    let title-column-width = if title-width == auto { w * 0.84 } else { title-width }
    let body-column-width = if body-width == auto { w * 0.78 } else { body-width }
    if title-column-width <= 0pt or body-column-width <= 0pt { panic("title-width and body-width must be positive") }
    let title-box = box(width: title-column-width, align(center, heading))
    let body-box = box(width: body-column-width,
      align(if rtl { right } else { left }, paragraph))
    let title-y = h * 0.31 + title-offset-y
    let default-gap = h * 0.44 - (h * 0.31 + measure(title-box).height)
    let gap = if title-body-gap == auto { default-gap } else { title-body-gap }
    let body-y = h * 0.31 + measure(title-box).height + gap + body-offset-y

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      if rtl {
        place(top + right, dx: -w * 0.26 + number-offset-x, dy: h * 0.075 + number-offset-y, number-box)
      } else {
        place(top + left, dx: w * 0.26 + number-offset-x, dy: h * 0.075 + number-offset-y, number-box)
      }
      place(top + center, dx: title-offset-x, dy: title-y, title-box)
      place(top + center, dx: body-offset-x, dy: body-y, body-box)
    })
  })
}
