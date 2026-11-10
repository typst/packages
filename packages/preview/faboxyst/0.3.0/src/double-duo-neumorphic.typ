// Neumorphic duo cards with alternating icon wells.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ddn-icon-pad(size, surface, pad-fill, raised, print-mode, icon) = {
  let radius = size / 2
  let dark-fill = if raised {
    rgb("#286C8C").transparentize(if print-mode { 100% } else { 38% })
  } else {
    rgb("#C6C8CC").transparentize(if print-mode { 100% } else { 38% })
  }
  let light-fill = if raised {
    rgb("#B7E6F8").transparentize(if print-mode { 100% } else { 26% })
  } else {
    white.transparentize(if print-mode { 100% } else { 32% })
  }
  let dark-disc = circle(radius: radius, fill: dark-fill, stroke: none)
  let light-disc = circle(radius: radius, fill: light-fill, stroke: none)
  let base-disc = circle(radius: radius, fill: pad-fill,
    stroke: if print-mode { (paint: rgb("#C8C9CC"), thickness: 0.55pt) } else { none })
  box(width: size, height: size, inset: 0pt, {
    if raised {
      place(top + left, dx: 0.11cm, dy: 0.12cm, dark-disc)
      place(top + left, dx: -0.07cm, dy: -0.07cm, light-disc)
    } else {
      place(top + left, dx: -0.07cm, dy: -0.07cm, dark-disc)
      place(top + left, dx: 0.10cm, dy: 0.10cm, light-disc)
    }
    place(top + left, base-disc)
    if icon != none {
      place(top + left, dx: size * 0.15, dy: size * 0.15,
        box(width: size * 0.70, height: size * 0.70, align(center, icon)))
    }
  })
}

#let _ddn-card(
  step, index, card-width, height, rtl, print-mode, title-size, body-size,
  icon-size,
) = {
  let surface = if print-mode { white } else { rgb("#F0F1F3") }
  let raised = if print-mode { false }
    else if "raised" in step { step.at("raised") }
    else { false }
  let pad-fill = if print-mode { luma(238) }
    else if "icon-fill" in step { step.at("icon-fill") }
    else { surface }
  let title-ink = if print-mode { black }
    else if "title-colour" in step { step.at("title-colour") }
    else { rgb("#606165") }
  let body-ink = if print-mode { black }
    else if "body-colour" in step { step.at("body-colour") }
    else { rgb("#66676A") }
  let edge = if print-mode {
    (paint: rgb("#C2C3C5"), thickness: 0.7pt)
  } else { none }
  let card = box(width: card-width, height: height,
    radius: 0.30cm, fill: surface, stroke: edge, inset: 0pt)
  let dark-shadow = box(width: card-width, height: height,
    radius: 0.30cm,
    fill: rgb(if print-mode { "#DADBDD" } else { "#C7C9CD" }).transparentize(
      if print-mode { 75% } else { 42% },
    ), inset: 0pt)
  let light-shadow = box(width: card-width, height: height,
    radius: 0.30cm,
    fill: white.transparentize(if print-mode { 75% } else { 40% }), inset: 0pt)
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let icon-pad = _ddn-icon-pad(icon-size, surface, pad-fill, raised, print-mode, icon)
  let icon-left = if rtl {
    calc.rem(index, 2) == 1
  } else { calc.rem(index, 2) == 0 }
  let padding = 0.48cm
  let text-width = card-width - icon-size - 1.32cm
  let icon-x = if icon-left { padding } else { card-width - padding - icon-size }
  let text-x = if icon-left { padding + icon-size + 0.36cm } else { padding }
  let text-align = if rtl { right } else { left }
  let title-box = box(width: text-width, height: 0.52cm,
    align(text-align + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
  let body-box = box(width: text-width, height: height - 1.72cm,
    align(text-align + top,
      text(size: body-size, fill: body-ink, step.at("body"))))
  let title-y = 0.73cm
  let body-y = 1.34cm
  let card-x = 0.06cm
  let card-y = 0.06cm

  box(width: card-width + 0.18cm, height: height + 0.18cm, inset: 0pt, {
    place(top + left, dx: card-x + 0.11cm, dy: card-y + 0.12cm, dark-shadow)
    place(top + left, dx: card-x - 0.04cm, dy: card-y - 0.04cm, light-shadow)
    place(top + left, dx: card-x, dy: card-y, card)
    place(top + left, dx: card-x + icon-x, dy: card-y + (height - icon-size) / 2, icon-pad)
    place(top + left, dx: card-x + text-x, dy: card-y + title-y, title-box)
    place(top + left, dx: card-x + text-x, dy: card-y + body-y, body-box)
  })
}

/// A two-column or grid layout of soft double-shadowed cards.
///
/// Each step requires `title` and `body`; `icon` and `print-icon` are optional.
/// Icon wells alternate sides and mirror in RTL; an item may set `raised: true`
/// and `icon-fill:` to use a colored raised circle. Print mode uses white cards,
/// gray outlines, recessed icon wells, and monochrome text/icons.
///
/// ```typ
/// #double-duo-neumorphic(steps: (
///   (title: [Discover], body: [A short description.], icon: [◎]),
///   (title: [Imagine], body: [Another description.], icon: [✧]),
/// ))
/// ```
#let double-duo-neumorphic(
  steps: (),
  width: auto,
  columns: 2,
  gap: 0.66cm,
  row-gap: 0.68cm,
  height: 3.55cm,
  direction: auto,
  title-size: 13pt,
  body-size: 8.8pt,
  icon-size: 2.04cm,
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
      let tile-cm = calc.max(5.0,
        (total-cm - (columns - 1) * gap-cm) / columns)
      let rows = calc.ceil(count / columns)
      let height-cm = height / 1cm
      let total-height = (rows * (height-cm + 0.18)
        + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left,
            dx: (visual-col * (tile-cm + gap-cm)) * 1cm,
            dy: (row * (height-cm + row-gap-cm)) * 1cm,
            _ddn-card(
              steps.at(index), index, tile-cm * 1cm, height, rtl, print-mode,
              title-size, body-size, icon-size,
            ))
        }
      })
    }
  })
}
