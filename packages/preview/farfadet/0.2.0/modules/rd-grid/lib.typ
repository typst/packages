// rdgrid — Grilles de triangles équilatéraux, d'hexagones, d'hexagones tournés et isométriques.
//
// La clé `type:` choisit la forme de la grille : "equi", "hexa", "rhexa" ou "iso".
//
//   #import "lib.typ": *
//
//   #rdgrid(8, 4)                                                  // triangles (type: "equi", défaut)
//   #rdgrid(type: "hexa", width: 0.5, 6, 3)                        // hexagones ("hexa", "rhexa", "iso")
//   #setrdgrid(scope-style: (draw: "blue!50"))                     // réglage global
//   #setrdgrid(pour: "hexa", width: 0.35)                          // réglage d'un seul type
//   #setrdgrid(definir: "pointe", only-dot: true)                  // style nommé
//   #rdgrid(style: "pointe", 8, 3)                                 // appel du style ; une clé locale l'emporte
//   #setrdgrid(reinitialiser: true)                                // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdgrid.typ": rdgrid, setrdgrid
