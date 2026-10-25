// One irregular pencil-drawn oval callout, adapted from SlideHunter's
// Hand Drawn Callouts & Boxes PowerPoint Template.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "session-box-utils.typ": session-title-layout

#let _pse-frame(width, height, ink, trace, stroke-width) = {
  let sw = stroke-width / 1cm * 500 / (width / 1cm)
  let main-path = "M 42 108 C 34 82 67 55 121 40 C 185 22 279 21 355 38 C 422 53 474 82 465 111 C 457 142 389 169 305 180 C 226 191 134 177 79 151 C 53 139 39 123 42 108 Z"
  let echo-path = "M 47 105 C 42 79 73 51 128 37 C 193 20 287 25 360 43 C 427 59 468 84 460 115 C 451 146 381 174 300 184 C 223 193 131 172 75 147 C 51 136 43 119 47 105 Z"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 500 210\" preserveAspectRatio=\"none\">"
    + "<path d=\"" + echo-path + "\" fill=\"none\" stroke=\"" + trace.to-hex() + "\" stroke-width=\"" + str(sw * 0.62) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\" opacity=\"0.72\"/>"
    + "<path d=\"" + main-path + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// A single hand-drawn elliptical callout with an optional title and body.
///
/// Adapted from one of the freehand oval outlines in SlideHunter's *Hand Drawn
/// Callouts & Boxes* reference. It draws one editable oval, not the sheet of
/// surrounding callouts. In print mode the primary and echo strokes become
/// separate grayscale values; Arabic RTL text is shaped and centered normally.
#let pencil-sketch-ellipse(
  title: [],
  body: [],
  width: auto,
  height: 2.80cm,
  direction: auto,
  text-align: "center",
  colour: rgb("#D99042"),
  stroke-colour: auto,
  stroke-width: 2.10pt,
  icon: none,
  icon-position: "top",
  icon-size: 0.34cm,
  icon-colour: auto,
  icon-gap: 0.08cm,
  paper: rgb("#FFFEFC"),
  title-colour: auto,
  text-colour: auto,
  title-size: 12pt,
  body-size: 8.6pt,
  title-gap: 0.07cm,
  text-width: 0.84,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if (text-align != "center" and text-align != "left" and text-align != "right") {
    panic("text-align must be center, left, or right")
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
  let align-x = if text-align == "left" { left }
    else if text-align == "right" { right }
    else { center }
  if stroke-width <= 0pt { panic("stroke-width must be positive") }
  let title-text = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.30em, spacing: 0.20em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir,
      size: body-size, fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 6.4) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    if text-width <= 0.5 or text-width > 0.92 {
      panic("text-width must be greater than 0.5 and no greater than 0.92")
    }
    let inner-w = w * text-width
    let icon-layout = session-title-layout(title-text, icon, icon-position,
      icon-size, icon-ink, rtl, text-dir, align-x, inner-w, icon-gap)
    let title-content = icon-layout.title
    let icon-h = icon-layout.above-h
    let icon-gap-h = icon-layout.above-gap
    let title-box = box(width: inner-w,
      align(align-x + horizon, title-content))
    let body-box = box(width: inner-w,
      align(align-x + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = icon-h + icon-gap-h + title-h + gap + body-h
    let copy-y = (H - copy-h) / 2
    let copy-x = (w - inner-w) / 2
    let frame = _pse-frame(w, H, frame-ink, frame-trace, stroke-width)

    box(width: w, height: H, fill: face, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, frame)
      if icon-h > 0pt { place(top + left, dx: copy-x, dy: copy-y, icon-layout.above) }
      place(top + left, dx: copy-x, dy: copy-y + icon-h + icon-gap-h, title-box)
      if body-h > 0pt {
        place(top + left, dx: copy-x, dy: copy-y + icon-h + icon-gap-h + title-h + gap, body-box)
      }
    })
  })
}
