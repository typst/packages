// White process cards with diagonal, icon and index corner tabs.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _cc8-corner-art(size, colour, shade, rtl: false, bottom: false) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = size / 1cm
  let d = 0.20
  let points = if bottom {
    ((w, 0), (w, -w), (0, -w))
  } else {
    ((0, 0), (w, 0), (0, -w))
  }
  let fold-a = ((w, 0), (w, -d), (w - d, 0))
  let fold-b = ((0, -w), (d, -w), (0, -w + d))
  if rtl {
    points = points.map(((x, y)) => (w - x, y))
    fold-a = fold-a.map(((x, y)) => (w - x, y))
    fold-b = fold-b.map(((x, y)) => (w - x, y))
  }
  draw.line(..points, close: true, fill: colour, stroke: none)
  draw.line(..fold-a, close: true, fill: shade, stroke: none)
  draw.line(..fold-b, close: true, fill: shade, stroke: none)
})

#let _cc8-card(
  step, index, tile-width, height, rtl, print-mode, colours,
  title-size, body-size, icon-size, corner-size, corner-overhang,
) = {
  let pair = colours.at(calc.rem(index, colours.len()))
  let face-colour = if "colour" in step { step.at("colour") } else { pair.at(0) }
  let title-colour = if "title-colour" in step {
    step.at("title-colour")
  } else { pair.at(1) }
  let number-colour = if "number-colour" in step {
    step.at("number-colour")
  } else { pair.at(2) }
  let border = if print-mode { rgb("#707070") } else { face-colour }
  let corner-fill = if print-mode { luma(218) } else { face-colour }
  let corner-shade = if print-mode { luma(155) } else { face-colour.darken(32%) }
  let title-ink = if print-mode { black } else { title-colour }
  let body-ink = if print-mode { black }
    else if "body-colour" in step { step.at("body-colour") }
    else { rgb("#555555") }
  let number-ink = if print-mode { rgb("#555555") } else { number-colour }
  let stroke-style = if print-mode {
    (paint: border, thickness: 0.8pt)
  } else { (paint: border, thickness: 1.15pt) }
  let shadow-ink = rgb("#666666").transparentize(if print-mode { 89% } else { 82% })
  let shadow = box(width: tile-width, height: height,
    radius: 0.12cm, fill: shadow-ink, inset: 0pt)
  let card = box(width: tile-width, height: height,
    radius: 0.12cm, fill: white, stroke: stroke-style, inset: 0pt)
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let number = if "number" in step { step.at("number") }
    else if index + 1 < 10 { [0#(index + 1)] }
    else { [#(index + 1)] }
  let text-align = if rtl { right } else { left }
  let card-x = corner-overhang
  let card-y = corner-overhang
  let top-x = if rtl {
    card-x + tile-width - corner-size + corner-overhang
  } else { card-x - corner-overhang }
  let top-y = card-y - corner-overhang
  let bottom-x = if rtl {
    card-x - corner-overhang
  } else { card-x + tile-width - corner-size + corner-overhang }
  let bottom-y = card-y + height - corner-size + corner-overhang
  let top-art = _cc8-corner-art(
    corner-size, corner-fill, corner-shade, rtl: rtl,
  )
  let bottom-art = _cc8-corner-art(
    corner-size, corner-fill, corner-shade, rtl: rtl, bottom: true,
  )
  let icon-centre-x = if rtl {
    top-x + 2 * corner-size / 3
  } else { top-x + corner-size / 3 }
  let icon-centre-y = top-y + corner-size / 3
  let icon-x = icon-centre-x - icon-size / 2
  let icon-y = icon-centre-y - icon-size / 2
  let title-box = box(width: tile-width - 0.70cm, height: 0.48cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
  let rule = box(width: tile-width - 0.60cm, height: 0.075cm,
    radius: 0.04cm, fill: if print-mode { luma(130) } else { face-colour }, inset: 0pt)
  let body-box = box(width: tile-width - 0.70cm, height: height - 3.35cm,
    align(text-align + top,
      text(size: body-size, fill: body-ink, step.at("body"))))
  let title-y = card-y + 1.78cm
  let rule-y = card-y + 2.50cm
  let body-y = card-y + 2.82cm
  let number-box = box(width: 0.74cm, height: 0.34cm,
    align(center + horizon,
      text(size: 10pt, weight: "bold", fill: number-ink, number)))
  let number-x = if rtl { bottom-x + 0.04cm } else { bottom-x + corner-size - 0.78cm }
  let number-y = bottom-y + corner-size - 0.60cm

  box(width: tile-width + 2 * corner-overhang,
    height: height + 2 * corner-overhang, inset: 0pt, {
    place(top + left, dx: card-x + 0.14cm, dy: card-y + 0.18cm, shadow)
    place(top + left, dx: card-x, dy: card-y, card)
    place(top + left, dx: top-x, dy: top-y, top-art)
    place(top + left, dx: bottom-x, dy: bottom-y, bottom-art)
    if icon != none {
      place(top + left, dx: icon-x, dy: icon-y,
        box(width: icon-size, height: icon-size, align(center, icon)))
    }
    place(top + left, dx: card-x + 0.35cm, dy: title-y, title-box)
    place(top + left, dx: card-x + 0.30cm, dy: rule-y, rule)
    place(top + left, dx: card-x + 0.35cm, dy: body-y, body-box)
    place(top + left, dx: number-x, dy: number-y, number-box)
  })
}

/// A grid of white cards with diagonal icon and number corners.
///
/// Each step requires `title` and `body`; `icon`, `print-icon`, and `number`
/// are optional. `colour`, `title-colour`, `body-colour`, and `number-colour`
/// may override per-step colors. RTL moves the icon tab to the upper-right and
/// the number tab to the lower-left, and reverses card order. Print mode uses
/// gray corner tabs and outlines with monochrome text and icons.
///
/// ```typ
/// #cornered-cards(steps: (
///   (title: [Discover], body: [A short description.], icon: [★], number: [01]),
///   (title: [Plan], body: [Another description.], icon: [⚑], number: [02]),
/// ))
/// ```
#let cornered-cards(
  steps: (),
  width: auto,
  columns: 4,
  gap: 0.54cm,
  row-gap: 0.76cm,
  height: 6.15cm,
  direction: auto,
  colours: (
    (rgb("#F15F52"), rgb("#F15F52"), white),
    (rgb("#F7AD1E"), rgb("#D99516"), rgb("#71460E")),
    (rgb("#78A878"), rgb("#659665"), white),
    (rgb("#39BED0"), rgb("#279EAE"), rgb("#17404A")),
  ),
  title-size: 12.5pt,
  body-size: 7.8pt,
  icon-size: 0.78cm,
  corner-size: 1.92cm,
  corner-overhang: 0.18cm,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
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
      let overhang-cm = corner-overhang / 1cm
      let columns = calc.max(1, columns)
      let tile-cm = calc.max(3.45,
        (total-cm - 2 * overhang-cm - (columns - 1) * gap-cm) / columns)
      let height-cm = height / 1cm
      let rows = calc.ceil(count / columns)
      let row-stride-cm = height-cm + 2 * overhang-cm + row-gap-cm
      let total-height = (rows * (height-cm + 2 * overhang-cm)
        + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left, dx: ((visual-col * (tile-cm + gap-cm)) * 1cm) + icon-offset-x, dy: ((row * row-stride-cm) * 1cm) + icon-offset-y, _cc8-card(
              steps.at(index), index, tile-cm * 1cm, height, rtl, print-mode,
              colours, title-size, body-size, icon-size, corner-size,
              corner-overhang,
            ))
        }
      })
    }
  })
}
