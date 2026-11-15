// One colorful, interlocking wave-textbox adapted from PresentationGO's Infographic Text Boxes.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _wib-cubic(p0, p1, p2, p3, n: 16) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _wib-outline(w, h, rtl: false) = {
  let r = calc.min(w * 0.075, 0.34cm)
  let p = ((r, 0pt), (w - r, 0pt))
  p += _wib-cubic((w - r, 0pt), (w - r * 0.35, 0pt),
    (w, r * 0.35), (w, r)).slice(1)
  p.push((w, h * 0.27))
  // A broad inward-and-outward sweep gives the right edge its interlocking wave.
  p += _wib-cubic((w, h * 0.27), (w - w * 0.13, h * 0.35),
    (w - w * 0.13, h * 0.63), (w, h * 0.72)).slice(1)
  p.push((w, h - r))
  p += _wib-cubic((w, h - r), (w, h - r * 0.35),
    (w - r * 0.35, h), (w - r, h)).slice(1)
  p.push((w * 0.42, h))
  // The lower shoulder curves inward beneath the medallion, like the source card.
  p += _wib-cubic((w * 0.42, h), (w * 0.30, h),
    (w * 0.27, h * 0.91), (w * 0.27, h * 0.78)).slice(1)
  p.push((w * 0.27, h * 0.43))
  p += _wib-cubic((w * 0.27, h * 0.43), (w * 0.27, h * 0.34),
    (w * 0.05, h * 0.34), (0pt, h * 0.25)).slice(1)
  p.push((0pt, r))
  p += _wib-cubic((0pt, r), (0pt, r * 0.35),
    (r * 0.35, 0pt), (r, 0pt)).slice(1)
  if rtl { p.map(((x, y)) => (w - x, y)) } else { p }
}

#let _wib-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if calc.rem(kind, 4) == 0 {
    "<path d=\"M25 34h46l-5 47H30zM34 34v-9a14 14 0 0 1 28 0v9\"/><path d=\"M35 49v17M48 49v17M61 49v17\"/>"
  } else if calc.rem(kind, 4) == 1 {
    "<path d=\"M18 31h33l27 22-27 27-33-33z\"/><circle cx=\"31\" cy=\"44\" r=\"4\"/><path d=\"M18 31l-5-7M40 35l11-11\"/>"
  } else if calc.rem(kind, 4) == 2 {
    "<path d=\"M18 23h10l9 43h39l8-30H33\"/><circle cx=\"43\" cy=\"76\" r=\"4\"/><circle cx=\"68\" cy=\"76\" r=\"4\"/><path d=\"M39 48h39M46 37l2 28M62 37l-1 28\"/>"
  } else {
    "<circle cx=\"48\" cy=\"48\" r=\"27\"/><path d=\"M48 31v17l13 8M48 8v7M48 81v7M8 48h7M81 48h7M20 20l5 5M71 71l5 5M76 20l-5 5M25 71l-5 5\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// A single wavy infographic text box with an inset shoulder and round icon medallion.
///
/// Adapted from PresentationGO's *Infographic Text Boxes*. It keeps one
/// interlocking wave silhouette and badge, rather than reproducing the source row.
/// - `icon` accepts custom Typst content; otherwise `icon-style` selects a line icon.
/// - `direction` mirrors the wave and badge for RTL; `width`, `height`, and `colour` tune it.
#let wavy-infographic-box(
  title: [],
  body: [],
  icon: none,
  icon-style: 0,
  width: auto,
  height: 5.45cm,
  direction: auto,
  colour: rgb("#F49A24"),
  title-colour: auto,
  text-colour: auto,
  badge-size: 2.15cm,
  icon-size: 1.20cm,
  title-size: 11pt,
  body-size: 8pt,
  title-y: 2.50cm,
  label-gap: 0.10cm,
  corner-radius: 0.32cm,
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
  let fill-colour = if print-mode { white }
    else { gradient.linear(colour.lighten(8%), colour.darken(7%), angle: 90deg) }
  let edge-colour = if print-mode { luma(90) } else { none }
  let title-ink = if print-mode { black }
    else if title-colour == auto { colour.darken(32%) } else { title-colour }
  let body-ink = if print-mode { luma(32) }
    else if text-colour == auto { luma(38) } else { text-colour }
  let icon-ink = if print-mode { luma(28) } else { colour.darken(28%) }
  let back-fill = if print-mode { luma(225) }
    else { colour.darken(25%).transparentize(44%) }
  let icon-content = if icon == none { _wib-icon(icon-size, icon-ink, icon-style) }
    else { icon }
  let title-content = text(dir: if rtl { std.rtl } else { std.ltr },
    size: title-size, weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.30em, spacing: 0.22em, justify: false)
    text(dir: if rtl { std.rtl } else { std.ltr }, size: body-size, fill: body-ink, body)
  }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 6.2) }
      else { width / 1cm }
    let badge = badge-size / 1cm
    let text-w = W * 0.54
    let text-x = if rtl { W * 0.16 } else { W * 0.30 }
    let title-box = box(width: text-w * 1cm,
      align(if rtl { right } else { left }, title-content))
    let body-box = box(width: text-w * 1cm,
      align(if rtl { right } else { left }, body-content))
    let title-h = measure(title-box).height / 1cm
    let body-h = measure(body-box).height / 1cm
    let body-y = title-y + title-h * 1cm + label-gap
    let H = calc.max(height / 1cm, body-y / 1cm + body-h + 0.32)
    let card-h = H * 1cm
    let badge-x = if rtl { (W - badge - 0.18) * 1cm } else { 0.18cm }
    let badge-y = 0.20cm
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, icon-content))
    let points = _wib-outline(W * 1cm, card-h, rtl: rtl)
    let outline-stroke = if print-mode { (paint: luma(75), thickness: 0.75pt) } else { none }
    let badge-stroke = if print-mode { (paint: luma(90), thickness: 0.8pt) }
      else { (paint: white, thickness: 1pt) }

    box(width: W * 1cm, height: card-h, inset: 0pt, {
      if shadow {
        place(top + left, dx: 0.06cm, dy: 0.12cm,
          polygon(fill: back-fill, stroke: none, ..points))
        place(top + left, dx: badge-x + 0.045cm, dy: badge-y + 0.065cm,
          ellipse(width: badge-size, height: badge-size,
            fill: if print-mode { luma(229) } else { colour.darken(22%).transparentize(62%) },
            stroke: none))
      }
      place(top + left, dx: 0pt, dy: 0pt,
        polygon(fill: fill-colour, stroke: outline-stroke, ..points))
      place(top + left, dx: badge-x, dy: badge-y,
        ellipse(width: badge-size, height: badge-size, fill: white, stroke: badge-stroke))
      place(top + left, dx: (badge-x + (badge-size - icon-size) / 2) + icon-offset-x, dy: (badge-y + (badge-size - icon-size) / 2) + icon-offset-y, icon-box)
      place(top + left, dx: (text-x * 1cm) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
      place(top + left, dx: (text-x * 1cm) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
    })
  })
}
