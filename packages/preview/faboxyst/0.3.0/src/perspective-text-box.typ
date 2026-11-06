// One reusable trapezoid panel with a shaded depth edge, after PresentationGO's Perspective Text Boxes.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single perspective text panel with a slanted front face and shaded side.
/// This is the reusable box, not the source's five- or six-item progression.
#let perspective-text-box(
  title: [],
  body: [],
  icon: none,
  print-icon: none,
  width: 6.8cm,
  height: 3.85cm,
  direction: auto,
  dark: false,
  colour: rgb("#53BCE4"),
  side-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-size: 0.72cm,
  side-depth: 0.34cm,
  face-slope: 0.30cm,
  side-slope: 0.20cm,
  inset-x: 0.48cm,
  icon-y: 0.35cm,
  title-y: 1.25cm,
  body-y: 1.88cm,
  title-size: 11pt,
  body-size: 8.5pt,
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

  let face-fill = if print-mode { luma(224) } else { colour }
  let side-fill = if print-mode { luma(165) }
    else if side-colour != auto { side-colour }
    else { colour.darken(34%) }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else if dark { white }
    else { black }
  let copy-ink = if print-mode { luma(25) }
    else if text-colour != auto { text-colour }
    else if dark { white }
    else { rgb("#242424") }
  let canvas-width = width + side-depth
  let face-left = if rtl { side-depth } else { 0pt }
  let content-width = width - 2 * inset-x
  let icon-x = if rtl { face-left + width - inset-x - icon-size }
    else { face-left + inset-x }
  let content-icon = if print-mode and print-icon != none { print-icon }
    else if icon == none {
      text(size: icon-size, weight: "bold", fill: if print-mode { black } else if dark { white } else { black }, [✦])
    } else { icon }
  let front = if rtl {
    polygon(fill: face-fill, stroke: none,
      (side-depth, 0pt), (canvas-width, face-slope),
      (canvas-width, height - face-slope), (side-depth, height))
  } else {
    polygon(fill: face-fill, stroke: none,
      (0pt, face-slope), (width, 0pt),
      (width, height), (0pt, height - face-slope))
  }
  let side = if rtl {
    polygon(fill: side-fill, stroke: none,
      (0pt, side-slope), (side-depth, 0pt),
      (side-depth, height), (0pt, height - side-slope))
  } else {
    polygon(fill: side-fill, stroke: none,
      (width, 0pt), (canvas-width, side-slope),
      (canvas-width, height - side-slope), (width, height))
  }
  let icon-box = box(width: icon-size, height: icon-size,
    align(center + horizon, content-icon))
  let heading = box(width: content-width, height: 0.48cm,
    align((if rtl { right } else { left }) + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy = box(width: content-width, height: height - body-y - 0.22cm,
    align((if rtl { right } else { left }) + top,
      text(size: body-size, fill: copy-ink, body)))

  box(width: canvas-width, height: height, inset: 0pt, {
    place(top + left, side)
    place(top + left, front)
    place(top + left, dx: (icon-x) + icon-offset-x, dy: (icon-y) + icon-offset-y, icon-box)
    place(top + left, dx: (face-left + inset-x) + title-offset-x, dy: (title-y) + title-offset-y, heading)
    place(top + left, dx: (face-left + inset-x) + body-offset-x, dy: (body-y) + body-offset-y, copy)
  })
}
