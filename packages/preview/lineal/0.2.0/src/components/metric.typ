#import "../brand.typ": colour

#let text-align = align

/// A prominent value with a label, optional context and optional change label.
#let metric(
  value,
  label: none,
  detail: none,
  change: none,
  accent: colour.primary,
  ink: colour.neutral-dark,
  muted: rgb("#626b73"),
  fill: none,
  size: 1em,
  value-size: 2.5em,
  inset: .8em,
  radius: .25em,
  align: left,
) = block(
  width: 100%, inset: inset, fill: fill, radius: radius, breakable: false,
  {
    set text(size: size, fill: ink)
    set par(spacing: .55em, leading: .4em)
    set text-align(align)
    let items = if label == none { () } else { (text(weight: "semibold", label),) }
    items.push(text(size: value-size, weight: "bold", fill: accent,
      if type(value) in (int, float) { str(value) } else { value },
    ))
    if change != none {
      items.push(text(weight: "semibold", fill: accent, change))
    }
    if detail != none {
      items.push(text(size: .85em, fill: muted, detail))
    }
    stack(dir: ttb, spacing: .45em, ..items)
  },
)
