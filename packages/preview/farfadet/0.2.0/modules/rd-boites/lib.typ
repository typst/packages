// rdboites — Boîtes de cours et d'activités sous le module `rd`.
//
//   #import "lib.typ": *
//
//   #rd.zone[Titre][Contenu]                                 // une boîte (clés de tcolorbox)
//   #setrdboites(colframe: red)                              // réglage global (toutes les boîtes qui ont la clé)
//   #setrdboites(pour: "zone", arc: 0pt)                     // réglage d'une seule boîte (ou d'un tableau de boîtes)
//   #setrdboites(definir: "sobre", arc: 0pt, boxrule: 0.4pt) // style nommé
//   #rd.zone(style: "sobre")[Titre][Contenu]                 // appel du style ; une clé locale l'emporte
//   #setrdboites(reinitialiser: true)                        // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Les boîtes : un module, `rd.zone[…]`…
#import "src/rd-paresseux.typ" as rd

// Personnalisation (mécanisme générique de farfadet-socle)
#let cles-rd(..a) = { import "src/reglages.typ": cles-rd as _f; _f(..a) }
#let setrdboites(..a) = { import "src/reglages.typ": setrdboites as _f; _f(..a) }
