// One reusable offset-frame feature block, after PresentationGO's Frame Accent Blocks.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

/// A single icon block with an offset colored square, open frame, title, and copy.
/// This is the reusable block, not the source's four-column slide layout.
#let frame-accent-block(
  title: [],
  body: [],
  icon: none,
  width: 4.1cm,
  square-size: 2.70cm,
  offset: 0.34cm,
  frame-weight: 2.2pt,
  direction: auto,
  dark: false,
  colour: rgb("#F9A619"),
  frame-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-size: 1.0cm,
  title-size: 11pt,
  body-size: 8.5pt,
  title-gap: 0.30cm,
  body-gap: 0.16cm,
  body-height: 1.45cm,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() } else { direction == std.rtl }
  set text(dir: if rtl { std.rtl } else { ltr })

  let accent-fill = if print-mode { luma(218) } else { colour }
  let frame-ink = if print-mode { black }
    else if frame-colour != auto { frame-colour }
    else if dark { white }
    else { black }
  let heading-ink = if print-mode { black }
    else if title-colour != auto { title-colour }
    else if dark { white }
    else { black }
  let body-ink = if print-mode { luma(30) }
    else if text-colour != auto { text-colour }
    else if dark { white }
    else { rgb("#30343A") }
  let assembly-width = square-size + offset
  let assembly-x = (width - assembly-width) / 2
  let accent-x = if rtl { assembly-x } else { assembly-x + offset }
  let frame-x = if rtl { assembly-x + offset } else { assembly-x }
  let content-icon = if icon == none { text(size: icon-size, weight: "bold", [✦]) } else { icon }
  let title-y = offset + square-size + title-gap
  let body-y = title-y + 0.48cm + body-gap
  let total-height = body-y + body-height
  let accent-square = box(width: square-size, height: square-size,
    fill: accent-fill, inset: 0pt)
  let outline-square = box(width: square-size, height: square-size,
    fill: none, stroke: (paint: frame-ink, thickness: frame-weight), inset: 0pt)
  let icon-box = box(width: square-size, height: square-size,
    align(center + horizon, content-icon))
  let heading = box(width: width, height: 0.48cm,
    align(center + horizon,
      text(size: title-size, weight: "bold", fill: heading-ink, title)))
  let copy = box(width: width, height: body-height,
    align(center + horizon, text(size: body-size, fill: body-ink, body)))

  box(width: width, height: total-height, inset: 0pt, {
    place(top + left, dx: accent-x, dy: 0pt, accent-square)
    place(top + left, dx: accent-x, dy: 0pt, icon-box)
    // Draw the open frame last so its offset edges cross over the accent square.
    place(top + left, dx: frame-x, dy: offset, outline-square)
    place(top + left, dx: 0pt, dy: title-y, heading)
    place(top + left, dx: 0pt, dy: body-y, copy)
  })
}
