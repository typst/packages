// plate.typ — an engraved "plate" around a figure: notched double border and calligraphic flourish (drawn by nibart).
#import "@preview/nibart:0.3.0" as nib
#import "engrave.typ": engraving-paper, engraving-ink

// Flourish of total width `w`: tapered wavy rules and a pair of curls around a centre dot.
#let flourish(w, ink) = {
  let hw = w.pt() / 2
  let curl = nib.mp-path("(4,0){dir 60}..(12,10)..(23,6){dir -70}..(18,-3)..(11,0)")
  let rule = nib.mp-path("(26,3){dir 6}..(" + str(hw * 0.55) + ",5)..(" + str(hw) + ",1.5){dir -12}")
  let half(sgn) = {
    let parts = (
      nib.copperplate(curl, light: 0.25pt, heavy: 1.7pt, slant: 100deg, taper: "end", taper-length: 10pt, fill: ink),
      nib.copperplate(rule, light: 0.2pt, heavy: 1.2pt, slant: 100deg, taper: "end", taper-length: 40pt, fill: ink),
    )
    if sgn > 0 { parts } else {
      (nib.copperplate(nib.xscaled(curl, -1), light: 0.25pt, heavy: 1.7pt, slant: 80deg, taper: "end", taper-length: 10pt, fill: ink),
       nib.copperplate(nib.xscaled(rule, -1), light: 0.2pt, heavy: 1.2pt, slant: 80deg, taper: "end", taper-length: 40pt, fill: ink))
    }
  }
  nib.mp-fig(..half(1), ..half(-1), nib.mp-dot((0pt, 3pt), pen: nib.pencircle(3pt), fill: ink), pad: 0pt)
}

/// Wrap `body` (a figure) in an engraved plate.
/// - `title`: heading above the figure (small caps, spaced); `subtitle`: italic line under the flourish;
///   `number`: plate number, e.g. `"I"` → « Pl. I »; `caption`: italic legend under the figure.
/// - `ink`, `paper`: colours. `pad`: inner margin. `band`: thickness of the outer rule. `corner`: radius of the notched corners.
/// - `ornament: false` omits the flourish under the title.
/// - `border: false` omits the frame (flourish and legends are kept).
#let plate(body, title: none, subtitle: none, number: none, caption: none, ink: engraving-ink, paper: engraving-paper,
  pad: 16pt, band: 2.2pt, corner: 9pt, border: true, width: auto, font: auto, ornament: true) = layout(sz => {
  let width = if width == auto { auto } else if type(width) == ratio { sz.width * width } else if type(width) == relative { sz.width * width.ratio + width.length } else { width }
  let f = if font == auto { ("Libertinus Serif",) } else { font }
  set text(fill: ink, font: f)
  let head = {
    if number != none { align(center, text(size: 8pt, tracking: 1.5pt, smallcaps[Pl. #number])) ; v(2pt, weak: true) }
    if title != none { align(center, text(size: 17pt, weight: "regular", tracking: 1.2pt, smallcaps(title))) }
  }
  let foot = {
    if caption != none { v(5pt); align(center, text(size: 9.5pt, style: "italic", caption)) }
  }
  let content = block(width: width, inset: pad, {
    head
    if ornament and (title != none) { v(3pt); align(center, flourish(120pt, ink)) }
    if subtitle != none { v(3pt); align(center, text(size: 10pt, style: "italic", subtitle)) }
    v(6pt)
    align(center, body)
    foot
  })
  let m = measure(content)
  let (W, H) = (m.width, m.height)
  let (w, h) = (W.pt(), H.pt())
  let frame = if border {
    let r = corner.pt()
    let q = 0.7071 * r
    let pen = nib.broadnib(band, t: band * 0.28, angle: 35deg)
    let thin = nib.pencircle(0.45pt)
    let m1 = 3.5  // gap between the two rules
    let rect = (x0, y0, x1, y1, rr) => {
      let k = 0.7071 * rr
      let segs = (
        "(" + str(x0 + rr) + "," + str(y0) + ")--(" + str(x1 - rr) + "," + str(y0) + ")",
        "(" + str(x1 - rr) + "," + str(y0) + "){dir 90}..{dir 0}(" + str(x1) + "," + str(y0 + rr) + ")",
        "(" + str(x1) + "," + str(y0 + rr) + ")--(" + str(x1) + "," + str(y1 - rr) + ")",
        "(" + str(x1) + "," + str(y1 - rr) + "){dir 180}..{dir 90}(" + str(x1 - rr) + "," + str(y1) + ")",
        "(" + str(x1 - rr) + "," + str(y1) + ")--(" + str(x0 + rr) + "," + str(y1) + ")",
        "(" + str(x0 + rr) + "," + str(y1) + "){dir -90}..{dir 180}(" + str(x0) + "," + str(y1 - rr) + ")",
        "(" + str(x0) + "," + str(y1 - rr) + ")--(" + str(x0) + "," + str(y0 + rr) + ")",
        "(" + str(x0) + "," + str(y0 + rr) + "){dir 0}..{dir -90}(" + str(x0 + rr) + "," + str(y0) + ")",
      )
      segs
    }
    let outer = rect(0, 0, w, h, r)
    let inner = rect(m1 + band.pt(), m1 + band.pt(), w - m1 - band.pt(), h - m1 - band.pt(), calc.max(r - m1 - band.pt(), 2))
    let items = ()
    for sg in outer { items += nib.stroke-items(nib.mp-path(sg), pen: pen, fill: ink) }
    for sg in inner { items += nib.stroke-items(nib.mp-path(sg), pen: thin, fill: ink) }
    nib.mp-fig(..items, width: W, height: H, pad: 0pt)
  } else { none }
  box(width: W, height: H, fill: paper, {
    place(top + left, content)
    if frame != none { place(top + left, frame) }
  })
})
