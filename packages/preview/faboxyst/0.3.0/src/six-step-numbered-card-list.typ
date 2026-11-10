// Numbered two-column cards for process stages, agendas, and concise checklists.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _sncl-card(
  step, index, width, height, rtl, print-mode, dark,
  colours, monochrome, monochrome-colour, badge-size,
  title-size, body-size, corner-radius, shadow-offset,
  title-y, body-y, body-gap,
) = {
  let palette = if monochrome { (monochrome-colour,) } else { colours }
  let accent = if "colour" in step { step.at("colour") }
    else { palette.at(calc.rem(index, palette.len())) }
  let panel = white
  let badge-fill = if print-mode { luma(190) } else { accent }
  let title-ink = if print-mode { black }
    else if "title-colour" in step { step.at("title-colour") }
    else { rgb("#18253A") }
  let body-ink = if print-mode { rgb("#242424") }
    else if "body-colour" in step { step.at("body-colour") }
    else { rgb("#596372") }
  let number-ink = if print-mode { black }
    else if "number-colour" in step { step.at("number-colour") }
    else { white }
  let shadow-ink = if print-mode { luma(225) }
    else if dark { rgb("#000000").transparentize(83%) }
    else { rgb("#4A5665").transparentize(87%) }
  let edge = if print-mode { (paint: luma(205), thickness: 0.55pt) } else { none }
  let face = box(width: width, height: height,
    radius: corner-radius, fill: panel, stroke: edge, inset: 0pt)
  let shadow = box(width: width, height: height,
    radius: corner-radius, fill: shadow-ink, inset: 0pt)
  let badge = circle(radius: badge-size / 2, fill: badge-fill)
  let number = if "number" in step { step.at("number") }
    else if index + 1 < 10 { [0#(index + 1)] }
    else { [#(index + 1)] }
  let badge-x = if rtl { width - 0.44cm - badge-size } else { 0.44cm }
  let text-start = if rtl { 0.42cm } else { 0.44cm + badge-size + 0.44cm }
  let text-width = width - 2.54cm
  let align-x = if rtl { right } else { left }
  let title = box(width: text-width, height: 0.46cm,
    align(align-x + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
  let body = box(width: text-width, height: height - body-y - body-gap,
    align(align-x + top,
      text(size: body-size, fill: body-ink, step.at("body"))))

  box(width: width, height: height + shadow-offset, inset: 0pt, {
    place(top + left, dx: shadow-offset, dy: shadow-offset, shadow)
    place(top + left, face)
    place(top + left, dx: badge-x, dy: (height - badge-size) / 2, badge)
    place(top + left, dx: badge-x, dy: (height - badge-size) / 2,
      box(width: badge-size, height: badge-size,
        align(center + horizon,
          text(dir: ltr, size: 12.5pt, weight: "bold", fill: number-ink, number))))
    place(top + left, dx: text-start, dy: title-y, title)
    place(top + left, dx: text-start, dy: body-y, body)
  })
}

/// A two-column list of numbered cards. Items require `title:` and `body:`;
/// `number:` and `colour:` can be overridden per card. The first six palette
/// colors cycle by default; `monochrome: true` uses a single badge color.
/// RTL reverses reading order across the grid and mirrors the number badge to
/// the right edge. `dark: true` is useful on dark slide backgrounds; cards
/// remain white. Print mode uses gray number circles, black text, and pale
/// gray card shadows.
///
/// ```typ
/// #six-step-numbered-card-list(steps: (
///   (title: [Define the goal], body: [Agree on the outcome and how success will be measured.]),
///   (title: [Gather inputs], body: [Collect the facts, views, and resources needed.]),
/// ))
/// ```
#let six-step-numbered-card-list(
  steps: (),
  width: auto,
  columns: 2,
  gap: 1.18cm,
  row-gap: 0.72cm,
  height: 2.35cm,
  direction: auto,
  dark: false,
  monochrome: false,
  colours: (
    rgb("#F15E4B"), rgb("#FFA21A"), rgb("#FFD52D"),
    rgb("#74A779"), rgb("#38BDD1"), rgb("#284A73"),
  ),
  monochrome-colour: rgb("#82B4A0"),
  badge-size: 1.24cm,
  title-size: 12.5pt,
  body-size: 8.1pt,
  corner-radius: 0.10cm,
  shadow-offset: 0.07cm,
  title-y: 0.38cm,
  body-y: 1.12cm,
  body-gap: 0.10cm,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
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
      let tile-cm = calc.max(5.8, (total-cm - (columns - 1) * gap-cm) / columns)
      let height-cm = height / 1cm
      let rows = calc.ceil(count / columns)
      let row-stride-cm = height-cm + shadow-offset / 1cm + row-gap-cm
      let total-height = (rows * (height-cm + shadow-offset / 1cm)
        + (rows - 1) * row-gap-cm) * 1cm
      let palette = if monochrome { (monochrome-colour,) } else { colours }
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left, dx: ((visual-col * (tile-cm + gap-cm)) * 1cm) + number-offset-x, dy: ((row * row-stride-cm) * 1cm) + number-offset-y, _sncl-card(
              steps.at(index), index, tile-cm * 1cm, height, rtl, print-mode,
              dark, palette, monochrome, monochrome-colour, badge-size,
              title-size, body-size, corner-radius, shadow-offset,
              title-y, body-y, body-gap,
            ))
        }
      })
    }
  })
}
