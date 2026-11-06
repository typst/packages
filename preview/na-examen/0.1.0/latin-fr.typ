// Modèle latin (LTR) : devoir de mathématiques en français
#import "../lib.typ": *

#show: examen.with(
  lang: "fr",                              // ou : #show: examen-latin.with(...)
  school: "Lycée Ibn Khaldoun",
  year: "2026-2027",
  level: "1re année secondaire — tronc commun sciences et technologie",
  term: "Premier trimestre",
  kind: "Devoirs du",                      // « Devoirs du Premier trimestre » ; none pour supprimer
  subject: "Mathématiques",
  duration: "2 h",
  code: "devoir 1 trimestre 1-1AS-typst",
)

#exercise(points: 8)[
  *I.* Soient les nombres $A$ et $B$ tels que :
  $A = 27300$ et $B = (2 times 3)^3 times 27 times 5$

  #q[1] Décomposer $A$ et $B$ en produit de facteurs premiers.

  #q[2] Calculer $"PPCM"(A; B)$ et $"PGCD"(A; B)$.

  *II.* Écrire $a = 0","underline(233766)$ sous forme de fraction irréductible.
]

#exercise(points: 1)[
  Un exercice sur un point : le titre affiche « (01 point) ».
]

#exercise(points: 11)[
  #part(points: 4)[
    On considère le nombre réel $X = sqrt(7 sqrt(7 sqrt(7 dots.c)))$.

    Déterminer la valeur exacte de $X$.
  ]

  #part(points: 7)[
    Soient $a$ et $b$ deux réels positifs tels que $a < b$, $a + b = 7$ et $a b = 12$.

    #q[1] Calculer $sqrt(a) + sqrt(b)$ et $sqrt(a) - sqrt(b)$.

    #q[2] En déduire les valeurs de $a$ et de $b$.
  ]
]

// Titre manuel à la place de la numérotation automatique
#exercise(points: "04 points", title: [Problème])[
  Énoncé du problème.
]
