#import "@preview/beautiframe:0.4.0": *

#set page(width: 16cm, height: auto, margin: (x: 1.5cm, y: 1cm))
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[#text(size: 14pt, weight: "bold")[Cours Style]]

#v(0.5em)

#preset-french-math()
#beautiframe-reset-french-math()

// Théorème — standard with accent border
#theoreme(name: "Valeurs intermédiaires")[
  Si $f$ est continue sur $[a ; b]$ et si $y$ est compris entre $f(a)$ et $f(b)$, alors il existe $c in [a ; b]$ tel que $f(c) = y$.
]

// Définition
#definitionfr[
  Une suite $(u_n)$ *converge* vers $ell in RR$ si, pour tout $epsilon > 0$, il existe $N in NN$ tel que, pour tout $n >= N$, $|u_n - ell| < epsilon$.
]

// Propriété
#propriete[
  Toute suite monotone et bornée converge.
]

// Remarque — minimal
#remarque[
  La réciproque est fausse : une suite convergente n'est pas nécessairement monotone.
]

// Exemple
#exemplefr[
  La suite $u_n = 1/n$ est décroissante et minorée par $0$, donc elle converge. Sa limite est $0$.
]

// Preuve
#preuve[
  Soit $epsilon > 0$. Posons $N = floor(1/epsilon) + 1$. Pour $n >= N$, on a $1/n <= 1/N < epsilon$, donc $|u_n - 0| = 1/n < epsilon$.
]
