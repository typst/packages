// One expanded folding card inspired by SlideModel's Folding Cards template.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _fcb-default-icon(size, ink) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = "<circle cx=\"48\" cy=\"48\" r=\"30\"/><circle cx=\"48\" cy=\"48\" r=\"17\"/><circle cx=\"48\" cy=\"48\" r=\"5\"/><path d=\"M50 47l22-24M63 23h10v10\"/>"
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// A single expanded folding card with a numbered front, title leaf, and content leaf.
///
/// Adapted from SlideModel's public Folding Cards preview; this renders one
/// component, not the source's three-card row or its animated slide sequence.
/// RTL mirrors the flap and leaves. Use `front-text` for the short copy on the
/// numbered face and `body` for the expanded content leaf.
///
/// - `number` accepts localized content (including Arabic numerals).
/// - `icon` accepts arbitrary Typst content; a target glyph is used by default.
/// - `spine-width` and `title-width` set the proportions of the three leaves.
#let folding-card-box(
  title: [],
  front-text: [],
  body: [],
  number: [01],
  icon: none,
  width: auto,
  height: auto,
  min-height: 6.0cm,
  direction: auto,
  colour: rgb("#078ED8"),
  text-colour: auto,
  icon-colour: auto,
  spine-width: 0.31,
  title-width: 0.34,
  title-size: 13pt,
  body-size: 7.8pt,
  number-size: 25pt,
  icon-size: 0.76cm,
  corner-radius: 0.18cm,
  pane-gap: 0.045cm,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let copy-ink = if print-mode { luma(28) }
    else if text-colour == auto { white } else { text-colour }
  let symbol-ink = if print-mode { luma(55) }
    else if icon-colour == auto { copy-ink } else { icon-colour }
  let pane-ink = if print-mode { black }
    else { white }
  let shadow-fill = if print-mode { luma(236) }
    else { rgb("#091827").transparentize(88%) }
  let outline = if print-mode { (paint: luma(80), thickness: 0.7pt) } else { none }
  let front-fill = if print-mode { luma(241) }
    else { gradient.linear(colour.lighten(10%), colour.darken(4%), angle: 0deg) }
  let title-fill = if print-mode { white }
    else { gradient.linear(colour.darken(7%), colour.lighten(9%), angle: 0deg) }
  let content-fill = if print-mode { luma(248) }
    else { gradient.linear(colour.lighten(24%), colour.lighten(5%), angle: 0deg) }
  let fold-fill = if print-mode { luma(205) }
    else { colour.darken(25%).transparentize(24%) }
  let highlight-fill = if print-mode { luma(190) }
    else { white.transparentize(62%) }
  let title-content = text(dir: if rtl { std.rtl } else { std.ltr },
    size: title-size, weight: "bold", fill: pane-ink, title)
  let body-content = {
    set par(leading: 0.28em, spacing: 0.22em, justify: false)
    text(dir: if rtl { std.rtl } else { std.ltr },
      size: body-size, fill: copy-ink, body)
  }
  let front-content = {
    set par(leading: 0.30em, spacing: 0.24em, justify: false)
    text(dir: if rtl { std.rtl } else { std.ltr },
      size: body-size, fill: copy-ink, front-text)
  }
  let symbol = if icon == none { _fcb-default-icon(icon-size, symbol-ink) } else { icon }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 8.0) }
      else { width / 1cm }
    let gap = pane-gap / 1cm
    let front-w = W * spine-width
    let title-w = W * title-width
    let content-w = W - front-w - title-w - 2 * gap
    if content-w <= 1.4 { panic("folding-card-box needs more width for its content leaf") }
    let front-copy-w = calc.max(1.0, front-w - 0.32)
    let title-copy-w = calc.max(1.0, title-w - 0.32)
    let content-copy-w = calc.max(1.2, content-w - 0.34)
    let front-box = box(width: front-copy-w * 1cm, front-content)
    let body-box = box(width: content-copy-w * 1cm, body-content)
    let title-box-measure = box(width: title-copy-w * 1cm, title-content)
    let front-h = measure(front-box).height / 1cm
    let body-h = measure(body-box).height / 1cm
    let title-h = measure(title-box-measure).height / 1cm
    let content-stack-h = icon-size / 1cm + 0.22 + body-h
    let min-h = min-height / 1cm
    let required-h = calc.max(
      content-stack-h + 1.25,
      title-h + 1.05,
      (front-h + 0.72) / 0.67,
      min-h,
    )
    let H = if height == auto { required-h }
      else { calc.max(height / 1cm, required-h) }
    let number-h = H * 0.33
    let content-x = if rtl { 0.0 } else { front-w + gap + title-w + gap }
    let title-x = if rtl { content-w + gap } else { front-w + gap }
    let front-x = if rtl { W - front-w } else { 0.0 }
    let content-panel-x = content-x + gap
    let title-panel-x = title-x
    let front-copy-y = number-h + gap + (H - number-h - gap - front-h) / 2
    let title-copy-y = (H - title-h) / 2
    let body-stack-y = (H - content-stack-h) / 2
    let number-box = box(width: front-w * 0.88 * 1cm,
      height: number-h * 0.72 * 1cm,
      align(center + horizon,
        text(dir: std.ltr, size: number-size, weight: "bold", fill: pane-ink, number)))
    let front-copy = box(width: front-copy-w * 1cm, height: front-h * 1cm,
      align(center + horizon, front-box))
    let title-copy = box(width: title-copy-w * 1cm, height: title-h * 1cm,
      align(center + horizon, title-box-measure))
    let icon-area = box(width: content-copy-w * 1cm,
      height: icon-size, align(center + horizon, symbol))
    let body-area = box(width: content-copy-w * 1cm,
      height: body-h * 1cm, align(center + horizon, body-box))
    let number-x = front-x + (front-w - front-w * 0.88) / 2
    let crease-w = 0.055
    let front-hinge-x = if rtl { title-panel-x + title-w - crease-w / 2 }
      else { front-x + front-w - crease-w / 2 }
    let content-hinge-x = if rtl { content-w + gap - crease-w / 2 }
      else { title-panel-x + title-w - crease-w / 2 }

    box(width: W * 1cm, height: H * 1cm, inset: 0pt, {
      // Soft, separate shadows keep the four editable leaves visually distinct.
      if shadow {
        place(top + left, dx: (front-x * 1cm + 0.035cm) + number-offset-x, dy: (0.055cm) + number-offset-y, rect(width: (front-w - gap) * 1cm, height: number-h * 1cm,
            radius: corner-radius, fill: shadow-fill, stroke: none))
        place(top + left, dx: (front-x * 1cm + 0.035cm) + number-offset-x, dy: ((number-h + gap) * 1cm + 0.055cm) + number-offset-y, rect(width: (front-w - gap) * 1cm,
            height: (H - number-h - gap) * 1cm,
            radius: corner-radius, fill: shadow-fill, stroke: none))
        place(top + left, dx: (title-panel-x * 1cm + 0.035cm) + title-offset-x, dy: (0.055cm) + title-offset-y, rect(width: title-w * 1cm, height: H * 1cm,
            radius: corner-radius, fill: shadow-fill, stroke: none))
        place(top + left, dx: content-panel-x * 1cm + 0.035cm, dy: 0.055cm,
          rect(width: content-w * 1cm, height: H * 1cm,
            radius: corner-radius, fill: shadow-fill, stroke: none))
      }
      // Front card: numbered upper tile and the short copy beneath it.
      place(top + left, dx: (front-x * 1cm) + number-offset-x, dy: number-offset-y, rect(width: (front-w - gap) * 1cm, height: number-h * 1cm,
          radius: corner-radius, fill: front-fill, stroke: outline))
      place(top + left, dx: (front-x * 1cm) + number-offset-x, dy: ((number-h + gap) * 1cm) + number-offset-y, rect(width: (front-w - gap) * 1cm,
          height: (H - number-h - gap) * 1cm,
          radius: corner-radius, fill: front-fill, stroke: outline))
      // The two unfolded leaves use distinct gradients, joined with a shaded hinge.
      place(top + left, dx: (title-panel-x * 1cm) + title-offset-x, dy: title-offset-y, rect(width: title-w * 1cm, height: H * 1cm,
          radius: corner-radius, fill: title-fill, stroke: outline))
      place(top + left, dx: content-panel-x * 1cm,
        rect(width: content-w * 1cm, height: H * 1cm,
          radius: corner-radius, fill: content-fill, stroke: outline))
      if not print-mode {
        place(top + left, dx: front-hinge-x * 1cm,
          rect(width: crease-w * 1cm, height: H * 1cm, fill: fold-fill, stroke: none))
        place(top + left, dx: content-hinge-x * 1cm,
          rect(width: crease-w * 1cm, height: H * 1cm, fill: fold-fill, stroke: none))
      } else {
        place(top + left, dx: front-hinge-x * 1cm,
          rect(width: crease-w * 1cm, height: H * 1cm, fill: luma(205), stroke: none))
        place(top + left, dx: content-hinge-x * 1cm,
          rect(width: crease-w * 1cm, height: H * 1cm, fill: luma(205), stroke: none))
      }
      // Narrow highlights make each fold read as a plane change, not a plain grid.
      if not print-mode {
        place(top + left, dx: (title-panel-x + (if rtl { 0.09 } else { title-w - 0.10 })) * 1cm,
          dy: 0.18cm,
          rect(width: 0.018cm, height: (H - 0.36) * 1cm,
            fill: highlight-fill, stroke: none))
      }
      // Number tile; short front copy; title leaf; icon and explanatory text.
      place(top + left, dx: (number-x * 1cm) + number-offset-x, dy: (H * 0.055 * 1cm) + number-offset-y, number-box)
      place(top + left, dx: ((front-x + (front-w - front-copy-w) / 2) * 1cm) + body-offset-x, dy: (front-copy-y * 1cm) + body-offset-y, front-copy)
      place(top + left, dx: ((title-panel-x + (title-w - title-copy-w) / 2) * 1cm) + title-offset-x, dy: (title-copy-y * 1cm) + title-offset-y, title-copy)
      place(top + left, dx: ((content-panel-x + (content-w - content-copy-w) / 2) * 1cm) + icon-offset-x, dy: (body-stack-y * 1cm) + icon-offset-y, icon-area)
      place(top + left, dx: ((content-panel-x + (content-w - content-copy-w) / 2) * 1cm) + body-offset-x, dy: ((body-stack-y + icon-size / 1cm + 0.22) * 1cm) + body-offset-y, body-area)
    })
  })
}
