#import "@preview/uma-tfe:0.1.0": *

#set align(center)

#context [
  #set text(size: Large)
  #fakesc("Universidad de Málaga") \ 
  #v(8pt)
  #fakesc("Escuela Técnica Superior de") \ #fakesc("Ingeniería de Telecomunicación")

  #v(1.4fr) 

  #set text(size: Large)
  TRABAJO FIN DE MÁSTER

  #v(1.2fr) 

  // Title
  #set text(size: huge) 
  #set par(justify: false, leading: 0.7em)     
  #fakesc(titlename.at(here()))

  #v(1.2fr)

  // Degree
  #block(width: 62%)[
    #set text(size: Large)
    #set par(leading: 0.7em)
    #fakesc("Máster en " + titulacion.at(here()))
  ]

  #v(1.1fr) 

  // Author and date
  #align(right)[
    #set text(size: large)
    #fakesc(author.at(here())) \
    #fakesc("Málaga,")#h(0.6em)#fakesc(anno.at(here()))
  ]
]

#chapterend()
