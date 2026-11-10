// One reusable horizontal row for a vertical numbered-chevron list.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _vcli-art(width, height, badge, badge-shadow, face, edge, shadow, mirror) = {
  let flip = if mirror { "<g transform=\"translate(1000 0) scale(-1 1)\">" } else { "<g>" }
  let points = "M 12 4 L 102 40 L 192 4 V 94 L 102 151 L 12 94 Z"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1000 160\" preserveAspectRatio=\"none\">"
    + flip
    + "<rect x=\"144\" y=\"10\" width=\"846\" height=\"144\" rx=\"26\" fill=\"" + shadow.to-hex() + "\" opacity=\"0.80\"/>"
    + "<rect x=\"140\" y=\"2\" width=\"848\" height=\"144\" rx=\"26\" fill=\"" + face.to-hex() + "\" stroke=\"" + edge.to-hex() + "\" stroke-width=\"1.4\"/>"
    + "<path d=\"" + points + "\" transform=\"translate(0 8)\" fill=\"" + badge-shadow.to-hex() + "\"/>"
    + "<path d=\"" + points + "\" fill=\"" + badge.to-hex() + "\"/>"
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One horizontal row from a vertical chevron list, with a numbered down-chevron,
/// bold title, and supporting copy. Compose multiple items outside this function.
/// RTL mirrors the badge to the right and reverses the title/body reading order.
#let vertical-chevron-list-item(
  number: [01],
  title: [Lorem Ipsum],
  body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.],
  width: auto,
  height: 1.55cm,
  direction: auto,
  badge-side: "start",
  colour: rgb("#103C51"),
  face-colour: white,
  title-colour: auto,
  text-colour: auto,
  number-colour: auto,
  title-size: 11pt,
  body-size: 6pt,
  title-width: auto,
  body-width: auto,
  title-body-gap: auto,
  number-size: 22pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if badge-side != "start" and badge-side != "end" { panic("badge-side must be start or end") }
  if title-body-gap != auto and title-body-gap < 0pt { panic("title-body-gap cannot be negative") }
  if number-size <= 0pt { panic("number-size must be positive") }
  if height <= 0pt or title-size <= 0pt or body-size <= 0pt {
    panic("height, title-size, and body-size must be positive")
  }
  let mirror = if badge-side == "start" { rtl } else { not rtl }
  let badge-fill = if print-mode { luma(178) } else { colour }
  let badge-shade = if print-mode { luma(115) } else { colour.darken(17%) }
  let face = if print-mode { white } else { face-colour }
  let edge = if print-mode { luma(215) } else { face.darken(2%) }
  let shadow = if print-mode { luma(222) } else { rgb("#74797D").transparentize(76%) }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#151719") } else { title-colour }
  let body-ink = if print-mode { luma(45) }
    else if text-colour == auto { rgb("#5E6062") } else { text-colour }
  let number-ink = if print-mode { luma(55) }
    else if number-colour == auto { rgb("#8EACCC") } else { number-colour }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let text-align = if rtl { right } else { left }
  let title-content = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.24em, spacing: 0.06em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir, size: body-size,
      fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 10.8) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 8.5cm { panic("vertical-chevron-list-item needs at least 8.5 cm of width") }
    let art = _vcli-art(w, h, badge-fill, badge-shade, face, edge, shadow, mirror)
    let title-column-width = if title-width == auto { w * 0.28 } else { title-width }
    let body-column-width = if body-width == auto { w * 0.44 } else { body-width }
    if title-column-width <= 0pt or body-column-width <= 0pt { panic("title-width and body-width must be positive") }
    let base-title-x = if mirror { w * 0.53 } else { w * 0.23 }
    let base-body-x = if mirror { w * 0.03 } else { w * 0.53 }
    let default-gap = if mirror { base-title-x - (base-body-x + body-column-width) }
      else { base-body-x - (base-title-x + title-column-width) }
    let column-gap = if title-body-gap == auto { default-gap } else { title-body-gap }
    let title-x = base-title-x + title-offset-x
    let body-x = (if mirror { title-x - column-gap - body-column-width } else { title-x + title-column-width + column-gap }) + body-offset-x
    let title-box = box(width: title-column-width, height: h,
      align(text-align + horizon, title-content))
    let body-box = box(width: body-column-width, height: h * 0.82,
      align(text-align + horizon, body-content))
    if measure(title-content).height > h * 0.8 { panic("title does not fit; increase height or reduce title-size") }
    if measure(body-content).height > h * 0.82 { panic("body does not fit; increase height or reduce the copy") }
    let badge-width = w * 0.19
    let number-box = box(width: badge-width, height: h,
      align(center + horizon,
        text(font: "DejaVu Sans", dir: ltr, size: number-size,
          weight: "bold", fill: number-ink, number)))
    let number-x = (if mirror { w * 0.805 } else { w * 0.005 }) + number-offset-x

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: title-x, dy: title-offset-y, title-box)
      place(top + left, dx: body-x, dy: (h - h * 0.82) / 2 + body-offset-y, body-box)
      place(top + left, dx: number-x, dy: number-offset-y, number-box)
    })
  })
}
