// One reusable layered paper note adapted from PresentationGO's Paper Notes.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _pnb-paperclip(colour, angle) = {
  let outer = rect(width: 0.62cm, height: 1.35cm, radius: 0.31cm,
    fill: none, stroke: (paint: colour, thickness: 2.2pt))
  let inner = rect(width: 0.28cm, height: 0.88cm, radius: 0.14cm,
    fill: none, stroke: (paint: colour, thickness: 1.6pt))
  box(width: 0.86cm, height: 1.52cm, {
    place(top + left, dx: 0.12cm, dy: 0.03cm,
      rotate(angle, origin: center + horizon, outer))
    place(top + left, dx: 0.29cm, dy: 0.21cm,
      rotate(angle, origin: center + horizon, inner))
  })
}

/// Draw one layered paper-note box with an overlapping sheet, clip, heading, and copy.
/// The source's four-note cluster is intentionally reduced to one reusable note.
#let paper-note-box(
  title: [LOREM IPSUM],
  body: [],
  width: 6.1cm,
  height: auto,
  min-height: 8.0cm,
  direction: auto,
  body-direction: auto,
  colour: rgb("#FFA91F"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  clip-colour: auto,
  shadow-colour: auto,
  title-size: 17pt,
  body-size: 10pt,
  text-padding-x: 0.48cm,
  title-y: 1.62cm,
  title-body-gap: 0.34cm,
  bottom-padding: 1.25cm,
  backing-angle: 7deg,
  shadow-offset: 0.12cm,
  paperclip: true,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let body-rtl = if body-direction == auto { rtl }
    else { body-direction == "rtl" or body-direction == std.rtl }
  let title-dir = if rtl { std.rtl } else { std.ltr }
  let body-dir = if body-rtl { std.rtl } else { std.ltr }

  let front-fill = if print-mode { white }
    else if panel-colour != auto { panel-colour }
    else { colour }
  let back-fill = if print-mode { luma(195) } else { colour.darken(15%) }
  let title-ink = if print-mode { luma(20) }
    else if title-colour != auto { title-colour }
    else { rgb("#253143") }
  let body-ink = if print-mode { luma(45) }
    else if text-colour != auto { text-colour }
    else { rgb("#344154") }
  let clip-ink = if print-mode { luma(25) }
    else if clip-colour != auto { clip-colour }
    else { rgb("#101820") }
  let shadow-ink = if shadow-colour != auto { shadow-colour } else { rgb("#2E3943") }
  let shadow-fill = if print-mode { luma(225) } else { shadow-ink.transparentize(87%) }

  let content-width = width - 2 * text-padding-x
  let title-content = text(dir: title-dir, size: title-size,
    weight: "bold", fill: title-ink, title)
  let body-content = {
    set par(leading: 0.50em, spacing: 0.38em, justify: false)
    text(dir: body-dir, size: body-size, fill: body-ink, body)
  }
  let title-measure = measure(title-content, width: content-width)
  let body-measure = measure(body-content, width: content-width)
  let title-height = calc.max(0.58cm, title-measure.height)
  let body-y = title-y + title-height + title-body-gap
  let measured-height = body-y + body-measure.height + bottom-padding
  let final-height = if height == auto { calc.max(min-height, measured-height) }
    else { calc.max(height, measured-height) }

  let pad-x = 0.53cm
  let pad-y = 0.50cm
  let front-x = pad-x
  let front-y = pad-y
  let back-width = width + 0.43cm
  let back-height = final-height + 0.28cm
  let back-x = front-x - 0.215cm
  let back-y = front-y - 0.14cm
  let back-angle = if rtl { backing-angle } else { -backing-angle }
  let back-sheet = rect(width: back-width, height: back-height,
    fill: back-fill, stroke: none)
  let tilted-back = rotate(back-angle, origin: center + horizon, back-sheet)
  let shadow-sheet = rect(width: width, height: final-height,
    fill: shadow-fill, stroke: none)
  let front-edge = if print-mode { (paint: luma(170), thickness: 0.65pt) } else { none }
  let front-sheet = rect(width: width, height: final-height,
    fill: front-fill, stroke: front-edge)

  let title-x = front-x + text-padding-x
  let title-box = box(width: content-width, height: title-height,
    align(if rtl { right + horizon } else { left + horizon }, title-content))
  let body-box = box(width: content-width,
    height: final-height - body-y - bottom-padding,
    align(if body-rtl { right + top } else { left + top }, body-content))
  let clip = _pnb-paperclip(clip-ink, if rtl { -14deg } else { 14deg })
  let clip-x = if rtl { front-x + width - 1.24cm } else { front-x + 0.38cm }
  let clip-y = front-y - 0.40cm
  let shadow-x = front-x + shadow-offset
  let shadow-y = front-y + shadow-offset

  box(width: width + 1.10cm, height: final-height + 1.08cm,
    inset: 0pt, {
      place(top + left, dx: back-x, dy: back-y, tilted-back)
      if shadow {
        place(top + left, dx: shadow-x, dy: shadow-y, shadow-sheet)
      }
      place(top + left, dx: front-x, dy: front-y, front-sheet)
      if paperclip {
        place(top + left, dx: clip-x, dy: clip-y, clip)
      }
      place(top + left, dx: (title-x) + title-offset-x, dy: (front-y + title-y) + title-offset-y, title-box)
      place(top + left, dx: (title-x) + body-offset-x, dy: (front-y + body-y) + body-offset-y, body-box)
    })
}
