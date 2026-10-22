// Cards with an overlapping diagonal corner sleeve.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _csc-cubic(p0, p1, p2, p3, n: 12) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _csc-sleeve-art(
  width, height, colour, outline-style, side-colour, overhang, rtl: false,
) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = height / 1cm
  let o = overhang / 1cm
  let r = calc.min(0.34, w / 2, h / 2)
  let points = ((r, 0), (w, 0), (0, -h), (0, -r))
  points += _csc-cubic((0, -r), (0, -r * 0.45),
    (r * 0.45, 0), (r, 0)).slice(1)
  // Triangle vertices: lower tip, its horizontal projection onto the box side,
  // and the hypotenuse/box-side intersection.
  let side-intersection-y = -h * (1 - o / w)
  let side-triangle = ((0, -h), (o, -h), (o, side-intersection-y))
  if rtl {
    points = points.map(((x, y)) => (w - x, y))
    side-triangle = side-triangle.map(((x, y)) => (w - x, y))
  }
  draw.line(..points, close: true, fill: colour, stroke: outline-style)
  draw.line(..side-triangle, close: true, fill: side-colour, stroke: none)
})

#let _csc-overhang-faces(width, height, overhang, colour, rtl: false) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = height / 1cm
  let o = overhang / 1cm
  let r = calc.min(0.34, w / 2, h / 2)
  let top-face = ((r, 0), (w, 0), (w, o), (r, o))
  // Project the upper pointed tip onto the adjacent top edge.
  if rtl { top-face = top-face.map(((x, y)) => (w - x, y)) }
  draw.line(..top-face, close: true, fill: colour, stroke: none)
})

#let _csc-fold-art(width, height, colour, weight, rtl: false) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = height / 1cm
  let points = ((w, 0), (0, -h))
  if rtl { points = points.map(((x, y)) => (w - x, y)) }
  draw.line(..points,
    stroke: (paint: colour, thickness: weight, cap: "butt", join: "round"))
})

#let _csc-card(
  step, index, tile-width, height, flap-width, flap-height, rtl, print-mode,
  colours, title-size, body-size, icon-size,
) = {
  let pair = colours.at(calc.rem(index, colours.len()))
  let source-colour = if "colour" in step { step.at("colour") } else { pair.at(0) }
  let icon-colour = if "icon-colour" in step { step.at("icon-colour") } else { pair.at(1) }
  let card-face = if print-mode { white } else { rgb("#BDBDBD") }
  let sleeve-face = if print-mode { luma(218) } else { source-colour }
  let fold-face = if print-mode { luma(165) } else { source-colour.darken(18%) }
  let outline = if print-mode { (paint: rgb("#707070"), thickness: 0.75pt) } else { none }
  let title-ink = if print-mode { black }
    else if "title-colour" in step { step.at("title-colour") }
    else { rgb("#1C1C1C") }
  let body-ink = if print-mode { black }
    else if "body-colour" in step { step.at("body-colour") }
    else { rgb("#595959") }
  let shadow-ink = rgb("#777777").transparentize(if print-mode { 88% } else { 72% })
  let card-radius = 0.34cm
  let flap-w = calc.min(flap-width, tile-width * 0.75)
  let flap-h = calc.min(flap-height, height * 0.52)
  // Let the sleeve overhang the card at the top and outer edge, as in the
  // reference treatment; mirror the overhang for RTL.
  let cap-w = flap-w
  let cap-h = flap-h
  let cap-overhang = 0.28cm
  let cap-x = if rtl {
    tile-width - flap-w + cap-overhang
  } else { -cap-overhang }
  let cap-y = -cap-overhang
  // The LTR top-face canvas starts at its rounded x = radius; compensate for
  // that bbox so its pointed end aligns with the sleeve tip. RTL is mirrored.
  let top-face-x = if rtl { cap-x } else { cap-x + card-radius }
  let sleeve-side = if print-mode { luma(178) } else { source-colour.darken(28%) }
  let overhang-art = _csc-overhang-faces(
    cap-w, cap-h, cap-overhang, sleeve-side, rtl: rtl,
  )
  let face-art = _csc-sleeve-art(
    cap-w, cap-h, sleeve-face, outline, sleeve-side, cap-overhang, rtl: rtl,
  )
  let fold-art = _csc-fold-art(
    cap-w, cap-h, fold-face, if print-mode { 0.55pt } else { 0.075cm }, rtl: rtl,
  )
  let shadow = box(width: tile-width, height: height,
    radius: card-radius, fill: shadow-ink, inset: 0pt)
  let card = box(width: tile-width, height: height,
    radius: card-radius, fill: card-face, stroke: outline, inset: 0pt)
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let icon-box = if icon == none { none } else {
    box(width: icon-size, height: icon-size, align(center, icon))
  }
  // Center the pictogram at the centroid of the triangular sleeve.
  let icon-centre-x = if rtl {
    cap-x + 2 * cap-w / 3
  } else { cap-x + cap-w / 3 }
  let icon-centre-y = cap-y + cap-h / 3
  let icon-x = icon-centre-x - icon-size / 2
  let icon-y = icon-centre-y - icon-size / 2
  let title-y = 2.24cm
  let title-x = 0.35cm
  let title-width = tile-width - 0.70cm
  let text-align = if rtl { right } else { left }
  let title-box = box(width: title-width, height: 0.50cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
  let body-box = box(width: tile-width - 0.84cm, height: height - 3.50cm,
    align(text-align + top,
      text(size: body-size, fill: body-ink, step.at("body"))))
  let body-y = 2.88cm
  box(width: tile-width, height: height + 0.16cm, inset: 0pt, {
    place(top + left, dx: 0.12cm, dy: 0.16cm, shadow)
    place(top + left, card)
    place(top + left, dx: top-face-x, dy: cap-y, overhang-art)
    place(top + left, dx: cap-x, dy: cap-y, face-art)
    place(top + left, dx: cap-x, dy: cap-y, fold-art)
    if icon != none {
      place(top + left, dx: icon-x, dy: icon-y,
        box(width: icon-size, height: icon-size,
          align(center, text(fill: if print-mode { rgb("#707070") } else { icon-colour }, icon))))
    }
    place(top + left, dx: title-x, dy: title-y, title-box)
    place(top + left, dx: 0.42cm, dy: body-y, body-box)
  })
}

/// A grid of rounded cards with a colored diagonal sleeve over each corner.
///
/// Each step requires `title` and `body`; `icon` is optional. A per-item
/// `colour` can override the sleeve palette, and `print-icon` may provide a
/// monochrome image counterpart. RTL moves the sleeve to the opposite corner
/// and reverses card order. Print mode uses white cards and gray outlines.
///
/// ```typ
/// #cards-with-corner-sleeve(steps: (
///   (title: [Lorem Ipsum], body: [A short card description.], icon: [🚀]),
///   (title: [Lorem Ipsum], body: [Another card description.], icon: [♟]),
/// ))
/// ```
#let cards-with-corner-sleeve(
  steps: (),
  width: auto,
  columns: 4,
  gap: 0.48cm,
  row-gap: 0.64cm,
  height: 6.15cm,
  flap-width: 3.65cm,
  flap-height: 3.10cm,
  direction: auto,
  colours: (
    (rgb("#F7941D"), black),
    (rgb("#49BDE6"), black),
    (rgb("#9DBB68"), black),
    (rgb("#C32E1F"), white),
  ),
  title-size: 12pt,
  body-size: 7.7pt,
  icon-size: 0.78cm,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  layout(avail => {
    let count = steps.len()
    if count == 0 { none } else {
      let total-width = if width == auto { avail.width }
        else if type(width) == ratio { avail.width * width }
        else { width }
      let total-cm = total-width / 1cm
      let gap-cm = gap / 1cm
      let row-gap-cm = row-gap / 1cm
      let columns = calc.max(1, columns)
      let tile-cm = calc.max(3.3, (total-cm - (columns - 1) * gap-cm) / columns)
      let height-cm = height / 1cm
      let rows = calc.ceil(count / columns)
      let total-height = (rows * (height-cm + 0.16) + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left, dx: ((visual-col * (tile-cm + gap-cm)) * 1cm) + icon-offset-x, dy: ((row * (height-cm + row-gap-cm)) * 1cm) + icon-offset-y, _csc-card(
              steps.at(index), index, tile-cm * 1cm, height, flap-width,
              flap-height, rtl, print-mode, colours, title-size, body-size,
              icon-size,
            ))
        }
      })
    }
  })
}
