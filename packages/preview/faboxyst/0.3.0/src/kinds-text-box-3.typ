// One horizontal numbered hand-drawn text-box style adapted from the supplied
// Freepik Kinds Text Boxes reference. Free-license attribution: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ktb3-art(width, height, fill-colour, shadow-colour, ink, stroke-width, mirror) = {
  let sw = stroke-width / 1cm * 520 / (width / 1cm)
  let mirror-group = if mirror { "<g transform=\"translate(520 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 520 400\" preserveAspectRatio=\"none\">"
    + mirror-group
    + "<rect x=\"24\" y=\"20\" width=\"472\" height=\"360\" transform=\"translate(8 8)\" fill=\"" + shadow-colour.to-hex() + "\"/>"
    + "<rect x=\"24\" y=\"20\" width=\"472\" height=\"360\" fill=\"" + fill-colour.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\"/>"
    + "<rect x=\"32\" y=\"28\" width=\"456\" height=\"344\" fill=\"none\" stroke=\"" + ink.lighten(24%).to-hex() + "\" stroke-width=\"" + str(sw * 0.5) + "\" opacity=\"0.64\"/>"
    + "<path d=\"M 184 77 C 183 151 186 249 184 323\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.9) + "\" stroke-linecap=\"round\"/>"
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// A single horizontal numbered text box with an accent number, divider,
/// editable title and body. `number-position: "lower"` covers the closely
/// related fourth reference variant without duplicating the component.
#let kinds-text-box-3(
  number: [3],
  title: [Your title],
  body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
  width: auto,
  height: 6.2cm,
  direction: auto,
  number-position: "center",
  colour: rgb("#C5E6F8"),
  shadow-colour: auto,
  stroke-colour: auto,
  stroke-width: 1.6pt,
  number-colour: rgb("#FFE86D"),
  title-colour: auto,
  text-colour: auto,
  number-size: 52pt,
  title-size: 13.5pt,
  body-size: 9pt,
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
  if number-position != "center" and number-position != "lower" {
    panic("number-position must be center or lower")
  }
  if title-body-gap != auto and title-body-gap < 0pt { panic("title-body-gap cannot be negative") }
  if height <= 0pt or stroke-width <= 0pt or number-size <= 0pt or title-size <= 0pt or body-size <= 0pt {
    panic("height and stroke/text sizes must be positive")
  }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let ink = if grayscale { luma(45) }
    else if stroke-colour == auto { rgb("#211F1D") } else { stroke-colour }
  let fill-colour = if grayscale { luma(226) } else { colour }
  let offset-colour = if grayscale { luma(210) }
    else if shadow-colour == auto { rgb("#AFCFE5") } else { shadow-colour }
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
    let W = if width == auto { calc.min(avail.width / 1cm, 8.8) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 5.2cm { panic("kinds-text-box-3 needs at least 5.2 cm of width") }
    let art = _ktb3-art(w, h, fill-colour, offset-colour, ink, stroke-width, rtl)
    let number-box = box(width: w * 0.25, align(center, numeral))
    let default-text-width = w * 0.52
    let title-column-width = if title-width == auto { default-text-width } else { title-width }
    let body-column-width = if body-width == auto { default-text-width } else { body-width }
    if title-column-width <= 0pt or body-column-width <= 0pt { panic("title-width and body-width must be positive") }
    let heading-box = box(width: title-column-width,
      align(if rtl { right } else { left }, heading))
    let body-box = box(width: body-column-width,
      align(if rtl { right } else { left }, paragraph))
    let text-start = w * 0.405
    let title-y = h * 0.22 + title-offset-y
    let default-gap = h * 0.43 - (h * 0.22 + measure(heading-box).height)
    let gap = if title-body-gap == auto { default-gap } else { title-body-gap }
    let body-y = h * 0.22 + measure(heading-box).height + gap + body-offset-y
    let number-y = (if number-position == "lower" { h * 0.40 } else { h * 0.34 }) + number-offset-y

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      if rtl {
        place(top + right, dx: -w * 0.055 + number-offset-x, dy: number-y, align(center, number-box))
        place(top + right, dx: -text-start + title-offset-x, dy: title-y, heading-box)
        place(top + right, dx: -text-start + body-offset-x, dy: body-y, body-box)
      } else {
        place(top + left, dx: w * 0.055 + number-offset-x, dy: number-y, align(center, number-box))
        place(top + left, dx: text-start + title-offset-x, dy: title-y, heading-box)
        place(top + left, dx: text-start + body-offset-x, dy: body-y, body-box)
      }
    })
  })
}
