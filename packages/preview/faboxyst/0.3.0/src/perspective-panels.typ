// Configurable perspective panel set adapted from PresentationGO's 5-Option layout.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _pp-cubic(p0, p1, p2, p3, n: 12) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _pp-side-points(width, height, side, skew, radius) = {
  let tl = (skew * 0.25 + radius, 0pt)
  let tr = (width, skew * 0.72 + radius * 0.45)
  let br = (width - skew * 0.72, height - radius)
  let bl = (skew * 0.18 + radius, height)
  let p = (tl,)
  p += _pp-cubic(tl, (width * 0.38, 0pt),
    (width * 0.78, skew * 0.44), (width - radius, tr.at(1)))
  p += _pp-cubic((width - radius, tr.at(1)),
    (width - radius * 0.25, tr.at(1) + radius * 0.12),
    (width, tr.at(1) + radius * 0.30), tr)
  p.push((width, height * 0.84))
  p += _pp-cubic((width, height * 0.84),
    (width, height * 0.93), (width - radius * 0.8, height), br)
  p.push((bl.at(0) + radius, height))
  p += _pp-cubic((bl.at(0) + radius, height),
    (bl.at(0) + radius * 0.20, height), bl, (bl.at(0), height - radius))
  p.push((bl.at(0), height * 0.18))
  p += _pp-cubic((bl.at(0), height * 0.18),
    (bl.at(0), height * 0.07), (tl.at(0) - radius * 0.25, 0pt), tl)
  if side == "right" { p.map(((x, y)) => (width - x, y)) } else { p }
}

#let _pp-depth-points(width, height, side, skew, depth) = if side == "left" {
  ((width - depth, skew * 0.55), (width, skew * 0.72 + 0.04cm),
   (width - skew * 0.72, height - 0.05cm),
   (width - skew * 0.72 - depth, height - 0.05cm))
} else {
  ((depth, skew * 0.72 + 0.04cm), (0pt, skew * 0.55),
   (skew * 0.72, height - 0.05cm),
   (skew * 0.72 + depth, height - 0.05cm))
}

#let _pp-face(width, height, side, skew, radius, fill, stroke) = if side == "center" {
  rect(width: width, height: height, radius: radius, fill: fill, stroke: stroke)
} else {
  polygon(fill: fill, stroke: stroke,
    .._pp-side-points(width, height, side, skew, radius))
}

#let _pp-default-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if calc.rem(kind, 5) == 0 {
    "<rect x=\"20\" y=\"19\" width=\"56\" height=\"56\" rx=\"4\"/><path d=\"M31 47l11 11 24-28\"/>"
  } else if calc.rem(kind, 5) == 1 {
    "<path d=\"M18 75h62M25 70V47h11v23M43 70V29h11v41M61 70V42h11v28\"/>"
  } else if calc.rem(kind, 5) == 2 {
    "<path d=\"M48 16a22 22 0 0 0-13 40c4 3 6 7 7 12h12c1-5 3-9 7-12A22 22 0 0 0 48 16Z M42 73h12M44 80h8M48 5v5M17 22l7 5M79 22l-7 5M12 48h8M76 48h8\"/>"
  } else if calc.rem(kind, 5) == 3 {
    "<rect x=\"24\" y=\"22\" width=\"48\" height=\"60\" rx=\"4\"/><path d=\"M37 22v-6h22v6M33 42l4 4 7-8M50 43h13M33 57l4 4 7-8M50 58h13M33 72l4 4 7-8M50 73h13\"/>"
  } else {
    "<path d=\"M48 13l7 3 6-3 6 6-3 6 3 7 7 3v8l-7 3-3 7 3 6-6 6-6-3-7 3-3 7h-8l-3-7-7-3-6 3-6-6 3-6-3-7-7-3v-8l7-3 3-7-3-6 6-6 6 3 7-3 3-7h8z\"/><circle cx=\"48\" cy=\"39\" r=\"9\"/><circle cx=\"65\" cy=\"67\" r=\"7\"/><path d=\"M65 54v3M77 67h-3M65 80v-3M53 67h3\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// Lay out a configurable row of perspective panels.
/// The panel count comes from `panels.len()`; set per-panel widths, a shared gap,
/// or individual `gaps` to tune the composition. In RTL the logical order reverses.
#let perspective-panels(
  panels,
  panel-widths: auto,
  panel-width: 3.2cm,
  gap: -0.18cm,
  gaps: auto,
  height: auto,
  min-height: 6.2cm,
  center-recess: 0.24cm,
  direction: auto,
  palette: (
    rgb("#F5A623"), rgb("#F2D42E"), rgb("#E85B4A"),
    rgb("#77A96F"), rgb("#35BBD5"),
  ),
  perspective: 0.44cm,
  depth: 0.24cm,
  corner-radius: 0.18cm,
  body-width: 0.76,
  icon-size: 0.88cm,
  badge-size: 0.88cm,
  title-size: 12pt,
  body-size: 7.8pt,
  icon-y: 0.15,
  title-y: 0.41,
  body-y: 0.54,
  bottom-padding: 0.48cm,
  text-colour: auto,
  title-colour: auto,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let count = panels.len()
  if count == 0 { panic("perspective-panels needs at least one panel") }
  if panel-widths != auto and panel-widths.len() != count {
    panic("panel-widths must have one entry per panel")
  }
  if palette.len() == 0 { panic("palette must contain at least one colour") }

  let widths = if panel-widths == auto {
    range(0, count).map(_ => panel-width)
  } else { panel-widths }
  let gaps = if gaps == auto {
    range(0, count - 1).map(_ => gap)
  } else { gaps }
  if gaps.len() != count - 1 {
    panic("gaps must have one entry between each adjacent pair of panels")
  }
  for width in widths {
    if width <= 0pt { panic("panel widths must be greater than zero") }
  }
  let sum-lengths = (values) => values.fold(0pt, (total, value) => total + value)
  let total-width = sum-lengths(widths) + sum-lengths(gaps)
  if total-width <= 0pt { panic("the combined panel widths and gaps must be positive") }
  let mid = (count - 1) / 2
  let skew-denominator = calc.max(mid, 0.5)

  let default-ink = if print-mode { luma(25) } else { rgb("#182D38") }
  let panel-fills = panels.enumerate().map(((i, panel)) =>
    if print-mode { luma(241) }
    else { panel.at("colour", default: palette.at(calc.rem(i, palette.len()))) })
  let body-contents = panels.enumerate().map(((i, panel)) => {
    let ink = if print-mode { luma(34) }
      else if panel.at("text-colour", default: text-colour) != auto {
        panel.at("text-colour", default: text-colour)
      } else { default-ink }
    set par(leading: 0.30em, spacing: 0.32em, justify: false)
    text(dir: if rtl { std.rtl } else { std.ltr },
      size: body-size, fill: ink, panel.at("body", default: []))
  })
  let required-height = range(0, count).fold(0pt, (largest, i) => {
    let body-h = measure(body-contents.at(i), width: widths.at(i) * body-width).height
    let visual-i = if rtl { count - 1 - i } else { i }
    let inset = if calc.abs(visual-i - mid) <= 0.5 { center-recess } else { 0pt }
    calc.max(largest, (body-h + bottom-padding) / (1 - body-y) + inset)
  })
  let panel-height = if height == auto { calc.max(min-height, required-height) }
    else { calc.max(height, required-height) }
  let recesses = range(0, count).map(i => {
    let visual-i = if rtl { count - 1 - i } else { i }
    if calc.abs(visual-i - mid) <= 0.5 { center-recess } else { 0pt }
  })
  let panel-heights = range(0, count).map(i => panel-height - recesses.at(i))
  let panel-tops = recesses.map(inset => inset / 2)
  let canvas-height = panel-height + badge-size * 0.46
  let positions = range(0, count).map(i => {
    let before = range(0, i).fold(0pt, (total, j) => total + widths.at(j) + gaps.at(j))
    if rtl { total-width - before - widths.at(i) } else { before }
  })
  let sides = range(0, count).map(i => {
    let visual-i = if rtl { count - 1 - i } else { i }
    if calc.rem(count, 2) == 1 and visual-i == mid { "center" }
    else if visual-i < mid { "left" } else { "right" }
  })
  let skews = range(0, count).map(i => {
    let visual-i = if rtl { count - 1 - i } else { i }
    perspective * calc.min(1, calc.abs(visual-i - mid) / skew-denominator)
  })
  let panel-strokes = if print-mode { (paint: luma(82), thickness: 0.75pt) } else { none }
  let depth-fills = panel-fills.map(colour =>
    if print-mode { luma(194) } else { colour.darken(19%) })
  let badge-fills = panel-fills.map(colour =>
    if print-mode { luma(115) } else { colour.darken(24%) })
  let panel-shadow = if print-mode { luma(220) }
    else { rgb("#071722").transparentize(78%) }

  box(width: total-width, height: canvas-height, inset: 0pt, {
    // A restrained offset shadow separates the overlapping cards from the page.
    for i in range(0, count) {
      let shadow = _pp-face(widths.at(i), panel-heights.at(i), sides.at(i),
        skews.at(i), corner-radius, panel-shadow, none)
      place(top + left, dx: positions.at(i) + 0.06cm,
        dy: panel-tops.at(i) + 0.10cm, shadow)
    }

    // Paint from the outer edges inward so nearer panels naturally overlap the rear ones.
    for layer in range(0, count) {
      let target-distance = mid - layer
      if target-distance >= 0 {
        for i in range(0, count) {
          let visual-i = if rtl { count - 1 - i } else { i }
          let distance = calc.abs(visual-i - mid)
          if distance == target-distance {
            let w = widths.at(i)
            let h = panel-heights.at(i)
            let y = panel-tops.at(i)
            let side = sides.at(i)
            let skew = skews.at(i)
            let fill = panel-fills.at(i)
            let face = _pp-face(w, h, side, skew, corner-radius, fill, panel-strokes)
            place(top + left, dx: positions.at(i), dy: y, face)
            if side != "center" and depth > 0pt {
              let facet = polygon(fill: depth-fills.at(i), stroke: none,
                .._pp-depth-points(w, h, side, skew, depth))
              place(top + left, dx: positions.at(i), dy: y, facet)
            }
          }
        }
      }
    }

    // Contents and raised numbered markers sit above every panel face.
    for i in range(0, count) {
      let w = widths.at(i)
      let h = panel-heights.at(i)
      let y = panel-tops.at(i)
      let panel = panels.at(i)
      let fill = panel-fills.at(i)
      let text-override = panel.at("text-colour", default: text-colour)
      let title-override = panel.at("title-colour", default: title-colour)
      let ink = if print-mode { luma(22) }
        else if title-override != auto { title-override }
        else if text-override != auto { text-override }
        else { default-ink }
      let icon-ink = if print-mode { luma(65) }
        else if panel.at("icon-colour", default: auto) != auto {
          panel.at("icon-colour", default: auto)
        } else { rgb("#202F36") }
      let custom-icon = panel.at("icon", default: none)
      let print-icon = panel.at("print-icon", default: none)
      let icon-style = panel.at("icon-style", default: calc.rem(i, 5))
      let icon-content = if print-mode and print-icon != none { print-icon }
        else if custom-icon != none { custom-icon }
        else { _pp-default-icon(icon-size, icon-ink, icon-style) }
      let icon-box = box(width: icon-size, height: icon-size,
        align(center + horizon, icon-content))
      let title-box = box(width: w * 0.82, height: 0.62cm,
        align(center + horizon,
          text(dir: if rtl { std.rtl } else { std.ltr },
            size: title-size, weight: "bold", fill: ink,
            panel.at("title", default: [PANEL]))))
      let body-ink = if print-mode { luma(34) }
        else if text-override != auto { text-override } else { default-ink }
      let body-content = if print-mode { body-contents.at(i) }
        else { text(dir: if rtl { std.rtl } else { std.ltr },
          size: body-size, fill: body-ink, panel.at("body", default: [])) }
      let body-w = w * body-width
      let body-box = box(width: body-w,
        height: h * (1 - body-y) - bottom-padding,
        align(center + top, body-content))
      let badge-size-local = calc.min(badge-size, w * 0.32)
      let number = panel.at("number", default: auto)
      let number-content = if number == auto { str(i + 1) } else { number }
      let badge = ellipse(width: badge-size-local, height: badge-size-local,
        fill: badge-fills.at(i),
        stroke: if print-mode { (paint: luma(75), thickness: 0.6pt) }
          else { (paint: fill.darken(34%), thickness: 0.45pt) })
      let badge-shadow = ellipse(width: badge-size-local, height: badge-size-local,
        fill: if print-mode { luma(195) } else { rgb("#06141D").transparentize(66%) })
      let badge-text = box(width: badge-size-local * 0.82,
        height: badge-size-local,
        align(center + horizon,
          text(dir: std.ltr, size: 8.5pt, weight: "bold", fill: white, number-content)))
      let icon-x = positions.at(i) + (w - icon-size) / 2
      let icon-y-pos = y + h * icon-y
      let title-y-pos = y + h * title-y
      let body-y-pos = y + h * body-y
      let badge-x = positions.at(i) + (w - badge-size-local) / 2
      let badge-y = y + h - badge-size-local * 0.52
      place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y-pos) + icon-offset-y, icon-box)
      place(top + left, dx: (positions.at(i) + (w - w * 0.82) / 2) + title-offset-x, dy: (title-y-pos) + title-offset-y, title-box)
      place(top + left, dx: (positions.at(i) + (w - body-w) / 2) + body-offset-x, dy: (body-y-pos) + body-offset-y, body-box)
      place(top + left, dx: badge-x + 0.035cm, dy: badge-y + 0.055cm, badge-shadow)
      place(top + left, dx: badge-x, dy: badge-y, badge)
      place(top + left, dx: badge-x + badge-size-local * 0.09,
        dy: badge-y, badge-text)
    }
  })
}
