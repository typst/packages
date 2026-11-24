// rdratio — Barres de proportion (« 2 : 3 »), rapport écrit et somme d'une liste.
//
// La barre de proportion s'appelle `rdratio` : `ratio` est un type natif de Typst.
//
//   #import "lib.typ": *
//
//   #rdratio((2, 3))                                               // barre de proportion
//   #rdratio(width: 5cm, label-above: [150 €], "1,2,3")            // légendes
//   #dratio("2:3")  #sumlist("2,3,4")                              // rapport écrit, somme
//   #setrdratio(leftcol: "yellow", rightcol: "brown")              // réglage global
//   #setrdratio(definir: "sarcelle", colframe: "teal")             // style nommé
//   #rdratio(style: "sarcelle", (1, 2))                            // appel du style ; une clé locale l'emporte
//   #setrdratio(reinitialiser: true)                               // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdratio.typ": rdratio, dratio, sumlist, setrdratio
