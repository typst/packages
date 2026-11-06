// One reusable layered folder-step box, adapted from PresentationGO's Folder Step Trio.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single folder silhouette with a contrasting, stepped foreground content panel.
/// This is one reusable box, not the source's three-card slide layout.
#let folder-step-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  number: none,
  width: 5.9cm,
  front-height: 3.30cm,
  folder-height: 2.55cm,
  direction: auto,
  dark: false,
  colour: rgb("#78AA78"),
  front-colour: auto,
  outline-colour: auto,
  title-colour: auto,
  text-colour: auto,
  front-overhang: 0.20cm,
  tab-width: 1.62cm,
  tab-height: 0.43cm,
  tab-slope: 0.32cm,
  front-step: 0.48cm,
  front-slope: 0.38cm,
  front-cap-width: 2.20cm,
  radius: 0.20cm,
  outline-weight: 0.10cm,
  inset-x: 0.36cm,
  icon-size: 0.62cm,
  icon-y: 0.36cm,
  number-size: 16pt,
  title-size: 12pt,
  body-size: 8.5pt,
  title-y: 0.68cm,
  body-y: 1.24cm,
  body-height: 1.72cm,
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

  let folder-fill = if print-mode { luma(185) } else { colour }
  let folder-ink = if print-mode { black }
    else if outline-colour != auto { outline-colour }
    else if dark { white }
    else { rgb("#062337") }
  let panel-fill = if print-mode { luma(235) }
    else if front-colour != auto { front-colour }
    else if dark { rgb("#F1F2F4") }
    else { rgb("#062337") }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else if dark { rgb("#13171A") }
    else { white }
  let body-ink = if print-mode { luma(25) }
    else if text-colour != auto { text-colour }
    else if dark { rgb("#252A2E") }
    else { white }
  let front-width = width + 2 * front-overhang
  let canvas-width = front-width + 2 * outline-weight
  let folder-x = front-overhang + outline-weight
  let panel-x = outline-weight
  let icon-local-x = if rtl { width - icon-size - 0.42cm } else { 0.42cm }
  let content-width = front-width - 2 * inset-x
  let number-width = 1.00cm
  let number-local-x = if rtl { inset-x } else { front-width - inset-x - number-width }
  let folder-left = (0.18cm, 0pt)
  let folder-points = (
    folder-left,
    (tab-width, 0pt),
    (tab-width + tab-slope, tab-height),
    (width - radius, tab-height),
    (width, tab-height + radius),
    (width, folder-height - radius),
    (width - radius, folder-height),
    (radius, folder-height),
    (0pt, folder-height - radius),
    (0pt, radius),
  )
  let mirror(point) = (width - point.at(0), point.at(1))
  let mirrored-folder = if rtl {
    (mirror(folder-points.at(0)), mirror(folder-points.at(1)),
     mirror(folder-points.at(2)), mirror(folder-points.at(3)),
     mirror(folder-points.at(4)), mirror(folder-points.at(5)),
     mirror(folder-points.at(6)), mirror(folder-points.at(7)),
     mirror(folder-points.at(8)), mirror(folder-points.at(9)))
  } else { folder-points }
  let folder-shape = polygon(
    fill: folder-fill,
    stroke: (paint: folder-ink, thickness: outline-weight, join: "round"),
    ..mirrored-folder,
  )
  let lower-panel = box(width: front-width, height: front-height - front-step,
    radius: (top-left: 0pt, top-right: 0pt, bottom-left: radius, bottom-right: radius),
    fill: panel-fill, inset: 0pt)
  let upper-cap-x = if rtl { 0pt } else { front-width - front-cap-width }
  let upper-cap = box(width: front-cap-width, height: front-step,
    radius: if rtl {
      (top-left: radius, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt)
    } else {
      (top-left: 0pt, top-right: radius, bottom-left: 0pt, bottom-right: 0pt)
    },
    fill: panel-fill, inset: 0pt)
  let icon-content = if print-mode and print-icon != none { print-icon }
    else if icon == none {
      text(size: icon-size, weight: "bold", fill: if print-mode { black } else if dark { white } else { folder-ink }, [✦])
    } else { icon }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center + horizon, icon-content))
  let number-box = if number == none { none } else {
    box(width: number-width, height: 0.62cm,
      align(center + horizon,
        text(size: number-size, weight: "bold", fill: if print-mode { black } else if dark { black } else { white }, number)))
  }
  let heading = box(width: content-width, height: 0.48cm,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy = box(width: content-width, height: body-height,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: body-ink, body)))
  box(width: canvas-width, height: front-height + 1.62cm, inset: 0pt, {
    place(top + left, dx: folder-x, dy: outline-weight, folder-shape)
    place(top + left, dx: panel-x, dy: 1.62cm + front-step, lower-panel)
    place(top + left, dx: panel-x + upper-cap-x, dy: 1.62cm, upper-cap)
    place(top + left, dx: panel-x, dy: 1.62cm,
      if rtl {
        polygon(fill: panel-fill, stroke: none,
          (front-cap-width, 0pt),
          (front-cap-width, front-step),
          (front-cap-width + front-slope, front-step))
      } else {
        polygon(fill: panel-fill, stroke: none,
          (front-width - front-cap-width - front-slope, front-step),
          (front-width - front-cap-width, 0pt),
          (front-width - front-cap-width, front-step))
      })
    place(top + left, dx: (folder-x + icon-local-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    if number-box != none {
      place(top + left, dx: (panel-x + number-local-x) + number-offset-x, dy: (1.75cm) + number-offset-y, number-box)
    }
    place(top + left, dx: (panel-x + inset-x) + title-offset-x, dy: (1.62cm + title-y) + title-offset-y, heading)
    place(top + left, dx: (panel-x + inset-x) + body-offset-x, dy: (1.62cm + body-y) + body-offset-y, copy)
  })
}
