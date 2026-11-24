// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Outils communs (non exportés).

// Écriture française d'un entier : espace fine tous les 3 chiffres à partir
// de 10 000 (2500 reste 2500, 13500 devient 13 500), signe moins typographique.
#let _nombre(n) = {
  let s = str(calc.abs(n))
  if s.len() > 4 {
    let groupes = ()
    while s.len() > 3 {
      groupes.insert(0, s.slice(s.len() - 3))
      s = s.slice(0, s.len() - 3)
    }
    groupes.insert(0, s)
    s = groupes.join(sym.space.thin)
  }
  if n < 0 { $-#s$ } else { $#s$ }
}

// Même chose, entre parenthèses si l'entier est négatif (7 × (–6)).
#let _facteur(n) = if n < 0 { $(#_nombre(n))$ } else { _nombre(n) }

// Groupes de 3 chiffres séparés par une espace fine : depuis la droite pour
// la partie entière (à partir de 5 chiffres, comme dans pgcd.typ), depuis la
// gauche pour la partie décimale (à partir de 4 chiffres, comme siunitx).
#let _grouper(s, depuis-gauche: false) = {
  if s.len() < (if depuis-gauche { 4 } else { 5 }) { return s }
  let groupes = ()
  while s.len() > 3 {
    if depuis-gauche {
      groupes.push(s.slice(0, 3))
      s = s.slice(3)
    } else {
      groupes.insert(0, s.slice(s.len() - 3))
      s = s.slice(0, s.len() - 3)
    }
  }
  if depuis-gauche { groupes.push(s) } else { groupes.insert(0, s) }
  groupes.join(sym.space.thin)
}

// x arrondi à `arrondi` décimales, en maths. Le calcul passe par l'entier
// n = x × 10^arrondi : les chiffres affichés sont exactement ceux de n.
#let _decimal(x, arrondi, scientifique) = {
  let n = int(calc.round(calc.abs(x) * calc.pow(10.0, arrondi)))
  let s = str(n)
  let signe = if x < 0 and n != 0 { $-$ } else { [] }
  if scientifique and n != 0 {
    let p = s.len() - 1 - arrondi
    let mantisse = s.at(0) + if s.len() > 1 { "," + _grouper(s.slice(1), depuis-gauche: true) }
    if p == 0 { return $#signe #mantisse$ }
    let puissance = if p < 0 { $10^(-#str(-p))$ } else { $10^#str(p)$ }
    return $#signe #mantisse times #puissance$
  }
  if s.len() <= arrondi { s = "0" * (arrondi + 1 - s.len()) + s }
  let entier = s.slice(0, s.len() - arrondi)
  let decimales = s.slice(s.len() - arrondi)
  let texte = _grouper(entier) + if arrondi > 0 { "," + _grouper(decimales, depuis-gauche: true) }
  $#signe #texte$
}
