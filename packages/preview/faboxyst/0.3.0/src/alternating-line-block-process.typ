// Alternating line process cards whose outgoing arrows are part of each outline.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

// One closed contour per card: a rounded rectangle whose right-hand side ends
// in an ARROW HEAD (the head is part of the outline, as in the reference
// slide). Odd cards carry the head at the bottom, even cards at the top.
#let _albp-round-poly(corners, n: 7) = {
  // corners: ((x, y), radius) in order; a quadratic fillet is put on each
  let out = ()
  let k = corners.len()
  for i in range(k) {
    let (pt, rad) = corners.at(i)
    let prev = corners.at(calc.rem(i + k - 1, k)).first()
    let next = corners.at(calc.rem(i + 1, k)).first()
    let d1 = (prev.at(0) - pt.at(0), prev.at(1) - pt.at(1))
    let d2 = (next.at(0) - pt.at(0), next.at(1) - pt.at(1))
    let l1 = calc.sqrt(d1.at(0) * d1.at(0) + d1.at(1) * d1.at(1))
    let l2 = calc.sqrt(d2.at(0) * d2.at(0) + d2.at(1) * d2.at(1))
    let r = calc.min(rad, l1 * 0.5, l2 * 0.5)
    if r <= 0.001 { out.push(pt) } else {
      let a0 = (pt.at(0) + d1.at(0) / l1 * r, pt.at(1) + d1.at(1) / l1 * r)
      let a1 = (pt.at(0) + d2.at(0) / l2 * r, pt.at(1) + d2.at(1) / l2 * r)
      for j in range(n + 1) {
        let t = j / n
        let u = 1 - t
        out.push((u * u * a0.at(0) + 2 * u * t * pt.at(0) + t * t * a1.at(0),
                  u * u * a0.at(1) + 2 * u * t * pt.at(1) + t * t * a1.at(1)))
      }
    }
  }
  out
}

// Geometry measured on the reference slide (px / 356 of the card height = k):
// the card's bottom edge steps down into a block arrow, whose shaft is the
// short stub left inside the card; the right edge stops above the head.
#let _albp-k(height) = height / 356

#let _albp-contour-art(card-width, height, extension, radius, background,
                       colour, weight, upper: true, rtl: false) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let r = radius / 1cm
  let w = card-width
  let h = height
  let k = _albp-k(h)
  let xb = w - 30 * k
  let corners = (
    ((w, h - 73 * k), 0),
    ((w, 0), r), ((0, 0), r), ((0, h), r),
    ((xb, h), 6 * k),
    ((xb, h + 16 * k), 7 * k),
    ((w + extension, h - 28.5 * k), 6 * k),
    ((xb, h - 72 * k), 7 * k),
    ((xb, h - 50.5 * k), 6 * k),
    ((w - 54 * k, h - 50.5 * k), 0),
  )
  let pts = _albp-round-poly(corners)
  // `upper` = the head goes to the TOP-right: flip vertically
  let pts = pts.map(((x, y)) => (x, -(if upper { h - y } else { y })))
  let canvas-width = card-width + extension
  let pts = if rtl { pts.map(((x, y)) => (canvas-width - x, y)) } else { pts }
  draw.line(..pts, close: true, fill: background, stroke: none)
  draw.line(..pts, stroke: (paint: colour, thickness: weight, cap: "round", join: "round"))
})

#let _albp-panel(
  step, index, card-width, height, radius, rtl, print-mode,
  colours, title-size, body-size,
  body-colour,
) = {
  let upper = calc.rem(index, 2) == 0
  let colour = if "colour" in step {
    step.at("colour")
  } else { colours.at(calc.rem(index, colours.len())) }
  let title-colour = if print-mode { black }
    else if "title-colour" in step { step.at("title-colour") }
    else if colour == rgb("#C23221") { white } else { rgb("#262626") }
  let header-colour = if print-mode { luma(226) } else { colour }
  let body-ink = if print-mode { black } else { body-colour }
  let inner-width = calc.max(1.2, card-width - 0.40)
  let header-height = 0.82
  let header-y = if upper { 0.14 } else { height - header-height - 0.14 }
  let title-box = box(
    width: inner-width * 1cm,
    height: header-height * 1cm,
    radius: if upper {
      (top-left: 0.16cm, top-right: 0.16cm,
       bottom-right: 0pt, bottom-left: 0pt)
    } else {
      (top-left: 0pt, top-right: 0pt,
       bottom-right: 0.16cm, bottom-left: 0.16cm)
    },
    fill: header-colour,
    inset: (x: 0.08cm, y: 0.04cm),
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-colour,
        step.at("title"))),
  )
  let body-box = box(
    width: inner-width * 1cm,
    height: (height - 2.20) * 1cm,
    inset: 0pt,
    align(if rtl { top + right } else { top + left },
      { set par(justify: card-width >= 3.6, leading: 0.5em); text(size: body-size, fill: body-ink, step.at("body")) }),
  )
  box(width: card-width * 1cm, height: height * 1cm,
    radius: radius, fill: none, stroke: none, inset: 0pt, {
      place(top + left, dx: 0.20cm, dy: header-y * 1cm, title-box)
      place(top + left, dx: 0.20cm, dy: 1.62cm, body-box)
    })
}

/// Alternating tall text cards with arrow heads integrated into their contours.
///
/// Each step supplies `title` and `body`; optional `icon` (and `print-icon`)
/// pictograms sit inside its outgoing arrow. Headings alternate between the top
/// and bottom of the cards while the connectors alternate high and low. The
/// sequence and arrow direction reverse in RTL. `width`, `height`, `gap`,
/// `arrow-outset` and `radius` can be adjusted for the slide layout.
///
/// ```typ
/// #alternating-line-block-process(steps: (
///   (title: [Discover], body: [Gather observations and define the question.]),
///   (title: [Plan], body: [Choose a method and organize the work.]),
/// ))
/// ```
#let alternating-line-block-process(
  steps: (),
  width: auto,
  height: 6.20cm,
  gap: 0.72cm,
  arrow-outset: 0.68cm,
  radius: 0.26cm,
  direction: auto,
  colours: (
    rgb("#FFD04A"), rgb("#4ABCE6"), rgb("#A5BF6A"), rgb("#C23221"),
  ),
  line-colour: auto,
  body-colour: rgb("#505050"),
  title-size: 10.2pt,
  body-size: 7.6pt,
  icon-size: 0.58cm,
  stroke-weight: 2.0pt,
  background-colour: auto,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })
  if print-mode { set text(fill: black) }

  layout(avail => {
    let count = steps.len()
    if count == 0 { none } else {
      let total-width = if width == auto { avail.width }
        else if type(width) == ratio { avail.width * width }
        else { width }
      let total-cm = total-width / 1cm
      let gap-cm = gap / 1cm
      let outset-cm = arrow-outset / 1cm
      let card-width = calc.max(2.0, (total-cm - (count - 1) * gap-cm - outset-cm) / count)
      let height-cm = height / 1cm
      let tip-clearance = 0.12
      let background = if print-mode { white }
        else if background-colour == auto { rgb("#F2EFF1") }
        else { background-colour }
      let frame-colour = if print-mode { rgb("#707070") }
        else if line-colour == auto { rgb("#BDBDBD") } else { line-colour }
      let cards = range(count).map(index => {
        _albp-panel(
          steps.at(index), index, card-width, height-cm, radius, rtl,
          print-mode, colours, title-size, body-size,
          body-colour,
        )
      })
      align(center, box(width: total-width, height: height, inset: 0pt, {
        // Draw each card and its outgoing arrow as one filled, closed contour.
        // The slightly raised contour origin compensates for the arrow's top
        // shoulder so the card body aligns exactly with the row bounds.
        for index in range(count) {
          let visual-index = if rtl { count - 1 - index } else { index }
          let panel-x = if rtl {
            outset-cm + visual-index * (card-width + gap-cm)
          } else { visual-index * (card-width + gap-cm) }
          let has-next = index + 1 < count
          let extension = if has-next { gap-cm - tip-clearance } else { outset-cm }
          let contour-x = if rtl { panel-x - extension } else { panel-x }
          place(top + left, dx: contour-x * 1cm,
            dy: if calc.rem(index, 2) == 1 { -16 * _albp-k(height-cm) * 1cm } else { 0cm },
            _albp-contour-art(
              card-width, height-cm, extension, radius, background,
              frame-colour, stroke-weight,
              upper: calc.rem(index, 2) == 1, rtl: rtl,
            ))
        }
        // Transparent panel boxes contribute only the title and body content.
        for index in range(count) {
          let visual-index = if rtl { count - 1 - index } else { index }
          let panel-x = if rtl {
            outset-cm + visual-index * (card-width + gap-cm)
          } else { visual-index * (card-width + gap-cm) }
          place(top + left, dx: panel-x * 1cm, dy: 0pt, cards.at(index))
        }
        // Keep pictograms above the integrated contour, centered in its arrow
        // head; no separate connector stroke or frame mask is drawn.
        for index in range(count) {
          let visual-index = if rtl { count - 1 - index } else { index }
          let upper = calc.rem(index, 2) == 1
          let cy = if upper { 25.5 * _albp-k(height-cm) } else { height-cm - 25.5 * _albp-k(height-cm) }
          let has-next = index + 1 < count
          let extension = if has-next { gap-cm - tip-clearance } else { outset-cm }
          let panel-x = if rtl {
            outset-cm + visual-index * (card-width + gap-cm)
          } else { visual-index * (card-width + gap-cm) }
          let icon = if print-mode and "print-icon" in steps.at(index) {
            steps.at(index).at("print-icon")
          } else if "icon" in steps.at(index) {
            steps.at(index).at("icon")
          } else { none }
          if icon != none {
            let icon-cm = icon-size / 1cm
            let icon-x = if rtl {
              panel-x + 18 * _albp-k(height-cm) - icon-cm / 2
            } else {
              panel-x + card-width - 18 * _albp-k(height-cm) - icon-cm / 2
            }
            place(top + left, dx: icon-x * 1cm, dy: (cy - icon-cm / 2) * 1cm,
              box(width: icon-size, height: icon-size, align(center, icon)))
          }
        }
      }))
    }
  })
}
