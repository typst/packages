// rdarithm — Décompositions en facteurs premiers, diviseurs, PGCD et PPCM, fractions irréductibles.
//
// `decomp-fp(mise-en-page:)` choisit la présentation de la décomposition ; `pgcd()` et `ppcm()` appelés
// sans argument s'écrivent comme des opérateurs (PGCD, PPCM).
//
//   #import "lib.typ": *
//
//   #liste-fp(210)  #decomp-fp(126)  #pgcd(60, 75, etoile: true)     // écritures en ligne
//   #decomp-fp(mise-en-page: "arbre", 126)                          // "produit", "etapes", "arbre", "tableau"
//   #tab-pgcd(420, 126)  #row-pgcd(420, 126)  #decomp-frac(105, 273)  // figures
//   #setrdarithm(colors: ("red", "green"))                         // réglage global
//   #setrdarithm(definir: "vert", cell-style: (fill: "green!15"))  // style nommé
//   #decomp-fp(mise-en-page: "arbre", style: "vert", 105)           // appel du style ; une clé locale l'emporte
//   #setrdarithm(reinitialiser: true)                              // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdarithm.typ": (
  setrdarithm, liste-fp, decomp-fp, liste-diviseurs, tab-diviseurs, pgcd, ppcm, tab-pgcd, row-pgcd, decomp-frac, fracirr,
  dfracirr,
)
