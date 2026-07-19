#let copyright(
  title: "", 
  description: "",
  authors: (), 
  date: none, 
  university: "", 
  department: "",
  department-full-title: "",
  address-i: "",
  address-ii: "",
  body) = { 
  
  set page(
    margin: auto
  )
  v(1fr)

  text(
    weight: "bold",
    title
  )

  v(1em)
  [
    #description \
    #date
  ]

  v(1em)
  text("By")
  v(-5pt)
  grid(
    gutter: 5pt,
    ..authors.map(author => author),
  )

  v(1em)
  grid(
    columns: (auto, 1fr),
    rows: (auto, auto, auto),
    gutter: 1em,
    row-gutter: 1.2em,
    [Copyright:], [Reproduction of this publication in whole or in part must include the customary bibliographic citation, including author attribution, report title, etc.],
    [Cover photo:], [Vibeke Hempler, 2012],
    [Published by:], [#department, #university, #address-i, #address-ii],
  )

  pagebreak()
  
  body
  
}
