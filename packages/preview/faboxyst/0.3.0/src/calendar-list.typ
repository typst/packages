// Calendar-style cards with a colored title band, twin binding tabs and a U-frame.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _calendar-card(
  step, index, tile-width, height, header-height, rtl, print-mode,
  colours, title-size, body-size, icon-size,
) = {
  let source-colour = if "colour" in step {
    step.at("colour")
  } else { colours.at(calc.rem(index, colours.len())) }
  let header-colour = if print-mode { luma(224) } else { source-colour }
  let frame-colour = if print-mode { rgb("#707070") } else { source-colour }
  let title-colour = if print-mode { black } else { white }
  let body-colour = if print-mode { black } else { rgb("#5A5A5A") }
  let edge = (paint: frame-colour, thickness: 1.45pt, join: "miter")
  let detail-edge = if print-mode {
    (paint: rgb("#4F4F4F"), thickness: 0.70pt, join: "round")
  } else { none }
  let header-y = 0.30cm
  let frame-y = header-y + header-height - 0.035cm
  let frame-height = height - frame-y
  let frame = box(width: tile-width, height: frame-height,
    fill: none, stroke: edge, inset: 0pt)
  let header = box(width: tile-width, height: header-height,
    fill: header-colour, stroke: detail-edge, inset: 0pt)
  let title = box(width: tile-width - 0.30cm, height: header-height,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-colour, step.at("title"))))

  let pin-outer-width = 0.54cm
  let pin-outer-height = 0.68cm
  let pin-inner-width = 0.31cm
  let pin-inner-height = 0.56cm
  let pin-centres = (tile-width * 0.25, tile-width * 0.75)
  let body-top = frame-y + 1.20cm
  let body-height = calc.max(0.55cm, height - body-top - 0.44cm)
  let body = box(width: tile-width - 0.46cm, height: body-height,
    align(center + top, text(size: body-size, fill: body-colour, step.at("body"))))
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let icon-box = if icon == none { none } else {
    box(width: icon-size, height: icon-size, align(center, icon))
  }
  let icon-x = (tile-width - icon-size) / 2
  let icon-y = frame-y + 0.24cm

  box(width: tile-width, height: height, inset: 0pt, {
    // The frame sits behind the title band, which masks its top rule to form a U.
    place(top + left, dy: frame-y, frame)
    place(top + left, dy: header-y, header)
    for centre in pin-centres {
      let outer-x = centre - pin-outer-width / 2
      let inner-x = centre - pin-inner-width / 2
      place(top + left, dx: outer-x, dy: header-y - 0.08cm,
        box(width: pin-outer-width, height: pin-outer-height,
          radius: 0.27cm, fill: white, stroke: detail-edge, inset: 0pt))
      place(top + left, dx: inner-x, dy: header-y - 0.18cm,
        box(width: pin-inner-width, height: pin-inner-height,
          radius: 0.155cm, fill: header-colour, stroke: detail-edge, inset: 0pt))
    }
    place(top + left, dy: header-y + 0.14cm, title)
    if icon != none { place(top + left, dx: icon-x, dy: icon-y, icon-box) }
    place(top + left, dx: 0.23cm, dy: body-top, body)
  })
}

/// A grid of calendar-style list cards with twin binder tabs and an open U-frame.
///
/// Each `steps:` entry requires `title:` and `body:`; an `icon:` is optional.
/// `width:` sets the total grid width, and `columns:` controls cards per row.
/// RTL reverses card order; print mode uses gray title bands and outlines.
///
/// ```typ
/// #calendar-list(
///   width: 18cm,
///   steps: (
///     (title: [LOREM IPSUM], body: [A short calendar item.], icon: [◷]),
///     (title: [LOREM IPSUM], body: [Another item.], icon: [✓]),
///   ),
/// )
/// ```
#let calendar-list(
  steps: (),
  width: auto,
  columns: 4,
  gap: 0.36cm,
  row-gap: 0.65cm,
  height: 5.65cm,
  header-height: 1.42cm,
  direction: auto,
  colours: (
    rgb("#F05C4D"), rgb("#F4A51C"), rgb("#71A36F"), rgb("#24466F"),
  ),
  title-size: 11.2pt,
  body-size: 7.7pt,
  icon-size: 0.82cm,
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
      let tile-cm = calc.max(2.2, (total-cm - (columns - 1) * gap-cm) / columns)
      let rows = calc.ceil(count / columns)
      let height-cm = height / 1cm
      let total-height = (rows * height-cm + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left,
            dx: (visual-col * (tile-cm + gap-cm)) * 1cm,
            dy: (row * (height-cm + row-gap-cm)) * 1cm,
            _calendar-card(
              steps.at(index), index, tile-cm * 1cm, height, header-height,
              rtl, print-mode, colours, title-size, body-size, icon-size,
            ))
        }
      })
    }
  })
}
