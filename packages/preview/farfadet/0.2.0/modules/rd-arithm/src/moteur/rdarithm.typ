// rdarithm.typ (rdarithm, moteur) — décompositions en facteurs premiers (liste, produit, potence, arbre,
// tableau), diviseurs, PGCD et PPCM, tableau et alignement des facteurs communs, fractions.
//
// Chaque présentation est MESURÉE puis posée à la main (`place`) : on connaît donc la position de chaque
// nœud sans seconde compilation, et les décorations (boîtes colorées, traits, liens, bulles) se dessinent
// dans le même bloc. Les nœuds portent des noms (`cell 1`, `cell 2-1`…) pour la clé `overlay`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: reglages-paquet, reglages-controles, reglages-choix, reglages-ou
#import "../../../zones-reponse/lib.typ": interne as _crep
#import _crep: tccrep
#import "commun.typ": *

// =====================================================================
// Couleurs du paquet
// =====================================================================

#let rdarithm-couleurs = (
  arithmcol1: rgb("#FF6633"),
  arithmcol2: rgb("#00A580"),
  arithmcol3: rgb("#FFC518"),
)

/// Couleur rdarithm : comprend arithmcol1/2/3 et la couleur dynamique « arithmcol » (\RowPGCD, \DecompFrac).
#let ra-couleur(v, commande: "rdarithm", courante: none) = {
  if type(v) != str { return rd-couleur(v, commande: commande, courante: courante) }
  let morceaux = v.split("!").map(m => {
    let t = m.trim()
    if t in rdarithm-couleurs { rdarithm-couleurs.at(t).to-hex() } else { m }
  })
  rd-couleur(morceaux.join("!"), commande: commande, courante: courante)
}

// Remplace dans un style normalisé les noms arithmcol<n> (fill, draw, text) par leur valeur.
#let _st(st, courante: none, commande: "rdarithm") = {
  let k = st.cles
  for c in ("fill", "draw", "text") {
    if c in k and type(k.at(c)) == str { k.insert(c, ra-couleur(k.at(c), commande: commande, courante: courante)) }
  }
  (cles: k, fns: st.fns)
}

// =====================================================================
// Réglages (`setrdarithm`)
// =====================================================================

#let _style = rd-controle-style
#let _ou-vrai(..choix) = (
  v => v == true or v in choix.pos(),
  "true ou " + choix.pos().map(x => "\"" + x + "\"").join(", ", last: " ou "),
)

#let rdarithm-reglages = reglages-paquet(
  "rdarithm",
  (
    colors: ("arithmcol1", "arithmcol2"),
    node-opacity: 0.25,
    node-style: none,
    decorate: true,
    stop: 0,
    powers: "none",
    crep: false,
    crep-width: 3em,
    crep-style: (seyes: true, boxsep: 1pt, opacityback: 0.6, left: 2pt, right: 2pt),
    prime-style: (fill: "arithmcol1", fill-opacity: 0.25, draw: "arithmcol1", text-opacity: 1, font: (weight: "bold")),
    prime-append-style: none,
    cell-style: none,
    cell-append-style: none,
    cell: none,
    picture-style: none,
    level-distance: 8mm,
    sibling-distance: 15mm,
    label: "none",
    label-style: none,
    prefix-label: none,
    suffix-label: none,
    label-extrasep: 0mm,
    overlay: none,
    column-sep: 1mm,
    line-width: 0.7pt,
    separator: [,~],
    cf: 0,
    cf-style: (fill: "arithmcol3!50"),
    gcd-style: (fill: "arithmcol3"),
    tab-orientation: "horizontal",
    header-style: (fill: "gray!50", font: (weight: "bold")),
    prefix-header: none,
    suffix-header: [~:],
    rules: "all",
    rule-color: "black",
    forced-width: 0cm,
    inner-xsep: 3pt,
    header-width: 0cm,
    frac-mode: "dfrac",
    link: "bubble",
    line-style: none,
    to: none,
    // valeurs réglables supplémentaires (ajouts)
    row-sep: 1.24em + 3pt, // \baselineskip + \jot de l'environnement aligned (\DecompFPA, \RowPGCD)
    decoration-line-width: 0.4pt, // trait des potences de \DecompFPA (épaisseur TikZ par défaut)
    bubble-width: 1.25mm, // amplitude de la barre des bulles (\RowPGCD, link=bubble)
    bubble-line-width: 0.7pt, // contour des bulles (postaction={draw, line width=0.7pt})
    cell-min-width: 3em, // minimum width des styles par défaut B, C et D
  ),
  controles: (
    colors: (v => type(v) in (array, str) or type(v) == color, "un tableau de couleurs ou une chaîne LaTeX « a, b »"),
    node-opacity: (v => type(v) in (int, float) and v >= 0 and v <= 1, "un nombre entre 0 et 1"),
    node-style: _style,
    decorate: reglages-controles.booleen,
    stop: reglages-controles.entier,
    powers: _ou-vrai("none", "right", "bottom"),
    crep: reglages-controles.booleen,
    crep-width: reglages-controles.longueur,
    crep-style: (v => v == none or type(v) == dictionary, "none ou un dictionnaire de clés de tccrep (seyes, boxsep, opacityback…)"),
    prime-style: _style,
    prime-append-style: _style,
    cell-style: _style,
    cell-append-style: _style,
    cell: rd-controle-styles-numerotes,
    picture-style: _style,
    level-distance: reglages-controles.longueur,
    sibling-distance: reglages-controles.longueur,
    label: _ou-vrai("none", "left", "above"),
    label-style: _style,
    prefix-label: reglages-controles.contenu-ou-none,
    suffix-label: reglages-controles.contenu-ou-none,
    label-extrasep: reglages-controles.longueur,
    overlay: (v => v == none or type(v) == function, "none ou une fonction (cellules) => contenu"),
    column-sep: reglages-controles.longueur,
    line-width: reglages-controles.longueur,
    separator: reglages-controles.contenu,
    cf: reglages-controles.entier,
    cf-style: _style,
    gcd-style: _style,
    tab-orientation: _ou-vrai("horizontal", "vertical"),
    header-style: _style,
    prefix-header: reglages-controles.contenu-ou-none,
    suffix-header: reglages-controles.contenu-ou-none,
    rules: _ou-vrai("none", "all", "horizontal", "Horizontal", "vertical", "Vertical"),
    rule-color: reglages-controles.couleur-ou-nom,
    forced-width: reglages-controles.longueur,
    inner-xsep: reglages-controles.longueur,
    header-width: reglages-controles.longueur,
    frac-mode: _ou-vrai("frac", "dfrac"),
    link: _ou-vrai("none", "line", "bubble"),
    line-style: _style,
    to: rd-controle-styles-numerotes,
    row-sep: reglages-controles.longueur,
    decoration-line-width: reglages-controles.longueur,
    bubble-width: reglages-controles.longueur,
    bubble-line-width: reglages-controles.longueur,
    cell-min-width: reglages-controles.longueur,
  ),
  commande: "setrdarithm",
)

// Valeur « clé seule » de LaTeX (powers → bottom, label → above…).
#let _choix(v, defaut) = if v == true { defaut } else { v }

// =====================================================================
// Arithmétique
// =====================================================================

/// Facteurs premiers de n, dans l'ordre croissant. n = 1 → (1,).
#let ra-facteurs(n, commande: "rdarithm") = {
  if type(n) != int or n < 1 { panic(commande + " : un entier positif est attendu ; reçu : " + repr(n) + ".") }
  let res = ()
  let m = n
  let p = 2
  while p * p <= m {
    while calc.rem(m, p) == 0 {
      res.push(p)
      m = calc.quo(m, p)
    }
    p += if p == 2 { 1 } else { 2 }
  }
  if m > 1 or res.len() == 0 { res.push(m) }
  res
}

/// Diviseurs de n, dans l'ordre croissant.
#let ra-diviseurs(n) = {
  let petits = ()
  let grands = ()
  let d = 1
  while d * d <= n {
    if calc.rem(n, d) == 0 {
      petits.push(d)
      if d * d != n { grands.insert(0, calc.quo(n, d)) }
    }
    d += 1
  }
  petits + grands
}

#let ra-pgcd(a, b) = calc.gcd(a, b)
#let ra-ppcm(a, b) = calc.lcm(a, b)

/// Facteurs en colonnes (\TabPGCD, \RowPGCD) : pour chaque facteur du PPCM, le facteur s'il divise
/// encore A (resp. B), sinon 0.
#let ra-colonnes(a, b) = {
  let (ra, rb) = (a, b)
  let (la, lb) = ((), ())
  for f in ra-facteurs(ra-ppcm(a, b)) {
    if calc.rem(ra, f) == 0 {
      la.push(f)
      ra = calc.quo(ra, f)
    } else { la.push(0) }
    if calc.rem(rb, f) == 0 {
      lb.push(f)
      rb = calc.quo(rb, f)
    } else { lb.push(0) }
  }
  (la, lb)
}

/// Facteurs groupés en puissances : ((2, 1), (3, 2), (7, 1)).
#let ra-puissances(l) = {
  let res = ()
  for f in l {
    if res.len() > 0 and res.last().at(0) == f { res.last().at(1) += 1 } else { res.push((f, 1)) }
  }
  res
}

// =====================================================================
// Briques de rendu (dans un `context`)
// =====================================================================

#let _m(x) = math.equation(block: false, [#x])
#let _fois = h(2em / 9) + _m(sym.times) + h(2em / 9)
#let _egal = h(5em / 18) + _m("=") + h(5em / 18)

/// \WriteWithPowers : produit avec exposants (contenu mathématique).
#let ra-avec-puissances(l) = {
  let morceaux = ra-puissances(l).map(((f, e)) => if e == 1 { [#f] } else { math.attach([#f], t: [#e]) })
  math.equation(block: false, morceaux.join([#sym.times]))
}

/// Produit simple 2 × 3 × 3 (contenu mathématique).
#let ra-produit(l) = math.equation(block: false, l.map(f => [#f]).join([#sym.times]))

/// Contenu d'une cellule : nombre (texte ou maths), dans une boîte \tccrep si `crep`.
#let ra-contenu(r, v, maths: false) = {
  let c = if v == none { none } else if maths { _m([#v]) } else { [#v] }
  if r.crep and v != none { tccrep(..r.crep-style, r.crep-width, c) } else { c }
}

/// Ancres d'un nœud posé en (x, y) (coin haut-gauche), de taille w × h, ligne de base à `asc` sous le haut.
#let ra-ancres(x, y, w, h, asc) = (
  x: x, y: y, width: w, height: h,
  center: (x + w / 2, y + h / 2),
  north: (x + w / 2, y), south: (x + w / 2, y + h),
  east: (x + w, y + h / 2), west: (x, y + h / 2),
  north-west: (x, y), north-east: (x + w, y),
  south-west: (x, y + h), south-east: (x + w, y + h),
  base: (x + w / 2, y + asc), base-west: (x, y + asc), base-east: (x + w, y + asc),
)

/// Style de la clé `cell` pour la cellule « m-n » ou « 1 ».
#let _cell(r, nom) = if r.cell == none { none } else { r.cell.at(nom, default: none) }

/// Fond, contour et rayon de `picture-style` (show background rectangle, draw=…).
#let _image(r, corps, w, h, cmd) = {
  let st = _st(rd-style(r.picture-style, commande: cmd, cle: "picture-style"), commande: cmd)
  let fond = rd-fond(st, commande: cmd)
  if fond == none { return corps }
  let m = rd-marges(st.cles.at("inset", default: 0.3333em))
  box(width: w, height: h, {
    place(top + left, dx: -m.left, dy: -m.top, rect(
      width: w + m.left + m.right, height: h + m.top + m.bottom, fill: fond, stroke: none,
      radius: st.cles.at("radius", default: 0pt),
    ))
    corps
  })
}

// Couleur de trait par défaut : `draw` de picture-style, sinon noir.
#let _trait-image(r, cmd) = {
  let st = _st(rd-style(r.picture-style, commande: cmd, cle: "picture-style"), commande: cmd)
  let d = st.cles.at("draw", default: none)
  if d == none or d == true { black } else { d }
}

// Aide `overlay` : cellules nommées + `node(point, contenu)`.
#let _overlay(r, cellules) = if r.overlay == none { none } else { (r.overlay)(cellules + (node: rd-node-at)) }

/// Nœud posé à (x, y) (coin haut-gauche).
#let _poser(n, x, y) = place(top + left, dx: x, dy: y, n.corps)

// =====================================================================
// Rangées alignées (environnement aligned : \DecompFPA, \RowPGCD)
// =====================================================================

/// `rangees` : tableau de (gauche: contenu ou none, droite: tableau d'éléments) ; un élément est un contenu
/// ou (n: nœud rd-noeud, id: nom). Renvoie (corps, w, h, ht0, noeuds: id → ancres) ; corps de taille w × h,
/// première ligne de base à ht0 sous le haut.
#let ra-aligne(rangees, sep) = {
  let mesurees = rangees.map(rg => {
    let g = if rg.gauche == none { none } else { rg.gauche }
    let wg = if g == none { 0pt } else { measure(box(g)).width }
    let elements = rg.droite.map(e => if type(e) == dictionary { e } else { (c: e) })
    let largeurs = elements.map(e => if "n" in e { e.n.w } else { measure(box(e.c)).width })
    let hts = elements.map(e => if "n" in e { e.n.asc } else { rd-hauteur(e.c) })
    let dps = elements.map(e => if "n" in e { e.n.h - e.n.asc } else { rd-profondeur(e.c) })
    if g != none {
      hts.push(rd-hauteur(g))
      dps.push(rd-profondeur(g))
    }
    (g: g, wg: wg, el: elements, ws: largeurs, ht: calc.max(0pt, ..hts), dp: calc.max(0pt, ..dps))
  })
  let x0 = calc.max(0pt, ..mesurees.map(m => m.wg))
  let ht0 = mesurees.first().ht
  let noeuds = (:)
  let morceaux = ()
  let largeur = x0
  for (i, m) in mesurees.enumerate() {
    let base = ht0 + i * sep
    if m.g != none { morceaux.push(place(top + left, dx: x0 - m.wg, dy: base - rd-haut-cadre(m.g), m.g)) }
    let x = x0
    for (e, w) in m.el.zip(m.ws) {
      if "n" in e {
        let y = base - e.n.asc
        morceaux.push(place(top + left, dx: x, dy: y, e.n.corps))
        if "id" in e and e.id != none { noeuds.insert(e.id, ra-ancres(x, y, e.n.w, e.n.h, e.n.asc)) }
      } else {
        morceaux.push(place(top + left, dx: x, dy: base - rd-haut-cadre(e.c), e.c))
      }
      x += w
    }
    largeur = calc.max(largeur, x)
  }
  let h = ht0 + (mesurees.len() - 1) * sep + mesurees.last().dp
  (corps: box(width: largeur, height: h, morceaux.join()), w: largeur, h: h, ht0: ht0, noeuds: noeuds)
}

// =====================================================================
// Tableaux (\matrix of nodes : \DecompFPC, \TabDiviseurs, \TabPGCD)
// =====================================================================

/// `grille` : tableau de rangées de nœuds (rd-noeud). Colonnes : largeur maximale, nœuds centrés ;
/// rangées espacées de `sep` entre lignes de base (row sep={…, between origins}). Renvoie les positions.
#let ra-matrice(grille, sep, colsep) = {
  let nc = calc.max(..grille.map(rg => rg.len()))
  let lc = range(nc).map(j => calc.max(0pt, ..grille.map(rg => if j < rg.len() { rg.at(j).w } else { 0pt })))
  let xs = ()
  let x = 0pt
  for w in lc {
    xs.push(x)
    x += w + colsep
  }
  let largeur = x - colsep
  let pos = ()
  let (ymin, ymax) = (0pt, 0pt)
  for (i, rg) in grille.enumerate() {
    let ligne = ()
    for (j, n) in rg.enumerate() {
      let nx = xs.at(j) + (lc.at(j) - n.w) / 2
      let ny = i * sep - n.asc
      ligne.push((x: nx, y: ny, n: n))
      ymin = calc.min(ymin, ny)
      ymax = calc.max(ymax, ny + n.h)
    }
    pos.push(ligne)
  }
  // décalage : haut de la matrice en y = 0
  pos = pos.map(l => l.map(p => p + (y: p.y - ymin)))
  (pos: pos, w: largeur, h: ymax - ymin, base0: -ymin, xs: xs, lc: lc)
}

// Ancres des cellules d'une matrice, nommées « cell m-n » (et « rdarithm-m-n »).
#let _cellules-matrice(m, decalage: (0pt, 0pt)) = {
  let res = (:)
  for (i, l) in m.pos.enumerate() {
    for (j, p) in l.enumerate() {
      let a = ra-ancres(p.x + decalage.at(0), p.y + decalage.at(1), p.n.w, p.n.h, p.n.asc)
      res.insert("cell " + str(i + 1) + "-" + str(j + 1), a)
      res.insert("rdarithm-" + str(i + 1) + "-" + str(j + 1), a)
    }
  }
  res
}

// Libellé (\DecompFPC, \TabDiviseurs : clés label, label-style, prefix-label, suffix-label).
#let _libelle(r, n, cmd) = {
  let st = _st(rd-style(r.label-style, commande: cmd, cle: "label-style"), commande: cmd)
  let c = [#if r.prefix-label != none { r.prefix-label }#n#if r.suffix-label != none { r.suffix-label }]
  rd-noeud(c, st, defaut-inset: 0.3333em, commande: cmd, epaisseur: r.line-width, trait-defaut: _trait-image(r, cmd))
}

/// Tableau à deux colonnes séparées par un trait (\DecompFPC, \TabDiviseurs) : `grille` de nœuds, `n` le
/// nombre décomposé (libellé).
#let ra-tableau-deux(r, grille, n, cmd) = {
  let lw = r.line-width
  let m = ra-matrice(grille, r.level-distance, r.column-sep)
  let label = _choix(r.label, "above")
  let el = ()
  let (dx, dy) = (0pt, 0pt) // position de la matrice dans le bloc
  let lab = none
  let (xmin, xmax, ymin, ymax) = (0pt, m.w, 0pt, m.h)
  let c11 = m.pos.at(0).at(0)
  let base11 = c11.y + c11.n.asc
  if label != "none" {
    lab = _libelle(r, n, cmd)
    let d = r.level-distance + r.label-extrasep
    if label == "left" {
      // ancre base east à (cell 1-1.base west) - d
      lab.x = c11.x - d - lab.w
      lab.y = base11 - lab.asc
    } else {
      let c12 = m.pos.at(0).at(1)
      let xm = (c11.x + c12.x + c12.n.w) / 2
      lab.x = xm - lab.w / 2
      lab.y = base11 - d - lab.asc
    }
    xmin = calc.min(xmin, lab.x)
    xmax = calc.max(xmax, lab.x + lab.w)
    ymin = calc.min(ymin, lab.y)
    ymax = calc.max(ymax, lab.y + lab.h)
  }
  let (ox, oy) = (-xmin, -ymin)
  for l in m.pos { for p in l { el.push(_poser(p.n, p.x + ox, p.y + oy)) } }
  // trait vertical (rdarithm.north) -- (rdarithm.south)
  el.push(place(top + left, line(start: (m.w / 2 + ox, oy), end: (m.w / 2 + ox, m.h + oy), stroke: lw + _trait-image(r, cmd))))
  if lab != none { el.push(_poser(lab, lab.x + ox, lab.y + oy)) }
  let cellules = _cellules-matrice(m, decalage: (ox, oy))
  if lab != none { cellules.insert("arithmlabel", ra-ancres(lab.x + ox, lab.y + oy, lab.w, lab.h, lab.asc)) }
  el.push(_overlay(r, cellules))
  let w = xmax - xmin
  let h = ymax - ymin
  let base = if label == "above" { lab.y + oy + lab.asc } else { base11 + oy }
  box(baseline: h - base, _image(r, box(width: w, height: h, el.join()), w, h, cmd))
}

// Style des cellules : défaut du type, cell-style, cell-append-style (prefix style).
#let _cellule-base(r, defaut, cmd) = rd-style-fusion(defaut, r.cell-style, r.cell-append-style, commande: cmd)
#let _prime(r, cmd) = rd-style-fusion(r.prime-style, r.prime-append-style, commande: cmd)

// Dans un tableau, seuls la police, la couleur du texte et `nodes`
// du style des facteurs premiers agissent sur les cellules (doc rdarithm p. 10).
#let _prime-colonne(r, cmd) = {
  let p = _prime(r, cmd)
  let k = (:)
  for c in ("font", "text", "text-opacity") { if c in p.cles { k.insert(c, p.cles.at(c)) } }
  let nodes = p.cles.at("nodes", default: none)
  rd-style-fusion(k, nodes, commande: cmd)
}

#let _noeud(r, c, st, cmd, courante: none) = rd-noeud(
  if c == none { [] } else { c }, _st(st, courante: courante, commande: cmd),
  commande: cmd, courante: courante, epaisseur: r.line-width, trait-defaut: _trait-image(r, cmd),
)

// =====================================================================
// Commandes
// =====================================================================

/// \ListeFP : facteurs premiers séparés par `separator`.
#let ra-listefp(r, n) = ra-facteurs(n, commande: "ListeFP").map(f => [#f]).join(r.separator)

/// \DecompFP : produit de facteurs premiers (avec puissances si `powers` ≠ none).
#let ra-decompfp(r, n) = {
  let l = ra-facteurs(n, commande: "DecompFP")
  if _choix(r.powers, "bottom") != "none" { ra-avec-puissances(l) } else { ra-produit(l) }
}

// couleur!50 (mélange à 50 % avec du blanc, comme xcolor)
#let xmix-light(c) = {
  let a = rgb(c).components(alpha: false).map(v => v / 100%)
  rgb(..a.map(x => (0.5 * x + 0.5) * 100%))
}

/// Décomposition en étapes alignées, avec boîtes colorées et traits.
#let ra-decompfpa(r, n, cmd: "DecompFPA") = {
  let l = ra-facteurs(n, commande: cmd)
  let k = l.len()
  let couleurs = rd-liste(r.colors)
  let powers = _choix(r.powers, "bottom")
  let vide = rd-style(none)
  let st-noeud = rd-style(r.node-style, commande: cmd, cle: "node-style")
  let rangees = ()
  let laststep = 0
  if k == 1 {
    rangees.push((gauche: _m([#n]), droite: (_egal, _m([#n]))))
  } else {
    laststep = if r.stop == 0 { k } else { calc.min(r.stop + 1, k) }
    let precedents = ()
    let reste = n
    for i in range(1, laststep) {
      let f = l.at(i - 1)
      reste = calc.quo(reste, f)
      let speciale = i < k - 1 and r.decorate
      let droite = (_egal,)
      for p in precedents { droite += (ra-contenu(r, p, maths: true), _fois) }
      droite.push((n: _noeud(r, ra-contenu(r, f, maths: true), vide, cmd), id: str(i) + "-1"))
      droite.push(_fois)
      droite.push((n: _noeud(r, ra-contenu(r, reste, maths: true), if speciale { st-noeud } else { vide }, cmd), id: str(i) + "-2", speciale: speciale))
      precedents.push(f)
      rangees.push((gauche: if i == 1 { _m([#n]) } else { none }, droite: droite))
    }
  }
  if powers == "right" { rangees.last().droite += (_egal, ra-avec-puissances(l)) } else if powers == "bottom" {
    rangees.push((gauche: none, droite: (_egal, ra-avec-puissances(l))))
  }
  let a = ra-aligne(rangees, r.row-sep)
  let el = ()
  // boîtes colorées (special node : fill, opacity, 1pt autour du nœud), derrière le texte
  if r.decorate {
    for (i, rg) in rangees.enumerate() {
      for e in rg.droite {
        if type(e) == dictionary and e.at("speciale", default: false) {
          let c = ra-couleur(rd-cycle(couleurs, i + 1), commande: cmd)
          let b = a.noeuds.at(e.id)
          el.push(place(top + left, dx: b.x - 1pt, dy: b.y - 1pt, rect(
            width: b.width + 2pt, height: b.height + 2pt, stroke: none,
            fill: c.transparentize((1 - r.node-opacity) * 100%),
          )))
        }
      }
    }
  }
  el.push(a.corps)
  // traits (rdarithm line style) : de n-2 à n+1-2
  if r.decorate and laststep - 2 > 0 {
    let lw = r.decoration-line-width
    for i in range(1, laststep - 1) {
      let c = ra-couleur(rd-cycle(couleurs, i), commande: cmd)
      let p = a.noeuds.at(str(i) + "-2")
      let q = a.noeuds.at(str(i + 1) + "-2")
      let (x1, y1) = (p.x - 1.5pt, p.y - 1pt)
      let (y2, x2) = (q.y + q.height + 1.5pt, q.x + q.width + 1pt)
      let trace(dx, dy, couleur, raccourci) = place(top + left, curve(
        stroke: (paint: couleur, thickness: lw),
        curve.move((x1 + dx, y1 + dy + raccourci)),
        curve.line((x1 + dx, y2 + dy)),
        curve.line((x2 + dx - raccourci, y2 + dy)),
      ))
      el.push(trace(lw, -lw, xmix-light(c), lw))
      el.push(trace(0pt, 0pt, c, 0pt))
    }
  }
  let cellules = (:)
  for (id, b) in a.noeuds { cellules.insert(id, b) }
  el.push(_overlay(r, cellules))
  box(baseline: a.h - a.ht0, box(width: a.w, height: a.h, el.join()))
}

/// Arbre de décomposition.
#let ra-decompfpb(r, n, cmd: "DecompFPB") = {
  let l = ra-facteurs(n, commande: cmd)
  let k = l.len()
  let laststep = if r.stop == 0 { k + 1 } else { calc.min(r.stop + 1, k + 1) }
  let base-b = (draw: true, min-width: r.cell-min-width, inset: 0.3333em)
  let st-cell = _cellule-base(r, base-b, cmd)
  let st-prime = _prime(r, cmd)
  let trait = _trait-image(r, cmd)
  let lw = r.line-width
  // nœuds : (nom, nœud, cx, cy)
  let noeuds = ()
  let racine = _noeud(r, [#n], rd-style-fusion(st-cell, _cell(r, "1"), commande: cmd), cmd)
  noeuds.push((nom: "cell 1", n: racine, cx: 0pt, cy: 0pt, parent: none))
  let reste = n
  let (L, S) = (r.level-distance, r.sibling-distance)
  let parent = 0
  for i in range(1, laststep) {
    let f = l.at(i - 1)
    reste = calc.quo(reste, f)
    let px = noeuds.at(parent).cx
    let nf = _noeud(r, ra-contenu(r, f), rd-style-fusion(st-cell, st-prime, _cell(r, str(i + 1) + "-1"), commande: cmd), cmd)
    let nr = _noeud(r, ra-contenu(r, reste), rd-style-fusion(st-cell, _cell(r, str(i + 1) + "-2"), commande: cmd), cmd)
    noeuds.push((nom: "cell " + str(i + 1) + "-1", n: nf, cx: px - S / 2, cy: i * L, parent: parent))
    noeuds.push((nom: "cell " + str(i + 1) + "-2", n: nr, cx: px + S / 2, cy: i * L, parent: parent))
    parent = noeuds.len() - 1
  }
  // boîte englobante (outer sep=0pt : contours compris à moitié, comme TikZ)
  let xmin = calc.min(..noeuds.map(x => x.cx - x.n.w / 2))
  let xmax = calc.max(..noeuds.map(x => x.cx + x.n.w / 2))
  let ymin = calc.min(..noeuds.map(x => x.cy - x.n.h / 2))
  let ymax = calc.max(..noeuds.map(x => x.cy + x.n.h / 2))
  let (ox, oy) = (-xmin, -ymin)
  let el = ()
  // arêtes : du bord du parent au bord de l'enfant, selon la ligne des centres
  for x in noeuds {
    if x.parent == none { continue }
    let p = noeuds.at(x.parent)
    let (dx, dy) = (x.cx - p.cx, x.cy - p.cy)
    let a = rd-bord(p.cx, p.cy, p.n.w / 2, p.n.h / 2, dx, dy)
    let b = rd-bord(x.cx, x.cy, x.n.w / 2, x.n.h / 2, -dx, -dy)
    el.push(place(top + left, line(start: (a.at(0) + ox, a.at(1) + oy), end: (b.at(0) + ox, b.at(1) + oy), stroke: lw + trait)))
  }
  let cellules = (:)
  for x in noeuds {
    let (nx, ny) = (x.cx - x.n.w / 2 + ox, x.cy - x.n.h / 2 + oy)
    el.push(_poser(x.n, nx, ny))
    cellules.insert(x.nom, ra-ancres(nx, ny, x.n.w, x.n.h, x.n.asc))
  }
  el.push(_overlay(r, cellules))
  let (w, h) = (xmax - xmin, ymax - ymin)
  let base = -racine.h / 2 + racine.asc + oy
  box(baseline: h - base, _image(r, box(width: w, height: h, el.join()), w, h, cmd))
}

/// Décomposition en tableau à deux colonnes.
/// Pour un nombre premier p, on écrit « p | p » puis « 1 ».
#let ra-decompfpc(r, n, cmd: "DecompFPC") = {
  let l = ra-facteurs(n, commande: cmd)
  let k = l.len()
  let laststep = if r.stop == 0 { k } else { calc.min(r.stop, k) }
  let base-c = (min-width: r.cell-min-width, inset: 3pt)
  let st-cell = _cellule-base(r, base-c, cmd)
  let st-prime = _prime-colonne(r, cmd)
  let vide = (opacity: 0, text-opacity: 0)
  let grille = ()
  let reste = n
  for (i, f) in l.enumerate() {
    let num = str(i + 1)
    if i < laststep {
      grille.push((
        _noeud(r, ra-contenu(r, reste), rd-style-fusion(st-cell, _cell(r, num + "-1"), commande: cmd), cmd),
        _noeud(r, ra-contenu(r, f), rd-style-fusion(st-cell, st-prime, _cell(r, num + "-2"), commande: cmd), cmd),
      ))
    } else {
      grille.push((
        _noeud(r, none, rd-style-fusion(st-cell, _cell(r, num + "-1"), vide, commande: cmd), cmd),
        _noeud(r, none, rd-style-fusion(st-cell, st-prime, _cell(r, num + "-2"), vide, commande: cmd), cmd),
      ))
    }
    reste = calc.quo(reste, f)
  }
  let num = str(k + 1)
  grille.push((
    if laststep == k { _noeud(r, ra-contenu(r, 1), rd-style-fusion(st-cell, _cell(r, num + "-1"), commande: cmd), cmd) } else {
      _noeud(r, none, rd-style-fusion(st-cell, _cell(r, num + "-1"), vide, commande: cmd), cmd)
    },
    _noeud(r, none, rd-style-fusion(st-cell, st-prime, _cell(r, num + "-2"), vide, commande: cmd), cmd),
  ))
  ra-tableau-deux(r, grille, n, cmd)
}

/// Diviseurs rangés par paires.
#let ra-tabdiviseurs(r, n, cmd: "TabDiviseurs") = {
  let d = ra-diviseurs(n)
  let nb = calc.quo(d.len() + 1, 2)
  let laststep = if r.stop == 0 { nb } else { calc.min(r.stop, nb) }
  let st-cell = _cellule-base(r, (min-width: r.cell-min-width, inset: 3pt), cmd)
  let g = if r.cf > 0 { ra-pgcd(n, r.cf) } else { 0 }
  let style-cf(v) = if r.cf > 0 and calc.rem(r.cf, v) == 0 { if v == g { r.gcd-style } else { r.cf-style } } else { none }
  let vide = (opacity: 0, text-opacity: 0)
  let grille = ()
  for i in range(nb) {
    let (a, b) = (d.at(i), d.at(d.len() - 1 - i))
    let num = str(i + 1)
    if i < laststep {
      grille.push((
        _noeud(r, ra-contenu(r, a), rd-style-fusion(st-cell, style-cf(a), _cell(r, num + "-1"), commande: cmd), cmd),
        _noeud(r, ra-contenu(r, b), rd-style-fusion(st-cell, style-cf(b), _cell(r, num + "-2"), commande: cmd), cmd),
      ))
    } else {
      grille.push((
        _noeud(r, none, rd-style-fusion(st-cell, _cell(r, num + "-1"), vide, commande: cmd), cmd),
        _noeud(r, none, rd-style-fusion(st-cell, _cell(r, num + "-2"), vide, commande: cmd), cmd),
      ))
    }
  }
  ra-tableau-deux(r, grille, n, cmd)
}

/// \ListeDiviseurs : diviseurs séparés par `separator`.
#let ra-listediviseurs(r, n) = ra-diviseurs(n).map(x => [#x]).join(r.separator)

/// Tableau des facteurs premiers de deux nombres, facteurs communs mis en valeur
/// (un seul tableau pour les deux nombres).
#let ra-tabpgcd(r, a, b, cmd: "TabPGCD") = {
  let (la, lb) = ra-colonnes(a, b)
  let nf = la.len()
  let lw = r.line-width
  let vertical = _choix(r.tab-orientation, "horizontal") == "vertical"
  let rules = _choix(r.rules, "all")
  let (hrules, vrules, coef) = if rules == "none" { (false, 0, 1) } else if rules == "all" { (true, 1, 1) } else if rules == "horizontal" {
    (true, 0, 1)
  } else if rules == "Horizontal" { (true, 0, 1.7) } else if rules == "vertical" { (false, 1, 1) } else { (false, 2, 1) }
  let base-d = (min-width: r.cell-min-width, inset: 3pt, min-height: r.level-distance)
  let st-cell = _cellule-base(r, base-d, cmd)
  let entete(v) = [#if r.prefix-header != none { r.prefix-header }#v#if r.suffix-header != none { r.suffix-header }]
  let st-head = rd-style-fusion(r.header-style, commande: cmd)
  // largeur naturelle des entêtes (+ 10 %)
  let lh = calc.max(..(a, b).map(v => rd-noeud(entete(v), _st(rd-style-fusion(st-cell, st-head, (inset: 0pt, min-width: 0pt), commande: cmd), commande: cmd), commande: cmd).w)) * 1.1
  let forcees-h = none
  let forcees-c = none
  let ix = r.inner-xsep
  if r.forced-width > 0pt {
    let rl = if vrules == 1 { lw } else { 0pt }
    if not vertical {
      let hw = if r.header-width == 0pt { lh } else { r.header-width }
      let cw = (r.forced-width - 2 * (nf + 1) * ix - hw - rl) / nf
      forcees-h = (text-width: hw, inset: (x: ix, y: 3pt), min-width: 0pt)
      forcees-c = (text-width: cw, inset: (x: ix, y: 3pt), min-width: 0pt, align: "center")
    } else {
      let cw = (r.forced-width - 4 * ix - rl) / 2
      forcees-h = (text-width: cw, inset: (x: ix, y: 3pt), min-width: 0pt, align: "center")
      forcees-c = forcees-h
    }
  } else if vertical {
    forcees-h = (text-width: lh, align: "center")
    forcees-c = forcees-h
  }
  let cellule(v, ligne, col, commun) = {
    let nom = str(ligne) + "-" + str(col)
    // case vide : \phantom{0}, dans le conteneur \tccrep comme les autres
    let c = if v == 0 {
      if r.crep { tccrep(..r.crep-style, r.crep-width, hide([0])) } else { hide([0]) }
    } else { ra-contenu(r, v) }
    _noeud(r, c, rd-style-fusion(st-cell, if commun { r.gcd-style } else { none }, _cell(r, nom), forcees-c, commande: cmd), cmd)
  }
  // avec crep : entête à la hauteur et à la profondeur d'une boîte \tccrep
  let tete-crep = if r.crep { rd-boite(tccrep(..r.crep-style, r.crep-width, [0])) } else { none }
  let tete(v, nom, al) = _noeud(r, entete(v), rd-style-fusion(
    st-cell,
    if tete-crep != none { (text-height: tete-crep.ht, text-depth: tete-crep.dp) },
    (align: al),
    st-head, _cell(r, nom), forcees-h, commande: cmd), cmd)
  let grille = ()
  if not vertical {
    let ra = (tete(a, "1-1", "left"),)
    let rb = (tete(b, "2-1", "left"),)
    for i in range(nf) {
      let commun = la.at(i) == lb.at(i)
      ra.push(cellule(la.at(i), 1, i + 2, commun))
      rb.push(cellule(lb.at(i), 2, i + 2, commun))
    }
    grille = (ra, rb)
  } else {
    grille.push((tete(a, "1-1", "center"), tete(b, "1-2", "center")))
    for i in range(nf) {
      let commun = la.at(i) == lb.at(i)
      grille.push((cellule(la.at(i), i + 2, 1, commun), cellule(lb.at(i), i + 2, 2, commun)))
    }
  }
  let m = ra-matrice(grille, r.level-distance, 0pt)
  let el = ()
  for l in m.pos { for p in l { el.push(_poser(p.n, p.x, p.y)) } }
  let couleur = ra-couleur(r.rule-color, commande: cmd)
  let trait(e) = (paint: couleur, thickness: e)
  let seg(x1, y1, x2, y2, e) = place(top + left, line(start: (x1, y1), end: (x2, y2), stroke: trait(e)))
  let P(i, j) = m.pos.at(i).at(j)
  let ext = if hrules { lw / 2 } else { 0pt }
  if not vertical {
    let n1 = nf + 1
    let (x0, x1) = (P(0, 0).x, P(0, n1 - 1).x + P(0, n1 - 1).n.w)
    if hrules {
      el.push(seg(x0, P(0, 0).y, x1, P(0, 0).y, coef * lw))
      el.push(seg(x0, P(0, 0).y + P(0, 0).n.h, x1, P(0, 0).y + P(0, 0).n.h, lw))
      el.push(seg(x0, P(1, 0).y + P(1, 0).n.h, x1, P(1, 0).y + P(1, 0).n.h, coef * lw))
    }
    if vrules == 1 {
      for j in range(n1) { el.push(seg(P(0, j).x, P(0, j).y - ext, P(1, j).x, P(1, j).y + P(1, j).n.h + ext, lw)) }
      let q = P(0, n1 - 1)
      el.push(seg(q.x + q.n.w, q.y - ext, q.x + q.n.w, P(1, n1 - 1).y + P(1, n1 - 1).n.h + ext, lw))
    }
  } else {
    let n1 = nf + 1
    let (x0, x1) = (P(0, 0).x, P(0, 1).x + P(0, 1).n.w)
    if hrules {
      for i in range(n1) { el.push(seg(x0, P(i, 0).y, x1, P(i, 0).y, lw)) }
      let q = P(n1 - 1, 0)
      el.push(seg(x0, q.y + q.n.h, x1, q.y + q.n.h, lw))
    }
    if vrules == 1 {
      let yb = P(n1 - 1, 0).y + P(n1 - 1, 0).n.h
      el.push(seg(x0, -ext, x0, yb + ext, lw))
      el.push(seg(m.w / 2, -ext, m.w / 2, m.h + ext, lw))
      el.push(seg(x1, -ext, x1, yb + ext, lw))
    } else if vrules == 2 { el.push(seg(m.w / 2, 0pt, m.w / 2, m.h, lw)) }
  }
  el.push(_overlay(r, _cellules-matrice(m)))
  let base = P(0, 0).y + P(0, 0).n.asc
  box(baseline: m.h - base, _image(r, box(width: m.w, height: m.h, el.join()), m.w, m.h, cmd))
}

/// Facteurs de A et de B en ligne, facteurs communs en nœuds colorés (\rdarithm@CodeCommun@i).
/// Renvoie (num, den) : tableaux d'éléments pour ra-aligne, et le nombre de couples communs.
#let ra-lignes-communes(r, a, b, link, cmd) = {
  let (la, lb) = ra-colonnes(a, b)
  let couleurs = rd-liste(r.colors)
  let (num, den) = ((), ())
  let (ia, ib) = (1, 1)
  for (fa, fb) in la.zip(lb) {
    for (f, liste, ligne) in ((fa, "num", 1), (fb, "den", 2)) {
      if f == 0 { continue }
      let cible = if liste == "num" { num } else { den }
      if cible.len() > 0 { cible.push(_fois) }
      if fa == fb {
        let idx = if ligne == 1 { ia } else { ib }
        let col = ra-couleur(rd-cycle(couleurs, idx), commande: cmd)
        let bulle = if link == "bubble" { (shape: "circle", fill: col) } else { none }
        let st = rd-style-fusion(r.cf-style, _cell(r, str(ligne) + "-" + str(idx)), bulle, commande: cmd)
        let nd = _noeud(r, ra-contenu(r, f, maths: true), st, cmd, courante: col)
        if link == "bubble" {
          // postaction={draw=arithmcol, line width=0.7pt}
          let d = nd.w
          nd.corps = box(width: nd.w, height: nd.h, {
            nd.corps
            place(top + left, circle(radius: d / 2, stroke: r.bubble-line-width + col))
          })
        }
        cible.push((n: nd, id: str(ligne) + "-" + str(idx), couleur: col))
        if ligne == 1 { ia += 1 } else { ib += 1 }
      } else {
        cible.push(ra-contenu(r, f, maths: true))
      }
      if liste == "num" { num = cible } else { den = cible }
    }
  }
  (num: num, den: den, communs: ia - 1)
}

/// Point du bord d'un nœud (ancres) dans la direction (dx, dy) : rectangle ou cercle.
#let _bord(a, dx, dy, cercle: false) = {
  let (cx, cy) = a.center
  if cercle {
    let d = calc.sqrt(calc.pow(dx / 1pt, 2) + calc.pow(dy / 1pt, 2))
    if d == 0 { return (cx, cy) }
    let rr = a.width / 2
    return (cx + dx / 1pt / d * rr, cy + dy / 1pt / d * rr)
  }
  rd-bord(cx, cy, a.width / 2, a.height / 2, dx, dy)
}

/// Décompositions alignées et liens entre facteurs communs.
#let ra-rowpgcd(r, a, b, cmd: "RowPGCD") = {
  let link = _choix(r.link, "bubble")
  let lc = ra-lignes-communes(r, a, b, link, cmd)
  let al = ra-aligne(
    ((gauche: _m([#a]), droite: (_egal,) + lc.num), (gauche: _m([#b]), droite: (_egal,) + lc.den)),
    r.row-sep,
  )
  let couleurs = rd-liste(r.colors)
  let el = ()
  for i in range(1, lc.communs + 1) {
    let x = al.noeuds.at("1-" + str(i))
    let y = al.noeuds.at("2-" + str(i))
    let col = ra-couleur(rd-cycle(couleurs, i), commande: cmd)
    if link == "line" {
      let st = _st(rd-style-fusion(r.line-style, (draw: col, line-width: r.line-width), (if r.to == none { (:) } else { r.to }).at(str(i), default: none), commande: cmd), courante: col, commande: cmd)
      let k = st.cles
      let tr = rd-trait(st, defaut: col, epaisseur: r.line-width, commande: cmd, courante: col)
      let sh = k.at("shorten", default: 0pt)
      let (cx1, cy1) = x.center
      let (cx2, cy2) = y.center
      if "out" in k or "in" in k {
        let o = k.at("out", default: -90) * 1deg
        let ii = k.at("in", default: 90) * 1deg
        let p1 = _bord(x, calc.cos(o) * 1pt, -calc.sin(o) * 1pt)
        let p2 = _bord(y, calc.cos(ii) * 1pt, -calc.sin(ii) * 1pt)
        let d = calc.sqrt(calc.pow((p2.at(0) - p1.at(0)) / 1pt, 2) + calc.pow((p2.at(1) - p1.at(1)) / 1pt, 2)) * 1pt * 0.3915
        el.push(place(top + left, curve(
          stroke: tr,
          curve.move(p1),
          curve.cubic(
            (p1.at(0) + d * calc.cos(o), p1.at(1) - d * calc.sin(o)),
            (p2.at(0) + d * calc.cos(ii), p2.at(1) - d * calc.sin(ii)),
            p2,
          ),
        )))
      } else {
        let p1 = _bord(x, cx2 - cx1, cy2 - cy1)
        let p2 = _bord(y, cx1 - cx2, cy1 - cy2)
        let (ux, uy) = (p2.at(0) - p1.at(0), p2.at(1) - p1.at(1))
        let dl = calc.sqrt(calc.pow(ux / 1pt, 2) + calc.pow(uy / 1pt, 2))
        let (ex, ey) = if dl == 0 { (0pt, 0pt) } else { (ux / 1pt / dl * sh, uy / 1pt / dl * sh) }
        el.push(place(top + left, line(start: (p1.at(0) + ex, p1.at(1) + ey), end: (p2.at(0) - ex, p2.at(1) - ey), stroke: tr)))
      }
    } else if link == "bubble" {
      // circle connection bar : deux disques reliés par une barre (derrière les nœuds)
      el.push(place(top + left, line(start: x.center, end: y.center, stroke: (paint: col, thickness: r.bubble-width, cap: "round"))))
    }
  }
  el.push(al.corps)
  el.push(_overlay(r, al.noeuds.pairs().map(((k, v)) => ("cell " + k, v)).to-dict()))
  box(baseline: al.h - al.ht0, box(width: al.w, height: al.h, el.join()))
}

/// Fraction dont numérateur et dénominateur sont décomposés, facteurs communs mis en
/// valeur (`link: "none"` imposé).
#let ra-decompfrac(r, a, b, cmd: "DecompFrac") = {
  let lc = ra-lignes-communes(r, a, b, "none", cmd)
  let mode = _choix(r.frac-mode, "dfrac")
  context {
    // Les facteurs mis en valeur sont des nœuds composés à part (formule à part entière) : la
    // fraction en ligne (`frac-mode: "frac"`) réduit son texte, pas eux. On leur applique la même
    // réduction, mesurée sur la police mathématique courante (numérateur d'une fraction en ligne).
    let k = if mode == "dfrac" { 1 } else {
      let chiffres = $0000000000000000000000000000000000000000$
      let q = measure($inline(frac(#chiffres, 1))$).width / measure(chiffres).width
      if q > 0.97 { 1 } else { q }
    }
    let noeud(n) = if k == 1 { rd-noeud-en-ligne(n) } else {
      let s = scale(k * 100%, reflow: true, n.corps)
      box(baseline: (n.h - n.asc) * k, s)
    }
    let ligne(l) = l.map(e => if type(e) == dictionary { noeud(e.n) } else { e }).join()
    let f = math.frac(ligne(lc.num), ligne(lc.den))
    math.equation(block: false, if mode == "dfrac" { math.display(f) } else { math.inline(f) })
  }
}

/// \pgcd / \ppcm (non étoilées) : PGCD(a ; b).
#let ra-ecrire(nom, a, b) = $op(nom) lr((#a thin ";" thin #b))$
