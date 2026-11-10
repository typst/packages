// rdtabnum — tableaux de numération : classes, rangs décimaux, nombres placés ou convertis par
// puissances de dix, virgule, zéros ajoutés et barrés, flèches latérales, version professeur et élève.
//
//   #import "lib.typ": *
//
//   #rdtabnum(width: 7.5cm, rdtnplace(1500), rdtnplace(42), rdtnplace("3,14"))
//   #rdtabnum(correction: true, rdtnplace(4, etoile: true), rdtnconvert("12,5", 0, 2))
//   #rdtabnum(rdtnplace(7), rdtnplace(70), rdtn-arrow(1, 2, $times 10$))
//   #setrdtabnum(width: 8cm, grid-style: (thickness: 0.8pt, paint: teal))      // réglage global
//   #setrdtabnum(definir: "ardoise", header-tikz: (fill: "gray!20"))           // style nommé
//   #rdtabnum(style: "ardoise", rdtnplace(35))                                 // appel du style
//   #setrdtabnum(reinitialiser: true)                                          // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdtabnum.typ": rdtabnum, rdtnplace, rdtnconvert, rdtnemptyline, rdtn-arrow, rdtnsurcouche, setrdtabnum
#import "src/moteur/rdtabnum.typ": rdtabnumarrowcol, rdtnpurple
