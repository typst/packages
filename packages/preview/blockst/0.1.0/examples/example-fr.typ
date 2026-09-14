#import "@preview/blockst:0.1.0": blockst, scratch

#set page(height: auto, width: auto, margin: 1cm)
#set text(font: "Helvetica Neue", lang: "fr")

= Test blocs français

#blockst[
  #import scratch.fr: *

  #quand-drapeau[
    #mettre-variable("score", 0)
    #répéter(val: 5)[
      #avancer(pas: 10)
      // Single statement: pass the call directly — no content block needed.
      #si-alors-sinon(
        toucher-objet("bord"),
        tourner-à-droite(degres: 180),
        ajouter-variable("score", 1),
      )
    ]
    #dire-pendant(saisie-perso("score"), secondes: 2)
  ]
]

#blockst[
  #import scratch.fr: *

  #quand-drapeau[
    // Multiple statements branch: wrap statements in a content block.
    #si-alors-sinon(
      intersection(
        supérieur(souris-x(), 0),
        inférieur(souris-y(), 100),
      ),
      [#dire-pendant("Souris dans la zone!", secondes: 2)
       #changer-costume("costume2")
       #ajouter-effet("couleur", valeur: 10)
      ],
      dire-pendant("En dehors", secondes: 2),
    )
  ]
]

#blockst[
  #import scratch.fr: *

  #let sauter = bloc-perso("sauter", (name: "n"), "fois")

  #définir(sauter)[
    #répéter(val: parameter("n"))[
      #ajouter-y(y: 10)
    ]
  ]

  #quand-drapeau[
    #sauter(5)
  ]
]
