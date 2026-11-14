#import "../helpers.typ": *

//Abstract of thesis
#let abstract(vars) = {
  Large[*Abstrakt*]
  parbreak()

  [Text abstraktu v češtině]
  v(4mm)

  Large[*Klíčová slova* \ ]
  parbreak()

  //Doporučeno 3-5 klíčových slov
  vars.Keywords

  pagebreak()

  Large[*Abstract*]
  parbreak()

  [Abstract in english]
  v(4mm)

  Large[*Keywords*]
  parbreak()

  //3-5 key words recommended
  vars.KeywordsEN

  pagebreak()
  }