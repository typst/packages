// rdopp — Opérations posées à la française : additions, soustractions, multiplications et divisions en
// colonnes, avec retenues, zéros ajoutés, grille, mise en page Séyès et version professeur / élève.
//
//   #import "lib.typ": *
//
//   #rdopp("12.5, 3.45", sub: true)                               // soustraction posée
//   #rdopp("234, 56", mul: true, carry: true)                     // multiplication avec retenues
//   #rdopp("857, 12", div: true, precision: 0)                    // division euclidienne
//   #setrdopp(carry: true, seyes: true)                           // réglage global
//   #setrdopp(definir: "gris", zero: true, zero-style: (text: gray))   // style nommé
//   #rdopp(style: "gris", "12, 3.4", sub: true)                   // appel du style ; une clé locale l'emporte
//   #setrdopp(reinitialiser: true)                                // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdopp.typ": rdopp, setrdopp
