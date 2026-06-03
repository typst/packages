//#import "@preview/rapport-labo-hes-so:0.1.0": *
#import "@preview/rapport-labo-hes-so:0.1.0": *


// ============================================================================
// ANNEXE.TYP - INSERTION DES ANNEXES
// ============================================================================
// Ce fichier insère les annexes du rapport

#if config.afficher-annexes == true {
  page(
    header: none,
    footer: none,
    margin: (top: 2mm, right: 2mm, bottom: 2mm, left: 2mm),
  )[
    // Page de titre ANNEXES
    #context {
      let annexes = query(figure.where(kind: "annexe"))
      if annexes.len() > 0 {
        align(center + horizon)[
          #text(size: 40pt, weight: "bold")[
            #if annexes.len() > 1 [ANNEXES] else [ANNEXE]
            #pagebreak()
          ]
        ]
      }
    }


    // Insérer vos annexes ici (exemples):
    #page(flipped: true)[
      #pdf("exemple.pdf", "exemple", debut: 1, fin: 1, etiquette: <ann:reference1>)
    ]

    #pdf("exemple.pdf", "exemple", debut: 2, fin: 3, etiquette: <ann:reference2>)
  ]
}




