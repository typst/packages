// rdarithm — Décompositions en facteurs premiers, diviseurs, PGCD et PPCM, fractions irréductibles.
//
// `DecompFP(mise-en-page:)` choisit la présentation de la décomposition ; `pgcd()` et `ppcm()` appelés
// sans argument s'écrivent comme des opérateurs (PGCD, PPCM).
//
//   #import "lib.typ": *
//
//   #ListeFP(210)  #DecompFP(126)  #pgcd(60, 75, etoile: true)     // écritures en ligne
//   #DecompFP(mise-en-page: "arbre", 126)                          // "produit", "etapes", "arbre", "tableau"
//   #TabPGCD(420, 126)  #RowPGCD(420, 126)  #DecompFrac(105, 273)  // figures
//   #setrdarithm(colors: ("red", "green"))                         // réglage global
//   #setrdarithm(definir: "vert", cell-style: (fill: "green!15"))  // style nommé
//   #DecompFP(mise-en-page: "arbre", style: "vert", 105)           // appel du style ; une clé locale l'emporte
//   #setrdarithm(reinitialiser: true)                              // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets bfcours-*)
#import "interne.typ"

#import "src/rdarithm.typ": (
  setrdarithm, ListeFP, DecompFP, ListeDiviseurs, TabDiviseurs, pgcd, ppcm, TabPGCD, RowPGCD, DecompFrac, fracirr,
  dfracirr,
)
