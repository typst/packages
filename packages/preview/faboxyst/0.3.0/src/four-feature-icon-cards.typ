// Four-feature 2x2 card grid with colorful icon medallions and dotted ring accents.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ffic-cubic(p0, p1, p2, p3, n: 10) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _ffic-mirror(points, w, rtl) = if rtl {
  points.map(((x, y)) => (w - x, y)).rev()
} else { points }

#let _ffic-art(width, height, accent, print-mode, rtl, icon: none, icon-box: 1.12cm, icon-dx: 0pt, icon-dy: 0pt) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = height / 1cm
  let border = if print-mode { (paint: luma(65), thickness: 1.05pt, join: "round", cap: "round") }
    else { (paint: accent, thickness: 0.085cm, join: "round", cap: "round") }
  let x-left = 1.44
  let x-right = w - 0.12
  let corner = 0.42
  let top = -0.10
  let bottom = -(h - 0.10)

  // Hand-drawn rounded frame with two small, dotted interruptions.
  let frame = ((x-left, top), (w * 0.64, top))
  frame += _ffic-cubic((w * 0.64, top), (w * 0.68, top), (w * 0.69, top), (w * 0.70, top))
  draw.line(.._ffic-mirror(frame, w, rtl), stroke: border)
  for x in (w * 0.725, w * 0.75, w * 0.775) {
    draw.circle((if rtl { w - x } else { x }, top), radius: if print-mode { 0.035 } else { 0.055 }, fill: if print-mode { luma(95) } else { accent }, stroke: none)
  }
  let upper = ((w * 0.805, top), (x-right - corner, top))
  upper += _ffic-cubic((x-right - corner, top), (x-right - corner * 0.45, top),
    (x-right, top - corner * 0.45), (x-right, top - corner))
  upper.push((x-right, bottom + corner))
  upper += _ffic-cubic((x-right, bottom + corner),
    (x-right, bottom + corner * 0.45), (x-right - corner * 0.45, bottom),
    (x-right - corner, bottom))
  upper.push((w * 0.40, bottom))
  draw.line(.._ffic-mirror(upper, w, rtl), stroke: border)
  for x in (w * 0.355, w * 0.33, w * 0.305) {
    draw.circle((if rtl { w - x } else { x }, bottom), radius: if print-mode { 0.035 } else { 0.055 }, fill: if print-mode { luma(95) } else { accent }, stroke: none)
  }
  let lower = ((w * 0.27, bottom), (x-left + 0.36, bottom))
  lower += _ffic-cubic((x-left + 0.36, bottom), (x-left + 0.12, bottom),
    (x-left, bottom + 0.02), (x-left, bottom + corner))
  draw.line(.._ffic-mirror(lower, w, rtl), stroke: border)

  let cx = if rtl { w - 1.42 } else { 1.42 }
  let cy = -h / 2
  let ring-stroke = if print-mode {
    (paint: luma(95), thickness: 0.8pt)
  } else { (paint: accent, thickness: 0.065cm) }
  draw.circle((cx, cy), radius: 0.91, fill: none, stroke: ring-stroke)
  // Dotted outer arc on the leading side of the medallion.
  for i in range(11) {
    let angle = (110 + i * 14) * 1deg
    let x = if rtl { w - (1.42 + 1.02 * calc.cos(angle)) }
      else { 1.42 + 1.02 * calc.cos(angle) }
    let y = cy - 1.02 * calc.sin(angle)
    draw.circle((x, y), radius: if print-mode { 0.025 } else { 0.035 }, fill: if print-mode { luma(120) } else { accent }, stroke: none)
  }
  draw.circle((cx, cy), radius: 0.72,
    fill: if print-mode { white } else { accent },
    stroke: if print-mode { (paint: luma(85), thickness: 0.65pt) } else { none })
  // The icon is drawn INSIDE the canvas, on the medallion's centre, so it is
  // centred on the disc whatever the canvas bounds are.
  if icon != none {
    draw.content((cx + (if rtl { -1 } else { 1 }) * icon-dx / 1cm, cy - icon-dy / 1cm), anchor: "center",
      box(width: icon-box, height: icon-box, align(center + horizon, icon)))
  }
})

/// A two-by-two feature grid with colorful circular icon medallions and framed
/// text panels. Each item requires `title:` and `body:`; `icon:` is optional,
/// with optional `dark-icon:` and `print-icon:` replacements. Palette, cell
/// dimensions, gaps, typography and the icon-ring treatment are configurable.
/// RTL reverses grid reading order and mirrors each card's icon/text layout.
/// Set `dark: true` on dark slides. Print mode switches panels to white and
/// uses monochrome borders, dots, and optional print pictograms.
///
/// ```typ
/// #four-feature-icon-cards(steps: (
///   (title: [Feature], body: [A short description.], icon: [★]),
///   (title: [Benefit], body: [Another description.], icon: [✓]),
///   (title: [Idea], body: [A third description.], icon: [✦]),
///   (title: [Data], body: [A final description.], icon: [▤]),
/// ))
/// ```
#let four-feature-icon-cards(
  steps: (),
  width: auto,
  columns: 2,
  gap: 0.72cm,
  row-gap: 0.88cm,
  height: 3.18cm,
  direction: auto,
  dark: false,
  colours: (
    rgb("#F25E4B"), rgb("#10B4CE"),
    rgb("#FF9500"), rgb("#284A73"),
  ),
  title-size: 13pt,
  body-size: 7.6pt,
  icon-size: 1.12cm,
  title-height: 0.76cm,
  title-width: auto,
  title-y: 0.38cm,
  body-y: 1.32cm,
  text-start: 2.72cm,
  text-end: 1.05cm,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
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
      let tile-cm = calc.max(5.0, (total-cm - (columns - 1) * gap-cm) / columns)
      let rows = calc.ceil(count / columns)
      let height-cm = height / 1cm
      let row-stride-cm = height-cm + 0.20 + row-gap-cm
      let total-height = (rows * (height-cm + 0.20) + (rows - 1) * row-gap-cm) * 1cm
      let title-width = if title-width == auto { tile-cm - text-start / 1cm - text-end / 1cm } else { title-width / 1cm }
      let text-width = tile-cm - text-start / 1cm - text-end / 1cm
      let panel-ink = if print-mode { black } else if dark-mode { white } else { rgb("#555555") }
      let title-ink-default = if print-mode { black } else if dark-mode { rgb("#032A3B") } else { white }
      let art-y = 0.10cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          let step = steps.at(index)
          let accent = if "colour" in step { step.at("colour") }
            else { colours.at(calc.rem(index, colours.len())) }
          let face = if print-mode { luma(226) } else { accent }
          let title-ink = if print-mode { black }
            else if "title-colour" in step { step.at("title-colour") }
            else { title-ink-default }
          let body-ink = if print-mode { black }
            else if "body-colour" in step { step.at("body-colour") }
            else { panel-ink }
          let cell-width = tile-cm * 1cm
          let icon = if print-mode and "print-icon" in step { step.at("print-icon") }
            else if dark-mode and "dark-icon" in step { step.at("dark-icon") }
            else if "icon" in step { step.at("icon") }
            else { [✦] }
          let outer-icon = if icon == none { [✦] } else { icon }
          let shape = _ffic-art(cell-width, height, accent, print-mode, rtl, icon: outer-icon, icon-box: icon-size,
            icon-dx: icon-offset-x, icon-dy: icon-offset-y)
          let title-content = text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))
          let title-box = box(width: title-width * 1cm, height: title-height,
            radius: 0.13cm,
            fill: face,
            inset: (x: 0.14cm, y: 0.04cm),
            align(center + horizon, title-content))
          let body-align = if rtl { right } else { left }
          let body-box = box(width: text-width * 1cm, height: height - body-y - 0.32cm,
            align(body-align + top,
              text(size: body-size, fill: body-ink, step.at("body"))))
          let title-x = if rtl { cell-width - text-start - title-width * 1cm } else { text-start }
          let body-x = if rtl { cell-width - text-start - text-width * 1cm } else { text-start }
          place(top + left, dx: (visual-col * (tile-cm + gap-cm)) * 1cm, dy: (row * row-stride-cm) * 1cm, box(width: cell-width, height: (height-cm + 0.20) * 1cm, inset: 0pt, {
              place(top + left, dy: art-y, shape)
              place(top + left, dx: title-x, dy: art-y + title-y, title-box)
              place(top + left, dx: body-x, dy: art-y + body-y, body-box)
            }))
        }
      })
    }
  })
}
