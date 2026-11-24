// One reusable vertical card extracted from PresentationGO's Continuous Block Process.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _cbp-arrow-points(width, height, rtl: false) = if rtl {
  ((0pt, 0pt), (width, 0pt), (width, height), (0pt, height), (0pt, height * 0.78),
   (height * 0.42, height / 2), (0pt, height * 0.22))
} else {
  ((0pt, 0pt), (width - height * 0.42, 0pt), (width, height / 2),
   (width - height * 0.42, height), (0pt, height), (height * 0.42, height / 2))
}

#let _cbp-chart-icon(size, colour, rtl: false) = {
  let bw = size * 0.15
  let base = size * 0.78
  let bar1 = rect(width: bw, height: size * 0.28, fill: colour)
  let bar2 = rect(width: bw, height: size * 0.47, fill: colour)
  let bar3 = rect(width: bw, height: size * 0.68, fill: colour)
  let baseline = rect(width: size * 0.78, height: 0.045cm, fill: colour)
  let shaft-points = if rtl {
    ((size * 0.95, size * 0.60), (size * 0.90, size * 0.67),
     (size * 0.22, size * 0.16), (size * 0.28, size * 0.09))
  } else {
    ((size * 0.05, size * 0.60), (size * 0.10, size * 0.67),
     (size * 0.78, size * 0.16), (size * 0.72, size * 0.09))
  }
  let head-points = if rtl {
    ((size * 0.36, size * 0.03), (size * 0.04, size * 0.00),
     (size * 0.14, size * 0.32))
  } else {
    ((size * 0.64, size * 0.03), (size * 0.96, size * 0.00),
     (size * 0.86, size * 0.32))
  }
  box(width: size, height: size, {
    place(top + left, dx: size * 0.08, dy: base - size * 0.28, bar1)
    place(top + left, dx: size * 0.30, dy: base - size * 0.47, bar2)
    place(top + left, dx: size * 0.52, dy: base - size * 0.68, bar3)
    place(top + left, dx: size * 0.06, dy: base + 0.06cm, baseline)
    place(top + left, polygon(fill: colour, stroke: none, ..shaft-points))
    place(top + left, polygon(fill: colour, stroke: none, ..head-points))
  })
}

/// Draw one vertical Continuous Block Process card with progress window and arrow segment.
/// The source's three-card row is intentionally reduced to one configurable box.
#let continuous-block-process-box(
  title: [LOREM IPSUM],
  value: [66%],
  body: [],
  icon: none,
  print-icon: none,
  width: 6.4cm,
  height: auto,
  min-height: 11.8cm,
  direction: auto,
  body-direction: auto,
  colour: rgb("#F7941D"),
  panel-colour: auto,
  title-colour: auto,
  value-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  arrow-overhang: 0.68cm,
  window-width: 0.78,
  window-height: 2.00cm,
  window-y: 0.76cm,
  title-size: 17pt,
  value-size: 29pt,
  body-size: 10.5pt,
  icon-size: 1.75cm,
  card-radius: 0.78cm,
  body-start: 4.10cm,
  body-padding-x: 0.48cm,
  body-to-icon-gap: 0.38cm,
  bottom-padding: 0.62cm,
  shadow-offset: 0.18cm,
  shadow: true,
  show-arrow: true,
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
  let body-rtl = if body-direction == auto { rtl }
    else { body-direction == "rtl" or body-direction == std.rtl }
  let body-dir = if body-rtl { std.rtl } else { std.ltr }

  let accent = if print-mode { luma(174) } else { colour }
  let arrow-ink = if print-mode { luma(122) } else { colour.darken(14%) }
  let face-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { rgb("#17191B") }
  let value-ink = if print-mode { black }
    else if value-colour != auto { value-colour }
    else if luma(colour).components().first() > 55% { colour.darken(67%) }
    else { white }
  let body-ink = if print-mode { luma(48) }
    else if text-colour != auto { text-colour }
    else { rgb("#595D61") }
  let shadow-tone = if shadow-colour != auto { shadow-colour } else { rgb("#626A70") }
  let shadow-fill = if print-mode { luma(220) } else { shadow-tone.transparentize(72%) }
  let edge = if print-mode { (paint: luma(150), thickness: 1.1pt) }
    else { (paint: luma(218), thickness: 0.75pt) }
  let icon-ink = if print-mode { luma(65) } else { colour }

  let body-content = if body-direction == auto {
    {
      set par(leading: 1.12em, spacing: 0.36em, justify: false)
      text(size: body-size, fill: body-ink, body)
    }
  } else {
    {
      set par(leading: 1.12em, spacing: 0.36em, justify: false)
      text(dir: body-dir, size: body-size, fill: body-ink, body)
    }
  }
  let content-width = width - 2 * body-padding-x
  let body-measure = measure(body-content, width: content-width)
  let content-height = (
    body-start + body-measure.height + body-to-icon-gap
      + icon-size + bottom-padding
  )
  let final-height = if height == auto { calc.max(min-height, content-height) }
    else { calc.max(height, content-height) }
  let icon-y = final-height - icon-size - bottom-padding
  let body-height = icon-y - body-to-icon-gap - body-start

  let overhang = arrow-overhang
  let card-x = overhang
  let stage-width = width + 2 * overhang + shadow-offset
  let stage-height = final-height + shadow-offset
  let card-shadow = box(width: width, height: final-height,
    radius: card-radius, fill: shadow-fill, inset: 0pt)
  let card = box(width: width, height: final-height,
    radius: card-radius, fill: face-fill, stroke: edge, inset: 0pt)

  let bar-width = width + 2 * overhang
  let bar-height = 0.47cm
  let bar-y = window-y + (window-height - bar-height) / 2
  let arrow = polygon(fill: arrow-ink, stroke: none,
    .._cbp-arrow-points(bar-width, bar-height, rtl: rtl))
  let window-w = width * window-width
  let window-x = card-x + (width - window-w) / 2
  let window-base = box(width: window-w, height: window-height,
    fill: if print-mode { luma(175) }
      else { gradient.linear(colour.lighten(9%), colour, colour.darken(9%), angle: 90deg) })
  let window-shadow = box(width: window-w, height: window-height,
    fill: if print-mode { luma(118) } else { colour.darken(25%) })
  let window-edge = if print-mode { luma(98) } else { colour.darken(30%) }
  let window-stripe = box(width: 0.12cm, height: window-height,
    fill: window-edge)
  let value-content = text(dir: if rtl { std.rtl } else { std.ltr },
    size: value-size, weight: "bold", fill: value-ink, value)
  let value-box = box(width: window-w - 0.2cm, height: window-height,
    align(center + horizon, value-content))

  let title-box = box(width: content-width, height: 0.74cm,
    align((if rtl { right } else { left }) + horizon,
      text(dir: if rtl { std.rtl } else { std.ltr }, size: title-size,
        weight: "bold", fill: title-ink, title)))
  let body-box = box(width: content-width, height: body-height,
    align((if body-rtl { right } else { left }) + top, body-content))
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { _cbp-chart-icon(icon-size, icon-ink, rtl: rtl) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center + horizon, icon-content))
  let title-x = card-x + body-padding-x
  let body-x = title-x
  let icon-x = card-x + (width - icon-size) / 2
  let shadow-x = card-x + shadow-offset
  let arrow-x = 0pt
  let window-shadow-x = window-x + 0.045cm
  let window-shadow-y = window-y + 0.07cm
  let stripe-x = window-x + window-w - 0.12cm
  let value-x = window-x + 0.10cm

  box(width: stage-width, height: stage-height, inset: 0pt, {
    if shadow {
      place(top + left, dx: shadow-x, dy: shadow-offset, card-shadow)
    }
    place(top + left, dx: card-x, dy: 0pt, card)
    if show-arrow {
      place(top + left, dx: arrow-x, dy: bar-y, arrow)
    }
    place(top + left, dx: window-shadow-x, dy: window-shadow-y, window-shadow)
    place(top + left, dx: window-x, dy: window-y, window-base)
    place(top + left, dx: stripe-x, dy: window-y, window-stripe)
    place(top + left, dx: value-x, dy: window-y, value-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (3.12cm) + title-offset-y, title-box)
    place(top + left, dx: (body-x) + body-offset-x, dy: (body-start) + body-offset-y, body-box)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
  })
}
