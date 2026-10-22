// One reusable folder-tab information box, adapted from PresentationGO's Tabbed Folder Grid.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single folder-shaped text box with a colored tab/header, body panel, and foot strip.
/// This is one reusable box, not the source's six-box grid.
#let tabbed-folder-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 8.2cm,
  body-height: 2.20cm,
  direction: auto,
  dark: false,
  colour: rgb("#E95548"),
  body-colour: auto,
  title-colour: auto,
  text-colour: auto,
  footer-colour: auto,
  tab-width: 1.55cm,
  tab-height: 0.36cm,
  tab-slope: 0.32cm,
  header-height: 0.84cm,
  footer-height: 0.18cm,
  radius: 0.22cm,
  inset-x: 0.34cm,
  icon-size: 0.60cm,
  title-size: 12pt,
  body-size: 9pt,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let accent = if print-mode { luma(165) } else { colour }
  let panel-fill = if print-mode { luma(238) }
    else if body-colour != auto { body-colour }
    else if dark { colour.darken(67%) }
    else { colour.lighten(79%) }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { white }
  let body-ink = if print-mode { luma(30) }
    else if text-colour != auto { text-colour }
    else if dark { white }
    else { rgb("#343434") }
  let footer-fill = if print-mode { luma(120) }
    else if footer-colour != auto { footer-colour }
    else { colour.darken(8%) }
  let folder-icon = if print-mode and print-icon != none { print-icon }
    else if icon == none {
      text(size: icon-size, weight: "bold", fill: if print-mode { black } else { white }, [✦])
    } else { icon }
  let body-top = tab-height + header-height
  let card-height = body-top + body-height
  let title-x = if rtl { inset-x } else { inset-x + icon-size + 0.24cm }
  let title-width = width - icon-size - 2 * inset-x - 0.24cm
  let icon-x = if rtl { width - inset-x - icon-size } else { inset-x }
  let header-corners = if rtl {
    (top-left: radius, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt)
  } else {
    (top-left: 0pt, top-right: radius, bottom-left: 0pt, bottom-right: 0pt)
  }
  let panel-corners = (top-left: 0pt, top-right: 0pt,
    bottom-left: radius, bottom-right: radius)
  let footer-corners = (top-left: 0pt, top-right: 0pt,
    bottom-left: radius, bottom-right: radius)
  let header-band = box(width: width, height: header-height,
    radius: header-corners, fill: accent, inset: 0pt)
  let folder-tab = if rtl {
    polygon(fill: accent, stroke: none,
      (width, 0pt), (width - tab-width, 0pt),
      (width - tab-width - tab-slope, tab-height), (width, tab-height))
  } else {
    polygon(fill: accent, stroke: none,
      (0pt, 0pt), (tab-width, 0pt),
      (tab-width + tab-slope, tab-height), (0pt, tab-height))
  }
  let body-panel = box(width: width, height: body-height,
    radius: panel-corners, fill: panel-fill, inset: 0pt)
  let footer = box(width: width, height: footer-height,
    radius: footer-corners, fill: footer-fill, inset: 0pt)
  let heading = box(width: title-width, height: header-height,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy = box(width: width - 2 * inset-x, height: body-height - 0.43cm,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: body-ink, body)))
  let icon-box = box(width: icon-size, height: header-height,
    align(center + horizon, folder-icon))

  box(width: width, height: card-height, inset: 0pt, {
    place(top + left, dx: (0pt) + body-offset-x, dy: (body-top) + body-offset-y, body-panel)
    place(top + left, dx: 0pt, dy: body-top + body-height - footer-height, footer)
    place(top + left, dx: 0pt, dy: tab-height, header-band)
    place(top + left, dy: 0pt, folder-tab)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (tab-height) + icon-offset-y, icon-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (tab-height) + title-offset-y, heading)
    place(top + left, dx: (inset-x) + body-offset-x, dy: (body-top + 0.18cm) + body-offset-y, copy)
  })
}
