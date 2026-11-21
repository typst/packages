// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Résolution approchée d'une équation f(x) = k par dichotomie, d'après
// \ResolutionApprochee du paquet LaTeX ProfLycee (Cédric Pierquet, §7 de sa
// documentation 4.02b).
//
//   #let s = resolution-approchee(x => calc.pow(x, 3) - 2 * x * x - x - 1, k: 2, intervalle: (0, 10))
//   $x_0 approx #s.defaut$ par défaut, $x_0 approx #s.exces$ par excès,
//   $x_0 approx #s.approchee$ arrondi à $10^(-2)$.
//
// L'équation est donnée par la FONCTION f (fonction Typst) et le second
// membre k ; le résultat est un dictionnaire (au lieu des macros
// \masolutiond, \masolutione, \masolutiona de ProfLycee) :
//
//   defaut     valeur approchée par défaut, formatée (2,75) ;
//   exces      valeur approchée par excès, formatée (2,76) ;
//   approchee  valeur arrondie, formatée (2,76) ;
//   valeur     la solution, flottant précis à 1e-12 près (pas dans ProfLycee) ;
//   et ce qu'il faut aux écrans NumWorks (numworks.typ) : f, k, intervalle,
//   precision, variable.
//
// Clés (entre parenthèses : équivalent ProfLycee, puis défaut) :
//
//   intervalle  (Intervalle)  intervalle (a, b) de recherche, obligatoire ;
//                             f(a) – k et f(b) – k de signes contraires
//                             (ou nuls) ........................... —
//   k           (« = k » de l'équation)  second membre ............ 0
//   precision   (Precision)   nombre de décimales .................. 2
//   variable    (Variable)    nom de la variable, pour les écrans
//                             NumWorks seulement (la fonction Typst a
//                             déjà la sienne) ..................... "x"
//
// Les valeurs formatées gardent toutes `precision` décimales (2,70 et non
// 2,7), comme \num[minimum-decimal-digits=…] dans la doc de ProfLycee.
#import "../outils.typ": _decimal

#let resolution-approchee(f, intervalle: none, k: 0, precision: 2, variable: "x") = {
  assert(
    type(intervalle) == array and intervalle.len() == 2 and intervalle.first() < intervalle.last(),
    message: "resolution-approchee : clé intervalle: (a, b) obligatoire, avec a < b",
  )
  assert(type(precision) == int and precision >= 0, message: "resolution-approchee : precision entière positive")
  let g(x) = f(x) - k
  let (a, b) = intervalle.map(float)
  let (ga, gb) = (g(a), g(b))
  assert(
    ga * gb <= 0,
    message: "resolution-approchee : f(a) – k et f(b) – k doivent être de signes contraires sur l'intervalle",
  )
  // dichotomie (boucle `for` : Typst limite un `while` à 10 000 tours) ;
  // 100 étapes suffisent largement à la précision des flottants
  let x0 = if ga == 0 { a } else if gb == 0 { b } else {
    for _ in range(100) {
      let m = (a + b) / 2
      let gm = g(m)
      if gm == 0 or b - a < 1e-13 * calc.max(1, calc.abs(m)) { (a, b) = (m, m); break }
      if (ga < 0) == (gm < 0) { (a, ga) = (m, gm) } else { b = m }
    }
    (a + b) / 2
  }
  // valeurs approchées : entiers N / 10^precision, formatés exactement
  let echelle = calc.pow(10.0, precision)
  let n-defaut = calc.floor(x0 * echelle)
  let n-arrondi = calc.round(x0 * echelle)
  let format(n) = _decimal(n / echelle, precision, false)
  (
    defaut: format(n-defaut),
    exces: format(n-defaut + 1),
    approchee: format(n-arrondi),
    valeur: x0,
    f: f,
    k: k,
    intervalle: intervalle,
    precision: precision,
    variable: variable,
  )
}
