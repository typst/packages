#import "../brand.typ": colour

/// An inset note with an optional heading and a semantic accent.
#let callout(
  title: none,
  tone: "info",
  accent: auto,
  fill: auto,
  ink: colour.neutral-dark,
  size: 1em,
  inset: .8em,
  radius: .25em,
  body,
) = {
  let tones = (
    info: colour.primary,
    success: rgb("#21734b"),
    warning: rgb("#956114"),
    danger: rgb("#b12c3b"),
    neutral: rgb("#626b73"),
  )
  assert(tone in tones, message: "callout tone must be info, success, warning, danger or neutral")
  let accent = if accent == auto { tones.at(tone) } else { accent }
  let fill = if fill == auto { accent.lighten(94%) } else { fill }
  block(
    width: 100%, inset: inset, radius: radius, fill: fill,
    stroke: (left: 2.5pt + accent), breakable: false,
    {
      set text(size: size, fill: ink)
      set par(spacing: .55em, leading: .4em)
      let items = if title == none { () } else { (text(weight: "semibold", fill: accent, title),) }
      stack(dir: ttb, spacing: .35em, ..items, body)
    },
  )
}
