// rdconv — Tableaux de conversion d'unités : longueur, masse, capacité, aire, volume.
//
//   #import "lib.typ": *
//
//   #rdconv(rdplace(12, "m"), rdplace("3,45", "dam"))                       // chiffres placés
//   #rdconv(type: "mass", rdconvert(12, "g", "cg"), rdconvert(4500, "mg", "g")) // conversions
//   #rdconv(style: "rdtheme-teal", show-mult: true, rdconvert(12.3, "m", "mm"))  // style prédéfini
//   #setrdconv(decimal-sep: true)                                           // réglage global
//   #setrdconv(definir: "rouge", digit-style: (text: red))                  // style nommé
//   #rdconv(style: "rouge", rdplace(12, "m"))                               // appel du style ; une clé locale l'emporte
//   #setrdconv(reinitialiser: true)                                         // retour aux défauts
//   #rdconvtext("12.5", "km", "m")                                          // valeur convertie : "12500"
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdconv.typ": (
  rdconv, rdplace, rdconvert, rdconvemptyline, rdconvtext, setrdconv, rdtheme, rdconvdingnum, rdconvbadge,
)
