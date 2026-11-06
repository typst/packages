// Three highlighted process cards with numbered tabs and icon/text dividers.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _tsh-notch(width, depth, colour) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = depth / 1cm
  draw.line((0, 0), (w, 0), (w / 2, -h), close: true,
    fill: colour, stroke: none)
})

#let _tsh-card(
  step, index, card-width, height, rtl, print-mode, colours,
  title-size, body-size, icon-size, number-size, tab-width, tab-height,
  notch-depth,
) = {
  let accent = if "colour" in step {
    step.at("colour")
  } else {
    colours.at(calc.rem(index, colours.len()))
  }
  let tab-fill = if print-mode { luma(218) } else { accent }
  let card-fill = if print-mode { white } else { rgb("#F2F2F2") }
  let outline = if print-mode { rgb("#777777") } else { accent }
  let title-ink = if print-mode { black }
    else if "title-colour" in step { step.at("title-colour") }
    else { black }
  let body-ink = if print-mode { black }
    else if "body-colour" in step { step.at("body-colour") }
    else { rgb("#505050") }
  let number-ink = if print-mode { rgb("#333333") }
    else if "number-colour" in step { step.at("number-colour") }
    else { white }
  let outline-style = if print-mode {
    (paint: outline, thickness: 0.85pt)
  } else { (paint: outline, thickness: 0.11cm) }
  let card = box(width: card-width, height: height,
    radius: 0.38cm, fill: card-fill, stroke: outline-style, inset: 0pt)
  let tab = box(width: tab-width, height: tab-height,
    radius: 0.22cm, fill: tab-fill, inset: 0pt)
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let number = if "number" in step { step.at("number") }
    else if index + 1 < 10 { [0#(index + 1)] }
    else { [#(index + 1)] }
  let icon-left = not rtl
  let icon-x = if icon-left { 0.42cm } else { card-width - 0.42cm - icon-size }
  let divider-x = if icon-left { 2.48cm } else { card-width - 2.48cm }
  let text-x = if icon-left { 2.82cm } else { 0.42cm }
  let text-width = card-width - 3.20cm
  let text-align = if rtl { right } else { left }
  let separator = box(width: 0.035cm, height: 1.66cm,
    fill: if print-mode { luma(165) } else { luma(185) }, inset: 0pt)
  let title-box = box(width: text-width, height: 0.46cm,
    align(text-align + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
  let body-box = box(width: text-width, height: height - 2.45cm,
    align(text-align + top,
      text(size: body-size, fill: body-ink, step.at("body"))))
  let card-y = 0.50cm
  let tab-x = (card-width - tab-width) / 2
  let tab-y = 0pt
  let notch-x = (card-width - 0.72cm) / 2
  let notch-y = tab-height - 0.02cm
  let number-box = box(width: tab-width - 0.20cm, height: 0.48cm,
    align(center + horizon,
      text(size: number-size, weight: "bold", fill: number-ink, number)))
  let title-y = card-y + 1.28cm
  let body-y = card-y + 1.92cm
  let icon-y = card-y + (height - icon-size) / 2

  box(width: card-width, height: card-y + height + 0.08cm, inset: 0pt, {
    place(top + left, dy: card-y, card)
    place(top + left, dx: tab-x, dy: tab-y, tab)
    place(top + left, dx: notch-x, dy: notch-y, _tsh-notch(0.72cm, notch-depth, tab-fill))
    place(top + left, dx: tab-x + 0.10cm, dy: 0.10cm,
      box(width: tab-width - 0.20cm, height: 0.44cm,
        align(center + horizon,
          text(size: number-size, weight: "bold", fill: number-ink, number))))
    if icon != none {
      place(top + left, dx: icon-x, dy: icon-y,
        box(width: icon-size, height: icon-size, align(center, icon)))
    }
    place(top + left, dx: divider-x, dy: card-y + 1.72cm, separator)
    place(top + left, dx: text-x, dy: title-y, title-box)
    place(top + left, dx: text-x, dy: body-y, body-box)
  })
}

/// A row/grid of three rounded cards with colored borders, numbered tabs,
/// icon wells, and a vertical text divider.
///
/// Each `steps:` item requires `title:` and `body:`; `icon:` and `print-icon:`
/// are optional. `number:` can override the default sequence label. RTL mirrors
/// the icon/text zones and reverses card order. Print mode uses gray outlines,
/// tabs, dividers, and monochrome icons.
///
/// ```typ
/// #three-step-highlight-cards(steps: (
///   (title: [Discover], body: [A short description.], icon: [✦]),
///   (title: [Plan], body: [Another description.], icon: [◎]),
///   (title: [Act], body: [A final description.], icon: [✓]),
/// ))
/// ```
#let three-step-highlight-cards(
  steps: (),
  width: auto,
  columns: 3,
  gap: 0.56cm,
  row-gap: 0.78cm,
  height: 4.15cm,
  direction: auto,
  colours: (
    rgb("#25446F"),
    rgb("#6BA36C"),
    rgb("#F15F4B"),
  ),
  title-size: 12.5pt,
  body-size: 7.6pt,
  icon-size: 1.38cm,
  number-size: 15pt,
  tab-width: 1.82cm,
  tab-height: 0.76cm,
  notch-depth: 0.30cm,
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
      let columns = calc.max(1, columns)
      let tile-cm = calc.max(4.0,
        (total-cm - (columns - 1) * gap-cm) / columns)
      let rows = calc.ceil(count / columns)
      let height-cm = height / 1cm
      let row-stride-cm = height-cm + 0.58 + row-gap-cm
      let total-height = (rows * (height-cm + 0.58)
        + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left, dx: ((visual-col * (tile-cm + gap-cm)) * 1cm) + icon-offset-x, dy: ((row * row-stride-cm) * 1cm) + icon-offset-y, _tsh-card(
              steps.at(index), index, tile-cm * 1cm, height, rtl, print-mode,
              colours, title-size, body-size, icon-size, number-size, tab-width,
              tab-height, notch-depth,
            ))
        }
      })
    }
  })
}
