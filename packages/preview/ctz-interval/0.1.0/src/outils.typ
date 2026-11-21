// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Outils communs (non exportés).


// #_nombre arrondit les flottants à 4 chiffres après la virgule
//  #calc.round arrondit un flottant à un certain nb de chiffres après la virgule

#let _nombre(x) = {
  // arrondit la partie décimale de v à 4 chiffres max
  let v = if type(x) == float { calc.round(x, digits: 4) } else { x }
  // si v = 3.0, alors on renvoie 3
  if type(v) == float and v == calc.round(v) { v = int(v) }
  // formate en français l'écriture du réel
  let s = str(calc.abs(v)).replace(".", ",")
  if v < 0 { $-#s$ } else { $#s$ }
}
 
// Renvoie true si une borne est infini (noté par *), false sinon
#let _infini(borne) = borne == none or borne == "*"
 

// Renvoie vrai pour un nombre (entier, flottant ou décimal).
#let _est-nombre(x) = type(x) in (int, float, decimal)
