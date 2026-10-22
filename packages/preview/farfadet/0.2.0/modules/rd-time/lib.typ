// rdtime — Durées posées (additions et soustractions en colonnes, avec retenues et cases barrées).
//
//   #import "lib.typ": *
//
//   #rdtime("2h37min", "3h49min")                                  // addition posée
//   #rdtime(sub: true, "5h27min38s", "2h19min46s")                 // soustraction
//   #setrdtime(matrix: (fill: "blue!8"))                           // réglage global
//   #setrdtime(definir: "rouge", result: (text: red))              // style nommé
//   #rdtime(style: "rouge", "1h45min", "2h30min")                  // appel du style ; une clé locale l'emporte
//   #setrdtime(reinitialiser: true)                                // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdtime.typ": rdtime, setrdtime
