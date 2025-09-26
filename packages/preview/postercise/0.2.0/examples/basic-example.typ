// Import a theme
#import "../postercise.typ": *
#import themes.basic: *

// Set up paper dimensions and text
#set page(width: 24in, height: 18in)
#set text(size: 28pt)

// Set up colors
#show: theme.with()

// Add content
#poster-content[

  // Add title, subtitle, author, affiliation, logos
  #poster-header(
    title: [Title of Research Project:],
    subtitle: [Subtitle],
    authors: [List of Authors],
    logo-1: image("emu-logo.png")
    )

  // Include content in the footer
  #poster-footer[
    #set text(fill: white)
    _Additional information_
    ]

  // normal-box is used to create sections
  #normal-box()[
    = Background
    #lorem(20)
    ]

  // color can be overwritten
  #normal-box(color: aqua)[
    = Methods
    #lorem(20)
    $ gamma = 1/2 alpha beta^2 $
    #lorem(15)
    #figure(image("placeholder.png", width: 50%),
    caption: [_Fig. 1: Sample Figure_])
    ]

  #normal-box()[
    = Results
    #lorem(20)
    #figure(image("placeholder.png", width: 50%),
    caption: [_Fig. 2: Sample Results_])
    #lorem(20)
    #figure(table(columns: 3, 
                  rows: 2,
                  fill: white, stroke: 0.0625em,
                  [*a*], [*b*], [*c*],
                  [1], [2], [3]),
        caption: [_Table 1: Sample Table_])
    ]
    #lorem(20)

  #focus-box()[
    = Key Findings
    + #lorem(5)
    + #lorem(4)
    + #lorem(8)
    ]
  
  #normal-box()[
    = Discussion
    #lorem(30)
    ]

  // Content can also be added without boxes for more flexible formatting
  = Acknowledgements
  The authors wish to thank those providing guidance, support, and funding.

  = References
  #set text(size: 0.8em)
  + #lorem(8)
  + #lorem(12)
]
