// Layered 3D cube blocks with a title face and readable front panel.
#import "@preview/cetz:0.5.2"
#import cetz.draw
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _cbl-cube-art(width, head-height, body-height, depth,
                   face-colour, body-colour, shade-colour, outline, rtl: false) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let w = width / 1cm
  let h = head-height / 1cm
  let b = body-height / 1cm
  let d = depth / 1cm
  let body-top = -h - d
  let body-bottom = body-top - b
  let header = ((0, 0), (w, 0), (w, -h), (0, -h))
  let side = ((w, 0), (w + d, -d), (w + d, -h - d), (w, -h))
  let underside = ((0, -h), (w, -h), (w + d, -h - d), (d, -h - d))
  let body = ((d, body-top), (w + d, body-top),
    (w + d, body-bottom), (d, body-bottom))
  if rtl {
    header = header.map(((x, y)) => (w + d - x, y))
    side = side.map(((x, y)) => (w + d - x, y))
    underside = underside.map(((x, y)) => (w + d - x, y))
    body = body.map(((x, y)) => (w + d - x, y))
  }
  draw.line(..body, close: true, fill: body-colour, stroke: outline)
  draw.line(..underside, close: true, fill: shade-colour, stroke: outline)
  draw.line(..side, close: true, fill: shade-colour, stroke: outline)
  draw.line(..header, close: true, fill: face-colour, stroke: outline)
})

#let _cbl-card(
  step, index, face-width, head-height, body-height, depth, rtl, print-mode,
  colours, title-size, body-size, icon-size,
) = {
  let pair = colours.at(calc.rem(index, colours.len()))
  let source-colour = if "colour" in step { step.at("colour") } else { pair.at(0) }
  let head-ink = if print-mode { black }
    else if "title-colour" in step { step.at("title-colour") }
    else { pair.at(1) }
  let body-ink = if print-mode { black }
    else if "body-colour" in step { step.at("body-colour") }
    else { pair.at(2) }
  let head-fill = if print-mode { luma(222) } else { source-colour }
  let body-fill = if print-mode { white } else { source-colour }
  let shade-fill = if print-mode { luma(165) } else { source-colour.darken(28%) }
  let outline = if print-mode {
    (paint: rgb("#707070"), thickness: 0.7pt)
  } else { none }
  let card-width = face-width + depth
  let total-height = head-height + depth + body-height
  let shadow-ink = rgb("#555555").transparentize(if print-mode { 89% } else { 82% })
  let shadow = box(width: card-width, height: total-height,
    fill: shadow-ink, inset: 0pt)
  let art = _cbl-cube-art(
    face-width, head-height, body-height, depth,
    head-fill, body-fill, shade-fill, outline, rtl: rtl,
  )
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let icon-box = if icon == none { none } else {
    box(width: icon-size, height: icon-size, align(center, icon))
  }
  let head-left = if rtl { depth } else { 0pt }
  let icon-x = if rtl {
    head-left + face-width - 0.34cm - icon-size
  } else { head-left + 0.34cm }
  let title-x = if rtl { head-left + 0.30cm } else { head-left + 1.22cm }
  let title-width = face-width - 1.54cm
  let title-align = if rtl { right } else { left }
  let title-box = box(width: title-width, height: head-height,
    align(title-align + horizon,
      text(size: title-size, weight: "bold", fill: head-ink, step.at("title"))))
  let body-left = if rtl { 0pt } else { depth }
  let body-box = box(width: face-width - 0.72cm, height: body-height - 0.42cm,
    align(title-align + top,
      text(size: body-size, fill: body-ink, step.at("body"))))
  let panel-x = body-left + 0.36cm
  let header-icon-y = 0.17cm
  let body-y = head-height + depth + 0.22cm
  let card = box(width: card-width + 0.12cm, height: total-height + 0.14cm,
    inset: 0pt, {
    place(top + left, dx: 0.10cm, dy: 0.14cm, shadow)
    place(top + left, art)
    if icon != none {
      place(top + left, dx: icon-x, dy: header-icon-y, icon-box)
    }
    place(top + left, dx: title-x, dy: 0pt, title-box)
    place(top + left, dx: panel-x, dy: body-y, body-box)
  })
  card
}

/// A configurable grid of colored cube-like cards for a block list.
///
/// Each item in `steps:` requires `title:` and `body:`; `icon:` and
/// `print-icon:` are optional. Per-step `colour:`, `title-colour:` and
/// `body-colour:` overrides are supported. RTL mirrors each block's depth and
/// reverses card order. Print mode uses pale-gray title faces and gray side facets.
///
/// ```typ
/// #cube-block-list(steps: (
///   (title: [Plan], body: [A short block description.], icon: [⚙]),
///   (title: [Build], body: [Another description.], icon: [◉]),
/// ))
/// ```
#let cube-block-list(
  steps: (),
  width: auto,
  columns: 3,
  gap: 0.42cm,
  row-gap: 0.76cm,
  head-height: 1.18cm,
  body-height: 2.90cm,
  depth: 0.44cm,
  direction: auto,
  colours: (
    (rgb("#06445A"), white, white),
    (rgb("#52BEE7"), rgb("#063248"), rgb("#173C4B")),
    (rgb("#C32E1E"), white, white),
    (rgb("#F7941D"), black, rgb("#3D2A13")),
    (rgb("#FFCB4A"), black, rgb("#554016")),
    (rgb("#A7C36B"), black, rgb("#354426")),
  ),
  title-size: 14pt,
  body-size: 8.2pt,
  icon-size: 0.76cm,
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
      let depth-cm = depth / 1cm
      let columns = calc.max(1, columns)
      let face-cm = calc.max(3.8,
        (total-cm - columns * depth-cm - (columns - 1) * gap-cm) / columns)
      let rows = calc.ceil(count / columns)
      let head-cm = head-height / 1cm
      let body-cm = body-height / 1cm
      let total-card-cm = head-cm + depth-cm + body-cm
      let row-stride-cm = total-card-cm + row-gap-cm
      let total-height = (rows * total-card-cm + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          place(top + left,
            dx: (visual-col * (face-cm + depth-cm + gap-cm)) * 1cm,
            dy: (row * row-stride-cm) * 1cm,
            _cbl-card(
              steps.at(index), index, face-cm * 1cm, head-height, body-height,
              depth, rtl, print-mode, colours, title-size, body-size, icon-size,
            ))
        }
      })
    }
  })
}
