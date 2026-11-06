#let umfds(
  title: "",
  authors: (),
  date: none,
  abstract: none,
  bibliography: none,
  lang: "en",
  body
) = {
  set heading(numbering: "1.1   ")
  show heading.where(level: 1): set text(weight: "medium", size: 1em)
  set page(paper: "a4", numbering: "1")
  set par(justify: true, first-line-indent: 1em)
  show par: set block(spacing: 0.65em)
  set text(
    lang: lang,
  )
  
  grid(
    columns:  (1fr, 4fr, 1fr),
    rect(width: 100%, stroke: none)[
      #image("assets/um.png", width: 100%)
    ],
    rect(width: 100%, stroke: none),
    rect(width: 100%, stroke: none)[
      #image("assets/fds.png", width: 100%)
    ]
  )
  
  v(1cm)

  align(center)[
    #text(17pt)[
      #block(width: 85%)[
        #title
      ]
    ]
  ]

  v(.5em)
  
  align(center)[ 
    #grid(
      columns: (1fr,) * authors.len(),
      ..authors
    )
  ]

  v(.5em)
  
  align(center)[
    #if lang == "en" [
      Faculty of Sciences
    
      University of Montpellier
    ] else [
      Faculté des Sciences
    
      Université de Montpellier
    ]
    
    #v(.5em)

    #date
  ]
  
  v(5em)

  if abstract != [] [
    #align(center)[
      #block(width: 85%)[
        #if lang == "en" [
          *Abstract*
        ] else [
          *Résumé*
        ]
        #align(left)[
          #abstract
        ]
      ]
    ]
  ]
  
  pagebreak()
  
  body

  pagebreak()

  bibliography
}
