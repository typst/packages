// One standalone hand-drawn bullet panel adapted from the supplied
// Freepik Business Brochure reference. Free-license attribution: Designed by Freepik.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hdbp-art(width, height, colour, ink, stroke-width) = {
  let sw = stroke-width / 1cm * 540 / (width / 1cm)
  let panel = "M 23 18 C 143 13 338 20 516 16 C 520 84 514 190 519 264 C 369 270 167 263 24 270 C 19 207 25 91 20 22 C 20 20 21 19 23 18 Z"
  let echo = "M 29 24 C 151 20 342 26 509 22 C 513 89 508 190 512 258 C 367 264 170 257 30 264 C 25 203 31 94 26 27 C 26 26 27 25 29 24 Z"
  let shadow = "M 24 270 C 167 263 369 270 519 264 L 514 279 C 369 284 166 278 27 282 Z"
  let marks = "M 34 17 l 17 2 m -15 4 l 11 1 M 484 265 l 20 -2 m -16 5 l 10 -1 M 19 201 l 2 -18 m 3 14 l 1 -17 M 504 43 l 1 15"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 540 290\" preserveAspectRatio=\"none\">"
    + "<path d=\"" + shadow + "\" transform=\"translate(0 1)\" fill=\"" + ink.to-hex() + "\" opacity=\"0.26\"/>"
    + "<path d=\"" + panel + "\" fill=\"" + colour.to-hex() + "\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "<path d=\"" + echo + "\" fill=\"none\" stroke=\"" + ink.lighten(26%).to-hex() + "\" stroke-width=\"" + str(sw * 0.58) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.72\"/>"
    + "<path d=\"" + marks + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.92) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One editable hand-drawn panel containing a customizable bulleted list.
///
/// `items` is a tuple of content blocks. Direction controls both text flow and
/// bullet placement. The panel grows as needed for long, wrapped entries;
/// `grayscale: auto` follows the active theme, while `true` or `false` pins it.
#let hand-drawn-bullet-panel(
  items: (),
  width: auto,
  height: auto,
  min-height: 3.9cm,
  direction: auto,
  grayscale: auto,
  colour: rgb("#20B4DC"),
  stroke-colour: auto,
  stroke-width: 1.55pt,
  text-colour: auto,
  bullet-colour: auto,
  text-size: 8pt,
  bullet-size: 0.095cm,
  bullet-gap: 0.16cm,
  item-gap: 0.11cm,
  padding: 0.34cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
) = context {
  let print-mode = if grayscale == auto { theme-state.get().mode == "print" }
    else { grayscale }
  if type(print-mode) != bool { panic("grayscale must be auto or a boolean") }
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if items.len() == 0 { panic("hand-drawn-bullet-panel needs at least one item") }
  if min-height <= 0pt or stroke-width <= 0pt or text-size <= 0pt or bullet-size <= 0pt {
    panic("min-height, stroke-width, text-size, and bullet-size must be positive")
  }
  if bullet-gap < 0pt or item-gap < 0pt or padding < 0pt {
    panic("bullet-gap, item-gap, and padding cannot be negative")
  }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let fill-ink = if print-mode { luma(224) } else { colour }
  let edge-ink = if print-mode { luma(52) }
    else if stroke-colour == auto { rgb("#242222") } else { stroke-colour }
  let body-ink = if print-mode { luma(35) }
    else if text-colour == auto { rgb("#25343B") } else { text-colour }
  let dot-ink = if print-mode { luma(26) }
    else if bullet-colour == auto { edge-ink } else { bullet-colour }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 8.2) }
      else { width / 1cm }
    let w = W * 1cm
    let content-width = w - 2 * padding
    if content-width <= 1cm { panic("panel width is too small for padding and bullets") }
    let styled-items = items.map(item =>
      text(font: "DejaVu Sans", dir: text-dir, size: text-size,
        fill: body-ink, item)
    )
    let body = block(width: content-width, inset: 0pt, {
      set text(dir: text-dir)
      set align(if rtl { right } else { left })
      set par(leading: 0.20em, spacing: 0pt, justify: false)
      list(
        marker: text(font: "DejaVu Sans", size: bullet-size * 3,
          fill: dot-ink)[•],
        indent: bullet-size + 0.08cm,
        body-indent: bullet-gap,
        spacing: item-gap,
        ..styled-items,
      )
    })
    let body-height = measure(body).height
    let required-height = body-height + 2 * padding + 0.16cm
    let h = if height == auto { calc.max(min-height, required-height) }
      else { calc.max(height, required-height) }
    let art = _hdbp-art(w, h, fill-ink, edge-ink, stroke-width)

    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: (padding) + body-offset-x, dy: ((h - body-height) / 2) + body-offset-y, body)
    })
  })
}
