// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Calculs de probabilités, d'après les commandes \CalcBinomP, \BinomP, etc.
// du paquet LaTeX ProfLycee (Cédric Pierquet, §52 de sa documentation).
//
// Une loi est une FONCTION, fabriquée une fois pour toutes à partir de ses
// paramètres (pas dans ProfLycee : c'est la façon Typst de simplifier
// l'écriture) :
//
//   #let X = loi-binomiale(5, 0.4)
//   $P(X = 3) approx #X(3)$                   un argument  : P(X = k)
//   $P(X <= 1) approx #X(none, 1)$            deux arguments : P(a <= X <= b)
//   $P(X >= 2) approx #X(2, none, arrondi: 4)$
//
// Borne `none` (ou "*", comme dans ProfLycee) : pas de borne de ce côté.
// Clés de la fonction obtenue (pas dans ProfLycee, sauf équivalence notée) :
//
//   arrondi       (argument optionnel [prec])  nombre de décimales ...... 3
//   scientifique  (version étoilée *)          écriture n,… × 10^p ...... false
//   brut          (commandes \Calc…)           renvoie le flottant, non
//                                              formaté (pour calculer) .. false
//
// Lois disponibles (paramètres dans l'ordre de ProfLycee) :
//
//   loi-binomiale(n, p)            B(n ; p)
//   loi-poisson(l)                 P(λ)
//   loi-geometrique(p)             G(p), à valeurs dans {1, 2, …}
//   loi-hypergeometrique(N, n, m)  H(N ; n ; m) : m tirages sans remise dans
//                                  N objets, dont n « succès »
//   loi-normale(m, s)              N(μ ; σ), σ écart type
//   loi-exponentielle(l)           E(λ)
//
// Les lois continues n'acceptent que deux bornes (une probabilité ponctuelle
// y est nulle).
//
// Commandes ProfLycee, fabriquées à partir des lois (les paramètres de la loi
// puis k, ou a et b) :
//
//   \CalcBinomP{n}{p}{k}       →  calc-binom-p(n, p, k)          (flottant)
//   \CalcBinomC{n}{p}{a}{b}    →  calc-binom-c(n, p, a, b)
//   \CalcPoissP, \CalcPoissC   →  calc-poiss-p, calc-poiss-c
//   \CalcGeomP, \CalcGeomC     →  calc-geom-p, calc-geom-c
//   \CalcHypergeomP, …C        →  calc-hypergeom-p, calc-hypergeom-c
//   \CalcNormC, \CalcExpoC     →  calc-norm-c, calc-expo-c
//
//   \BinomP*[7]{n}{p}{k}       →  binom-p(n, p, k, arrondi: 7, scientifique: true)
//   \BinomC, \PoissonP, \PoissonC, \GeomP, \GeomC, \HypergeomP, \HypergeomC,
//   \NormaleC, \ExpoC          →  binom-c, poisson-p, poisson-c, geom-p,
//                                 geom-c, hypergeom-p, hypergeom-c,
//                                 normale-c, expo-c
//
// Formatage : virgule décimale, espaces fines par groupes de 3 chiffres
// (0,047 8), comme siunitx ; en écriture scientifique, le nombre est d'abord
// arrondi puis écrit n,… × 10^p (0,000 028 8 ≈ 2,88 × 10^(-5)).

#import "../outils.typ": _grouper, _decimal

// ---------------------------------------------------------------------------
// Fabriques de lois

// Fabrique commune : à partir de `probabilite` (tableau des bornes → flottant),
// la fonction que manipule l'utilisateur, avec ses clés de formatage.
#let _loi(probabilite) = (..bornes, arrondi: 3, scientifique: false, brut: false) => {
  let bornes = bornes.pos().map(x => if x == "*" { none } else { x })
  assert(bornes.len() in (1, 2), message: "loi : un argument (k) ou deux (a, b) attendus")
  let p = probabilite(bornes)
  if brut { p } else { _decimal(p, arrondi, scientifique) }
}

// Loi discrète : fonction de masse et support {min, …, max} (max: none pour
// un support infini). La probabilité cumulée est la somme des masses ; pour
// P(X >= a) sur un support infini, on passe par le complémentaire.
#let _loi-discrete(masse, min, max) = _loi(bornes => {
  let somme(a, b) = range(a, b + 1).map(masse).sum(default: 0.0)
  if bornes.len() == 1 {
    let k = bornes.first()
    return if k < min or (max != none and k > max) { 0.0 } else { masse(k) }
  }
  let (a, b) = bornes
  let a = if a == none { min } else { calc.max(min, int(calc.ceil(a))) }
  if b == none and max == none { return calc.max(0.0, 1 - somme(min, a - 1)) }
  let b = if b == none { max } else if max == none { int(calc.floor(b)) } else { calc.min(max, int(calc.floor(b))) }
  somme(a, b)
})

// Loi continue : fonction de répartition F et fonction de survie S = 1 – F
// (calculée à part pour garder la précision dans la queue de droite).
#let _loi-continue(F, S) = _loi(bornes => {
  assert(bornes.len() == 2, message: "loi continue : P(X = k) = 0, donner deux bornes a et b")
  let (a, b) = bornes
  if a == none and b == none { 1.0 } else if a == none { F(b) } else if b == none { S(a) } else if b < a { 0.0 } else {
    // la soustraction se fait du côté où les deux termes sont petits
    if S(a) < 0.5 { S(a) - S(b) } else { F(b) - F(a) }
  }
})

// ---------------------------------------------------------------------------
// Outils numériques

// ln(n!) : exact jusqu'à 20!, approximation de Lanczos (g = 7) au-delà.
#let _lanczos = (
  0.99999999999980993, 676.5203681218851, -1259.1392167224028,
  771.32342877765313, -176.61502916214059, 12.507343278686905,
  -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7,
)
#let _ln-fact(n) = {
  if n <= 20 { return calc.ln(calc.fact(n)) }
  // ln Γ(n + 1)
  let somme = _lanczos.first()
  for i in range(1, 9) { somme += _lanczos.at(i) / (n + i) }
  let t = n + 7.5
  0.5 * calc.ln(2 * calc.pi) + (n + 0.5) * calc.ln(t) - t + calc.ln(somme)
}
#let _ln-binom(n, k) = _ln-fact(n) - _ln-fact(k) - _ln-fact(n - k)

// Fonction de répartition de N(0 ; 1) : série de Taylor au centre, fraction
// continue de Laplace pour la queue (|z| > 3), précision ~1e-15.
#let _phi(z) = {
  let densite = calc.exp(-z * z / 2) / calc.sqrt(2 * calc.pi)
  if calc.abs(z) <= 3 {
    // Φ(z) = 1/2 + φ(z) × Σ z^(2k+1) / (1 × 3 × … × (2k+1))
    let (terme, somme, k) = (z, z, 0)
    while calc.abs(terme) > 1e-17 * calc.abs(somme) {
      k += 1
      terme *= z * z / (2 * k + 1)
      somme += terme
    }
    0.5 + densite * somme
  } else {
    // queue Q(|z|) = φ(z) / (|z| + 1/(|z| + 2/(|z| + 3/(|z| + …))))
    let x = calc.abs(z)
    let fraction = x
    for k in range(200, 0, step: -1) { fraction = x + k / fraction }
    let queue = densite / fraction
    if z > 0 { 1 - queue } else { queue }
  }
}

// ---------------------------------------------------------------------------
// Lois

#let loi-binomiale(n, p) = _loi-discrete(
  k => if p == 0 { float(k == 0) } else if p == 1 { float(k == n) } else {
    calc.exp(_ln-binom(n, k) + k * calc.ln(p) + (n - k) * calc.ln(1 - p))
  },
  0,
  n,
)

#let loi-poisson(l) = _loi-discrete(
  k => calc.exp(-l + k * calc.ln(l) - _ln-fact(k)),
  0,
  none,
)

#let loi-geometrique(p) = _loi-discrete(
  // k = 1 à part : calc.pow(0, 0) est refusé quand p = 1
  k => if k == 1 { float(p) } else { p * calc.pow(1 - p, k - 1) },
  1,
  none,
)

#let loi-hypergeometrique(N, n, m) = _loi-discrete(
  k => calc.exp(_ln-binom(n, k) + _ln-binom(N - n, m - k) - _ln-binom(N, m)),
  calc.max(0, m - (N - n)),
  calc.min(n, m),
)

#let loi-normale(m, s) = _loi-continue(
  x => _phi((x - m) / s),
  x => _phi((m - x) / s),
)

#let loi-exponentielle(l) = _loi-continue(
  x => if x <= 0 { 0.0 } else { 1 - calc.exp(-l * x) },
  x => if x <= 0 { 1.0 } else { calc.exp(-l * x) },
)

// ---------------------------------------------------------------------------
// Commandes ProfLycee

// Fabrique d'une commande « à plat » : les derniers arguments (`nb-bornes`)
// sont les bornes, les précédents les paramètres de la loi. La signature
// (« binom-p(n, p, k) ») sert au contrôle du nombre d'arguments et au
// message d'erreur.
#let _commande(signature, loi, nb-bornes, ..fixes) = {
  let nb = signature.split(",").len()
  (..args) => {
    let pos = args.pos()
    assert(
      pos.len() == nb,
      message: signature + " : " + str(nb) + " arguments attendus, " + str(pos.len()) + if pos.len() > 1 { " reçus" } else { " reçu" },
    )
    let i = pos.len() - nb-bornes
    loi(..pos.slice(0, i))(..pos.slice(i), ..args.named(), ..fixes)
  }
}

#let calc-binom-p = _commande("calc-binom-p(n, p, k)", loi-binomiale, 1, brut: true)
#let calc-binom-c = _commande("calc-binom-c(n, p, a, b)", loi-binomiale, 2, brut: true)
#let calc-poiss-p = _commande("calc-poiss-p(l, k)", loi-poisson, 1, brut: true)
#let calc-poiss-c = _commande("calc-poiss-c(l, a, b)", loi-poisson, 2, brut: true)
#let calc-geom-p = _commande("calc-geom-p(p, k)", loi-geometrique, 1, brut: true)
#let calc-geom-c = _commande("calc-geom-c(p, a, b)", loi-geometrique, 2, brut: true)
#let calc-hypergeom-p = _commande("calc-hypergeom-p(N, n, m, k)", loi-hypergeometrique, 1, brut: true)
#let calc-hypergeom-c = _commande("calc-hypergeom-c(N, n, m, a, b)", loi-hypergeometrique, 2, brut: true)
#let calc-norm-c = _commande("calc-norm-c(m, s, a, b)", loi-normale, 2, brut: true)
#let calc-expo-c = _commande("calc-expo-c(l, a, b)", loi-exponentielle, 2, brut: true)

#let binom-p = _commande("binom-p(n, p, k)", loi-binomiale, 1)
#let binom-c = _commande("binom-c(n, p, a, b)", loi-binomiale, 2)
#let poisson-p = _commande("poisson-p(l, k)", loi-poisson, 1)
#let poisson-c = _commande("poisson-c(l, a, b)", loi-poisson, 2)
#let geom-p = _commande("geom-p(p, k)", loi-geometrique, 1)
#let geom-c = _commande("geom-c(p, a, b)", loi-geometrique, 2)
#let hypergeom-p = _commande("hypergeom-p(N, n, m, k)", loi-hypergeometrique, 1)
#let hypergeom-c = _commande("hypergeom-c(N, n, m, a, b)", loi-hypergeometrique, 2)
#let normale-c = _commande("normale-c(m, s, a, b)", loi-normale, 2)
#let expo-c = _commande("expo-c(l, a, b)", loi-exponentielle, 2)
