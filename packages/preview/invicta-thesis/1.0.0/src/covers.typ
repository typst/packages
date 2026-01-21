// Cover page and committee page functions for Invicta thesis

// Helper function for cover page
#let make-cover(config) = {
  set page(numbering: none)
  set align(center)
  
  
  v(0.5em)
  text(size: 12.5pt, weight: "bold")[
    FACULDADE DE ENGENHARIA DA UNIVERSIDADE DO PORTO
  ]
  
  v(2cm)
  
  // Title
  text(size: 18pt, weight: "bold")[
    #config.title
  ]
  
  v(1cm)
  
  // Author
  text(size: 14pt, weight: "bold")[
    #config.author
  ]

  v(6cm)
  
  image("../template/figures/uporto-feup.png", width: 8cm)
  v(1cm)
  
  if config.additional-front-text != none {
    v(0.5em)
    text(size: 12pt)[
      #config.additional-front-text
    ]
  }
  
  v(1fr)
  
  // Degree
  text(size: 12pt)[
    #config.degree
  ]
  
  v(1cm)
  
  // Supervisor
  text(size: 12pt)[
    Supervisor: #config.supervisor
  ]
  
  if config.second-supervisor != none {
    parbreak()
    text(size: 12pt)[
      Second Supervisor: #config.second-supervisor
    ]
  }
  
  v(1cm)
  
  // Date
  let date-text = if config.thesis-date != none {
    config.thesis-date
  } else {
    datetime.today().display("[month repr:long] [day], [year]")
  }
  text(size: 12pt)[
    #date-text
  ]

  pagebreak()

  if config.copyright-notice != none {
      place(
        bottom + center, 
        text(size: 10pt)[
          © #config.copyright-notice
        ]
      )
  }
  
  if config.signature {
    v(1cm)
    line(length: 5cm)
    text(size: 10pt)[Signature]
  }
  
  pagebreak()
}

// Helper function for committee page
#let make-committee-page(config) = {
  if config.committee-text != none and config.committee-members.len() > 0 {
    // Date
    let date-text = if config.thesis-date != none {
      config.thesis-date
    } else {
      datetime.today().display("[month repr:long] [day], [year]")
    }
    
    set page(numbering: none)

    // Centered title, author, and degree at top
    set align(center)
    v(2cm)
    
    text(size: 18pt, weight: "bold")[
      #config.title
    ]
    
    v(1cm)
    
    text(size: 14pt, weight: "bold")[
      #config.author
    ]
    
    v(0.5cm)
    
    text(size: 12pt)[
      #config.degree
    ]
    
    v(1fr)
    
    // Committee information at bottom left
    set align(left)
    
    v(4cm)
    
    block(
        text(size: 14pt)[
        #config.committee-text
        ]
    )
    
    v(0.3cm)

    for member in config.committee-members {
      text(size: 12pt)[
        #member.role: #member.name
      ]
      linebreak()
    }


    v(0.3cm)
    
    block(
        text(size: 12pt)[
            #date-text
        ]
    )
    
    pagebreak()
  }
}
