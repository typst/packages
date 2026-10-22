// PowerPoint-inspired banners with overlapping numbered circles.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _bwc-banner(
  step, index, tile-width, height, circle-size, rtl, print-mode,
  colours, title-size, body-size, number-size, icon-size,
) = {
  let pair = colours.at(calc.rem(index, colours.len()))
  let main-colour = if "colour" in step { step.at("colour") } else { pair.at(0) }
  let accent-colour = if "accent" in step { step.at("accent") } else { pair.at(1) }
  let face = if print-mode { white } else { main-colour }
  let accent = if print-mode { rgb("#707070") } else { accent-colour }
  let title-ink = if print-mode { black } else { rgb("#171717") }
  let body-ink = if print-mode { black } else { rgb("#4F4F4F") }
  let edge = if print-mode { (paint: rgb("#707070"), thickness: 0.75pt) } else { none }
  let band-height = 1.44cm
  let strip-height = 0.25cm
  let band-y = (height - band-height) / 2
  let band-width = tile-width - circle-size / 2
  let band-x = if rtl { 0pt } else { circle-size / 2 }
  let far-radius = 0.22cm
  let radii = if rtl {
    (top-left: far-radius, bottom-left: far-radius,
     top-right: 0pt, bottom-right: 0pt)
  } else {
    (top-left: 0pt, bottom-left: 0pt,
     top-right: far-radius, bottom-right: far-radius)
  }
  let face-radii = if rtl {
    (top-left: far-radius, bottom-left: 0pt,
     top-right: 0pt, bottom-right: 0pt)
  } else {
    (top-left: 0pt, bottom-left: 0pt,
     top-right: far-radius, bottom-right: 0pt)
  }
  let shadow-ink = rgb("#858585").transparentize(78%)
  let shadow = box(width: band-width, height: band-height,
    radius: radii, fill: shadow-ink, inset: 0pt)
  let base = box(width: band-width, height: band-height,
    radius: radii, fill: accent, stroke: if print-mode { edge } else { none }, inset: 0pt)
  let top-face = box(width: band-width, height: band-height - strip-height,
    radius: face-radii, fill: face, stroke: edge, inset: 0pt)

  let outer = circle(radius: circle-size / 2, fill: accent,
    stroke: if print-mode { edge } else { none })
  let inner-size = circle-size * 0.67
  let inner = circle(radius: inner-size / 2, fill: white,
    stroke: if print-mode { edge } else { none })
  let number = if "number" in step { step.at("number") } else { index + 1 }
  let number-label = [#number]
  let number-content = box(width: inner-size, height: inner-size,
    align(center + horizon, text(size: number-size, weight: "bold", fill: black, number-label)))

  let title = text(size: title-size, weight: "bold", fill: title-ink, step.at("title"))
  let body = text(size: body-size, fill: body-ink, step.at("body"))
  let icon = if print-mode and "print-icon" in step {
    step.at("print-icon")
  } else if "icon" in step { step.at("icon") } else { none }
  let content-width = calc.max(0.6cm, tile-width - circle-size - icon-size - 0.58cm)
  let content-x = if rtl { icon-size + 0.20cm } else { circle-size + 0.14cm }
  let content-align = if rtl { right } else { left }
  let title-box = box(width: content-width, height: 0.42cm,
    align(content-align + horizon, title))
  let body-box = box(width: content-width, height: 0.55cm,
    align(content-align + top, body))
  let title-y = band-y + 0.13cm
  let body-y = band-y + 0.56cm
  let icon-box = if icon == none { none } else {
    box(width: icon-size, height: icon-size, align(center, icon))
  }
  let icon-x = if rtl { 0.16cm } else { tile-width - icon-size - 0.16cm }
  let circle-x = if rtl { tile-width - circle-size } else { 0pt }
  let circle-y = (height - circle-size) / 2

  box(width: tile-width, height: height, inset: 0pt, {
    if not print-mode {
      place(top + left, dx: band-x + 0.045cm, dy: band-y + 0.11cm, shadow)
      place(top + left, dx: circle-x + 0.045cm, dy: circle-y + 0.11cm,
        circle(radius: circle-size / 2, fill: shadow-ink))
    }
    place(top + left, dx: band-x, dy: band-y, base)
    place(top + left, dx: band-x, dy: band-y, top-face)
    place(top + left, dx: circle-x, dy: circle-y, outer)
    place(top + left, dx: circle-x + (circle-size - inner-size) / 2,
      dy: circle-y + (circle-size - inner-size) / 2, inner)
    place(top + left, dx: circle-x + (circle-size - inner-size) / 2,
      dy: circle-y + (circle-size - inner-size) / 2, number-content)
    place(top + left, dx: content-x, dy: title-y, title-box)
    place(top + left, dx: content-x, dy: body-y, body-box)
    if icon != none {
      place(top + left, dx: icon-x, dy: band-y + (band-height - icon-size) / 2, icon-box)
    }
  })
}

/// A two-column gallery of horizontal banners with an overlapping numbered circle.
///
/// Each item supplies `title` and `body`; `number` and `icon` are optional.
/// Pass `width` to control the total gallery width, and `columns` to change
/// how many banners share each row. Direction mirrors both the circle position
/// and text alignment. In print, the bands become white with gray accents.
///
/// ```typ
/// #banners-with-circles(
///   width: 18cm,
///   steps: (
///     (title: [Discover], body: [Collect observations and define the question.]),
///     (title: [Plan], body: [Choose a method and organize the work.]),
///   ),
/// )
/// ```
#let banners-with-circles(
  steps: (),
  width: auto,
  columns: 2,
  gap: 0.52cm,
  row-gap: 0.48cm,
  height: 2.08cm,
  circle-size: 1.78cm,
  direction: auto,
  colours: (
    (rgb("#35E2CD"), rgb("#00A994")),
    (rgb("#FFA975"), rgb("#F36B08")),
    (rgb("#51C5E3"), rgb("#058FAD")),
    (rgb("#F6DE7B"), rgb("#E8C628")),
    (rgb("#EF7D6A"), rgb("#BD2B1B")),
    (rgb("#C3D4A1"), rgb("#94B263")),
  ),
  title-size: 11.4pt,
  body-size: 7.2pt,
  number-size: 20pt,
  icon-size: 0.58cm,
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
      let tile-width = calc.max(3.2, (total-cm - (columns - 1) * gap-cm) / columns)
      let height-cm = height / 1cm
      let rows = calc.ceil(count / columns)
      let total-height = (rows * height-cm + (rows - 1) * row-gap-cm) * 1cm
      box(width: total-width, height: total-height, inset: 0pt, {
        for index in range(count) {
          let logical-col = calc.rem(index, columns)
          let row = calc.floor(index / columns)
          let visual-col = if rtl { columns - 1 - logical-col } else { logical-col }
          let dx = visual-col * (tile-width + gap-cm)
          let dy = row * (height-cm + row-gap-cm)
          place(top + left, dx: dx * 1cm, dy: dy * 1cm,
            _bwc-banner(
              steps.at(index), index, tile-width * 1cm, height, circle-size,
              rtl, print-mode, colours, title-size, body-size, number-size, icon-size,
            ))
        }
      })
    }
  })
}
