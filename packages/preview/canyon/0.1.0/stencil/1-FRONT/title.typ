#import "../SETUP/META.typ": META
#import "../SETUP/CONFIG.typ": resized, scaled
#import "../SETUP/ELEMENTS.typ": ELEM

#page(..ELEM.page.title)[
  #set par(..ELEM.par.bare)
  #set text(..ELEM.text.normal)
  #v(15mm)
  #align(center)[
    #block(..ELEM.block.title)[
      #set text(..ELEM.text.title)
      #META.title
      #v(15mm)
      #set text(size: scaled(-3) * 1em)
      #META.subtitle
    ]
  ]
  #v(2fr)
  #align(center)[
    #block(..ELEM.block.title)[
      #set text(..ELEM.text.title)
      #set text(size: scaled(-5) * 1em)
      #META.auth
    ]
  ]
  #v(2fr)
  #set text(..ELEM.text.title, weight: "medium")
  #set text(size: scaled(-6) * 1em)
  #align(left)[
    #META.address.long
  ]
  #v(1fr)
  #align(center)[
    #META.date.display()
  ]
  #v(15mm)
]
