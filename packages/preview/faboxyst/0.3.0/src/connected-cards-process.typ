// Rounded process cards joined by a soft, pinched connector.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _ccp-cubic(p0, p1, p2, p3, n: 18) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _ccp-link-art(width, height, neck-height, colour) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = height / 1cm
  let n = neck-height / 1cm
  let points = ((0, -h / 2), (0, h / 2))
  points += _ccp-cubic((0, h / 2), (w * 0.20, h / 2),
    (w * 0.28, n / 2), (w / 2, n / 2))
  points += _ccp-cubic((w / 2, n / 2), (w * 0.72, n / 2),
    (w * 0.80, h / 2), (w, h / 2))
  points.push((w, -h / 2))
  points += _ccp-cubic((w, -h / 2), (w * 0.80, -h / 2),
    (w * 0.72, -n / 2), (w / 2, -n / 2))
  points += _ccp-cubic((w / 2, -n / 2), (w * 0.28, -n / 2),
    (w * 0.20, -h / 2), (0, -h / 2))
  draw.line(..points, close: true, fill: colour, stroke: none)
})

#let _ccp-card(
  step, index, tile-width, height, print-mode, colours,
  title-size, body-size, icon-size,
) = {
  let pair = colours.at(calc.rem(index, colours.len()))
  let face-colour = if "colour" in step { step.at("colour") } else { pair.at(0) }
  let title-colour = if "title-colour" in step {
    step.at("title-colour")
  } else { pair.at(1) }
  let outer-fill = if print-mode { luma(218) } else { face-colour }
  let card-fill = white
  let title-ink = if print-mode { black } else { title-colour }
  let body-ink = if print-mode { black }
    else if "body-colour" in step { step.at("body-colour") }
    else { rgb("#565656") }
  let edge = if print-mode {
    (paint: rgb("#777777"), thickness: 0.75pt)
  } else { none }
  let outer = box(width: tile-width, height: height,
    radius: 0.66cm, fill: outer-fill, stroke: edge, inset: 0pt)
  let inner = box(width: tile-width - 0.70cm, height: height - 0.70cm,
    radius: 0.43cm, fill: card-fill,
    stroke: if print-mode { (paint: rgb("#8A8A8A"), thickness: 0.55pt) } else { none },
    inset: 0pt)
  let shadow-ink = rgb("#555555").transparentize(if print-mode { 90% } else { 84% })
  let shadow = box(width: tile-width - 0.18cm, height: height - 0.10cm,
    radius: 0.64cm, fill: shadow-ink, inset: 0pt)
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let icon-content = if icon == none { none } else {
    box(width: icon-size, height: icon-size, align(center, icon))
  }
  let title-box = box(width: tile-width - 0.90cm, height: 0.48cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))))
  let divider = box(width: tile-width - 1.18cm, height: 0.012cm,
    fill: if print-mode { luma(165) } else { luma(190) }, inset: 0pt)
  let body-box = box(width: tile-width - 0.98cm, height: height - 3.44cm,
    align(center + top,
      text(size: body-size, fill: body-ink, step.at("body"))))
  let inset = 0.35cm
  let icon-y = 0.62cm
  let title-y = 2.10cm
  let divider-y = 2.76cm
  let body-y = 2.98cm

  box(width: tile-width, height: height + 0.12cm, inset: 0pt, {
    place(top + left, dx: 0.10cm, dy: 0.12cm, shadow)
    place(top + left, outer)
    place(top + left, dx: inset, dy: inset, inner)
    if icon != none {
      place(top + left, dx: (tile-width - icon-size) / 2, dy: icon-y, icon-content)
    }
    place(top + left, dx: 0.45cm, dy: title-y, title-box)
    place(top + left, dx: 0.59cm, dy: divider-y, divider)
    place(top + left, dx: 0.49cm, dy: body-y, body-box)
  })
}

/// A row or grid of rounded process cards joined by curved connector necks.
///
/// Each step requires `title` and `body`; `icon` and `print-icon` are optional.
/// Steps retain their colors and reverse visual order in RTL. Print mode uses
/// pale-gray outer frames, white inner cards, and monochrome connector bands.
///
/// ```typ
/// #connected-cards-process(steps: (
///   (title: [Discover], body: [Identify the challenge.], icon: [💡]),
///   (title: [Plan], body: [Choose a direction.], icon: [◎]),
/// ))
/// ```
#let connected-cards-process(
  steps: (),
  width: auto,
  columns: 4,
  gap: 0.52cm,
  row-gap: 0.82cm,
  height: 6.15cm,
  direction: auto,
  colours: (
    (rgb("#F4A51C"), rgb("#CC8115")),
    (rgb("#F05F50"), rgb("#E45A4C")),
    (rgb("#254672"), rgb("#254672")),
    (rgb("#39BDD0"), rgb("#269AAA")),
  ),
  title-size: 13pt,
  body-size: 7.8pt,
  icon-size: 1.12cm,
  connector-height: 0.78cm,
  connector-neck: 0.42cm,
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
      let tile-cm = calc.max(3.45, (total-cm - (columns - 1) * gap-cm) / columns)
      let height-cm = height / 1cm
      let rows = calc.ceil(count / columns)
      let total-height = (rows * (height-cm + 0.12) + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        // Draw each neck first so the frames overlap its ends cleanly.
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          let neighbour-col = if rtl { logical-col - 1 } else { logical-col + 1 }
          let neighbour-index = row * columns + neighbour-col
          if visual-col < columns - 1 and neighbour-col >= 0 and neighbour-index < count {
            let pair = colours.at(calc.rem(index, colours.len()))
            let link-colour = if print-mode { luma(188) }
              else if "colour" in steps.at(index) {
                steps.at(index).at("colour")
              } else { pair.at(0).darken(5%) }
            let link-width = gap + 0.18cm
            let row-offset = (row * (height-cm + row-gap-cm)) * 1cm
            let link-mid = 1.58cm - connector-height / 2
            let link-top = row-offset + link-mid
            let link-x = (visual-col * (tile-cm + gap-cm) + tile-cm) * 1cm - 0.09cm
            place(top + left, dx: link-x, dy: link-top,
              _ccp-link-art(link-width, connector-height, connector-neck, link-colour))
          }
        }
        // Then paint cards over connector endpoints.
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left, dx: ((visual-col * (tile-cm + gap-cm)) * 1cm) + icon-offset-x, dy: ((row * (height-cm + row-gap-cm)) * 1cm) + icon-offset-y, _ccp-card(
              steps.at(index), index, tile-cm * 1cm, height, print-mode,
              colours, title-size, body-size, icon-size,
            ))
        }
      })
    }
  })
}
