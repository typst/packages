#let calc-elem-size(elem, sizes: (12pt, 10pt, 8pt, 6pt,4pt)) = {
  let size = 3pt
  if elem.level - 2 < sizes.len() {
    size = sizes.at(elem.level - 2)
  }
  return size
}

#let make-title(title, subtitle, author) = [
  #place(center + horizon, dy: -10em)[
    #text(size: 30pt)[
      #title
    ]
    
    #text(size: 15pt)[
      #subtitle
    ]
  ]

  #place(center + bottom)[
    #text(size: 20pt)[
      #author
    ]
  ]

  #pagebreak()
]

#let make-foreword(title, body) = [
  #set align(center)
  #text(size: 25pt)[
    #title
  ]
  
  #set align(center)
  
  #body
  
  #pagebreak()
]




