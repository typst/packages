#import "jurz.typ": *
#import "@preview/chic-hdr:0.4.0": *

#show: chic.with(
  chic-footer(
    // left-side: strong(
    //     link("mailto:admin@chic.hdr", "admin@chic.hdr")
    // ),
    center-side: chic-page-number()
  ),
  chic-header(
    // left-side: emph[jurz Demo],
    // right-side: counter("rz").at(here())
  ),
  chic-separator(1pt),
  // chic-offset(7pt),
  chic-height(1.5cm)
)
#set page(paper: "din-d6", fill: white, margin: (inside: 2em, outside: 4em))
#set par(justify: true)


#v(1fr)
#align(center)[
  = jurz Demo
  
  Now with auto references like "@abc".

  Zuri Klaschka

  \

  *On the package regsitry under*
  
  ```typst
  #import "@preview/jurz:0.1.0": *
  ```
]
#v(1fr)

#pagebreak(to: "even")

#show: init-jurz.with(
  gap: 1em,
  two-sided: true
)

#rz #lorem(50)

#lorem(20)

#rz<abc> #lorem(30)

#rz #lorem(40)

#rz #lorem(50)

#lorem(20)

#rz #lorem(24)

Fur further information, look at @abc.
