// One reusable L-shaped title box with an overlapping circular icon badge.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single L-shaped header box, not a full slide/grid. `header:` is the small
/// label in the colored band; `title:` and `body:` sit in the tinted panel.
#let l-shaped-header-box(
  header: [],
  title: [],
  body: [],
  icon: none,
  width: 4.15cm,
  height: 3.18cm,
  direction: auto,
  dark: false,
  colour: rgb("#45B9E0"),
  body-colour: auto,
  shadow-colour: auto,
  header-text-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-size: 0.68cm,
  badge-size: 1.46cm,
  header-height: 0.86cm,
  header-overhang: 0.44cm,
  header-x: 0.83cm,
  body-y: 0.76cm,
  title-y: 1.48cm,
  text-y: 2.52cm,
  title-size: 11.5pt,
  header-size: 10pt,
  body-size: 8pt,
  radius: 0.20cm,
  inset-x: 0.34cm,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  let dark-mode = dark and not print-mode
  set text(dir: if rtl { std.rtl } else { ltr })

  let accent = if print-mode { luma(178) } else { colour }
  let panel-colour = if print-mode { luma(235) }
    else if body-colour != auto { body-colour }
    else if dark-mode { colour.darken(8%) }
    else { colour.lighten(48%) }
  let shadow-ink = if print-mode { luma(85) }
    else if shadow-colour != auto { shadow-colour }
    else { colour.darken(48%) }
  let label-ink = if print-mode { black }
    else if header-text-colour != auto { header-text-colour }
    else if dark-mode { rgb("#09283A") }
    else { white }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else if dark-mode { white }
    else { rgb("#242424") }
  let body-ink = if print-mode { rgb("#222222") }
    else if text-colour != auto { text-colour }
    else if dark-mode { white }
    else { rgb("#2E2E2E") }
  let total-width = width + header-overhang
  let body-left = if rtl { header-overhang } else { 0pt }
  let header-left = if rtl { 0pt } else { header-x }
  let header-width = width - 0.34cm
  let disk-center = if rtl { total-width - header-x } else { header-x }
  let disk-top = (header-height - badge-size) / 2 + 0.06cm
  let body-title-width = width - 2 * inset-x
  let label-width = width - 1.49cm
  let label-x = if rtl {
    total-width - (header-x + 0.82cm + label-width)
  } else { header-x + 0.82cm }
  let body-x = body-left + inset-x
  let panel = box(width: width, height: height,
    radius: (top-left: 0pt, top-right: 0pt,
      bottom-right: radius, bottom-left: radius),
    fill: panel-colour, inset: 0pt)
  let header-band = box(width: header-width, height: header-height,
    radius: radius, fill: accent, inset: 0pt)
  let title-box = box(width: body-title-width, height: 0.44cm,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)))
  let body-box = box(width: body-title-width, height: height - (text-y - body-y) - 0.24cm,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: body-ink, body)))
  let content = if icon == none { [✦] } else { icon }
  let disk = ellipse(width: badge-size - 0.20cm, height: badge-size - 0.20cm,
    fill: white, stroke: (paint: if print-mode { luma(140) } else { white }, thickness: 0.04cm))
  let halo = ellipse(width: badge-size, height: badge-size,
    fill: shadow-ink, inset: 0pt)
  let card-height = body-y + height + 0.04cm
  let icon-x = disk-center - icon-size / 2
  let icon-y = disk-top + (badge-size - icon-size) / 2
  let panel-shadow = if print-mode { luma(235) } else { colour.darken(16%).transparentize(if dark-mode { 92% } else { 94% }) }
  let lower-shadow = box(width: width, height: height,
    radius: radius, fill: panel-shadow, inset: 0pt)

  box(width: total-width, height: card-height, inset: 0pt, {
    place(top + left, dx: body-left + 0.07cm, dy: body-y + 0.08cm, lower-shadow)
    place(top + left, dx: body-left, dy: body-y, panel)
    place(top + left, dx: header-left, dy: 0.02cm, header-band)
    // Small colored shoulder visually joins the roundel to the tall box body.
    let shoulder-x = if rtl { total-width - header-x - 0.44cm } else { header-x - 0.34cm }
    place(top + left, dx: shoulder-x, dy: body-y - 0.04cm,
      box(width: 0.78cm, height: 0.28cm, radius: 0.14cm, fill: shadow-ink, inset: 0pt))
    place(top + left, dx: disk-center - badge-size / 2,
      dy: disk-top + 0.11cm, halo)
    place(top + left, dx: disk-center - (badge-size - 0.20cm) / 2,
      dy: disk-top + 0.02cm, disk)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, box(width: icon-size, height: icon-size, align(center, content)))
    place(top + left, dx: label-x, dy: 0.02cm,
      box(width: label-width, height: header-height,
        align((if rtl { right } else { left }) + horizon,
          text(size: header-size, weight: "bold", fill: label-ink, header))))
    place(top + left, dx: (body-x) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
    place(top + left, dx: (body-x) + body-offset-x, dy: (text-y) + body-offset-y, body-box)
  })
}
