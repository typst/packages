// Document de cours bfcours-typst.
// Les polices (Erewhon, voir le README) sont facultatives : sans elles, Typst utilise Libertinus Serif
// et New Computer Modern Math, intégrées.
// Tous les réglages possibles : voir la documentation PDF (clés de `modele("cours", …)`).

#import "@preview/bfcours:0.1.0": *

#show: modele(
  "cours",
  niveau: "2nde", // 6e, 5e, 4e, 3e, 2nde, 1re, Tle, ou un texte libre
  theme: [Titre du chapitre],
  type-document: "cours", // cours, exercices, activite, fiche, evaluation
  cycle: [Lycée],
  etablissement: [Établissement],
  correction: true, // true : version professeur ; false : version élève
  sommaire: false,
)

= Première section

#Definition[Notion][Énoncé de la définition.]

#Propriete[Nom][Énoncé de la propriété.]

#Exemple[Un exemple][Corps de l'exemple.]

= Deuxième section

#Methode[Titre][Étapes de la méthode.]
