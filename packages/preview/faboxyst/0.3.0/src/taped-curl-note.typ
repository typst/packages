// A paper note held by a strip of translucent tape, with a lifted lower corner.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl
#import "session-box-utils.typ": session-title-layout

#let _tcn-art(width, height, paper, tape-colour, rtl, print-mode, stroke-colour, stroke-width, tape-angle: -38deg) = {
  let sw = stroke-width / 1cm * 300 / (width / 1cm)
  let shape = "M 29 29 C 94 26 182 31 266 29 C 272 29 274 34 273 43 L 271 270 C 271 282 263 289 250 292 C 238 295 225 291 216 298 C 208 304 205 316 202 326 C 148 328 82 325 30 326 C 26 326 28 314 28 303 L 29 51 C 28 41 25 33 29 29 Z"
  let flap = "M 202 326 C 209 311 219 301 232 299 C 247 296 261 286 271 270 C 269 289 260 301 247 310 C 234 319 216 329 202 326 Z"
  let ink = if print-mode { luma(34) }
    else if stroke-colour == auto { rgb("#3B3835") } else { stroke-colour }
  let flap-fill = if print-mode { luma(239) } else { paper.lighten(16%) }
  let crease = if print-mode { luma(106) } else { rgb("#77716A") }
  let tape-edge = if print-mode { luma(130) } else { tape-colour.darken(24%) }
  let tape-hi = if print-mode { luma(247) } else { tape-colour.lighten(25%) }
  let mirror = if rtl { "<g transform=\"translate(300 0) scale(-1 1)\">" } else { "<g>" }
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 300 360\" preserveAspectRatio=\"none\">"
    + "<defs><linearGradient id=\"curl-shade\" x1=\"0\" y1=\"0\" x2=\"1\" y2=\"1\"><stop offset=\"0\" stop-color=\"" + flap-fill.to-hex() + "\"/><stop offset=\"1\" stop-color=\"" + (if print-mode { luma(210) } else { paper.darken(8%) }).to-hex() + "\"/></linearGradient></defs>"
    + mirror
    + "<path d=\"" + shape + "\" transform=\"translate(4 7)\" fill=\"#4B4844\" opacity=\"0.17\"/>"
    + "<path d=\"" + flap + "\" transform=\"translate(3 5)\" fill=\"#4B4844\" opacity=\"0.24\"/>"
    + "<path d=\"" + shape + "\" fill=\"" + paper.to-hex() + "\" stroke=\"none\"/>"
    + "<path d=\"" + flap + "\" fill=\"url(#curl-shade)\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw * 0.88) + "\" stroke-linejoin=\"round\"/>"
    + "<path d=\"" + shape + "\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"" + str(sw) + "\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
    + "<path d=\"M 204 325 C 225 316 251 295 270 272\" fill=\"none\" stroke=\"" + crease.to-hex() + "\" stroke-width=\"" + str(sw * 0.52) + "\" stroke-linecap=\"round\" opacity=\"0.82\"/>"
    + "<g transform=\"rotate(-38 91 49)\">"
    + "<path d=\"M 35 33 L 42 29 L 51 32 L 62 29 L 74 32 L 87 29 L 101 32 L 115 29 L 129 32 L 141 29 L 146 35 L 142 42 L 146 49 L 142 56 L 145 62 L 138 67 L 124 64 L 111 67 L 96 64 L 82 67 L 68 64 L 53 67 L 40 64 L 35 58 L 39 51 L 34 44 L 38 38 Z\" fill=\"" + tape-colour.to-hex() + "\" fill-opacity=\"0.78\" stroke=\"" + tape-edge.to-hex() + "\" stroke-width=\"1.6\" stroke-linejoin=\"round\"/>"
    + "<path d=\"M 43 36 C 70 34 105 37 137 34\" fill=\"none\" stroke=\"" + tape-hi.to-hex() + "\" stroke-width=\"1.5\" stroke-linecap=\"round\" opacity=\"0.6\"/>"
    + "<path d=\"M 50 61 C 78 58 111 62 136 59\" fill=\"none\" stroke=\"" + tape-edge.to-hex() + "\" stroke-width=\"0.8\" stroke-linecap=\"round\" opacity=\"0.45\"/>"
    + "</g></g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height, fit: "stretch")
}

/// A single pastel paper note, fastened with masking tape and curled at one corner.
///
/// The lower corner lifts away from the sheet and casts a small shadow. The
/// tape is drawn across the upper leading edge; under RTL the note is mirrored,
/// including the tape and curl. The text remains editable. Print mode converts
/// the coloured paper, tape, crease, and shadow to grayscale.
#let taped-curl-note(
  title: [],
  body: [],
  width: auto,
  height: 6.80cm,
  direction: auto,
  text-align: "auto",
  stroke-colour: auto,
  stroke-width: 1.35pt,
  icon: none,
  icon-position: "top",
  icon-size: 0.34cm,
  icon-colour: auto,
  icon-gap: 0.08cm,
  paper: rgb("#EEF0DE"),
  tape-colour: rgb("#BACB98"),
  tape-angle: -38deg,
  title-colour: auto,
  text-colour: auto,
  title-size: 12pt,
  body-size: 9.2pt,
  title-gap: 0.12cm,
  padding: 0.54cm,
  top-padding: 1.55cm,
  bottom-padding: 0.70cm,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if (text-align != "auto" and text-align != "left" and text-align != "right" and text-align != "center") {
    panic("text-align must be auto, left, right, or center")
  }
  let face = if print-mode { white } else { paper }
  let tape-ink = if print-mode { luma(194) } else { tape-colour }
  let stroke-ink = if print-mode { luma(34) }
    else if stroke-colour == auto { rgb("#3B3835") } else { stroke-colour }
  let icon-ink = if print-mode { luma(45) }
    else if icon-colour == auto { stroke-ink } else { icon-colour }
  if stroke-width <= 0pt { panic("stroke-width must be positive") }
  let text-dir = if rtl { std.rtl } else { std.ltr }
  let resolved-align = if text-align == "center" { center }
    else if text-align == "left" { left }
    else if text-align == "right" { right }
    else if rtl { right } else { left }
  let title-ink = if print-mode { black }
    else if title-colour == auto { rgb("#302E2B") } else { title-colour }
  let body-ink = if print-mode { luma(42) }
    else if text-colour == auto { rgb("#4A4844") } else { text-colour }
  let title-text = text(font: "DejaVu Sans", dir: text-dir,
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.38em, spacing: 0.18em, justify: false)
    text(font: "DejaVu Sans", dir: text-dir,
      size: body-size, fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 6.1) }
      else { width / 1cm }
    let w = W * 1cm
    let H = height
    // The SVG silhouette is inset from its canvas so the cast shadow and
    // overhanging tape stay visible. Measure the text column from the actual
    // paper edge, not the outer art box.
    let paper-left = w * 29 / 300
    let paper-w = w * 244 / 300
    let copy-x = paper-left + padding
    let inner-w = paper-w - 2 * padding
    let icon-layout = session-title-layout(title-text, icon, icon-position,
      icon-size, icon-ink, rtl, text-dir, resolved-align, inner-w, icon-gap)
    let title-content = icon-layout.title
    let icon-h = icon-layout.above-h
    let icon-gap-h = icon-layout.above-gap
    let inner-h = H - top-padding - bottom-padding
    if inner-w <= 1cm { panic("taped-curl-note width is too small for its padding") }
    if inner-h <= 1cm { panic("taped-curl-note height is too small for its text area") }
    let title-box = box(width: inner-w,
      align(resolved-align + horizon, title-content))
    let body-box = box(width: inner-w,
      align(resolved-align + horizon, body-content))
    let title-h = measure(title-box).height
    let body-h = measure(body-box).height
    let gap = if body-h > 0pt { title-gap } else { 0pt }
    let copy-h = icon-h + icon-gap-h + title-h + gap + body-h
    if copy-h > inner-h {
      panic("taped-curl-note copy is too tall; increase height or shorten the text")
    }
    let copy-y = top-padding
    let art = _tcn-art(w, H, face, tape-ink, rtl, print-mode, stroke-ink, stroke-width, tape-angle: tape-angle)

    box(width: w, height: H, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      if icon-h > 0pt { place(top + left, dx: copy-x, dy: copy-y, icon-layout.above) }
      place(top + left, dx: copy-x, dy: copy-y + icon-h + icon-gap-h, title-box)
      if body-h > 0pt {
        place(top + left, dx: copy-x, dy: copy-y + icon-h + icon-gap-h + title-h + gap, body-box)
      }
    })
  })
}
