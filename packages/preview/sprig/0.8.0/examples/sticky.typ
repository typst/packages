// Sprig 0.8.0 — sticky : le mur de post-it.
// Une leçon entière, une idée par feuille, et des flèches au feutre.
#import "@preview/sprig:0.8.0": *

#set page(width: 29.7cm, height: 21cm, margin: 0.6cm, fill: white)
#set text(font: ("New Computer Modern",), size: 8.7pt)
#set par(leading: 0.62em)

#sticky(
  [*Continuité d'une fonction numérique*],
  cols: 4,
  hub-span: 2,
  cell: 6.3,
  cell-h: 3.9,
  gap-x: 0.75,
  gap-y: 0.95,
  tilt: 1.1deg,
  fold: 45%,
  palette: "sticky",
  numbering: true,

  note(title: [Définition en un point $a$])[
    $ lim_(x -> a) f(x) = f(a) $ \
    Autrement dit : la limite en $a$ existe et elle est égale à la valeur de
    la fonction en $a$.
  ],
  note(title: [Interprétation graphique])[
    On peut tracer la courbe sans lever le crayon au voisinage de $a$ : pas
    de « trou », pas de saut, pas de rupture en $a$.
  ],
  note(title: [Continuité sur un intervalle $I$])[
    $f$ est continue sur $I$ si, et seulement si, elle est continue en tout
    point de $I$.
  ],
  note(title: [À gauche et à droite])[
    Continue à gauche en $a$ : \
    $ lim_(x -> a^-) f(x) = f(a) $ \
    Continue à droite en $a$ : \
    $ lim_(x -> a^+) f(x) = f(a) $
  ],
  note(title: [Fonctions continues usuelles])[
    • Polynômes : continues sur $RR$. \
    • Rationnelles : sur leur domaine de définition. \
    • $sqrt(x)$ : sur $[0; +oo[$. \
    • $sin$, $cos$ : sur $RR$. \
    • $e^x$ : sur $RR$ ; $ln$ : sur $]0; +oo[$.
  ],
  note(title: [Opérations])[
    Si $f$ et $g$ sont continues en $a$, alors $f + g$, $f - g$ et $f g$ le
    sont, et $f / g$ est continue en $a$ si $g(a) != 0$.
  ],
  note(title: [Composition])[
    Si $g$ est continue en $a$ et $f$ continue en $g(a)$, alors $f compose g$ est
    continue en $a$.
  ],
  note(title: [Théorème des valeurs intermédiaires])[
    Si $f$ est continue sur $[a; b]$ et si $k$ est compris entre $f(a)$ et
    $f(b)$, il existe au moins un $c in [a; b]$ tel que $f(c) = k$.
  ],
  note(title: [Une racine quelque part], col: 3, row: 2)[
    Si de plus $f(a) f(b) < 0$, alors $f$ s'annule au moins une fois : \
    $ exists c in ]a; b[ : f(c) = 0$.
  ],
)
