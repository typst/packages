/// Raw badge primitive — takes explicit parameters only, no state access.
/// ui.typ resolves tokens and passes them here.
#let badge(
  body,
  base-color: rgb("#64748b"),
  bg-color: none,
  pad-h: 0.5em,
  pad-v: 0.25em,
  rad: 4pt,
  text-size: 0.85em,
) = {
  let bg = if bg-color != none { bg-color } else { base-color.lighten(85%) }
  rect(
    fill: bg,
    stroke: 0.5pt + base-color,
    radius: rad,
    inset: (x: pad-h, y: pad-v),
    outset: 0pt,
    text(fill: base-color, weight: "bold", size: text-size)[#body],
  )
}
