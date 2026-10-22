// Document de cours farfadet.
// Les polices (Erewhon, voir le README) sont facultatives : sans elles, Typst utilise Libertinus Serif
// et New Computer Modern Math, intégrées.
// Tous les réglages possibles : voir la documentation PDF (clés de `modele("cours", …)`).

#import "@preview/farfadet:0.2.0": *

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

#definition[Notion][Énoncé de la définition.]

#propriete[Nom][Énoncé de la propriété.]

#exemple[Un exemple][Corps de l'exemple.]

= Deuxième section

#methode[Titre][Étapes de la méthode.]
