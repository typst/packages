// Exemple d'utilisation du Position Helper
#import "@preview/coordy:0.1.0": ph

// Syntaxe simplifiée !
#show: ph("ddddddddddzzzzzzzzzz")

// === TON CONTENU NORMAL EN DESSOUS ===

= Mon Document

Voici un paragraphe de texte normal. Le point rouge se superpose par-dessus.

#lorem(50)

#figure(
  rect(width: 200pt, height: 150pt, fill: blue.lighten(80%))[
    #align(center + horizon)[Image placeholder]
  ],
  caption: [Une figure exemple]
)

#lorem(30)
