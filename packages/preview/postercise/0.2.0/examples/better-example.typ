// Import a theme
#import "../postercise.typ": *
#import themes.better: *

// Set up paper dimensions and text
#set page(width: 24in, height: 18in)
#set text(font: "Calibri", size: 24pt)

// Set up colors
#show: theme.with()

// Add content
#poster-content[

  // Add title, subtitle, author, affiliation, logos
  #poster-header(
    title: [Title of Research Project:],
    subtitle: [Subtitle],
    authors: [List of Authors],
    logo-1: image("placeholder.png")
    )

  // Include content in the footer
  #poster-footer[

    _Additional information_
      = Acknowledgements
    The authors wish to thank those providing guidance, support, and funding.
  
    = References
    #set text(size: 0.8em)
    + #lorem(8)
    + #lorem(12)

    #figure(image("emu-logo.png", width: 60%))
    ]

  = Research Question
  #lorem(10)

  = Methods
  #lorem(10)
  
  - #lorem(4)
  - #lorem(6)

  // A normal box can be used to highlight
  #normal-box()[
    = Results
    #lorem(10)
    
    #figure(image("placeholder.png", width: 50%),
    caption: [_Fig. 1: Sample Results_])
    ]

  // Focus-box is used for the main findings
  #focus-box()[
    = Key Findings
    #lorem(20)

    ]
  
  = Discussion
  #lorem(20)

]
