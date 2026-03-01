#import "@preview/polylux:0.4.0": *
#import "@preview/helios-polylux:0.1.0": *

#show: setup

// There is no specific function to create a cover slide for the
// presentation. Here is an example for using standard Typst
// functionality to this end:
#slide[
  #set page(header: none, footer: none)
  #set text(stretch: 50%)
  #set par(spacing: 1em)
  #show: pad.with(top: 10%, left: 5%, bottom: 10%, right: 5%)

  #text(size: 1.5em, weight: "bold", stretch: 50%)[
    Helios presentation theme
  ]

  #text(size: 1em, weight: "medium", stretch: 50%)[
    A minimal theme for academic presentations using Typst and Polylux
  ]

  #v(5fr)
  #text(weight: "regular", size: 0.75em)[
    #grid(columns: (1fr, 1fr, 1fr),
      text(weight: "medium", upper[Presenting author#super[1]]),
      text[#upper[Second author]#super[2]],
      text[#upper[Third author]#super[1,2]], 
    )
  ]

  #v(2fr)

  #text(style: "normal", size: 0.75em)[
  #super[1]First and third author affilitation\
  #super[2]Second and third author affiliation
  ]

  #v(5fr)

  #text(size: 0.85em, weight: "medium")[Scientific conference] \
  #text(size: 0.85em)[Soleil, #datetime.today().display()]

]

#img-slide(
  image("img_helios_example.jpg"), 
  invert: true,
  slide-fill: black
)[
  #place(bottom+right, text(size: 0.5em)[Image: NASA/Goddard/SDO])
]


#slide[
  = Overview

  #set text(size: 1.25em)

  #outline
]


#make-section[Introduction]

#slide[
  = Content slide

  == Schwarzschild black hole

  $
  (d s)^(2) = 
    - (1 - frac(2M, r)) thin (d t)^(2) + frac(1, (1 - frac(2M , r))) thin 
    (d r)^(2) + r^(2) thin (d Omega)^(2)
  $

  _Additional information_: #it[https://en.wikipedia.org/wiki/Schwarzschild_metric]

  == Sections and Slide numbering

  - Opening a new section will automatically register the section title
    in the footer.
  - First level headers correspond to slide titles that are placed in
    the header.
  - Slide numbers are provided by default on content slides but not on
    section slides or image slides.

]

#slide[
  = Hypotheses

  #grid(columns: (1fr, 1fr), gutter: 2em)[
    #hypothesis[
      H#sub[0] -- An uninteresting null hypothesis
    ][
      #lorem(25)
    ]
  ][
    #hypothesis(accent: rgb("#099D72"))[
      H#sub[1] -- An interesting hypothesis
    ][
      #lorem(25)
    ]

  ]

]

#make-section[Methods]

#slide[
  = Code

  A `Julia` function to obtain the _Fibonacci_ sequence recursively:

  ```julia
  function fib(n)
    if n <= 1 return 1 end
    return fib(n - 1) + fib(n - 2)
  end

  fib(13)
  ```
]

#make-section[Results]

#slide[
  #show: invert-slide

  = Inverted content slide

  #grid(columns: (1fr, 1fr), gutter: 4em)[
    #image("img_helios_example.jpg")
  ][
    The foreground and background colours can generally be inverted with `#show: invert-slide`.
  ]

]

#make-section[Discussion]


#slide[
  #show: focus
  *A particularly important aspect*

  Focus slides can be used to _emphasize_ a short but important message.
]


#slide[
  #show: focus
  #text(size: 2.25em)[Thank you !]

  #text(size: 0.9em)[your.name\@domain.com]
]


