/// Raw card primitive — takes explicit parameters only, no state access.
/// ui.typ resolves tokens and passes them here.
#let card(
  body,
  title: none,
  bg: rgb("#f8fafc"),
  border-color: rgb("#e2e8f0"),
  pad: 1em,
  rad: 8pt,
  title-size: 1.1em,
) = {
  let stroke-width = 0.75pt
  rect(
    fill: bg,
    stroke: stroke-width + border-color,
    radius: rad,
    inset: pad,
    width: 100%,
    {
      if title != none {
        text(weight: "bold", size: title-size)[#title]
        v(pad * 0.5)
      }
      body
    },
  )
}
