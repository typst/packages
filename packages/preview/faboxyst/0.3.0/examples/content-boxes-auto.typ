// First batch of content boxes with automatic sizing.
#import "@preview/faboxyst:0.3.0": *

#set page(paper: "a4", margin: 1.4cm)
#set text(size: 11pt)

#note[
  Première ligne. \
  Deuxième ligne.
]

#v(0.5cm)

#fabox(title: [Titre], leading: 0.5em)[
  Une fabox qui suit la largeur de son contenu.
]

#v(0.5cm)

#speech-bubble(width: auto, leading: 0.5em)[
  Une bulle qui suit son contenu.
]
