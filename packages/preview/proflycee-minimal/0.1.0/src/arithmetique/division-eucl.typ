// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Division euclidienne, d'après \DivisionEucl et \DivEucl du paquet LaTeX
// ProfLycee (Cédric Pierquet, §54 de sa documentation).
//
// Commandes :
//
//   #division-eucl(a, b)     -> écriture brute « b × q + r » ;
//   #div-eucl(a, b, clés)    -> présentation « a = b × q + r », éventuellement
//                               suivie de « avec 0 ⩽ r < |b| ».
//
// a et b entiers, b non nul ; le reste r vérifie toujours 0 ⩽ r < |b|
// (−40 = 7 × (−6) + 2, 145 = −7 × (−20) + 5).
//
// Clés de div-eucl (entre parenthèses : équivalent ProfLycee, puis défaut) :
//
//   aff-verif   (version étoilée *)  « avec 0 ⩽ r < |b| » à la suite ... false
//   quotient    (Quotient)           afficher le quotient ............. true
//   reste       (Reste)              afficher le reste ................ true
//   vide        (Vide)               ni quotient ni reste ............. false
//   pointilles  (Pointilles)         ce qui remplace un nombre caché .. $dots$
//
// La vérification affiche le vrai reste, même caché dans l'égalité.
//
// Exemples :
//   #div-eucl(145, 7, aff-verif: true)
//   #div-eucl(123456789, 8547, vide: true, pointilles: box(width: 1cm, repeat[.]))
#import "../outils.typ": _nombre, _facteur

#let _division(a, b) = {
  assert(
    type(a) == int and type(b) == int and b != 0,
    message: "division euclidienne : a et b entiers, b non nul",
  )
  // reste calculé directement : a – b × q peut dépasser les entiers 64 bits
  // près de leurs bornes, même quand q et r sont représentables
  (calc.div-euclid(a, b), calc.rem-euclid(a, b))
}

#let division-eucl(a, b) = {
  let (q, r) = _division(a, b)
  $#_nombre(b) times #_facteur(q) + #_nombre(r)$
}

#let div-eucl(
  a,
  b,
  aff-verif: false,
  quotient: true,
  reste: true,
  vide: false,
  pointilles: $dots$,
) = {
  let (q, r) = _division(a, b)
  let q-aff = if quotient and not vide { _facteur(q) } else { pointilles }
  let r-aff = if reste and not vide { _nombre(r) } else { pointilles }
  let egalite = $#_nombre(a) = #_nombre(b) times #q-aff + #r-aff$
  if aff-verif {
    [#egalite avec $0 lt.eq.slant #_nombre(r) < #_nombre(calc.abs(b))$]
  } else { egalite }
}
