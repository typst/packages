// rdsheet — Captures de feuilles de calcul (style LibreOffice Calc ou Excel).
//
//   #import "lib.typ": *
//
//   #rdsheet(select: "B2", ("Article", "Prix"), ("Bureau", "249"), ("Chaise", "89"))   // feuille avec sélection
//   #rdsheet(bar: true, select: "C2", ("Quantité", "Prix", "Total"), ("5", "12.00", "60.00"))   // barre de formule
//   #setrdsheet(theme: "excel")                                      // réglage global
//   #setrdsheet(definir: "imprime", bw: true, contrast: 0.9)         // style nommé
//   #rdsheet(style: "imprime", ("1", "2"), ("3", "4"))               // appel du style ; une clé locale l'emporte
//   #setrdsheet(reinitialiser: true)                                 // retour aux défauts
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdsheet.typ": rdsheet, setrdsheet, rdsheetsetup
