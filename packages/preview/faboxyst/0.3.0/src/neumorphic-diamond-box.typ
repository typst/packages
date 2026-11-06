// One soft-relief diamond tile adapted from PresentationGO's Neumorphic Wavy Process.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ndb-cubic(p0, p1, p2, p3, n: 8) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _ndb-diamond-points(d, corner) = {
  let a = calc.min(corner * 0.70, d * 0.09)
  let p = ((d * 0.5 - a, a),)
  p += _ndb-cubic((d * 0.5 - a, a),
    (d * 0.5 - a * 0.4, a * 0.10),
    (d * 0.5 + a * 0.4, a * 0.10), (d * 0.5 + a, a)).slice(1)
  p.push((d - a, d * 0.5 - a))
  p += _ndb-cubic((d - a, d * 0.5 - a),
    (d - a * 0.10, d * 0.5 - a * 0.4),
    (d - a * 0.10, d * 0.5 + a * 0.4), (d - a, d * 0.5 + a)).slice(1)
  p.push((d * 0.5 + a, d - a))
  p += _ndb-cubic((d * 0.5 + a, d - a),
    (d * 0.5 + a * 0.4, d - a * 0.10),
    (d * 0.5 - a * 0.4, d - a * 0.10), (d * 0.5 - a, d - a)).slice(1)
  p.push((a, d * 0.5 + a))
  p += _ndb-cubic((a, d * 0.5 + a),
    (a * 0.10, d * 0.5 + a * 0.4),
    (a * 0.10, d * 0.5 - a * 0.4), (a, d * 0.5 - a)).slice(1)
  p
}

#let _ndb-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4.2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if calc.rem(kind, 4) == 0 {
    "<circle cx=\"45\" cy=\"51\" r=\"26\"/><circle cx=\"45\" cy=\"51\" r=\"14\"/><path d=\"M45 51l34-34M64 17h15v15\"/>"
  } else if calc.rem(kind, 4) == 1 {
    "<path d=\"M48 17a22 22 0 0 0-13 40c4 3 6 7 7 12h12c1-5 3-9 7-12A22 22 0 0 0 48 17Z M42 73h12M44 80h8M48 5v5M16 22l7 5M80 22l-7 5M12 48h8M76 48h8\"/>"
  } else if calc.rem(kind, 4) == 2 {
    "<circle cx=\"48\" cy=\"52\" r=\"27\"/><path d=\"M48 52V33M48 52l15 10M38 12h20M48 12v13M67 27l8-8\"/>"
  } else {
    "<path d=\"M48 17a31 31 0 1 0 0 62 31 31 0 0 0 0-62Z M8 48h10M78 48h10M48 8v10M48 78v10M19 19l7 7M70 70l7 7M77 19l-7 7M26 70l-7 7\"/><circle cx=\"48\" cy=\"48\" r=\"13\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// One rounded rhombus information tile with a line icon and an outside caption.
///
/// Adapted from PresentationGO's *Neumorphic Wavy Process*: the diamond surface
/// and soft twin relief are retained, while the source's five-tile wave and
/// connector line are omitted. `label-position` places the title/body above or
/// below the tile. Set `accent: true` for the highlighted colored tile.
#let neumorphic-diamond-box(
  title: [],
  body: [],
  icon: none,
  icon-style: 1,
  width: auto,
  side: 2.0cm,
  direction: auto,
  label-position: "below",
  accent: false,
  dark: false,
  colour: rgb("#36B6DE"),
  title-colour: auto,
  text-colour: auto,
  icon-size: 1.45cm,
  corner: 0.24cm,
  title-size: 11pt,
  body-size: 8.2pt,
  label-gap: 0.10cm,
  tile-gap: 0.23cm,
  shadow: true,
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
  if label-position != "above" and label-position != "below" {
    panic("label-position must be above or below")
  }
  let surface = if print-mode { white }
    else if accent { gradient.linear(colour.lighten(10%), colour.darken(5%), angle: 90deg) }
    else if dark { rgb("#2B3038") }
    else { rgb("#F0F1F3") }
  // Four edge shadows. In print, keep a darker top and three lighter gray sides.
  let dark-shadow = if print-mode { luma(178).transparentize(12%) }
    else if dark { black.transparentize(52%) }
    else if accent { colour.darken(20%).transparentize(48%) }
    else { rgb("#C7C9CD").transparentize(46%) }
  let light-shadow = if print-mode { luma(216).transparentize(18%) }
    else if dark { luma(88).transparentize(48%) }
    else if accent { colour.lighten(15%).transparentize(48%) }
    else { rgb("#D3D5D8").transparentize(42%) }
  let shadow-top = dark-shadow
  let shadow-left = if print-mode { light-shadow } else { dark-shadow }
  let shadow-right = light-shadow
  let shadow-bottom = light-shadow
  let icon-ink = if print-mode { luma(35) }
    else if accent { white }
    else if dark { luma(225) }
    else { luma(145) }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else if accent { colour.darken(6%) }
    else if dark { white }
    else { luma(30) }
  let body-ink = if print-mode { luma(48) }
    else if text-colour != auto { text-colour }
    else if dark { luma(215) }
    else { luma(95) }
  let symbol = if icon == none { _ndb-icon(icon-size, icon-ink, icon-style) }
    else { icon }
  let title-content = text(dir: if rtl { std.rtl } else { std.ltr },
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.32em, spacing: 0.22em, justify: false)
    text(dir: if rtl { std.rtl } else { std.ltr }, size: body-size, fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 4.8) }
      else { width / 1cm }
    let side-cm = side / 1cm
    let d-cm = side-cm * calc.sqrt(2)
    let d = d-cm * 1cm
    let title-box = box(width: W * 1cm, align(center, title-content))
    let body-box = box(width: W * 1cm, align(center, body-content))
    let title-h = measure(title-box).height / 1cm
    let body-h = measure(body-box).height / 1cm
    let label-h = title-h + (if title-h > 0 and body-h > 0 { label-gap / 1cm } else { 0 }) + body-h
    let tile-gap-cm = tile-gap / 1cm
    let total-h = (label-h + tile-gap-cm + d-cm) * 1cm
    let tile-x = (W - d-cm) / 2
    let tile-y = if label-position == "above" { (label-h + tile-gap-cm) * 1cm } else { 0pt }
    let label-y = if label-position == "above" { 0pt } else { (d-cm + tile-gap-cm) * 1cm }
    let body-y = label-y + title-h * 1cm + (if title-h > 0 and body-h > 0 { label-gap } else { 0pt })
    let points = _ndb-diamond-points(d, corner)
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let edge = if print-mode { (paint: luma(232), thickness: 0.3pt) } else { none }
    let icon-x = tile-x * 1cm + (d - icon-size) / 2
    let icon-y = tile-y + (d - icon-size) / 2

    box(width: W * 1cm, height: total-h, inset: 0pt, {
      if shadow {
        // Draw the three softer sides first so the darker top edge stays distinct.
        place(top + left, dx: tile-x * 1cm - 0.09cm, dy: tile-y,
          polygon(fill: shadow-left, stroke: none, ..points))
        place(top + left, dx: tile-x * 1cm + 0.09cm, dy: tile-y,
          polygon(fill: shadow-right, stroke: none, ..points))
        place(top + left, dx: tile-x * 1cm, dy: tile-y + 0.09cm,
          polygon(fill: shadow-bottom, stroke: none, ..points))
        place(top + left, dx: tile-x * 1cm, dy: tile-y - 0.09cm,
          polygon(fill: shadow-top, stroke: none, ..points))
      }
      place(top + left, dx: tile-x * 1cm, dy: tile-y,
        polygon(fill: surface, stroke: edge, ..points))
      place(top + left, dx: icon-x + icon-offset-x, dy: icon-y + icon-offset-y, icon-box)
      place(top + left, dx: (0pt) + title-offset-x, dy: (label-y) + title-offset-y, title-box)
      place(top + left, dx: (0pt) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
    })
  })
}
