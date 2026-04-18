#import "../SETUP/META.typ": META
#import "../SETUP/CONFIG.typ": resized, scaled
#import "../SETUP/ELEMENTS.typ": ELEM

#page(..ELEM.page.half-title)[
  #set par(..ELEM.par.bare)
  #v(15mm)
  #align(center)[
    #block(..ELEM.block.half-title)[
      #set text(..ELEM.text.half-title)
      #META.title
      #v(15mm)
      #set text(size: scaled(-3) * 1em)
      #META.subtitle
    ]
  ]
  #v(1fr)
  #align(center)[
    #block(..ELEM.block.half-title)[
      #set text(..ELEM.text.half-title)
      #set text(size: scaled(-5) * 1em)
      #META.auth
    ]
  ]
  #v(15mm)
]
