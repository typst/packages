// One reusable peak-header information card, adapted from PresentationGO's Peak Header Cards.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single rounded box with a white peak-cut header and colored text body.
/// This is one box, not the source's connected four-step card sequence.
#let peak-header-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  number: none,
  width: 5.0cm,
  height: 4.65cm,
  direction: auto,
  dark: false,
  colour: rgb("#F05D4E"),
  header-colour: auto,
  title-colour: auto,
  text-colour: auto,
  shadow-colour: auto,
  header-height: 1.16cm,
  peak-depth: 0.62cm,
  radius: 0.24cm,
  inset-x: 0.36cm,
  icon-size: 0.62cm,
  icon-y: 0.28cm,
  title-size: 11pt,
  body-size: 8.5pt,
  title-gap: 0.22cm,
  body-gap: 0.15cm,
  body-height: 1.55cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  number-offset-x: 0pt,
  number-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let card-fill = if print-mode { luma(220) } else { colour }
  let header-fill = if print-mode { luma(248) }
    else if header-colour != auto { header-colour }
    else if dark { rgb("#E9EDF0") }
    else { white }
  let header-ink = if print-mode { black } else { colour }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { white }
  let copy-ink = if print-mode { luma(25) }
    else if text-colour != auto { text-colour }
    else { white }
  let shadow-ink = if print-mode { luma(232) }
    else if shadow-colour != auto { shadow-colour }
    else if dark { rgb("#000000").transparentize(74%) }
    else { rgb("#343A40").transparentize(88%) }
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon == none {
      text(size: icon-size, weight: "bold", fill: header-ink, [✦])
    } else { icon }
  let header-base = header-height
  let title-y = header-base + peak-depth + title-gap
  let body-y = title-y + 0.47cm + body-gap
  let body-box-height = if body-height == auto { height - body-y - 0.22cm } else { body-height }
  let icon-x = if rtl { width - inset-x - icon-size } else { inset-x }
  let number-x = if rtl { inset-x } else { width - inset-x - 0.66cm }
  let content-width = width - 2 * inset-x
  let card-shadow = box(width: width, height: height,
    radius: radius, fill: shadow-ink, inset: 0pt)
  let card = box(width: width, height: height,
    radius: radius, fill: card-fill, inset: 0pt)
  let header-panel = box(width: width, height: header-base,
    radius: (top-left: radius, top-right: radius, bottom-left: 0pt, bottom-right: 0pt),
    fill: header-fill, inset: 0pt)
  let peak = polygon(fill: header-fill, stroke: none,
    (0pt, header-base - 0.01cm),
    (width, header-base - 0.01cm),
    (width / 2, header-base + peak-depth))
  let icon-box = box(width: icon-size, height: icon-size,
    align(center + horizon, icon-content))
  let number-box = if number == none { none } else {
    box(width: 0.66cm, height: 0.34cm,
      align((if rtl { left } else { right }) + horizon,
        text(size: 9pt, weight: "bold", fill: if print-mode { luma(75) } else { luma(90) }, number)))
  }
  let heading = box(width: content-width, height: 0.47cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy = box(width: content-width, height: body-box-height,
    align(center + horizon, text(size: body-size, fill: copy-ink, body)))

  box(width: width + 0.08cm, height: height + 0.08cm, inset: 0pt, {
    place(top + left, dx: 0.06cm, dy: 0.08cm, card-shadow)
    place(top + left, card)
    place(top + left, header-panel)
    place(top + left, peak)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    if number-box != none {
      place(top + left, dx: (number-x) + number-offset-x, dy: (0.20cm) + number-offset-y, number-box)
    }
    place(top + left, dx: (inset-x) + title-offset-x, dy: (title-y) + title-offset-y, heading)
    place(top + left, dx: (inset-x) + body-offset-x, dy: (body-y) + body-offset-y, copy)
  })
}
