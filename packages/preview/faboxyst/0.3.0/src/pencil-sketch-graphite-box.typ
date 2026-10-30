// One rounded text box with a soft graphite-pencil hatch texture.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "session-box-utils.typ": session-title-layout

#let _psgb-art(width, height, paper, main-ink, soft-ink, trace-ink, stroke-width) = {
  let sw = stroke-width / 1cm * 500 / (width / 1cm)
  let shape = "M 39 26 C 102 20 167 25 231 22 C 310 19 390 25 458 22 C 472 22 476 32 474 48 C 472 72 478 96 474 119 C 470 143 477 160 471 176 C 467 185 444 182 418 184 C 346 188 285 180 222 184 C 153 188 96 178 40 183 C 26 183 24 171 27 151 C 31 126 23 101 27 76 C 30 54 24 36 31 29 Q 34 26 39 26 Z"
  let echo = "M 43 30 C 106 25 170 29 232 26 C 310 23 390 29 454 26 C 466 27 470 36 468 51 C 466 75 473 98 469 120 C 466 142 472 157 467 170 C 461 178 442 177 416 179 C 345 183 285 175 222 180 C 155 183 98 174 43 178 C 32 177 30 167 32 149 C 36 126 28 101 32 76 C 34 55 29 40 35 33 Q 38 30 43 30 Z"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 500 210\" preserveAspectRatio=\"none\">"
    + "<defs>"
    + "<clipPath id=\"paper-edge\"><path d=\"" + shape + "\"/></clipPath>"
    + "<pattern id=\"pencil-hatch\" width=\"16\" height=\"16\" patternUnits=\"userSpaceOnUse\" patternTransform=\"rotate(-38)\">"
    + "<path d=\"M 1 -2 C 0 4 2 9 1 18 M 6 -2 C 7 4 5 11 7 18 M 12 -2 C 11 4 13 10 12 18\" fill=\"none\" stroke=\"" + soft-ink.to-hex() + "\" stroke-width=\"1.05\" stroke-linecap=\"round\" opacity=\"0.42\"/>"
    + "<path d=\"M 3 1 C 4 5 2 9 4 14 M 10 0 C 9 6 11 10 10 15\" fill=\"none\" stroke=\"" + soft-ink.to-hex() + "\" stroke-width=\"0.65\" stroke-linecap=\"round\" opacity=\"0.27\"/>"
    + "</pattern>"
    + "<pattern id=\"pencil-cross\" width=\"20\" height=\"20\" patternUnits=\"userSpaceOnUse\" patternTransform=\"rotate(48)\">"
    + "<path d=\"M 4 -2 C 3 4 5 10 4 22 M 13 -1 C 14 5 12 12 14 21\" fill=\"none\" stroke=\"" + soft-ink.to-hex() + "\" stroke-width=\"0.8\" stroke-linecap=\"round\" opacity=\"0.17\"/>"
    + "</pattern>"
    + "</defs>"
    + "<path d=\"" + shape + "\" fill=\"" + paper.to-hex() + "\"/>"
    + "<path d=\"" + shape + "\" clip-path=\"url(#paper-edge)\" fill=\"url(#pencil-hatch)\"/>"
    + "<path d=\"" + shape + "\" clip-path=\"url(#paper-edge)\" fill=\"url(#pencil-cross)\"/>"
    + "<path d=\"" + echo + "\" fill=\"none\" stroke=\"" + trace-ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.72) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.68\"/>"
    + "<path d=\"" + shape + "\" fill=\"none\" stroke=\"" + main-ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.88\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// A single rounded text box with a light cross-hatched graphite-pencil surface.
///
/// Inspired by Presentation Process's Pencil Grayscale text-box treatment. The
/// source compares several colored rounded boxes with their pencil-rendered
/// results; this component keeps only one reusable box and adds editable text.
/// The pale hatch remains deliberately light for contrast. Print mode switches
/// the paper and pencil strokes to clean grayscale; Arabic direction is supported.
#let pencil-sketch-graphite-box(
  title: [],
  body: [],
  width: auto,
  height: 2.80cm,
  direction: auto,
  text-align: "auto",
  stroke-colour: auto,
  stroke-width: 1.70pt,
  icon: none,
  icon-position: "start",
  icon-size: 0.36cm,
  icon-colour: auto,
  icon-gap: 0.08cm,
  paper: rgb("#F6F3ED"),
  graphite-colour: rgb("#5C5A55"),
  title-colour: auto,
  text-colour: auto,
  title-size: 12pt,
  body-size: 8.6pt,
  title-gap: 0.08cm,
  padding: 0.52cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if (text-align != "auto" and text-align != "left" and text-align != "right" and text-align != "center") {
    panic("text-align must be auto, left, right, or center")
  }
  let face = if print-mode { white } else { paper }
  let main-ink = if print-mode { luma(70) }
    else if stroke-colour == auto { graphite-colour } else { stroke-colour }
  let icon-ink = if print-mode { luma(45) }
    else if icon-colour == auto { main-ink } else { icon-colour }
  let soft-ink = if print-mode { luma(158) } else { graphite-colour.lighten(55%) }
  let trace-ink = if print-mode { luma(188) } else { graphite-colour.lighten(68%) }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#292929") } else { title-colour }
  let body-ink = if print-mode { luma(48) }
    else if text-colour == auto { rgb("#4C4C4C") } else { text-colour }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let resolved-align = if text-align == "center" { center }
    else if text-align == "left" { left }
    else if text-align == "right" { right }
    else if rtl { right } else { left }
  if stroke-width <= 0pt { panic("stroke-width must be positive") }
  let title-text = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.30em, spacing: 0.20em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir,
      size: body-size, fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 7.2) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    let inner-w = w - 2 * padding
    let icon-layout = session-title-layout(title-text, icon, icon-position,
      icon-size, icon-ink, rtl, text-dir, resolved-align, inner-w, icon-gap)
    let title-content = icon-layout.title
    let icon-h = icon-layout.above-h
    let icon-gap-h = icon-layout.above-gap
    if inner-w <= 1cm { panic("pencil-sketch-graphite-box width is too small for the padding") }
    let title-box = box(width: inner-w,
      align(resolved-align + horizon, title-content))
    let body-box = box(width: inner-w,
      align(resolved-align + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = icon-h + icon-gap-h + title-h + gap + body-h
    if copy-h > H - 0.48cm {
      panic("pencil-sketch-graphite-box copy is too tall; increase height or shorten the text")
    }
    let copy-y = (H - copy-h) / 2
    let art = _psgb-art(w, H, face, main-ink, soft-ink, trace-ink, stroke-width)

    box(width: w, height: H, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      if icon-h > 0pt { place(top + left, dx: (padding) + icon-offset-x, dy: (copy-y) + icon-offset-y, icon-layout.above) }
      place(top + left, dx: (padding) + title-offset-x, dy: (copy-y + icon-h + icon-gap-h) + title-offset-y, title-box)
      if body-h > 0pt {
        place(top + left, dx: (padding) + body-offset-x, dy: (copy-y + icon-h + icon-gap-h + title-h + gap) + body-offset-y, body-box)
      }
    })
  })
}
