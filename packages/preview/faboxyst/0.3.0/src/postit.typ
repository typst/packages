// Minimal sticky note using faboxyst's lifted-shadow implementation.
#import "fabox.typ": fabox
#import "theme.typ": theme-state, grayscale-paint
#import "engine.typ": rounded-rect-pts

#let _postit-rtl(direction) = {
  if direction != auto { direction == rtl }
  else if text.dir != auto { text.dir == rtl }
  else { ("ar", "he", "fa", "ur", "ps", "syr", "dv", "ku", "yi").contains(text.lang) }
}

// One closed outline for the rounded note body and its circular top tab.
// `cut` is the vertical distance from the tab's centre to its intersection
// with the frame's top edge. Sampling the upper circular arc and splicing it
// into the rounded-rectangle top edge makes the joint a single contour.
#let _postit-tab-outline(width, height, top, radius, tab-radius, center-y, cut) = {
  let rect = rounded-rect-pts((0pt, top), (width, top + height),
    radius: radius, n: 8)
  let r = tab-radius / 1cm
  let d = cut / 1cm
  let chord = calc.sqrt(calc.pow(r, 2) - calc.pow(d, 2)) * 1cm
  let cx = width / 2
  let x0 = cx - chord
  let x1 = cx + chord
  let arch = range(25).map(i => {
    let x = x0 + 2 * chord * i / 24
    let dx = (x - cx) / 1cm
    let y = center-y - calc.sqrt(calc.pow(r, 2) - calc.pow(dx, 2)) * 1cm
    (x, y)
  })
  (rect.first(), (x0, top)) + arch.slice(1) + rect.slice(1)
}

/// A simple sticky note. Its inset rule and lifted shadow are independently
/// adjustable; both default to 93% of the paper's width.
#let postit(
  body,
  title: none,
  direction: auto,
  width: auto,
  height: auto,
  fill: rgb("#FFE52C"),
  pad: 0.30cm,
  radius: 0.24cm,
  line-color: auto,
  line-length: 93%,
  line-weight: 0.8pt,
  shadow-color: rgb("#C07800"),
  shadow-length: 93%,
  shadow-inside: true,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let paper = if print-mode { white } else { fill }
  let is-rtl = _postit-rtl(direction)
  let content-align = if is-rtl { right } else { left }
  set text(dir: if is-rtl { rtl } else { ltr })
  if print-mode { set text(fill: black) }
  set par(leading: 0.42em)

  layout(avail => {
    let tab-radius = 0.44cm
    let tab-lower = 0.08cm
    let note-y = tab-radius - tab-lower
    let edge = if print-mode { black } else { fill.darken(13%) }
    let border-width = 1pt
    let title-content = if title == none { none } else {
      text(size: 1.05em, weight: "bold",
        fill: if print-mode { black } else { rgb("#A84322") })[#title]
    }
    let title-w = if title-content == none { 0pt } else { measure(title-content).width }
    let natural-content-w = calc.max(measure(body).width, title-w)
    let wanted-w = natural-content-w + 2 * pad + 2pt
    let card-w = if width == auto { calc.min(avail.width, wanted-w) }
      else if type(width) == ratio { avail.width * width }
      else { width }
    let inner-w = calc.max(0pt, card-w - 2 * pad - 2 * border-width)

    let title-h = if title-content == none { 0pt }
      else { measure(box(width: inner-w, align(content-align, title-content))).height }
    let body-h = measure(box(width: inner-w, body)).height
    let gap = if title-content == none { 0pt } else { 0.12cm }
    let top-inset = calc.max(pad + 0.32cm, tab-radius + tab-lower + 0.08cm)
    let shadow-drop = 0.36cm
    let rule-h = 0.70cm
    // No bottom inset: the lifted shadow is allowed to meet the paper edge.
    let natural-card-h = title-h + body-h + gap + top-inset + shadow-drop + rule-h + 2 * border-width
    let card-h = if height == auto { natural-card-h }
      else { calc.max(natural-card-h, height) }
    let total-h = note-y + card-h
    // `card-h` includes the reserved shadow-drop band. Keep that band outside
    // the paper silhouette in both themes so the configured shadow can show.
    let paper-h = if shadow-inside { card-h } else { card-h - shadow-drop }
    let lift = if shadow-inside { shadow-drop } else { 0pt }

    let line-w = if type(line-length) == ratio { card-w * line-length } else { line-length }
    let shadow-w = if type(shadow-length) == ratio { card-w * shadow-length } else { shadow-length }
    let line-w = calc.min(card-w, line-w)
    let shadow-w = calc.min(calc.max(0pt, card-w - 2 * radius), shadow-w)
    let line-x = (card-w - line-w) / 2
    // The large fabox lifted shadow is inset inside its carrier; compensate
    // so the visible shadow stays close to its requested 90–95% width.
    let carrier-w = calc.min(card-w, shadow-w + 0.50cm)
    let carrier-x = (card-w - carrier-w) / 2
    let rule-y = note-y + card-h - shadow-drop - rule-h
    let paper-line = if print-mode { luma(224) }
      else if line-color == auto { fill } else { line-color }
    let outline = _postit-tab-outline(
      card-w, paper-h, note-y, radius, tab-radius, tab-radius, tab-lower,
    )

    let note = block(
      width: card-w,
      height: paper-h,
      fill: paper,
      radius: radius,
      inset: (left: pad, right: pad, top: top-inset, bottom: 0pt),
      { stack(dir: ttb, spacing: gap,
          if title-content != none {
            box(width: inner-w, align(content-align, title-content))
          },
          box(width: inner-w, align(content-align, body))) },
    )

    let shadow-box = place(top + left, dx: carrier-x, dy: rule-y + 0.65cm - lift,
      fabox([], width: carrier-w, height: rule-h,
        inset: 0pt, colour: paper, frame: paper, back: paper,
        frame-hidden: true, radius: 0.02, weight: 0.1pt,
        shadow: "large",
        shadow-colour: if print-mode { grayscale-paint(shadow-color) } else { shadow-color }))
    let rule-box = place(top + left, dx: line-x, dy: rule-y + rule-h - lift,
      box(width: line-w, height: line-weight, fill: paper-line,
        radius: line-weight / 2))

    box(width: card-w, height: total-h, clip: true, {
      // Lifted shadow under the inset rule. Outside mode: drawn first, below
      // the paper; inside mode: drawn over the paper, inside its silhouette.
      if not shadow-inside { shadow-box }

      // Fill the sheet plus its tab from one silhouette. Then draw its outer
      // edge once: the semicircle and top rule are one uninterrupted contour.
      place(top + left, polygon(fill: paper, stroke: none, ..outline))
      place(top + left, dy: note-y, note)
      if shadow-inside { shadow-box }
      place(top + left, polygon(fill: none,
        stroke: (paint: edge, thickness: border-width, join: "round"),
        ..outline))

      // Paper-colored by default; recolor the line independently if desired.
      rule-box
    })
  })
}

#let study-postit = postit
