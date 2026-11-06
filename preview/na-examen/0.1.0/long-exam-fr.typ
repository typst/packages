// Test : plusieurs pages en français (pied de page « Page X sur Y ») et titres jamais seuls en bas de page
#import "../lib.typ": *

#show: examen.with(lang: "fr", code: "long test fr", duration: "3 h")

#for i in range(1, 7) [
  #exercise(points: 3)[
    #for j in range(1, 9) [
      #q[#j] Question numéro #j de l’exercice #i : un texte assez long pour remplir la page et tester le passage d’une page à l’autre.

    ]
  ]
]
