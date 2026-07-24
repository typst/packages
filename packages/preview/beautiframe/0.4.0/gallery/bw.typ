#import "@preview/beautiframe:0.4.0": *

#set page(width: 16cm, height: auto, margin: (x: 1cm, y: 1cm))
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[#text(size: 14pt, weight: "bold")[BW Style]]

#v(0.5em)

#preset-french-math-bw()
#beautiframe-reset-french-math()

// Théorème — prominent variant (thick box)
#theoreme(name: "Pythagore")[
  Dans tout triangle rectangle d'hypoténuse $c$ et de côtés $a$, $b$ :
  $ a^2 + b^2 = c^2 $
]

// Définition — standard variant (horizontal rule + bare content)
#definitionfr[
  Une fonction $f : RR -> RR$ est *continue en $a$* si, pour tout $epsilon > 0$, il existe $delta > 0$ tel que $|x - a| < delta$ implique $|f(x) - f(a)| < epsilon$.
]

// Propriété — boxed variant
#propriete[
  Toute fonction continue sur un segment $[a; b]$ est bornée et atteint ses bornes.
]

// Remarque — minimal variant (inline)
#remarque[
  Cette propriété est fausse sur un intervalle ouvert : $f(x) = 1/x$ est continue sur $]0 ; 1[$ mais n'est pas bornée.
]

// Exemple — standard variant
#exemplefr[
  La fonction $f(x) = x^2$ est continue sur $RR$ et $f(2) = 4$.
]

// Preuve — proof layout with QED
#preuve[
  Par le théorème de Heine, toute fonction continue sur un compact est uniformément continue.
]

// Pratique with fill space — lines
#pratique(space: "lines", space-height: 3cm)[
  Montrer que $f(x) = sqrt(x)$ est continue sur $RR_+$.
]
