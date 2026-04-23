#import "@preview/glossarium:0.5.10": make-glossary, print-glossary, register-glossary
#show: make-glossary
#import "../template/src/settings/glossaire.typ": mes-acronymes
#import "../template/src/settings/name.typ": *

// ============================================================================
// 2-LAYOUT.TYP - CONTENU FINAL (Bibliographie, Figures, Annexes, Glossaire)
// ============================================================================
// Ce fichier gère l'affichage des éléments finaux du document

// FONCTION UTILITAIRE: Insérer une annexe (PDF/Figure)
#let pdf(nom_fichier, titre, debut: 1, fin: 1, etiquette: none) = {
  let chemin = "../template/src/assets/PDF/" + nom_fichier
  let fig = figure(
    image(chemin, page: debut, width: 100%),
    caption: titre,
    kind: "annexe",
    supplement: [Annexe],
    numbering: "A",
    outlined: true,
  )
  [
    #show figure.where(kind: "annexe"): it => it.body
    #if etiquette != none [
      #fig #etiquette
    ] else [
      #fig
    ]
  ]
  if fin > debut {
    for p in range(debut + 1, fin + 1) {
      image(chemin, page: p, width: 100%)
    }
  }
}

// Séparateur de contenu si nécessaire

// TABLE DES ILLUSTRATIONS
#context {
  let images = query(figure.where(kind: image))

  if (
    config.afficher-annexes == true
      or config.afficher-bibliographie == true
      or config.afficher-glossaire == true
      or images.len() > 0
  ) {
    pagebreak()
  }


  if images.len() > 0 {
    outline(
      title: "Table des illustrations",
      target: figure.where(kind: image),
      indent: auto,
    )
  }
}

// BIBLIOGRAPHIE
#if config.afficher-bibliographie == true {
  bibliography(
    "../template/src/settings/refs.bib",
    title: "Bibliographie",
  )
}

// GLOSSAIRE
#if config.afficher-glossaire == true {
  heading(level: 1, numbering: none)[Glossaire]
  set figure(outlined: false)
  print-glossary(mes-acronymes)
}
#label("fin_rapport"),
// TABLE DES ANNEXES
#context {
  let annexes = query(figure.where(kind: "annexe"))
  if annexes.len() > 0 {
    heading(level: 1, numbering: none)[Table des annexes]
    outline(
      title: none,
      target: figure.where(kind: "annexe"),
      indent: auto,
    )
  }
}



















