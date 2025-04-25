#let title-page(title, authors, uni-info , date, img) = {
  /*
  grid(
    columns:  (1fr, 4fr, 1fr),
    rect(width: 100%, stroke: none)[
     // #image("assets/logo.svg", width: 200%)
    ],
    rect(width: 100%, stroke: none),
    rect(width: 100%, stroke: none)[
     #image("assets/modul_logo_small.png", width: 100%)
    ]
  )
  */
  
  v(1.5cm)
  
// Image - university logo
  if img != none [
    #v(3em)
    #align(center)[
      #img
    ]
    #v(2em)
  ] else [
    #v(3em)
  ]
  
  v(.5em)

  // Department
  align(center)[
     #if uni-info.department != none [
      #uni-info.department
      #v(-.5em)
    ]
  ]

  align(center)[
    Faculty of 
    #if uni-info.faculty != none [
      #uni-info.faculty
      #v(.5em)
    ]
  ]

  align(center, line(length: 85%, stroke: 0.5pt))
  
  v(.5em)
  
  align(center)[
    
    #v(-.5em)
    
    #if uni-info.university != none [
      #uni-info.university
      #v(.5em)
    ]
    #date
  ]

  v(3em)

  // Title 
  align(center)[
    #text(25pt, weight: "extrabold")[
      #block(width: 85%)[
        #title
      ]
    ]
  ]

v(6em)
  
// Authors
  align(center)[ 
    #grid(
      columns: (1fr,) * authors.len(),
      ..authors
    )
  ]

  v(6em)

  align(center, line(length: 85%, stroke: 0.5pt))
  v(1em)

  align(center)[
    Academic Year
    #uni-info.academic_year
    
  ]
}
