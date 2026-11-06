// Additional minimal sticky-note variant with a native butterfly lifted shadow.
#import "fabox.typ": fabox
#import "theme.typ": theme-state, grayscale-paint
#import "postit.typ": _postit-tab-outline

#let _postit-rtl(direction) = {
  if direction != auto { direction == rtl }
  else if text.dir != auto { text.dir == rtl }
  else { ("ar", "he", "fa", "ur", "ps", "syr", "dv", "ku", "yi").contains(text.lang) }
}

/// An alternate simple sticky note with faboxyst's native large lifted
/// shadow. A small `tab-drop` lowers the top circular sector; the shadow's
/// gradient is derived from the paper fill with a configurable warm red mix.
/// The paper rule and butterfly shadow are independently adjustable; both
/// default to 93% of the paper's width.
#let postit-butterfly(
  body,
  title: none,
  direction: auto,
  width: auto,
  height: auto,
  fill: rgb("#FFE52C"),
  pad: 0.30cm,
  radius: 0.24cm,
  tab-drop: 0.03cm,
  line-color: auto,
  line-length: 93%,
  line-weight: 0.8pt,
  shadow-color: auto,
  shadow-red-color: rgb("#C64A2B"),
  shadow-red-mix: 12%,
  shadow-center-darken: 20%,
  shadow-edge-darken: 5%,
  shadow-gradient-in: auto,
  shadow-gradient-out: auto,
  shadow-length: 93%,
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
    let shadow-base = if shadow-color == auto { fill } else { shadow-color }
    let warm-shadow-base = shadow-base.mix((shadow-red-color, shadow-red-mix))
    // Explicit stops override the computed warm yellow-to-edge colors.
    let gradient-in = if shadow-gradient-in == auto {
      warm-shadow-base.darken(shadow-center-darken)
    } else { shadow-gradient-in }
    let gradient-out = if shadow-gradient-out == auto {
      warm-shadow-base.darken(shadow-edge-darken)
    } else { shadow-gradient-out }
    let lifted-shadow-colour = (center: gradient-in, edge: gradient-out)
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
    // Keep the lifted wing shadow in print, using the gray paint below.
    let lifted-shadow-height = 0.32cm
    let shadow-shift = lifted-shadow-height + 2pt
    let rule-h = 0.70cm
    // Zero bottom inset; keep the lifted shadow in the reserved lower band.
    let natural-card-h = title-h + body-h + gap + top-inset + shadow-drop + rule-h + 2 * border-width
    let card-h = if height == auto { natural-card-h }
      else { calc.max(natural-card-h, height) }
    let total-h = note-y + card-h
    // `card-h` includes the reserved shadow-drop band. Keep that band outside
    // the paper silhouette in both themes so the configured shadow can show.
    let paper-h = card-h - shadow-drop

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
    let line-mark = box(width: line-w, height: line-weight, fill: paper-line,
      radius: line-weight / 2)
    let outline = _postit-tab-outline(
      card-w, paper-h, note-y, radius, tab-radius,
      tab-radius + tab-drop, tab-lower + tab-drop,
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

    box(width: card-w, height: total-h, clip: true, {
      // Crop the native shadow to its lower-edge wings, then move it up by
      // its visible height + 2pt.
      place(top + left, dy: note-y + card-h - shadow-shift,
        box(width: card-w, height: lifted-shadow-height, clip: true, {
          place(top + left, dx: carrier-x,
            dy: -card-h - 0.30cm,
            fabox([], width: carrier-w, height: card-h + 0.80cm,
              inset: 0pt, colour: paper, frame: paper,
              back: paper.transparentize(100%), frame-hidden: true,
              radius: radius / 1cm, weight: 0.1pt,
              shadow: "large",
              shadow-colour: if print-mode { grayscale-paint(lifted-shadow-colour) } else { lifted-shadow-colour }))
        }))

      // Fill the paper and tab as one shape; stroke their joined perimeter
      // once so the raised semicircle meets the frame's top rule continuously.
      place(top + left, polygon(fill: paper, stroke: none, ..outline))
      place(top + left, dy: note-y, note)
      place(top + left, polygon(fill: none,
        stroke: (paint: edge, thickness: border-width, join: "round"),
        ..outline))

      // The default rule equals the paper and is omitted so it cannot show
      // through the translucent shadow as a bright stripe. Custom colours
      // remain visible above the shadow.
      if line-color != auto {
        place(top + left, dx: line-x, dy: rule-y + rule-h, line-mark)
      }
    })
  })
}


