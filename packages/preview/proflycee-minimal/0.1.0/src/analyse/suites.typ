// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Suites récurrentes simples u(n+1) = f(u(n)), d'après \CalculTermeRecurrence
// et \SolutionSeuil du paquet LaTeX ProfLycee (Cédric Pierquet, §9 de sa
// documentation 4.02b). La fonction associée f est une fonction Typst.
//
// Commandes :
//
//   #calcul-terme-recurrence(f, clés)   -> u_N, arrondi : 0,414 ;
//   suite-recurrente(f, no:, uno:)      -> la fonction n => u_n arrondi (pas
//                                          dans ProfLycee), à fabriquer une
//                                          fois pour toutes :
//       #let u = suite-recurrente(x => 1 / (x + 2), no: 0, uno: 50)
//       $u_10 approx #u(10)$, $u_20 approx #u(20, precision: 6)$
//   #solution-seuil(f, seuil, clés)     -> conclusion d'une recherche de seuil :
//                                          { u_7 ≈ 4,868 ⩽ 5 ; u_8 ≈ 5,209 > 5 | ⇒ n ⩾ 8 ;
//   rang-seuil(f, seuil, clés)          -> le rang trouvé, entier (le compteur
//                                          \CompteurSeuil de ProfLycee).
//
// Le tableau de valeurs n | u_n de l'exemple de la doc est remplacé par
// l'écran NumWorks numworks-suite (numworks.typ), qui prend les mêmes f,
// no, uno.
//
// Clés de calcul-terme-recurrence (et de la fonction de suite-recurrente,
// sauf no, uno) :
//
//   no         (No)         rang initial ............................ 0
//   uno        (UNo)        terme initial, obligatoire .............. —
//   n          (N)          rang du terme à calculer, obligatoire ... —
//   precision  (Precision)  nombre de décimales ..................... 3
//   brut       (pas dans ProfLycee)  renvoie le flottant ............ false
//
// Clés de solution-seuil (et rang-seuil : no, uno, sens) :
//
//   nom-suite     (NomSuite)      nom de la suite ...................... "u"
//   no, uno       (No, UNo)       rang et terme initiaux ............... 0, —
//   precision     (Precision)     nombre de décimales (la doc annonce 2,
//                                 mais son exemple sans la clé en montre 3,
//                                 que l'on suit) ....................... 3
//   stretch       (Stretch)       espacement des lignes ................ 1.15
//   balayage      (Balayage)      « Par balayage, on obtient » avant ... false
//   calculatrice  (Calculatrice)  « Par calculatrice, on obtient » ..... false
//   simple        (Simple)        présentation en ligne : « u_28 ≈ … ⩽ 10
//                                 et u_29 ≈ … > 10 » ................... false
//   majuscule     (Majuscule)     majuscule au début du texte avant .... true
//   exact         (Exact)         « = » au lieu de « ≈ », premier terme  false
//   exact-b       (ExactB)        « = » au lieu de « ≈ », second terme . false
//   conclusion    (Conclusion)    « ⇒ n ⩾ N » .......................... true
//   sens          (Sens)          type de seuil : ">", ">=", "<", "<=" . ">"
//
// La recherche s'arrête au premier rang qui vérifie u_n sens seuil (la
// conclusion n ⩾ N suppose la suite monotone, comme dans ProfLycee) ; au
// plus 100 000 termes.
#import "../outils.typ": _nombre, _decimal

// Termes u_no, …, u_n (flottants), par itérations successives.
#let _termes(f, no, uno, n) = {
  assert(uno != none, message: "suite récurrente : clé uno (terme initial) obligatoire")
  assert(type(n) == int and n >= no, message: "suite récurrente : le rang demandé doit être un entier ⩾ no")
  let termes = (float(uno),)
  for _ in range(n - no) { termes.push(float(f(termes.last()))) }
  termes
}

#let calcul-terme-recurrence(f, no: 0, uno: none, n: none, precision: 3, brut: false) = {
  let u = _termes(f, no, uno, n).last()
  if brut { u } else { _decimal(u, precision, false) }
}

#let suite-recurrente(f, no: 0, uno: none) = (n, precision: 3, brut: false) => calcul-terme-recurrence(
  f, no: no, uno: uno, n: n, precision: precision, brut: brut,
)

// Relation du seuil et relation contraire, en maths.
#let _relations = (
  ">": (math.gt, math.lt.eq.slant),
  ">=": (math.gt.eq.slant, math.lt),
  "<": (math.lt, math.gt.eq.slant),
  "<=": (math.lt.eq.slant, math.gt),
)
#let _verifie(u, sens, s) = (
  ">": u > s, ">=": u >= s, "<": u < s, "<=": u <= s,
).at(sens)

#let rang-seuil(f, seuil, no: 0, uno: none, sens: ">") = {
  assert(sens in _relations, message: "solution-seuil : sens parmi \">\", \">=\", \"<\", \"<=\"")
  assert(uno != none, message: "suite récurrente : clé uno (terme initial) obligatoire")
  let u = float(uno)
  for n in range(no, no + 100001) {
    if _verifie(u, sens, seuil) { return n }
    u = float(f(u))
  }
  panic("solution-seuil : seuil non atteint en 100 000 termes")
}

// Écriture française d'un seuil (entier ou décimal).
#let _seuil(s) = if type(s) == int { _nombre(s) } else {
  $#str(s).replace(".", ",").replace("−", "-")$
}

#let solution-seuil(
  f,
  seuil,
  nom-suite: "u",
  no: 0,
  uno: none,
  precision: 3,
  stretch: 1.15,
  balayage: false,
  calculatrice: false,
  simple: false,
  majuscule: true,
  exact: false,
  exact-b: false,
  conclusion: true,
  sens: ">",
) = {
  let N = rang-seuil(f, seuil, no: no, uno: uno, sens: sens)
  assert(N > no, message: "solution-seuil : le terme initial vérifie déjà le seuil")
  let termes = _termes(f, no, uno, N)
  let (rel, contraire) = _relations.at(sens)
  let nom = math.italic(nom-suite)
  let ligne(n, u, relation, egal) = {
    let signe = if egal { $=$ } else { $approx$ }
    $#nom _#_nombre(n) #signe #_decimal(u, precision, false) #relation #_seuil(seuil)$
  }
  let avant = ligne(N - 1, termes.at(-2), contraire, exact)
  let apres = ligne(N, termes.last(), rel, exact-b)
  let texte = if balayage { "par balayage, on obtient" } else if calculatrice { "par calculatrice, on obtient" }
  let texte = if texte == none { none } else if majuscule { upper(texte.first()) + texte.slice(1) } else { texte }

  let corps = if simple { [#avant et #apres] } else {
    // même centrage sur l'axe mathématique que presentation-pgcd
    let tableau = box(baseline: 50% - 0.25em, grid(
      row-gutter: 0.55em * stretch,
      align: left,
      avant, apres,
    ))
    if conclusion { $lr(\{ #tableau |) ==> n gt.eq.slant #_nombre(N)$ } else { $lr(\{ #tableau)$ }
  }
  if texte == none { corps } else [#texte #corps]
}
