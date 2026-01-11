#import "@preview/volt-internship-ensea:0.2.0": abstract-config

#let abstract() = [
  #abstract-config(language: "FRENCH")[
    #lorem(70)

    #underline()[*Mots clés*] : #lorem(5)
  ]

  #v(1.5em + 1.5em)

  #abstract-config(language: "ENGLISH")[
    #lorem(70)

    #underline()[*Keywords*]: #lorem(5)
  ]
]

