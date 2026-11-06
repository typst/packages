#let frontpage(
  title: "", 
  course:"" , 
  type: "",
  description: "",
  authors: (), 
  date: none, 
  university: "", 
  department: "",
  department-full-title: "",
  body) = {
    
  // Set the document's basic properties.
  set text(size: 10pt, fill: white)
    
  //frontpage
  set par(leading: 0.65em, justify: true)
  set page(numbering: none, number-align: center, fill: rgb("#224ea9"), margin: (top: 1.5in, rest: 2in))
  set page(margin: 0.5in)
  
  //Department information 
  let depart = [
    #align(right, [
      #block([
        #align(right)[
          #text(weight: 700, 1.0em, department )
          #v(0.7em, weak: true)
          #text(weight: 400, 1.0em, department-full-title)
          #v(0.7em, weak: true)
          
          #text(weight: 400, 1.0em, university)
        ]
      ])
    ])
  ]

  // top banner
  table(
    columns: (auto, 1fr),
    inset: 0pt,
    stroke: none,
    align: horizon,
    table.header(
      [#image("../images/DTU/white_rgb.svg", width: 3.5em)], 
      [#depart] 
    ),
  )
  
  v(2em)

  // Title row
  text(weight: 700, 24pt, title)
  linebreak()
  v(1em)
  
  //description
  text(18pt, description)
  
  v(1.5em)

  // Author information.
  pad(
    x: 0.1em,
    grid(
      gutter: 1em,
      columns: if authors.len() == 4 {2} else {3},
      ..authors.map(author => align(left, author)),
    ),
  )

  //alternative authors setup
  // pad(
  //   top: 0.5em,
  //   bottom: 0.5em,
  //   x: 0.1em,
  //   grid(
  //     columns: (1fr,) * calc.min(authors.len(), authors.len()),
  //     // columns: (auto,) * authors.len(),
  //     gutter: 1em,
  //     ..authors.map(author => align(left, author)),
  //   ),
  // )
  
  //bottom image
  place(
  bottom,
  dx: -7%,
  dy: 5%,
    image(
      "../images/DTU/DTU_stock_photo.jpg",
      width: 115%
    )
  )

  pagebreak()

  body
  
}