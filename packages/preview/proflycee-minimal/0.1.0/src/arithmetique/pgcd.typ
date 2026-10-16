// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Algorithme d'Euclide, d'après \PresentationPGCD du paquet LaTeX ProfLycee
// (Cédric Pierquet, §57 de sa documentation), et sa « remontée » (absente de
// ProfLycee en tant que commande).
//
// Deux commandes :
//
//   #presentation-pgcd(a, b, clés)  -> les divisions euclidiennes successives
//                                      entre accolade et trait, le dernier reste
//                                      non nul encadré, puis « ⇒ PGCD(a ; b) = d » ;
//   #remontee-euclide(a, b, clés)   -> la remontée de l'algorithme : on part du
//                                      PGCD et on remplace les restes un à un
//                                      jusqu'à écrire d = a × u + b × v (Bézout).
//
// Clés de presentation-pgcd (entre parenthèses : équivalent ProfLycee, puis défaut) :
//
//   couleur           (Couleur)            couleur de la mise en valeur .... red
//   decal-rect        (DecalRect)          marge du cadre autour du reste .. 2pt
//   rectangle         (Rectangle)          encadrer le dernier reste non nul true
//   couleur-resultat  (CouleurResultat)    PGCD de la conclusion en couleur  false
//   aff-conclusion    (AfficheConclusion)  afficher « ⇒ PGCD(a ; b) = d » .. true
//   aff-delimiteurs   (AfficheDelimiteurs) accolade et trait vertical ...... true
//
// Clés de remontee-euclide (pas dans ProfLycee) :
//
//   couleur           couleur du reste remplacé à chaque étape ......... red
//   aff-conclusion    afficher « Ainsi, a × u + b × v = d » ............ true
//
// a et b sont des entiers strictement positifs, dans n'importe quel ordre :
// si a < b, la première division est a = b × 0 + a, comme dans ProfLycee.
//
// Exemples :
//   #presentation-pgcd(150, 27)
//   D'après l'algorithme d'Euclide, #presentation-pgcd(150, 27, couleur-resultat: true).
//   #remontee-euclide(150, 27)

#import "../outils.typ": _nombre

// Divisions euclidiennes successives de a par b : tableau de
// (dividende, diviseur, quotient, reste), jusqu'au reste nul compris.
#let _divisions(a, b) = {
  assert(
    type(a) == int and type(b) == int and a > 0 and b > 0,
    message: "PGCD : a et b doivent être des entiers strictement positifs",
  )
  let etapes = ()
  let (x, y) = (a, b)
  while y != 0 {
    let r = calc.rem(x, y)
    etapes.push((x, y, calc.quo(x, y), r))
    (x, y) = (y, r)
  }
  etapes
}

#let presentation-pgcd(
  a,
  b,
  couleur: red,
  decal-rect: 2pt,
  rectangle: true,
  couleur-resultat: false,
  aff-conclusion: true,
  aff-delimiteurs: true,
) = {
  let etapes = _divisions(a, b)
  let d = calc.gcd(a, b)
  // ligne du dernier reste non nul (l'avant-dernière, ou la seule si b | a)
  let k = etapes.len() - 2

  let cellules = ()
  for (i, (x, y, q, r)) in etapes.enumerate() {
    let reste = if i == k and rectangle {
      box(
        stroke: couleur + 0.8pt,
        radius: 40%,
        // marge verticale en `outset` : le cadre déborde sans agrandir la ligne
        inset: (x: decal-rect),
        outset: (y: decal-rect + 1pt),
        _nombre(r),
      )
    } else { _nombre(r) }
    cellules += (
      _nombre(x),
      $=$,
      $#_nombre(y) times #_nombre(q)$,
      $+$,
      reste,
    )
  }
  // baseline à mi-hauteur, remontée de l'axe mathématique (~0,25 em) : le
  // tableau est centré sur l'axe, donc l'accolade et le trait aussi
  let tableau = box(baseline: 50% - 0.25em, grid(
    columns: 5,
    column-gutter: (0.25em, 0.25em, 0.35em, 0.35em),
    row-gutter: 0.55em,
    align: (right, center, left, center, right),
    ..cellules,
  ))

  let resultat = if couleur-resultat { text(fill: couleur, _nombre(d)) } else { _nombre(d) }
  let conclusion = $==> "PGCD"(#_nombre(a) med ";" med #_nombre(b)) = #resultat$
  if aff-delimiteurs {
    if aff-conclusion {
      $lr(\{ #tableau |) med #conclusion$
    } else {
      $lr(\{ #tableau |)$
    }
  } else {
    if aff-conclusion { $#tableau quad #conclusion$ } else { tableau }
  }
}

// Combinaison « N1 × c1 + N2 × c2 » avec les signes simplifiés
// (15 × 2 – 27 × 11 plutôt que 15 × 2 + 27 × (–11)), le terme positif en
// premier. Les Ni sont des contenus (un nombre, ou la parenthèse colorée de
// l'étape de substitution).
#let _combinaison(n1, c1, n2, c2) = {
  let ((n1, c1), (n2, c2)) = if c1 < 0 and c2 >= 0 { ((n2, c2), (n1, c1)) } else { ((n1, c1), (n2, c2)) }
  let t1 = if c1 < 0 { $- #n1 times #_nombre(-c1)$ } else { $#n1 times #_nombre(c1)$ }
  let t2 = if c2 < 0 { $- #n2 times #_nombre(-c2)$ } else { $+ #n2 times #_nombre(c2)$ }
  $#t1 #t2$
}

#let remontee-euclide(
  a,
  b,
  couleur: red,
  aff-conclusion: true,
) = {
  let etapes = _divisions(a, b)
  let d = calc.gcd(a, b)
  let n = etapes.len() - 1 // nombre de divisions à reste non nul

  // b divise a : rien à remonter, d = b = a × 0 + b × 1
  if n == 0 {
    let ligne = $#_nombre(d) = #_combinaison(_nombre(a), 0, _nombre(b), 1)$
    return if aff-conclusion {
      [#ligne\ Ainsi, $#_nombre(a) times 0 + #_nombre(b) times 1 = #_nombre(d)$.]
    } else { ligne }
  }

  // Suite des restes r(-1) = a, r(0) = b, r(1), …, r(n) = d, stockée décalée
  // d'un cran (r.at(j + 1) = r(j)), et quotients q(1), …, q(n).
  let r = (a, b) + etapes.map(e => e.at(3))
  let q = etapes.map(e => e.at(2))
  let rr(j) = r.at(j + 1)
  let qq(j) = q.at(j - 1)

  // Départ : d = r(n-2) – r(n-1) × q(n), lu sur l'avant-dernière division.
  // État courant : d = alpha × r(k-1) + beta × r(k).
  let k = n - 1
  let (alpha, beta) = (1, -qq(n))
  let lignes = (
    ($#_nombre(d)$, $#_nombre(rr(n - 2)) - #_nombre(rr(n - 1)) times #_nombre(qq(n))$),
  )
  while k >= 1 {
    // r(k) = r(k-2) – r(k-1) × q(k), d'après la k-ième division
    let remplace = text(fill: couleur, $(#_nombre(rr(k - 2)) - #_nombre(rr(k - 1)) times #_nombre(qq(k)))$)
    lignes.push(([], _combinaison(_nombre(rr(k - 1)), alpha, remplace, beta)))
    (alpha, beta) = (beta, alpha - beta * qq(k))
    k -= 1
    lignes.push(([], _combinaison(_nombre(rr(k - 1)), alpha, _nombre(rr(k)), beta)))
  }
  // Ici k = 0 : d = alpha × a + beta × b.
  let (u, v) = (alpha, beta)
  assert(a * u + b * v == d, message: "remontee-euclide : erreur interne")

  let tableau = grid(
    columns: 3,
    column-gutter: 0.3em,
    row-gutter: 0.65em,
    align: (right, center, left),
    ..lignes.map(((g, dr)) => (g, $=$, dr)).flatten(),
  )
  if aff-conclusion {
    let pv = if v < 0 { $(#_nombre(v))$ } else { _nombre(v) }
    let pu = if u < 0 { $(#_nombre(u))$ } else { _nombre(u) }
    [
      #tableau
      Ainsi, $#_nombre(a) times #pu + #_nombre(b) times #pv = #_nombre(d)$ : le couple $(u ; v) = (#_nombre(u) ; #_nombre(v))$ convient.
    ]
  } else { tableau }
}
