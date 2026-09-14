#let textbox(
  title,
  color: blue,
  radius: 2pt,
  width: auto,
  body
) = {
  let textbox-background(color: black, body) = {
    set text(fill: white, weight: "bold")
    context {
      let size = measure(body)
      let inset = 8pt
      [#block()[
          #polygon(
            fill: color,
            (0pt, 0pt),
            (0pt, size.height + (2 * inset)),
            (size.width + (2 * inset), size.height + (2 * inset)),
            (size.width + (2 * inset) + 6pt, 0cm),
          )
          #place(center + top, dy: size.height, dx: -3pt)[#body]
        ]]
    }
  }

  return block(
    stroke: 2pt + color,
    fill: color.transparentize(90%),
    
    radius: radius,
    width: width,
  )[
    #textbox-background(color: color)[#title]
    #block(width: 100%, inset: (top: -2pt, x: 10pt, bottom: 10pt))[
      #body
    ]
  ]
}