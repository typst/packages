// One rounded information box with a colored title bar, icon, and white body.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single Simple Rounded Text Box with a colored header and a separate body panel.
/// Draws one box only, not the source's six-card grid.
#let simple-rounded-text-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 7.8cm,
  height: 5.2cm,
  direction: auto,
  header-colour: rgb("#3D5F87"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  title-size: 14pt,
  body-size: 8.6pt,
  icon-size: 0.92cm,
  corner-radius: 0.26cm,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { std.ltr })

  let header-fill = if print-mode { luma(190) } else { header-colour }
  let panel-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { white }
  let title-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else { white }
  let copy-ink = if print-mode { luma(35) }
    else if text-colour != auto { text-colour }
    else { rgb("#5C6064") }

  let top-radius = (
    top-left: corner-radius, top-right: corner-radius,
    bottom-left: 0pt, bottom-right: 0pt,
  )
  let face = box(width: width, height: height,
    radius: corner-radius, fill: panel-fill, inset: 0pt,
    stroke: if print-mode { (paint: luma(170), thickness: 0.55pt) } else { none })
  let header-height = height * 0.292
  let header = box(width: width, height: header-height,
    radius: top-radius, fill: header-fill, inset: 0pt)

  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon != none { icon }
    else { text(size: icon-size, weight: "bold", fill: title-ink, [✦]) }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center, icon-content))
  let icon-x = if rtl { width - icon-size - width * 0.065 } else { width * 0.065 }
  let icon-y = (header-height - icon-size) / 2
  let title-x = if rtl { width * 0.065 } else { icon-size + width * 0.135 }
  let title-width = width - icon-size - width * 0.235
  let title-box = box(width: title-width, height: header-height,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: title-ink, title)))

  let body-width = width * 0.88
  let body-box = box(width: body-width, height: height * 0.56,
    align(center, {
      set par(justify: false)
      text(size: body-size, fill: copy-ink, body)
    }))
  let body-x = width * 0.06
  let body-y = header-height + height * 0.075

  let shadow-shape = box(width: width, height: height,
    radius: corner-radius, fill: rgb("#7B858C").transparentize(82%), inset: 0pt)

  box(width: width + 0.14cm, height: height + 0.16cm, inset: 0pt, {
    if shadow and not print-mode {
      place(top + left, dx: 0.07cm, dy: 0.10cm, shadow-shape)
    }
    place(top + left, dx: 0pt, dy: 0pt, face)
    place(top + left, dx: 0pt, dy: 0pt, header)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    place(top + left, dx: (title-x) + title-offset-x, dy: (0pt) + title-offset-y, title-box)
    place(top + left, dx: (body-x) + body-offset-x, dy: (body-y) + body-offset-y, body-box)
  })
}
