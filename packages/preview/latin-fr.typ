// Corrigé en français : même package, `lang: "fr"` (LTR), virgule décimale
#import "../lib.typ": *

#show: correction.with(
  lang: "fr",
  school: "Lycée Ibn Khaldoun",
  level: "1re année secondaire",
  term: "Premier trimestre",
  subject: "Mathématiques",
  duration: "2 h",
  code: "corrige-devoir-1-1AS",
  decimal: ",",
)

#exercise[
  #q[1] On a $A = 2^2 times 3 times 5^2 times 7 times 13$ #mk(10)

  #q[2] $"PGCD"(A; B) = 60$ #mk(5)
]

#exercise[
  #part[
    #q[1] Calcul de $x$ : $x = 3$ #mk(2)
  ]
  #part[
    #q[1] Démonstration par récurrence. #mk(1, 0.5)

    #q[2] Conclusion. #mk(1.5)
  ]
]

#summary(total: 20)
