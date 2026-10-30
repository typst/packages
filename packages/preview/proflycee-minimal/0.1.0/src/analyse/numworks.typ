// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Écrans de calculatrice NumWorks dessinés (pas dans ProfLycee : sa doc
// illustre \ResolutionApprochee, §7, par des captures d'écran). Ils
// reprennent l'allure de l'écran (bandeau de l'application, onglets, couleurs)
// pour montrer la même résolution « à la calculatrice ».
//
// Commandes, à partir du résultat de resolution-approchee :
//
//   #numworks-solveur(s, clés)     -> application Équations, écran Solution :
//                                     x1 = 2.757278921 ;
//   #numworks-graphique(s, clés)   -> application Fonctions, onglet Graphique :
//                                     la courbe, le point solution, et en bas
//                                     x = … et f(x) = k (bandeau « Zéros » si
//                                     k = 0, « Antécédent » sinon).
//
//   #let s = resolution-approchee(x => calc.pow(x, 3) - 2 * x * x - x - 1, k: 2, intervalle: (0, 10))
//   #numworks-solveur(s) #numworks-graphique(s, fenetre: (-1, 4, -4, 6))
//
// et, pour une suite récurrente u(n+1) = f(u(n)) (suites.typ) :
//
//   #numworks-suite(f, no:, uno:, clés) -> application Suites, onglet
//                                          Tableau : colonnes n et u_n.
//
//   #numworks-suite(x => 1 + (1 + x * x) / (1 + x), no: 1, uno: 2)
//
// Clés communes :
//
//   largeur   largeur de l'écran (proportions de l'écran réel, 320 × 240) . 6cm
//
// Clés de numworks-solveur :
//
//   lignes    lignes ajoutées au tableau, (étiquette, valeur) : par exemple
//             (("Δ", "-439"),) .................................... ()
//
// Clés de numworks-graphique :
//
//   fenetre   (xmin, xmax, ymin, ymax) ; auto : l'intervalle de recherche
//             élargi, et les valeurs prises par f dessus ............. auto
//   domaine   (a, b) où tracer la courbe, si f n'est pas définie sur
//             toute la fenêtre (1/x avec une fenêtre qui contient 0) ;
//             auto : toute la fenêtre ........................... auto
//   couleur   couleur de la courbe et du point ...................... red
//
// f doit être définie sur toute la fenêtre (ou sur `domaine`) : Typst ne
// permet pas de rattraper une erreur de calcul. La fenêtre automatique ne
// franchit pas 0 quand l'intervalle de recherche est d'un seul signe.
//
// Si k ≠ 0, k est une graduation de l'axe des ordonnées (on lit 4 au niveau
// du point pour f(t) = 4) : pas k/m si cela donne une graduation lisible,
// sinon pas rond et graduation k ajoutée à part.
//
// Clés de numworks-suite :
//
//   no, uno     rang et terme initiaux (uno obligatoire) ......... 0, —
//   debut       premier rang affiché (auto : no) ; l'écran montre
//               9 lignes, par exemple debut: N - 4 autour d'un seuil  auto
//   nom-suite   nom de la suite ................................... "u"
//   surligne    rangs dont la ligne est mise en valeur (seuil) .... ()
//
// Les nombres sont écrits comme sur la calculatrice : point décimal, 10
// chiffres significatifs (7 sous le graphique).
#import "../deps.typ": cetz

// Couleurs de l'interface
#let _bandeau = rgb("#ffb734")
#let _gris-fonce = rgb("#4d4d4d")
#let _gris-moyen = rgb("#a3a3a3")
#let _gris-clair = rgb("#eeeeee")
#let _fond = rgb("#e6e6ee")
#let _entete-tableau = rgb("#d9d9e6")

// Nombre écrit par la calculatrice : `chiffres` chiffres significatifs,
// point décimal, tiret pour le signe moins.
#let _nombre-ecran(x, chiffres) = {
  if x == 0 { return "0" }
  let ordre = calc.floor(calc.log(calc.abs(x), base: 10)) + 1
  let v = calc.round(x, digits: calc.max(0, chiffres - ordre))
  if calc.abs(v) >= calc.pow(10.0, chiffres) { v = calc.round(v) }
  let s = str(v).replace("−", "-")
  if s.ends-with(".0") { s.slice(0, -2) } else { s }
}

// Pas « rond » (1, 2 ou 5 × 10^p) pour environ 4 graduations sur `etendue`.
#let _pas(etendue) = {
  let brut = etendue / 4
  let p = calc.pow(10.0, calc.floor(calc.log(brut, base: 10)))
  for m in (1, 2, 5, 10) { if m * p >= brut { return m * p } }
}

// Pas qui fait de k une graduation : k / m (m entier), le plus proche de 3
// graduations sur `etendue` — comme l'écran Antécédent, qui gradue en k.
// none si aucun ne donne entre 2 et 6 graduations (k trop petit devant la
// fenêtre) : on garde alors le pas rond, et k est ajouté à part.
#let _pas-passant-par(etendue, k) = {
  let candidats = range(1, 21).map(m => calc.abs(k) / m)
  let p = candidats.sorted(key: p => calc.abs(etendue / p - 3)).first()
  if 2 <= etendue / p and etendue / p <= 6 { p } else { none }
}

// Fabrique d'un écran : cadre 320 × 240 (unités = pixels de l'écran réel),
// bandeau orange avec le nom de l'application ; `corps(px)` dessine le reste
// (px(n) : taille de texte de n pixels).
#let _ecran(application, corps, largeur) = {
  let px(n) = largeur * n / 320
  let police(n, fill: black, x) = text(font: "DejaVu Sans Mono", size: px(n), fill: fill, x)
  cetz.canvas(length: largeur / 320, {
    import cetz.draw: *
    rect((0, 0), (320, 240), fill: white, stroke: none)
    rect((0, 222), (320, 240), fill: _bandeau, stroke: none)
    content((6, 231), police(9, fill: white)[rad], anchor: "west")
    content((160, 231), police(10, fill: white, upper(application)))
    rect((296, 226), (312, 236), stroke: white + px(1.2), radius: 1)
    rect((312, 229), (314, 233), fill: white, stroke: none)
    corps(police)
    rect((0, 0), (320, 240), stroke: _gris-moyen + px(1))
  })
}

#let numworks-solveur(s, largeur: 6cm, lignes: ()) = _ecran("Solveur", police => {
  import cetz.draw: *
  rect((0, 202), (320, 222), fill: _gris-fonce, stroke: none)
  content((160, 212), police(10, fill: white)[Équations])
  rect((0, 188), (320, 202), fill: _gris-moyen, stroke: none)
  content((160, 195), police(9, fill: white)[Solution])
  rect((0, 0), (320, 188), fill: _fond, stroke: none)
  let tableau = ((s.variable + "1", _nombre-ecran(s.valeur, 10)),) + lignes
  for (i, (etiquette, valeur)) in tableau.enumerate() {
    let y = 178 - 22 * i
    rect((12, y - 20), (72, y), fill: _entete-tableau, stroke: _gris-clair + 0.5pt)
    content((42, y - 10), police(10, etiquette))
    rect((72, y - 20), (230, y), fill: white, stroke: _gris-clair + 0.5pt)
    content((80, y - 10), police(10, valeur), anchor: "west")
  }
}, largeur)

#let numworks-graphique(s, largeur: 6cm, fenetre: auto, domaine: auto, couleur: red) = _ecran("Fonctions", police => {
  import cetz.draw: *
  // onglets, l'onglet Graphique sélectionné
  rect((0, 202), (320, 222), fill: _gris-fonce, stroke: none)
  for (i, nom) in ("Expressions", "Graphique", "Tableau").enumerate() {
    if i == 1 { rect((107, 203), (213, 221), fill: _gris-clair, stroke: none) }
    content((53 + 107 * i, 212), police(9, fill: if i == 1 { black } else { white }, nom))
  }
  content((160, 195), police(8, fill: _gris-moyen, if s.k == 0 [Zéros] else [Antécédent]))

  // fenêtre : intervalle élargi de 15 % de chaque côté, sans franchir 0
  // s'il est d'un seul signe (ln, √, 1/x n'y sont peut-être pas définies :
  // Typst ne permet pas de rattraper l'erreur), puis valeurs de f dessus,
  // l'axe et k compris
  let (a, b) = s.intervalle
  let marge = (b - a) * 0.15
  let (xmin, xmax) = (a - marge, b + marge)
  if a >= 0 and xmin < 0 { xmin = if a == 0 { 0 } else { a / 2 } }
  if b <= 0 and xmax > 0 { xmax = if b == 0 { 0 } else { b / 2 } }
  // domaine du tracé : la fenêtre (imposée ou automatique), ou la clé domaine
  let (dmin, dmax) = if domaine != auto { domaine } else if fenetre != auto { (fenetre.at(0), fenetre.at(1)) } else { (xmin, xmax) }
  let (xmin, xmax, ymin, ymax) = if fenetre == auto {
    let ys = range(101).map(i => (s.f)(dmin + (dmax - dmin) * i / 100))
    let (lo, hi) = (calc.min(0, s.k, ..ys), calc.max(0, s.k, ..ys))
    let m = (hi - lo) * 0.1 + 1e-9
    (calc.min(xmin, dmin), calc.max(xmax, dmax), lo - m, hi + m)
  } else { fenetre }

  // zone de tracé, en pixels : (0, 18) – (320, 186)
  let (gauche, droite, bas, haut) = (0, 320, 18, 186)
  let X(x) = gauche + (x - xmin) / (xmax - xmin) * (droite - gauche)
  let Y(y) = bas + (y - ymin) / (ymax - ymin) * (haut - bas)
  let dedans(y) = ymin <= y and y <= ymax

  // quadrillage, axes et graduations
  // en ordonnée, k est une graduation (s'il est dans la fenêtre)
  let px = _pas(xmax - xmin)
  let k-visible = s.k != 0 and ymin <= s.k and s.k <= ymax
  let pk = if k-visible { _pas-passant-par(ymax - ymin, s.k) }
  let py = if pk != none { pk } else { _pas(ymax - ymin) }
  // k graduation à part : étiquettes ordinaires trop proches retirées
  let k-a-part = k-visible and pk == none
  let x0 = if xmin <= 0 and 0 <= xmax { X(0) } else { X(xmin) }
  let y0 = if ymin <= 0 and 0 <= ymax { Y(0) } else { Y(ymin) }
  // étiquettes du côté où elles tiennent dans l'écran : à droite de l'axe
  // des ordonnées s'il est collé au bord gauche, au-dessus de l'axe des
  // abscisses s'il est collé en bas
  let (dx, ancre-y) = if x0 < gauche + 30 { (3, "west") } else { (-3, "east") }
  let (dy, ancre-x) = if y0 < bas + 12 { (2, "south") } else { (-2, "north") }
  for i in range(calc.ceil(xmin / px), calc.floor(xmax / px) + 1) {
    line((X(i * px), bas), (X(i * px), haut), stroke: _gris-clair + 0.5pt)
    if i != 0 { content((X(i * px), y0 + dy), police(7, _nombre-ecran(i * px, 4)), anchor: ancre-x) }
  }
  for j in range(calc.ceil(ymin / py), calc.floor(ymax / py) + 1) {
    line((gauche, Y(j * py)), (droite, Y(j * py)), stroke: _gris-clair + 0.5pt)
    let trop-proche = k-a-part and calc.abs(Y(j * py) - Y(s.k)) < 12
    if j != 0 and not trop-proche { content((x0 + dx, Y(j * py)), police(7, _nombre-ecran(j * py, 4)), anchor: ancre-y) }
  }
  if k-a-part {
    line((gauche, Y(s.k)), (droite, Y(s.k)), stroke: _gris-clair + 0.5pt)
    content((x0 + dx, Y(s.k)), police(7, _nombre-ecran(s.k, 4)), anchor: ancre-y)
  }
  line((gauche, y0), (droite, y0), stroke: _gris-fonce + 0.6pt)
  line((x0, bas), (x0, haut), stroke: _gris-fonce + 0.6pt)

  // courbe, coupée là où elle sort de la fenêtre
  let morceaux = ((),)
  let (u, v) = (calc.max(xmin, dmin), calc.min(xmax, dmax))
  for i in range(321) {
    let x = u + (v - u) * i / 320
    let y = (s.f)(x)
    if dedans(y) { morceaux.last().push((X(x), Y(y))) } else if morceaux.last().len() > 0 { morceaux.push(()) }
  }
  for m in morceaux.filter(m => m.len() > 1) { line(..m, stroke: couleur + 1.2pt) }
  if dedans(s.k) and xmin <= s.valeur and s.valeur <= xmax {
    circle((X(s.valeur), Y(s.k)), radius: 3.5, fill: couleur, stroke: none)
  }

  // bandeau du bas : coordonnées du point
  rect((0, 0), (320, 18), fill: _gris-clair, stroke: none)
  content((8, 9), police(9, "x=" + _nombre-ecran(s.valeur, 7)), anchor: "west")
  content((240, 9), police(9, "f(x)=" + _nombre-ecran(s.k, 7)), anchor: "west")
}, largeur)

#let numworks-suite(f, no: 0, uno: none, debut: auto, nom-suite: "u", surligne: (), largeur: 6cm) = {
  assert(uno != none, message: "numworks-suite : clé uno (terme initial) obligatoire")
  let debut = if debut == auto { no } else { debut }
  assert(type(debut) == int and debut >= no, message: "numworks-suite : debut doit être un entier ⩾ no")
  // termes u_no, …, u_(debut + 8)
  let termes = (float(uno),)
  for _ in range(debut + 8 - no) { termes.push(float(f(termes.last()))) }
  _ecran("Suites", police => {
    import cetz.draw: *
    // onglets, l'onglet Tableau sélectionné
    rect((0, 202), (320, 222), fill: _gris-fonce, stroke: none)
    for (i, nom) in ("Suites", "Graphique", "Tableau").enumerate() {
      if i == 2 { rect((214, 203), (319, 221), fill: _gris-clair, stroke: none) }
      content((53 + 107 * i, 212), police(9, fill: if i == 2 { black } else { white }, nom))
    }
    rect((0, 0), (320, 202), fill: _fond, stroke: none)
    // en-têtes n et u_n, puis 9 lignes
    let (x0, x1, x2) = (10, 90, 250)
    let h = 19 // en-tête + 9 lignes = 190 px : tout tient sous les onglets
    let haut = 194
    rect((x0, haut - h), (x1, haut), fill: _entete-tableau, stroke: _gris-clair + 0.5pt)
    content(((x0 + x1) / 2, haut - h / 2), police(10)[n])
    rect((x1, haut - h), (x2, haut), fill: _entete-tableau, stroke: _gris-clair + 0.5pt)
    content(((x1 + x2) / 2, haut - h / 2), police(10)[#nom-suite#sub[n]])
    for i in range(9) {
      let n = debut + i
      let y = haut - h * (i + 2)
      let fond = if n in surligne { _bandeau.lighten(60%) } else { white }
      rect((x0, y), (x1, y + h), fill: fond, stroke: _gris-clair + 0.5pt)
      content(((x0 + x1) / 2, y + h / 2), police(10, str(n)))
      rect((x1, y), (x2, y + h), fill: fond, stroke: _gris-clair + 0.5pt)
      content((x2 - 6, y + h / 2), police(10, _nombre-ecran(termes.at(n - no), 7)), anchor: "east")
    }
  }, largeur)
}
