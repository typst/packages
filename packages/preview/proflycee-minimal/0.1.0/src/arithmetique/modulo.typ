// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Réduction modulo, d'après \ResteMod et \QuoMod du paquet LaTeX ProfLycee
// (Cédric Pierquet, §52 de sa documentation).
//
// Commandes :
//
//   #reste-mod(a, n, clés)   -> reste de a modulo n : le plus petit positif,
//                               ou le plus grand négatif (clé negatif) ;
//   #quo-mod(a, n)           -> quotient correspondant (division euclidienne) ;
//   modulo(n)                -> la fonction a => reste-mod(a, n) (pas dans
//                               ProfLycee), à fabriquer une fois pour toutes :
//
//   #let m26 = modulo(26)
//   $1234 equiv #m26(1234) space [26] equiv #m26(1234, negatif: true) space [26]$
//
// Clés de reste-mod (et de la fonction obtenue par modulo) :
//
//   negatif    (version étoilée *)   plus grand reste négatif ............ false
//   puissance  (pas dans ProfLycee)  reste de a^puissance, calculé par
//                                    exponentiation modulaire (7^50 dépasse
//                                    les entiers de Typst, pas 7^50 mod 8) . none
//
// Exemples :
//   $98 equiv #reste-mod(98, 9) space [9]$, $98 equiv #reste-mod(98, 9, negatif: true) space [9]$
//   $7^50 equiv #reste-mod(7, 8, puissance: 50) space [8]$
#import "../outils.typ": _nombre

// a^e modulo n, par carrés successifs (reste dans [0 ; |n|[).
#let _puissance-mod(a, e, n) = {
  let (resultat, base) = (1, calc.rem-euclid(a, n))
  while e > 0 {
    if calc.odd(e) { resultat = calc.rem-euclid(resultat * base, n) }
    base = calc.rem-euclid(base * base, n)
    e = calc.quo(e, 2)
  }
  calc.rem-euclid(resultat, n)
}

#let modulo(n) = {
  assert(type(n) == int and n != 0, message: "modulo : n doit être un entier non nul")
  (a, negatif: false, puissance: none) => {
    let r = if puissance == none { calc.rem-euclid(a, n) } else { _puissance-mod(a, puissance, n) }
    _nombre(if negatif and r != 0 { r - calc.abs(n) } else { r })
  }
}

#let reste-mod(a, n, ..cles) = modulo(n)(a, ..cles)

#let quo-mod(a, n) = _nombre(calc.div-euclid(a, n))
