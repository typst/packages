// One rounded feature tile with a pointer, based on SlideUplift's Product Features Callout.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _fcb-callout-icon(size, ink, kind) = {
  let head = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 96 96\" fill=\"none\" stroke=\"" + ink.to-hex() + "\" stroke-width=\"4\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
  let art = if calc.rem(kind, 4) == 0 {
    "<circle cx=\"48\" cy=\"53\" r=\"28\"/><path d=\"M48 53V34M48 53l15 10M38 13h20M48 13v11M68 28l7-7\"/><circle cx=\"48\" cy=\"53\" r=\"3\"/>"
  } else if calc.rem(kind, 4) == 1 {
    "<path d=\"M48 17a22 22 0 0 0-13 40c4 3 6 7 7 12h12c1-5 3-9 7-12A22 22 0 0 0 48 17Z M42 73h12M44 80h8M48 5v5M16 22l7 5M80 22l-7 5M12 48h8M76 48h8\"/>"
  } else if calc.rem(kind, 4) == 2 {
    "<path d=\"M15 76h66M22 69V48h12v21M42 69V29h12v40M62 69V40h12v29M19 39l18-14 15 7 22-19M65 13h10v10\"/>"
  } else {
    "<circle cx=\"48\" cy=\"48\" r=\"31\"/><path d=\"M19 49h16l8-17 10 33 9-19h15\"/>"
  }
  image(bytes(head + art + "</svg>"), format: "svg", width: size, height: size)
}

/// A single rounded feature-callout tile with a directional pointer and label copy.
///
/// Based on SlideUplift's Product Features Callout. The source shows several
/// icon tiles; this component renders one tile plus its title/body label. Use
/// `label-position: "above"` or `"below"` to point the tile toward its copy.
///
/// - `icon` accepts arbitrary Typst content; otherwise `icon-style` selects one
///   of four built-in vector icons.
/// - `size`, `width`, `tail-position`, `pointer-gap`, and `colour` tune the callout.
#let feature-callout-box(
  title: [],
  body: [],
  icon: none,
  icon-style: 0,
  width: auto,
  label-width: auto,
  size: 3.75cm,
  direction: auto,
  label-position: "above",
  tail-position: 0.5,
  tail-width: 0.62cm,
  tail-height: 0.34cm,
  pointer-gap: 0.12cm,
  colour: rgb("#45B7D2"),
  title-colour: auto,
  text-colour: auto,
  title-size: 11pt,
  body-size: 8.5pt,
  icon-size: 1.4cm,
  corner-radius: 0.30cm,
  label-gap: 0.12cm,
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
  let tile-fill = if print-mode { white }
    else { gradient.linear(colour.lighten(12%), colour.darken(4%), angle: 90deg) }
  let tile-stroke = if print-mode { (paint: luma(75), thickness: 0.75pt) } else { none }
  let ink = if print-mode { luma(25) }
    else if text-colour != auto { text-colour } else { luma(38) }
  let icon-ink = if print-mode { luma(35) } else { white }
  let soft-shadow = if print-mode { luma(228) }
    else { rgb("#26323A").transparentize(78%) }
  let soft-shadow-light = if print-mode { luma(241) }
    else { rgb("#26323A").transparentize(90%) }
  let title-content = text(dir: if rtl { std.rtl } else { std.ltr },
    size: title-size, weight: "bold",
    fill: if print-mode { black }
      else if title-colour == auto { colour.darken(26%) } else { title-colour }, title)
  let body-content = {
    set par(leading: 0.34em, spacing: 0.26em, justify: false)
    text(dir: if rtl { std.rtl } else { std.ltr }, size: body-size, fill: ink, body)
  }
  let symbol = if icon == none { _fcb-callout-icon(icon-size, icon-ink, icon-style) }
    else { icon }

  layout(avail => {
    let W = if width == auto { calc.min(avail.width / 1cm, 7.2) }
      else { width / 1cm }
    let L = if label-width == auto { W } else { calc.min(label-width / 1cm, W) }
    let tile = size / 1cm
    let title-box = box(width: L * 1cm, align(center, title-content))
    let body-box = box(width: L * 1cm, align(center, body-content))
    let title-h = measure(title-box).height / 1cm
    let body-h = measure(body-box).height / 1cm
    let label-h = title-h + (if title-h > 0 and body-h > 0 { label-gap / 1cm } else { 0 }) + body-h
    let tip-h = tail-height / 1cm
    let pointer-gap-cm = pointer-gap / 1cm
    let total-h = (label-h + pointer-gap-cm + tip-h + tile) * 1cm
    let tile-x = (W - tile) / 2
    let label-x = (W - L) / 2
    let label-y = if label-position == "above" { 0pt } else { (tile + tip-h + pointer-gap-cm) * 1cm }
    let tile-y = if label-position == "above" { (label-h + pointer-gap-cm + tip-h) * 1cm } else { 0pt }
    let label-title-y = if label-position == "above" { 0pt }
      else { label-y }
    let label-body-y = label-title-y + title-h * 1cm + (if title-h > 0 and body-h > 0 { label-gap } else { 0pt })
    let icon-box = box(width: icon-size, height: icon-size,
      align(center + horizon, symbol))
    let tail-cx = tile-x + tile * tail-position
    let tail-w = tail-width / 1cm
    let tail-geometry = if label-position == "above" {
      (((tail-cx - tail-w / 2) * 1cm, tile-y),
       (tail-cx * 1cm, tile-y - tip-h * 1cm),
       ((tail-cx + tail-w / 2) * 1cm, tile-y))
    } else {
      (((tail-cx - tail-w / 2) * 1cm, tile * 1cm),
       (tail-cx * 1cm, (tile + tip-h) * 1cm),
       ((tail-cx + tail-w / 2) * 1cm, tile * 1cm))
    }
    let icon-y = tile-y + (size - icon-size) / 2

    box(width: W * 1cm, height: total-h, inset: 0pt, {
      // Two light offset silhouettes approximate the source's soft drop shadow.
      if shadow {
        let shadow-y = if label-position == "above" { tile-y } else { 0pt }
        place(top + left, dx: tile-x * 1cm + 0.05cm, dy: shadow-y + 0.10cm,
          rect(width: size, height: size, radius: corner-radius,
            fill: soft-shadow, stroke: none))
        place(top + left, dx: 0.05cm, dy: 0.10cm,
          polygon(fill: soft-shadow, stroke: none, ..tail-geometry))
        place(top + left, dx: tile-x * 1cm + 0.025cm, dy: shadow-y + 0.055cm,
          rect(width: size, height: size, radius: corner-radius,
            fill: soft-shadow-light, stroke: none))
        place(top + left, dx: 0.025cm, dy: 0.055cm,
          polygon(fill: soft-shadow-light, stroke: none, ..tail-geometry))
      }
      if label-position == "above" {
        place(top + left, dx: (label-x * 1cm) + title-offset-x, dy: (label-title-y) + title-offset-y, title-box)
        place(top + left, dx: (label-x * 1cm) + body-offset-x, dy: (label-body-y) + body-offset-y, body-box)
      }
      place(top + left, dx: 0pt, dy: 0pt,
        polygon(fill: tile-fill, stroke: tile-stroke, ..tail-geometry))
      place(top + left, dx: tile-x * 1cm, dy: tile-y,
        rect(width: size, height: size, radius: corner-radius,
          fill: tile-fill, stroke: tile-stroke))
      place(top + left, dx: (tile-x * 1cm + (size - icon-size) / 2) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
      if label-position == "below" {
        place(top + left, dx: (label-x * 1cm) + title-offset-x, dy: (label-title-y) + title-offset-y, title-box)
        place(top + left, dx: (label-x * 1cm) + body-offset-x, dy: (label-body-y) + body-offset-y, body-box)
      }
    })
  })
}
