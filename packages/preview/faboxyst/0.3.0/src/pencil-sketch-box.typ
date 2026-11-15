// One irregular pencil-outline information box, adapted from SlideHunter's
// Hand Drawn Callouts & Boxes PowerPoint Template.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "session-box-utils.typ": session-title-layout

#let _psb-frame(width, height, ink, trace, stroke-width) = {
  let sw = stroke-width / 1cm * 500 / (width / 1cm)
  let main-path = "M 31 29 C 92 23 159 30 226 26 C 309 21 393 31 466 26 C 478 28 472 47 475 67 C 479 101 470 137 474 174 C 475 183 451 180 424 183 C 349 187 294 177 229 182 C 151 187 87 177 31 181 C 21 180 27 159 23 135 C 19 102 28 73 23 48 C 21 38 23 31 31 29 Z"
  let echo-path = "M 28 34 C 93 28 157 34 225 31 C 308 27 394 35 461 31 C 470 34 467 50 469 69 C 473 102 464 136 469 169 C 467 176 447 175 421 177 C 349 181 294 172 230 177 C 151 181 90 172 35 176 C 28 173 32 157 28 134 C 25 103 33 73 28 49 C 26 42 25 36 28 34 Z"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 500 210\" preserveAspectRatio=\"none\">"
    + "<path d=\"" + echo-path + "\" fill=\"none\" stroke=\"" + trace.to-hex() + "\" stroke-width=\"" + str(sw * 0.62) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.72\"/>"
    + "<path d=\"" + main-path + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// A single rounded-rectangle information box with an irregular double pencil outline.
///
/// Based on the hand-drawn rectangle in SlideHunter's *Hand Drawn Callouts &
/// Boxes* reference. The source sheet of many callouts is omitted; this reusable
/// component draws only one box. In print groups its two sketch strokes become
/// separate gray values to keep the hand-drawn edge visible.
#let pencil-sketch-box(
  title: [],
  body: [],
  width: auto,
  height: 2.70cm,
  direction: auto,
  text-align: "auto",
  colour: rgb("#D7A824"),
  stroke-colour: auto,
  stroke-width: 2.10pt,
  icon: none,
  icon-position: "start",
  icon-size: 0.36cm,
  icon-colour: auto,
  icon-gap: 0.08cm,
  paper: rgb("#FFFEFC"),
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
  let frame-ink = if print-mode { luma(72) }
    else if stroke-colour == auto { colour } else { stroke-colour }
  let frame-trace = if print-mode { luma(172) } else { frame-ink.lighten(28%) }
  let icon-ink = if print-mode { luma(45) }
    else if icon-colour == auto { frame-ink } else { icon-colour }
  let face = if print-mode { white } else { paper }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#323232") } else { title-colour }
  let body-ink = if print-mode { luma(48) }
    else if text-colour == auto { rgb("#555555") } else { text-colour }
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
    if inner-w <= 1cm { panic("pencil-sketch-box width is too small for the padding") }
    let title-box = box(width: inner-w,
      align(resolved-align + horizon, title-content))
    let body-box = box(width: inner-w,
      align(resolved-align + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = icon-h + icon-gap-h + title-h + gap + body-h
    let copy-y = (H - copy-h) / 2
    let frame = _psb-frame(w, H, frame-ink, frame-trace, stroke-width)

    box(width: w, height: H, fill: face, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, frame)
      if icon-h > 0pt { place(top + left, dx: (padding) + icon-offset-x, dy: (copy-y) + icon-offset-y, icon-layout.above) }
      place(top + left, dx: (padding) + title-offset-x, dy: (copy-y + icon-h + icon-gap-h) + title-offset-y, title-box)
      if body-h > 0pt {
        place(top + left, dx: (padding) + body-offset-x, dy: (copy-y + icon-h + icon-gap-h + title-h + gap) + body-offset-y, body-box)
      }
    })
  })
}
