#let box-text(
  font-size: 0.6em,
  text-color: black,
  bg-color: rgb(0, 0, 0, 0),
  stroke: 0.05em + black,
  radius: 0.4em,
  inset: 0.3em,
  content,
) = {
  box(
    fill: bg-color,
    radius: radius,
    inset: inset,
    stroke: stroke,
    text(
      fill: text-color,
      size: font-size,
    )[#content],
  )
}
