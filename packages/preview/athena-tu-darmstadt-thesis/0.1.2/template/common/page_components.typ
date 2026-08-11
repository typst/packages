#let tud-header(
  accentcolor_rgb: "55555555",
  content: []
) = {
    box(//fill: white,
      grid(
      rows: auto,
      rect(
        fill: color.rgb(accentcolor_rgb),
        width: 100%,
        height: 4mm //- 0.05mm
      ),
      v(1.4mm + 0.25mm), // should be 1.4mm according to guidelines
      line(length: 100%, stroke: 1.2pt), //+ 0.1pt) // should be 1.2pt according to guidelines
      content
      )
  )
}