// A standalone hand-drawn folded title ribbon adapted from the supplied
// Freepik Business Brochure reference. Free-license attribution: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hdfr-art(width, height, colour, ink, fold-ink, fold-size, stroke-width, mirror) = {
  let sw = stroke-width / 1cm * 500 / (width / 1cm)
  let depth = fold-size / width * 500
  let ribbon = (
    "M 18 13 C 103 9 171 16 250 12 C 335 8 411 16 482 12 "
    + "L " + str(482 - depth) + " 55 L 482 98 "
    + "C 403 102 331 96 250 101 C 166 105 94 97 19 101 "
    + "C 13 95 20 77 17 56 C 15 37 20 20 18 13 Z"
  )
  let echo = (
    "M 24 20 C 104 16 174 22 251 19 C 332 15 405 22 475 19 "
    + "L " + str(475 - depth * 0.82) + " 55 L 475 92 "
    + "C 401 96 329 90 250 95 C 169 99 98 91 25 95 "
    + "C 21 89 25 75 22 55 C 20 39 25 27 24 20 Z"
  )
  // Exposed underside fills the whole V-cut; the crease divides it into a
  // folded-back flap rather than leaving a detached-looking triangular chip.
  let fold = (
    "M " + str(482 - depth) + " 55 L 482 12 L 482 98 Z"
  )
  let crease = (
    "M " + str(482 - depth) + " 55 C "
    + str(482 - depth * 0.62) + " 52 "
    + str(482 - depth * 0.28) + " 53 482 55"
  )
  let mirror-group = if mirror { "<g transform=\"translate(500 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 500 110\" preserveAspectRatio=\"none\">"
    + mirror-group
    + "<path d=\"" + ribbon + "\" transform=\"translate(0 5)\" fill=\"" + fold-ink.to-hex() + "\" opacity=\"0.55\"/>"
    + "<path d=\"" + echo + "\" fill=\"none\" stroke=\"" + ink.lighten(26%).to-hex() + "\" stroke-width=\"" + str(sw * 0.62) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.76\"/>"
    + "<path d=\"" + fold + "\" fill=\"" + fold-ink.to-hex() + "\" opacity=\"0.88\"/>"
    + "<path d=\"" + ribbon + "\" fill=\"" + colour.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "<path d=\"" + crease + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.72) + "\" stroke-linecap=\"round\" opacity=\"0.88\"/>"
    + "</g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One editable, hand-drawn ribbon label with a folded V-notch at either end.
///
/// The logical `fold-side` follows `direction`; Arabic RTL therefore moves an
/// `end` fold to the visual left. Only this ribbon component is drawn.
#let hand-drawn-folded-ribbon(
  title: [],
  width: auto,
  height: 1.46cm,
  direction: auto,
  fold-side: "end",
  fold-size: 0.62cm,
  colour: rgb("#FFB52F"),
  stroke-colour: auto,
  stroke-width: 1.45pt,
  title-colour: auto,
  title-size: 14pt,
  text-align: "center",
  padding: 0.32cm,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if (fold-side != "start" and fold-side != "end" and fold-side != "left" and fold-side != "right") {
    panic("fold-side must be start, end, left, or right")
  }
  if (text-align != "left" and text-align != "right" and text-align != "center") {
    panic("text-align must be left, right, or center")
  }
  if height <= 0pt or fold-size <= 0pt or stroke-width <= 0pt or padding < 0pt {
    panic("height, fold-size, and stroke-width must be positive; padding cannot be negative")
  }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let align-x = if text-align == "left" { left }
    else if text-align == "right" { right } else { center }
  let fill-ink = if print-mode { luma(220) } else { colour }
  let edge-ink = if print-mode { luma(55) }
    else if stroke-colour == auto { rgb("#24201D") } else { stroke-colour }
  let crease-ink = if print-mode { luma(145) } else { colour.darken(31%) }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#171717") } else { title-colour }
  let title-content = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 8.0) }
      else { width / 1cm }
    let w = W * 1cm
    if w <= 2 * padding + fold-size + 0.5cm {
      panic("ribbon width is too small for its fold and title")
    }
    if fold-size >= w / 3 { panic("fold-size must be smaller than one third of ribbon width") }
    let mirror = if fold-side == "left" { true }
      else if fold-side == "right" { false }
      else if fold-side == "start" { not rtl }
      else { rtl }
    let title-box = box(width: w - 2 * padding - fold-size * 0.45,
      align(align-x + horizon, title-content))
    let title-h = measure(title-box).height
    if title-h > height - 0.18cm { panic("title is too tall for the ribbon") }
    let title-y = (height - title-h) / 2
    let art = _hdfr-art(w, height, fill-ink, edge-ink, crease-ink,
      fold-size, stroke-width, mirror)

    box(width: w, height: height, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: padding, dy: title-y, title-box)
    })
  })
}
