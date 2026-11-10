#let pagestyle(body) = {
  set page(
    paper: "us-letter",
    margin: (
      top: 0.55in + 48pt + 14pt, 
      bottom: 1.0in, left: 0.65in, right: 0.65in
    ),

    header: align(bottom)[
      #grid(
        columns: (1fr, 1fr),
        align: (left + bottom, right + bottom),
        image("/imgs/LOGO1.png", height: 40pt),
        image("/imgs/LOGO2.png", height: 40pt)
      )
      #v(-4pt)
      #line(length: 100%, stroke: 0.5pt + black)
      #v(14pt)
    ],
    numbering: none
  )
  body
}