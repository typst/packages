// Three expressive speech-bubble silhouettes: quotation, dialogue, and thought.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _hsb-cubic(p0, p1, p2, p3, n: 12) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _hsb-shape(kind, w, h) = {
  if kind == "quote" {
    let p = ((w * 0.20, -h * 0.14),)
    p += _hsb-cubic((w * 0.20, -h * 0.14),
      (w * 0.38, -h * 0.10), (w * 0.70, -h * 0.16), (w * 0.82, -h * 0.13))
    p += _hsb-cubic((w * 0.82, -h * 0.13),
      (w * 0.93, -h * 0.12), (w * 0.96, -h * 0.20), (w * 0.96, -h * 0.31))
    p.push((w * 0.96, -h * 0.64))
    p += _hsb-cubic((w * 0.96, -h * 0.64),
      (w * 0.96, -h * 0.77), (w * 0.89, -h * 0.83), (w * 0.78, -h * 0.83))
    p.push((w * 0.60, -h * 0.83))
    p += _hsb-cubic((w * 0.60, -h * 0.83),
      (w * 0.56, -h * 0.84), (w * 0.54, -h * 0.97), (w * 0.49, -h))
    p += _hsb-cubic((w * 0.49, -h),
      (w * 0.46, -h * 0.94), (w * 0.46, -h * 0.85), (w * 0.42, -h * 0.83))
    p.push((w * 0.22, -h * 0.83))
    p += _hsb-cubic((w * 0.22, -h * 0.83),
      (w * 0.12, -h * 0.82), (w * 0.08, -h * 0.76), (w * 0.08, -h * 0.64))
    p.push((w * 0.08, -h * 0.32))
    p += _hsb-cubic((w * 0.08, -h * 0.32),
      (w * 0.08, -h * 0.20), (w * 0.12, -h * 0.15), (w * 0.20, -h * 0.14))
    p
  } else if kind == "speech" {
    let p = ((w * 0.13, -h * 0.27),)
    p += _hsb-cubic((w * 0.13, -h * 0.27),
      (w * 0.35, -h * 0.20), (w * 0.73, -h * 0.09), (w * 0.88, -h * 0.08))
    p += _hsb-cubic((w * 0.88, -h * 0.08),
      (w * 0.96, -h * 0.08), (w * 0.96, -h * 0.14), (w * 0.95, -h * 0.25))
    p.push((w * 0.86, -h * 0.69))
    p += _hsb-cubic((w * 0.86, -h * 0.69),
      (w * 0.85, -h * 0.78), (w * 0.79, -h * 0.82), (w * 0.69, -h * 0.81))
    p.push((w * 0.55, -h * 0.77))
    p += _hsb-cubic((w * 0.55, -h * 0.77),
      (w * 0.49, -h * 0.82), (w * 0.43, -h * 0.94), (w * 0.39, -h * 0.99))
    p += _hsb-cubic((w * 0.39, -h * 0.99),
      (w * 0.36, -h * 0.94), (w * 0.37, -h * 0.82), (w * 0.35, -h * 0.75))
    p.push((w * 0.20, -h * 0.79))
    p += _hsb-cubic((w * 0.20, -h * 0.79),
      (w * 0.11, -h * 0.80), (w * 0.10, -h * 0.72), (w * 0.09, -h * 0.62))
    p.push((w * 0.06, -h * 0.40))
    p += _hsb-cubic((w * 0.06, -h * 0.40),
      (w * 0.04, -h * 0.31), (w * 0.07, -h * 0.26), (w * 0.13, -h * 0.27))
    p
  } else {
    let p = ((w * 0.18, -h * 0.76),)
    p += _hsb-cubic((w * 0.18, -h * 0.76),
      (w * 0.08, -h * 0.74), (w * 0.08, -h * 0.62), (w * 0.10, -h * 0.53))
    p += _hsb-cubic((w * 0.10, -h * 0.53),
      (w * 0.03, -h * 0.43), (w * 0.08, -h * 0.31), (w * 0.17, -h * 0.29))
    p += _hsb-cubic((w * 0.17, -h * 0.29),
      (w * 0.13, -h * 0.16), (w * 0.27, -h * 0.10), (w * 0.38, -h * 0.14))
    p += _hsb-cubic((w * 0.38, -h * 0.14),
      (w * 0.43, -h * 0.02), (w * 0.56, -h * 0.02), (w * 0.62, -h * 0.11))
    p += _hsb-cubic((w * 0.62, -h * 0.11),
      (w * 0.70, -h * 0.15), (w * 0.75, -h * 0.08), (w * 0.82, -h * 0.12))
    p += _hsb-cubic((w * 0.82, -h * 0.12),
      (w * 0.94, -h * 0.10), (w * 0.98, -h * 0.23), (w * 0.95, -h * 0.35))
    p += _hsb-cubic((w * 0.95, -h * 0.35),
      (w * 1.00, -h * 0.47), (w * 0.97, -h * 0.57), (w * 0.90, -h * 0.63))
    p += _hsb-cubic((w * 0.90, -h * 0.63),
      (w * 0.93, -h * 0.74), (w * 0.84, -h * 0.83), (w * 0.74, -h * 0.81))
    p += _hsb-cubic((w * 0.74, -h * 0.81),
      (w * 0.67, -h * 0.91), (w * 0.55, -h * 0.91), (w * 0.48, -h * 0.84))
    p += _hsb-cubic((w * 0.48, -h * 0.84),
      (w * 0.40, -h * 0.91), (w * 0.28, -h * 0.88), (w * 0.25, -h * 0.80))
    p += _hsb-cubic((w * 0.25, -h * 0.80),
      (w * 0.21, -h * 0.80), (w * 0.18, -h * 0.78), (w * 0.18, -h * 0.76))
    p
  }
}

#let _hsb-map(points, w, rtl, dx: 0, dy: 0) = points.map(((x, y)) => (
  (if rtl { w - x } else { x }) + dx,
  y + dy,
))

#let _hsb-art(kind, width, height, face, edge, accent, outline, dark, rtl) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = height / 1cm
  let points = _hsb-shape(kind, w, h)
  let points = _hsb-map(points, w, rtl)
  // Slightly offset pale trace beneath the main silhouette lends a sketchy edge.
  draw.line(.._hsb-map(points, w, false, dx: 0.035, dy: -0.025),
    close: true, fill: none,
    stroke: (paint: if dark { rgb("#0B3446") } else { white },
      thickness: if dark { 0.045cm } else { 0.055cm }, join: "round", cap: "round"))
  draw.line(..points, close: true, fill: face,
    stroke: (paint: edge, thickness: outline, join: "round", cap: "round"))

  let accent-style = (paint: accent, thickness: if dark { 0.075cm } else { 0.085cm }, cap: "round", join: "round")
  if kind == "quote" {
    let swoop-a = _hsb-cubic((w * 0.88, -h * 0.12), (w * 0.98, -h * 0.08),
      (w * 1.03, -h * 0.17), (w * 1.01, -h * 0.29))
    let swoop-b = _hsb-cubic((w * 0.04, -h * 0.77), (w * -0.02, -h * 0.88),
      (w * 0.03, -h * 0.96), (w * 0.13, -h * 0.99))
    draw.line(.._hsb-map(swoop-a, w, rtl), stroke: accent-style)
    draw.line(.._hsb-map(swoop-b, w, rtl), stroke: accent-style)
    let quote-ink = if dark { white } else { rgb("#032A3B") }
    let quote-style = (paint: quote-ink, thickness: 0.11cm, cap: "round", join: "round")
    let x1 = if rtl { w * 0.81 } else { w * 0.19 }
    let x2 = if rtl { w * 0.70 } else { w * 0.30 }
    let x3 = if rtl { w * 0.13 } else { w * 0.87 }
    let x4 = if rtl { w * 0.07 } else { w * 0.93 }
    for x in (x1, x2) {
      draw.circle((x, -h * 0.22), radius: 0.19, fill: quote-ink)
      draw.line((x - 0.04, -h * 0.25), (x - 0.14, -h * 0.31), stroke: quote-style)
    }
    for x in (x3, x4) {
      draw.circle((x, -h * 0.70), radius: 0.16, fill: quote-ink)
      draw.line((x + 0.04, -h * 0.67), (x + 0.14, -h * 0.76), stroke: quote-style)
    }
  } else if kind == "speech" {
    let swoop-a = _hsb-cubic((w * 0.20, -h * 0.14), (w * 0.31, -h * 0.11),
      (w * 0.40, -h * 0.09), (w * 0.49, -h * 0.07))
    let swoop-b = _hsb-cubic((w * 0.08, -h * 0.80), (w * 0.07, -h * 0.92),
      (w * 0.12, -h * 0.95), (w * 0.22, -h * 0.94))
    draw.line(.._hsb-map(swoop-a, w, rtl), stroke: accent-style)
    draw.line(.._hsb-map(swoop-b, w, rtl), stroke: accent-style)
  } else {
    let swoop-a = _hsb-cubic((w * 0.20, -h * 0.22), (w * 0.15, -h * 0.14),
      (w * 0.10, -h * 0.11), (w * 0.05, -h * 0.06))
    let swoop-b = _hsb-cubic((w * 0.89, -h * 0.78), (w * 0.96, -h * 0.74),
      (w * 0.99, -h * 0.68), (w * 1.01, -h * 0.60))
    draw.line(.._hsb-map(swoop-a, w, rtl), stroke: accent-style)
    draw.line(.._hsb-map(swoop-b, w, rtl), stroke: accent-style)
    let trail-style = (paint: edge, thickness: if dark { 0.06cm } else { 0.07cm })
    draw.circle((if rtl { w * 0.75 } else { w * 0.25 }, -h * 0.91), radius: 0.17, fill: accent, stroke: trail-style)
    draw.circle((if rtl { w * 0.83 } else { w * 0.17 }, -h * 0.99), radius: 0.11, fill: accent, stroke: trail-style)
  }
})

/// A row or grid of hand-drawn quote, speech, and thought bubbles.
///
/// Each item accepts `title:` and `body:`; `kind:` can be `quote`, `speech`,
/// or `thought`. Optional `colour:`, `title-colour:`, and `body-colour:` tune
/// individual bubbles. RTL reverses their reading order, mirrors their tails,
/// and sets the text direction. Set `dark: true` on a dark slide; print mode
/// automatically switches to white faces, black outlines, and gray accents.
///
/// ```typ
/// #hand-drawn-speech-bubbles(steps: (
///   (kind: "quote", title: [A memorable quote], body: [Keep the message short.]),
///   (kind: "speech", title: [Dialogue], body: [Make a point clearly.]),
///   (kind: "thought", title: [An idea], body: [Show a thought or reflection.]),
/// ))
/// ```
#let hand-drawn-speech-bubbles(
  steps: (),
  width: auto,
  columns: 3,
  gap: 0.52cm,
  row-gap: 0.54cm,
  height: 6.40cm,
  direction: auto,
  dark: false,
  colours: (rgb("#37BDD1"), rgb("#72A576"), rgb("#FFA91D")),
  title-size: 13pt,
  body-size: 8.6pt,
  outline: 0.13cm,
  padding-x: 1.02cm,
  title-y: auto,
  body-y: auto,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  let dark-mode = dark and not print-mode
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
      let tile-cm = calc.max(4.25, (total-cm - (columns - 1) * gap-cm) / columns)
      let rows = calc.ceil(count / columns)
      let height-cm = height / 1cm
      let row-height-cm = height-cm + 0.48
      let total-height = (rows * row-height-cm + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          let step = steps.at(index)
          let kind = if "kind" in step { step.at("kind") }
            else { ("quote", "speech", "thought").at(calc.rem(index, 3)) }
          let face = if print-mode { white }
            else if "colour" in step { step.at("colour") }
            else { colours.at(calc.rem(index, colours.len())) }
          let ink = if print-mode { black } else { rgb("#032A3B") }
          let edge = if print-mode { black } else if dark-mode { white } else { ink }
          let accent = if print-mode { luma(130) } else { face }
          let title-ink = if print-mode { black }
            else if "title-colour" in step { step.at("title-colour") }
            else if kind == "speech" and not dark-mode { white }
            else { ink }
          let body-ink = if print-mode { black }
            else if "body-colour" in step { step.at("body-colour") }
            else if kind == "speech" and not dark-mode { white }
            else { ink }
          let stroke-width = if print-mode { 1.15pt } else { outline }
          let bubble-width = (tile-cm - 0.12) * 1cm
          let bubble-height = height
          let art-y = 0.18cm
          let art = _hsb-art(
            kind, bubble-width, bubble-height, face, edge, accent,
            stroke-width, dark-mode, rtl,
          )
          let inset-x = (tile-cm - (tile-cm - 0.12)) / 2 * 1cm
          let text-width = bubble-width - 2 * padding-x
          let title-offset = if title-y == auto { height * 0.30 } else { title-y }
          let body-offset = if body-y == auto { height * 0.39 } else { body-y }
          let title-box = box(width: text-width, height: 0.50cm,
            align(center + horizon,
              text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
          let body-box = box(width: text-width, height: height - 2.28cm,
            align(center + top,
              text(size: body-size, fill: body-ink, step.at("body"))))
          place(top + left,
            dx: (visual-col * (tile-cm + gap-cm)) * 1cm,
            dy: (row * (row-height-cm + row-gap-cm)) * 1cm,
            box(width: tile-cm * 1cm, height: row-height-cm * 1cm, inset: 0pt, {
              place(top + left, dx: inset-x, dy: art-y, art)
              place(top + left, dx: inset-x + padding-x, dy: art-y + title-offset, title-box)
              place(top + left, dx: inset-x + padding-x, dy: art-y + body-offset, body-box)
            }))
        }
      })
    }
  })
}
