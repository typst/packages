// One horizontal looped frame with a multicolor chevron accent.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _lcc-monogram(size, ink, shadow) = {
  let d = "M 8 2 H 22 V 43 C 30 32 40 27 53 27 C 73 27 85 43 85 65 C 85 89 71 104 50 104 C 37 104 27 98 21 87 V 104 H 8 Z M 22 61 V 77 C 27 85 35 90 45 90 C 58 90 66 80 66 65 C 66 50 59 41 47 41 C 36 41 27 49 22 61 Z"
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 112\">"
    + "<path fill=\"" + shadow.to-hex() + "\" fill-rule=\"evenodd\" transform=\"translate(5 6)\" d=\"" + d + "\"/>"
    + "<path fill=\"" + ink.to-hex() + "\" fill-rule=\"evenodd\" d=\"" + d + "\"/>"
    + "</svg>"
  )
  image(bytes(svg), format: "svg", width: size * 0.64 * 96 / 90, height: size * 112 / 106)
}

// Artwork, in the pixel space of the reference picture (815 x 361): a broad
// band that loops round the panel (swallow-tail tail at the top left, slanted
// end on the left loop), two solid chevrons at that end, and ONE shadow: the
// whole drawing lowered to the right, separated from it by a white outline.
#let _lcc-frame = (
  "M 176 16 H 701 A 80 80 0 0 1 781 96 V 251 A 80 80 0 0 1 701 331 H 102 "
  + "A 85 85 0 0 1 17 246 V 196 A 85 85 0 0 1 102 111 H 170 L 153 144 H 102 "
  + "A 52 52 0 0 0 50 196 V 246 A 52 52 0 0 0 102 299 H 701 "
  + "A 47 47 0 0 0 748 252 V 95 A 47 47 0 0 0 701 48 H 176 L 192 32 Z"
)

#let _lcc-art(width, height, panel, border, chevrons, shadow, print-mode, mirror, chevron-offset-x, chevron-offset-y, chevron-step) = {
  let group = if mirror { "<g transform=\"translate(815 0) scale(-1 1)\">" } else { "<g>" }
  let chevron-a = if print-mode { luma(95) } else { chevrons.at(0) }
  let chevron-b = if print-mode { luma(125) } else { chevrons.at(1) }
  let lime = "M 159 95 H 180 L 202 127 L 180 159 H 159 L 181 127 Z"
  let step = str(chevron-step)
  let tx = str(chevron-offset-x) + " " + str(chevron-offset-y)
  // one layer of the drawing in a single colour (shadow, white outline)
  let silhouette(c, grow) = (
    "<g fill=\"" + c.to-hex() + "\" stroke=\"" + c.to-hex() + "\" stroke-width=\"" + str(grow)
    + "\" stroke-linejoin=\"round\"><path d=\"" + _lcc-frame + "\"/>"
    + "<g transform=\"translate(" + tx + ")\"><path d=\"" + lime + "\"/>"
    + "<path d=\"" + lime + "\" transform=\"translate(" + step + " 0)\"/></g></g>"
  )
  let svg = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 815 361\" preserveAspectRatio=\"none\">"
    + group
    + "<rect x=\"50\" y=\"48\" width=\"698\" height=\"251\" rx=\"52\" fill=\"" + panel.to-hex() + "\"/>"
    + "<g transform=\"translate(20 14)\">" + silhouette(shadow, 0.01) + "</g>"
    + silhouette(panel, 16)
    + "<path d=\"" + _lcc-frame + "\" fill=\"" + border.to-hex() + "\"/>"
    + "<g transform=\"translate(" + tx + ")\">"
    + "<path d=\"" + lime + "\" fill=\"" + chevron-a.to-hex() + "\"/>"
    + "<path d=\"" + lime + "\" transform=\"translate(" + step + " 0)\" fill=\"" + chevron-b.to-hex() + "\"/>"
    + "</g></g></svg>"
  )
  image(bytes(svg), format: "svg", width: width, height: height)
}

/// One horizontal callout inside a broad looped frame, with a left icon/emblem
/// and layered chevrons. Compose multiple calls externally; this function
/// produces a single banner, not a slide or multi-item layout.
#let looped-chevron-callout(
  body: [Place your text here. Add a concise explanation that fits in this wide callout.],
  icon: none,
  width: auto,
  height: 4.9cm,
  direction: auto,
  colour: rgb("#D29222"),
  panel-colour: white,
  chevron-colours: (rgb("#B5CC2E"), rgb("#16AFC3"), rgb("#A8ABAF")),   // 2 chevrons + the shadow
  icon-colour: rgb("#55418D"),
  text-colour: auto,
  icon-size: 1.50cm,
  body-size: 10.5pt,
  body-weight: "bold",
  body-stretch: 75%,   // condensed face when the font has one
  font: "DejaVu Sans",
  padding: 0.12cm,
  body-width: auto,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  chevron-offset-x: 0pt,
  chevron-offset-y: 0pt,
  chevron-spacing: auto,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  if width != auto and width < 8.5cm { panic("looped-chevron-callout needs at least 8.5 cm of width") }
  if chevron-spacing != auto and chevron-spacing <= 0pt { panic("chevron-spacing must be positive") }
  if height < 3.7cm or icon-size <= 0pt or body-size <= 0pt or padding < 0pt {
    panic("height must be at least 3.7 cm; icon and text sizes must be positive; padding cannot be negative")
  }
  if chevron-colours.len() != 3 { panic("chevron-colours must contain exactly three colors") }
  let border = if print-mode { luma(175) } else { colour }
  let face = if print-mode { white } else { panel-colour }
  let shadow = if print-mode { luma(205) } else { chevron-colours.at(2) }
  let ink = if print-mode { luma(42) }
    else if text-colour == auto { rgb("#513C82") } else { text-colour }
  let glyph-ink = if print-mode { black } else { icon-colour }
  let direction-value = if rtl { std.rtl } else { std.ltr }
  let align-x = if rtl { right } else { left }
  let glyph = if icon != none { icon } else { _lcc-monogram(icon-size, glyph-ink, shadow) }
  let copy-at(sz) = {
    set par(leading: 0.48em, spacing: 0.10em, justify: false)
    text(font: font, dir: direction-value, weight: body-weight, stretch: body-stretch,
      size: sz, fill: ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 11.2) }
      else { width / 1cm }
    let w = W * 1cm
    let h = height
    if w < 8.5cm { panic("looped-chevron-callout needs at least 8.5 cm of width") }
    let mirror = rtl
    let chevron-step-length = if chevron-spacing == auto { w * 31 / 815 } else { chevron-spacing }
    let art = _lcc-art(w, h, face, border, chevron-colours, shadow, print-mode, mirror,
      chevron-offset-x / w * 815, chevron-offset-y / h * 361, chevron-step-length / w * 815)
    let text-width = if body-width == auto { w * 0.50 - 2 * padding } else { body-width }
    if text-width <= 0pt { panic("body-width must be positive") }
    // the text shrinks (6 % per step) until it fits the panel
    let body-size-fit = range(14).fold(body-size, (sz, _) => {
      if measure(copy-at(sz), width: text-width).height > h * 0.60 { sz * 0.94 } else { sz }
    })
    let copy = copy-at(body-size-fit)
    let text-box = box(width: text-width, height: h * 0.60,
      align(align-x + horizon, copy))
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, glyph))
    let icon-x = (if mirror { w * 0.826 - icon-size / 2 } else { w * 0.174 - icon-size / 2 }) + icon-offset-x
    let body-x = (if mirror { w * 0.11 + padding } else { w * 0.38 + padding }) + body-offset-x
    let body-height = measure(copy, width: text-width).height
    if body-height > h * 0.60 { panic("body does not fit even after shrinking the text; increase height or shorten the copy") }
    box(width: w, height: h, inset: 0pt, {
      place(top + left, dx: 0pt, dy: 0pt, art)
      place(top + left, dx: icon-x, dy: h * 0.60 - icon-size / 2 + icon-offset-y, icon-box)
      place(top + left, dx: body-x, dy: h * 0.18 + body-offset-y, text-box)
    })
  })
}
