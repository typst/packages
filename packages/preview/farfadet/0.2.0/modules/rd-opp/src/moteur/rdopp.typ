// rdopp.typ (moteur) — opérations posées à la française : addition à plusieurs termes, soustraction,
// multiplication, division. Chaque opération est d'abord CALCULÉE en une grille de cellules (lignes de
// cellules `(c: contenu, calc: bool, zero: bool, role: …, marque: …)`) plus une liste de décorations
// (traits, virgules, potence, pont) ; la grille est ensuite DESSINÉE (`rdopp-dessiner`).
//
// Numérotation : les lignes et colonnes de la grille sont celles de la clé `cell` (ligne 1 = première
// ligne de la grille, colonne 1 = colonne des signes).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, reglages-resoudre, reglages-courants,
  bf-reglages-socle, est-correction, bf-xcolor,
)
#import "commun.typ": *

// =====================================================================
// Réglages (\setrdopp)
// =====================================================================

#let _style = rd-controle-style
#let _ex = 0.4333em // 1ex dans la police courante
#let _entier-pos = (v => type(v) == int and v >= 0, "un entier positif ou nul")
#let _lg-ou-none = reglages-controles.longueur-ou-none

#let _controle-cell = (
  v => v == none or type(v) in (array, dictionary),
  "none, un dictionnaire (rows, cols, style) ou un tableau de tels dictionnaires ou de triplets (lignes, colonnes, style)",
)

#let rdopp-reglages = reglages-paquet(
  "rdopp",
  (
    operation: "add",
    add: false,
    sub: false,
    mul: false,
    div: false,
    divint: false,
    precision: 2,
    add-symbol: $+$,
    sub-symbol: $-$,
    mul-symbol: $times$,
    matrix-name: none,
    hbar: "auto",
    vbar: "auto",
    vbar-leftsep: none,
    vbar-rightsep: none,
    vbar-sep: none,
    decimal-sep: [,],
    baseline: 1,
    carry: false,
    zero: false,
    carry-style: none,
    top-carry-style: none,
    bot-carry-style: none,
    carry-font: "tiny",
    zero-style: none,
    bar-style: none,
    subbar-style: none,
    bridge: false,
    bridge-style: none,
    offset-char: none,
    mul-zero-lines: false,
    intermediary: true,
    correction: false,
    tikz: none,
    matrix: none,
    seyes: false,
    grid: false,
    grid-width: 0.4pt,
    grid-color: "gray",
    lw: 0.8pt,
    cell-width: 2 * _ex,
    cell-height: 2 * _ex,
    cell-depth: 0.5 * _ex,
    cell: none,
    // réglages ajoutés
    row-sep: none,
    column-sep: none,
    matrix-inset: 0.3333em,
    overlay: none,
  ),
  controles: (
    operation: reglages-choix("add", "addition", "sub", "soustraction", "mul", "multiplication", "div"),
    add: reglages-controles.booleen,
    sub: reglages-controles.booleen,
    mul: reglages-controles.booleen,
    div: reglages-controles.booleen,
    divint: reglages-controles.booleen,
    precision: _entier-pos,
    add-symbol: reglages-controles.contenu,
    sub-symbol: reglages-controles.contenu,
    mul-symbol: reglages-controles.contenu,
    matrix-name: (v => v == none or type(v) == str, "none ou une chaîne (nom du label Typst posé sur l'opération)"),
    hbar: reglages-ou(reglages-choix("auto"), _entier-pos),
    vbar: reglages-ou(reglages-choix("auto", "max"), _entier-pos),
    vbar-leftsep: _lg-ou-none,
    vbar-rightsep: _lg-ou-none,
    vbar-sep: _lg-ou-none,
    decimal-sep: reglages-controles.contenu,
    baseline: reglages-ou(reglages-choix("t", "c", "b"), (v => type(v) == int and v >= 1, "un entier ≥ 1 (numéro de ligne)")),
    carry: reglages-controles.booleen,
    zero: reglages-controles.booleen,
    carry-style: _style,
    top-carry-style: _style,
    bot-carry-style: _style,
    carry-font: (
      v => v == none or type(v) in (dictionary, function, str, length),
      "none, un dictionnaire de police (size, weight…), une taille LaTeX (\"scriptsize\"), une longueur ou une fonction",
    ),
    zero-style: _style,
    bar-style: _style,
    subbar-style: _style,
    bridge: reglages-controles.booleen,
    bridge-style: _style,
    offset-char: reglages-controles.contenu-ou-none,
    mul-zero-lines: reglages-controles.booleen,
    intermediary: reglages-controles.booleen,
    correction: reglages-controles.booleen,
    tikz: _style,
    matrix: _style,
    seyes: reglages-controles.booleen,
    grid: reglages-controles.booleen,
    grid-width: reglages-controles.longueur,
    grid-color: reglages-controles.couleur-ou-nom,
    lw: reglages-controles.longueur,
    cell-width: reglages-controles.longueur,
    cell-height: reglages-controles.longueur,
    cell-depth: reglages-controles.longueur,
    cell: _controle-cell,
    row-sep: _lg-ou-none,
    column-sep: _lg-ou-none,
    matrix-inset: (v => type(v) in (length, dictionary), "une longueur ou un dictionnaire (left, right, top, bottom, x, y)"),
    overlay: (v => v == none or type(v) == function, "none ou une fonction (cellules) => contenu"),
  ),
  commande: "setrdopp",
)

// =====================================================================
// Lecture des nombres
// =====================================================================

/// Lit un nombre positif écrit avec un point (ou une virgule) décimal : (ent: chiffres, dec: chiffres).
#let rdopp-lire-nombre(v, commande: "rdopp") = {
  let s = if type(v) == str { v } else if type(v) in (int, float) { str(v) } else {
    panic(commande + " : un nombre s'écrit comme un entier, un décimal ou une chaîne (\"12.5\") ; reçu : " + repr(v) + ".")
  }
  let s = s.trim().replace(",", ".")
  if s.match(regex("^[0-9]*\.?[0-9]*$")) == none or s.find(regex("[0-9]")) == none {
    panic(commande + " : nombre illisible " + repr(v) + ". Attendu : un nombre positif écrit avec des chiffres et un point décimal (\"12.5\").")
  }
  let p = s.split(".")
  let ent = p.at(0)
  if ent == "" { ent = "0" }
  let dec = p.slice(1).join("")
  (ent: ent, dec: if dec == none { "" } else { dec })
}

/// Liste de nombres à partir des arguments positionnels : un seul argument chaîne « 12.5, 3.45 » (la
/// virgule sépare les nombres), un tableau, ou plusieurs nombres / chaînes (virgule décimale permise).
#let rdopp-lire-liste(args, commande: "rdopp") = {
  let l = ()
  if args.len() == 1 and type(args.first()) == str {
    l = args.first().split(",").map(x => x.trim()).filter(x => x != "")
  } else {
    for a in args {
      if type(a) == array { l += a } else { l.push(a) }
    }
  }
  if l.len() == 0 { panic(commande + " : aucun nombre à poser. Écrire par exemple rdopp(\"12.5, 3.45\") ou rdopp(12, 345).") }
  l
}

#let _cmp-decimaux(a, b) = {
  // -1, 0 ou 1 selon que a < b, a = b, a > b (comparaison exacte, sans flottants)
  let dm = calc.max(a.dec.len(), b.dec.len())
  let sa = a.ent + a.dec + "0" * (dm - a.dec.len())
  let sb = b.ent + b.dec + "0" * (dm - b.dec.len())
  let n = calc.max(sa.len(), sb.len())
  let sa = "0" * (n - sa.len()) + sa
  let sb = "0" * (n - sb.len()) + sb
  if sa < sb { -1 } else if sa > sb { 1 } else { 0 }
}

/// Plages de la clé `cell` : entier, « 2-4 », « 1,3 », « -3 », « 2- », ou tableau de ces formes.
#let rdopp-plage(v, maxi, commande: "rdopp") = {
  if type(v) == int { return (v,) }
  if type(v) == array { return v.map(x => rdopp-plage(x, maxi, commande: commande)).flatten() }
  if type(v) != str {
    panic(commande + " : une plage de lignes ou de colonnes est un entier, une chaîne comme \"2-4\" ou \"1,3\", ou un tableau ; reçu : " + repr(v) + ".")
  }
  let res = ()
  for part in v.split(",") {
    let p = part.trim()
    if p == "" { continue }
    if "-" in p {
      let ab = p.split("-")
      let a = if ab.at(0).trim() == "" { 1 } else { int(ab.at(0).trim()) }
      let b = if ab.at(1).trim() == "" { maxi } else { int(ab.at(1).trim()) }
      res += range(a, b + 1)
    } else { res.push(int(p)) }
  }
  res
}

// =====================================================================
// Cellules
// =====================================================================

#let _c(c, calc: false, zero: false, role: none, marque: none) = (c: c, calc: calc, zero: zero, role: role, marque: marque)
#let _vide() = _c(none)

// =====================================================================
// Addition (plusieurs termes)
// =====================================================================

#let _op-add(r, parts, commande) = {
  let n = parts.len()
  let ic = if r.carry { 1 } else { 0 }
  let ires = ic + n + 1
  let imax = calc.max(..parts.map(p => p.ent.len()))
  let dmax = calc.max(..parts.map(p => p.dec.len()))
  let cu = imax + 2
  let cm = cu + dmax
  let lig = ()
  let zer = ()
  for p in parts {
    let d = (:)
    let e = p.ent.clusters()
    for (i, ch) in e.enumerate() { d.insert(str(cu - e.len() + i + 1), ch) }
    for (i, ch) in p.dec.clusters().enumerate() { d.insert(str(cu + i + 1), ch) }
    lig.push(d)
    zer.push((:))
  }
  if r.zero {
    for k in range(n) {
      for col in range(cu - imax + 1, cm + 1) {
        if str(col) not in lig.at(k) {
          lig.at(k).insert(str(col), "0")
          zer.at(k).insert(str(col), true)
        }
      }
    }
  }
  let res = (:)
  let car = (:)
  let rep = 0
  for col in range(cm, 1, step: -1) {
    let t = rep
    for d in lig { if str(col) in d { t += int(d.at(str(col))) } }
    rep = calc.quo(t, 10)
    if rep > 0 { car.insert(str(col - 1), rep) }
    let ecrit = if col == cu { true } else if col < cu { col > cu - imax or t > 0 } else { lig.any(d => str(col) in d) }
    if ecrit { res.insert(str(col), calc.rem(t, 10)) }
  }
  if rep > 0 { res.insert("1", rep) }
  let utilise2 = "2" in res
  let cols = range(1, cm + 1).filter(c => utilise2 or c != 2)
  let nc(c) = cols.position(x => x == c) + 1
  let rows = ()
  if r.carry {
    rows.push(cols.map(c => {
      let v = car.at(str(c), default: none)
      _c(if v == none { none } else { str(v) }, calc: true, role: "retenue")
    }))
  }
  for k in range(n) {
    rows.push(cols.map(c => {
      if c == 1 and k >= 1 { return _c(r.add-symbol) }
      let z = zer.at(k).at(str(c), default: false)
      _c(lig.at(k).at(str(c), default: none), zero: z, calc: z)
    }))
  }
  rows.push(cols.map(c => {
    let v = res.at(str(c), default: none)
    _c(if v == none { none } else { str(v) }, calc: true)
  }))
  let decos = ()
  for k in range(n) {
    if parts.at(k).dec.len() > 0 or (r.zero and dmax > 0) {
      decos.push((genre: "virgule", row: ic + k + 1, col: nc(cu), calc: false))
    }
  }
  if dmax > 0 { decos.push((genre: "virgule", row: ires, col: nc(cu), calc: true)) }
  let hb = if r.hbar == "auto" { 0 } else { r.hbar }
  decos.push((genre: "trait", kind: "bar", row: ires - 1, c1: calc.max(1, 2 + hb), c2: cols.len(), calc: false))
  (rows: rows, decos: decos, sepcol: none)
}

// =====================================================================
// Soustraction
// =====================================================================

#let _op-sub(r, parts, commande) = {
  let (a, b) = parts
  let imax = calc.max(a.ent.len(), b.ent.len())
  let dmax = calc.max(a.dec.len(), b.dec.len())
  let cu = imax + 1
  let cm = cu + dmax
  let poser(p) = {
    let d = (:)
    let e = p.ent.clusters()
    for (i, ch) in e.enumerate() { d.insert(str(cu - e.len() + i + 1), ch) }
    for (i, ch) in p.dec.clusters().enumerate() { d.insert(str(cu + i + 1), ch) }
    d
  }
  let l1 = poser(a)
  let l2 = poser(b)
  let z1 = (:)
  let z2 = (:)
  if r.zero {
    for col in range(2, cm + 1) {
      if str(col) not in l1 { l1.insert(str(col), "0"); z1.insert(str(col), true) }
      if str(col) not in l2 { l2.insert(str(col), "0"); z2.insert(str(col), true) }
    }
  }
  let res = (:)
  let ct = (:)
  let cb = (:)
  if _cmp-decimaux(a, b) < 0 {
    for col in range(1, cm + 1) {
      if col == cu or str(col) in l1 or str(col) in l2 { res.insert(str(col), "?") }
    }
  } else {
    let rep = 0
    for col in range(cm, 1, step: -1) {
      let x = int(l1.at(str(col), default: "0"))
      let y = int(l2.at(str(col), default: "0"))
      let d = x - (y + rep)
      if d < 0 {
        d += 10
        ct.insert(str(col), true)
        cb.insert(str(col - 1), true)
        rep = 1
      } else { rep = 0 }
      let ecrit = if col == cu { true } else if col < cu { col > cu - imax or d > 0 } else { str(col) in l1 or str(col) in l2 }
      if ecrit { res.insert(str(col), str(d)) }
    }
  }
  let rows = (
    range(1, cm + 1).map(c => {
      let z = z1.at(str(c), default: false)
      _c(l1.at(str(c), default: none), zero: z, calc: z, marque: if r.carry and str(c) in ct { "haut" } else { none })
    }),
    range(1, cm + 1).map(c => {
      if c == 1 { return _c(r.sub-symbol) }
      let z = z2.at(str(c), default: false)
      _c(l2.at(str(c), default: none), zero: z, calc: z, marque: if r.carry and str(c) in cb { "bas" } else { none })
    }),
    range(1, cm + 1).map(c => _c(res.at(str(c), default: none), calc: true)),
  )
  let decos = ()
  if a.dec.len() > 0 or (r.zero and dmax > 0) { decos.push((genre: "virgule", row: 1, col: cu, calc: false)) }
  if b.dec.len() > 0 or (r.zero and dmax > 0) { decos.push((genre: "virgule", row: 2, col: cu, calc: false)) }
  if dmax > 0 { decos.push((genre: "virgule", row: 3, col: cu, calc: true)) }
  let hb = if r.hbar == "auto" { 0 } else { r.hbar }
  decos.push((genre: "trait", kind: "bar", row: 2, c1: calc.max(1, 2 + hb), c2: cm, calc: false))
  (rows: rows, decos: decos, sepcol: none)
}

// =====================================================================
// Multiplication
// =====================================================================

/// Retenues d'une colonne de la multiplication : les précédentes sont barrées (`\rlap{/}`), la dernière non.
#let _retenues-mul(liste) = {
  let el = ()
  for (i, v) in liste.enumerate() {
    if i < liste.len() - 1 {
      el.push(box(width: 0pt, "/"))
      el.push(str(v))
      el.push(h(0.3333em))
    } else { el.push(str(v)) }
  }
  el.join()
}

#let _op-mul(r, parts, commande) = {
  let (p1, p2) = parts
  let v1 = (p1.ent + p1.dec).clusters()
  let v2 = (p2.ent + p2.dec).clusters()
  let na = v1.len()
  let nb = v2.len()
  let ic = if r.carry { 1 } else { 0 }
  let i2 = ic + 2
  let dmax = p1.dec.len() + p2.dec.len()
  let cm = na + nb + 1
  let l1 = (:)
  for (i, ch) in v1.enumerate() { l1.insert(str(cm - na + i + 1), ch) }
  let l2 = (:)
  for (i, ch) in v2.enumerate() { l2.insert(str(cm - nb + i + 1), ch) }
  let lignes = ()
  let car = (:)
  let decal = 0
  for j in range(nb - 1, -1, step: -1) {
    let c = int(v2.at(j))
    if c != 0 or r.mul-zero-lines {
      let row = (:)
      let rep = 0
      for k in range(1, decal + 1) { row.insert(str(cm - k + 1), "off") }
      let cur = cm - decal
      for i in range(na - 1, -1, step: -1) {
        let e = int(v1.at(i)) * c + rep
        rep = calc.quo(e, 10)
        row.insert(str(cur), calc.rem(e, 10))
        if rep > 0 {
          let cc = str(cm - na + i)
          car.insert(cc, car.at(cc, default: ()) + (rep,))
        }
        cur -= 1
      }
      if rep > 0 { row.insert(str(cur), rep) }
      lignes.push(row)
    }
    decal += 1
  }
  if lignes.len() == 0 { { let z0 = (:); z0.insert(str(cm), 0); lignes.push(z0) } }
  let nlig = lignes.len()
  let res = (:)
  if nlig == 1 {
    for (k, v) in lignes.first() { res.insert(k, if v == "off" { 0 } else { v }) }
  } else {
    let rep = 0
    for col in range(cm, 0, step: -1) {
      let t = rep
      let vu = false
      for row in lignes {
        if str(col) in row {
          let v = row.at(str(col))
          t += if v == "off" { 0 } else { v }
          vu = true
        }
      }
      if vu or t > 0 {
        res.insert(str(col), calc.rem(t, 10))
        rep = calc.quo(t, 10)
      } else { rep = 0 }
    }
  }
  // zéros de tête manquants jusqu'à la colonne des unités (0,5 × 0,5 donne 0,25 et non ,25)
  if dmax > 0 and res.len() > 0 {
    let bas = calc.min(..res.keys().map(k => int(k)))
    for c in range(calc.max(2, cm - dmax), bas) { res.insert(str(c), 0) }
  }
  let utilise2 = "2" in res
  let cols = range(1, cm + 1).filter(c => utilise2 or c != 2)
  let ncol = cols.len()
  let rows = ()
  if r.carry {
    rows.push(cols.map(c => {
      let l = car.at(str(c), default: none)
      _c(if l == none { none } else { _retenues-mul(l) }, calc: true, role: "retenue")
    }))
  }
  rows.push(cols.map(c => _c(l1.at(str(c), default: none))))
  rows.push(cols.map(c => if c == 1 { _c(r.mul-symbol) } else { _c(l2.at(str(c), default: none)) }))
  if r.intermediary or nlig == 1 {
    for (idx, row) in lignes.enumerate() {
      rows.push(cols.map(c => {
        if c == 1 { return _c(if nlig > 1 and idx > 0 { r.add-symbol } else { none }, calc: true) }
        let v = if nlig == 1 { res.at(str(c), default: none) } else { row.at(str(c), default: none) }
        let txt = if v == "off" { r.offset-char } else if v == none { none } else { str(v) }
        _c(txt, calc: true)
      }))
    }
  }
  if nlig > 1 {
    rows.push(cols.map(c => {
      let v = res.at(str(c), default: none)
      _c(if v == none { none } else { str(v) }, calc: true)
    }))
  }
  let decos = ()
  if p1.dec.len() > 0 { decos.push((genre: "virgule", row: ic + 1, col: ncol - p1.dec.len(), calc: false)) }
  if p2.dec.len() > 0 { decos.push((genre: "virgule", row: ic + 2, col: ncol - p2.dec.len(), calc: false)) }
  if dmax > 0 {
    let lr = if r.intermediary and nlig > 1 { i2 + nlig + 1 } else { i2 + 1 }
    decos.push((genre: "virgule", row: lr, col: ncol - dmax, calc: true))
  }
  let hb = if r.hbar == "auto" { 0 } else { r.hbar }
  decos.push((genre: "trait", kind: "bar", row: i2, c1: calc.max(1, 2 + hb), c2: ncol, calc: false))
  if r.intermediary and nlig > 1 {
    decos.push((genre: "trait", kind: "bar", row: i2 + nlig, c1: calc.max(1, 2 + hb), c2: ncol, calc: true))
  }
  (rows: rows, decos: decos, sepcol: none)
}

// =====================================================================
// Division
// =====================================================================

#let _op-div(r, nombres, commande) = {
  let p = rdopp-lire-nombre(nombres.at(0), commande: commande)
  let ds = if type(nombres.at(1)) == str { nombres.at(1).trim() } else { str(nombres.at(1)) }
  if ds.match(regex("^[0-9]+$")) == none or int(ds) == 0 {
    panic(commande + " : le diviseur d'une division posée est un entier strictement positif ; reçu : " + repr(nombres.at(1)) + ".")
  }
  let dv = int(ds)
  let raw = (p.ent + p.dec).clusters()
  let ic = p.ent.len()
  // premier dividende partiel : le plus petit nombre de chiffres qui contient le diviseur
  let L = 1
  let trouve = false
  while not trouve and L <= ic {
    if int(raw.slice(0, L).join()) >= dv { trouve = true } else { L += 1 }
  }
  if L > ic { L = ic }
  let W = int(raw.slice(0, L).join())
  let pp = L
  let C = L + 1
  let ajoutes = 0
  let quo = ""
  let pas = ()
  let M = C - L
  let stop = false
  let garde = 0
  while not stop and garde < 500 {
    garde += 1
    let q = calc.quo(W, dv)
    quo += str(q)
    let S = q * dv
    let R = W - S
    if pp >= ic {
      let nd = quo.len() - (ic - L + 1)
      if nd >= r.precision { stop = true } else if pp >= raw.len() and R == 0 { stop = true }
    }
    if stop {
      pas.push((C: C, S: str(S), R: str(R), N: "", M: M))
    } else {
      let nx = if pp < raw.len() { raw.at(pp) } else { ajoutes += 1; "0" }
      pas.push((C: C, S: str(S), R: str(R), N: nx, M: M))
      W = R * 10 + int(nx)
      M = C - str(R).len()
      pp += 1
      C += 1
    }
  }
  let total-k = raw.len() + ajoutes
  let sr = total-k + 2
  let dlen = ds.len()
  let qlen = quo.len()
  let hb = if r.hbar == "auto" { calc.max(dlen, qlen) } else { r.hbar }
  let tc = sr + calc.max(dlen, qlen, hb) - 1
  let qd = quo.clusters()
  let dd = ds.clusters()
  let rows = ()
  rows.push(range(1, tc + 1).map(col => {
    let c = none
    let z = false
    if col >= 2 and col <= total-k + 1 {
      let idx = col - 1
      if idx <= raw.len() { c = raw.at(idx - 1) } else { c = "0"; z = true }
    }
    if col >= sr and col < sr + dlen { c = dd.at(col - sr) }
    _c(c, zero: z, calc: z)
  }))
  for (k, s) in pas.enumerate() {
    let sc = s.S.clusters()
    let rc = s.R.clusters()
    if r.intermediary {
      rows.push(range(1, tc + 1).map(col => {
        let c = none
        if col == s.M { c = $-$ }
        if col >= s.C - sc.len() + 1 and col <= s.C { c = sc.at(col - (s.C - sc.len()) - 1) }
        if k == 0 and col >= sr and col < sr + qlen { c = qd.at(col - sr) }
        _c(c, calc: true)
      }))
    }
    rows.push(range(1, tc + 1).map(col => {
      let c = none
      if col >= s.C - rc.len() + 1 and col <= s.C { c = rc.at(col - (s.C - rc.len()) - 1) }
      if col == s.C + 1 and s.N != "" { c = s.N }
      if not r.intermediary and k == 0 and col >= sr and col < sr + qlen { c = qd.at(col - sr) }
      _c(c, calc: true)
    }))
  }
  let nrows = rows.len()
  let vl = if r.vbar == "auto" { calc.min(4, nrows) } else if r.vbar == "max" { nrows } else { r.vbar }
  for _ in range(nrows, vl) { rows.push(range(1, tc + 1).map(_ => _c(none, calc: true))) }
  let decos = ()
  if r.intermediary {
    for (k, s) in pas.enumerate() {
      decos.push((genre: "trait", kind: "subbar", row: 2 * (k + 1), c1: s.M + 1, c2: s.C, calc: true))
    }
  }
  if raw.len() > ic or ajoutes > 0 { decos.push((genre: "virgule", row: 1, col: 1 + ic, calc: false)) }
  let tq = ic - L + 1
  if qlen > tq { decos.push((genre: "virgule", row: 2, col: sr + tq - 1, calc: true)) }
  decos.push((genre: "potence", sr: sr, hbar: hb, vbar: vl))
  if r.bridge { decos.push((genre: "pont", c1: 2, c2: 1 + L)) }
  (rows: rows, decos: decos, sepcol: sr - 1)
}

// =====================================================================
// Rendu (dans un `context`)
// =====================================================================

#let _ancres(x, y, w, h, asc) = (
  x: x, y: y, width: w, height: h,
  center: (x + w / 2, y + h / 2),
  north: (x + w / 2, y), south: (x + w / 2, y + h),
  east: (x + w, y + h / 2), west: (x, y + h / 2),
  north-west: (x, y), north-east: (x + w, y),
  south-west: (x, y + h), south-east: (x + w, y + h),
  base: (x + w / 2, y + asc), base-west: (x, y + asc), base-east: (x + w, y + asc),
)

/// Pointe pleine à l'extrémité `q` d'un trait venant de `p` (coordonnées en longueurs).
#let _pointe(p, q, t) = {
  let dx = (q.at(0) - p.at(0)) / 1pt
  let dy = (q.at(1) - p.at(1)) / 1pt
  let n = calc.sqrt(dx * dx + dy * dy)
  if n == 0 { return none }
  let ux = dx / n
  let uy = dy / n
  let ep = t.thickness
  let l = 3.5pt + 2.5 * ep
  let w = 0.32 * l
  let bx = q.at(0) - ux * l
  let by = q.at(1) - uy * l
  place(top + left, polygon(
    fill: t.paint,
    stroke: none,
    (q.at(0), q.at(1)),
    (bx - uy * w, by + ux * w),
    (bx + uy * w, by - ux * w),
  ))
}

#let _trait(x1, y1, x2, y2, st, ep, cmd) = {
  let t = rd-trait(st, epaisseur: ep, commande: cmd)
  if t == none { return none }
  let pts = (
    place(top + left, line(start: (x1, y1), end: (x2, y2), stroke: t)),
  )
  let fl = st.cles.at("arrow", default: none)
  if fl in ("end", "both") { pts.push(_pointe((x1, y1), (x2, y2), t)) }
  if fl in ("start", "both") { pts.push(_pointe((x2, y2), (x1, y1), t)) }
  pts.join()
}

/// Dessine la grille `g` (lignes de cellules et décorations) : renvoie l'opération posée, boîte alignée
/// sur la ligne de base demandée. `loc` : clés écrites sur l'appel (la mise en page `seyes` ne l'emporte
/// pas sur elles).
#let rdopp-dessiner(r, g, loc, commande: "rdopp") = {
  let cmd = commande
  // contrôle des styles sous le nom de leur clé (messages d'erreur explicites)
  for k in ("carry-style", "top-carry-style", "bot-carry-style", "zero-style", "bar-style", "subbar-style", "bridge-style", "matrix", "tikz") {
    let _ = rd-style(r.at(k), commande: cmd, cle: k)
  }
  let corr = r.correction
  let prof = est-correction()
  let cache = corr and not prof
  let sr = reglages-courants(bf-reglages-socle)
  let coul = bf-xcolor(sr.correction-color, commande: cmd)
  let st-calc = if corr and prof { (text: coul, font: (weight: "bold")) } else { none }
  let tr-calc = if corr and prof { (draw: coul) } else { none }
  // dimensions des cellules
  let dim(cle, seyes-val) = rd-abs(if cle in loc { loc.at(cle) } else if r.seyes { seyes-val } else { r.at(cle) })
  let cw = dim("cell-width", 2.4 * _ex)
  let ch = dim("cell-height", 6mm)
  let cd = dim("cell-depth", 2mm)
  let gw = rd-abs(r.grid-width)
  let mst = rd-style(r.matrix, commande: cmd, cle: "matrix")
  // Avec `grid`, les cellules sont jointives : le trait d'un `rect` Typst est centré sur son bord (pas
  // d'« outer sep » comme en TikZ), donc un écart nul fait coïncider les traits de deux cellules voisines.
  // (Un écart de -gw, repris de TikZ, décalait les deux traits d'une épaisseur : filets doublés.)
  let sepx = rd-abs(if r.column-sep != none { r.column-sep } else if "column-sep" in mst.cles { mst.cles.column-sep } else { 0pt })
  let sepy = rd-abs(if r.row-sep != none { r.row-sep } else if "row-sep" in mst.cles { mst.cles.row-sep } else { 0pt })
  let base = (text-height: ch, text-depth: cd, min-width: cw)
  let st-grille = if r.grid { (draw: r.grid-color, line-width: gw) } else { none }
  let nodes-user = mst.cles.at("nodes", default: none)
  let lw = rd-abs(r.lw)
  let rows = g.rows
  let nl = rows.len()
  let nc = rows.first().len()
  // styles des cellules (clé `cell`)
  let cst = (:)
  let specs = if r.cell == none { () } else if type(r.cell) == dictionary { (r.cell,) } else { r.cell }
  for sp in specs {
    let (lg, cl, st) = if type(sp) == dictionary { (sp.at("rows"), sp.at("cols"), sp.at("style", default: none)) } else { (sp.at(0), sp.at(1), sp.at(2)) }
    for i in rdopp-plage(lg, nl, commande: cmd) {
      for j in rdopp-plage(cl, nc, commande: cmd) {
        if i >= 1 and i <= nl and j >= 1 and j <= nc {
          let cle = str(i) + "-" + str(j)
          cst.insert(cle, rd-style-fusion(cst.at(cle, default: none), st, commande: cmd))
        }
      }
    }
  }
  // nœuds
  let noeuds = ()
  for (i0, rg) in rows.enumerate() {
    let ligne = ()
    for (j0, cel) in rg.enumerate() {
      let cle = str(i0 + 1) + "-" + str(j0 + 1)
      let contenu = if cel.calc and cache { none } else { cel.c }
      if cel.role == "retenue" and contenu != none { contenu = rd-appliquer-police(contenu, r.carry-font, commande: cmd) }
      let st = rd-style-fusion(
        base, st-grille, nodes-user,
        if cel.zero { r.zero-style } else { none },
        cst.at(cle, default: none),
        if cel.role == "retenue" { r.carry-style } else { none },
        if cel.calc { st-calc } else { none },
        commande: cmd,
      )
      ligne.push((n: rd-noeud(contenu, st, commande: cmd, epaisseur: gw), st: st, cel: cel))
    }
    noeuds.push(ligne)
  }
  // mise en page : colonnes de largeur maximale, lignes alignées sur leur ligne de base
  let W = range(nc).map(j => calc.max(..noeuds.map(rg => rg.at(j).n.w)))
  let A = noeuds.map(rg => calc.max(..rg.map(x => x.n.asc)))
  let D = noeuds.map(rg => calc.max(..rg.map(x => x.n.h - x.n.asc)))
  let H = range(nl).map(i => A.at(i) + D.at(i))
  let ls = if r.vbar-sep != none { rd-abs(r.vbar-sep) } else { rd-abs(_ex) }
  let lsep = if r.vbar-leftsep != none { rd-abs(r.vbar-leftsep) } else { ls }
  let rsep = if r.vbar-rightsep != none { rd-abs(r.vbar-rightsep) } else { ls }
  let xs = ()
  let x0 = 0pt
  for j in range(nc) {
    xs.push(x0)
    x0 += W.at(j) + (if g.sepcol != none and j + 1 == g.sepcol { lsep + rsep } else { sepx })
  }
  let largeur = xs.last() + W.last()
  let ys = ()
  let y0 = 0pt
  for i in range(nl) {
    ys.push(y0)
    y0 += H.at(i) + sepy
  }
  let hauteur = ys.last() + H.last()
  let x-w(c) = xs.at(c - 1)
  let x-e(c) = xs.at(c - 1) + W.at(c - 1)
  let y-n(i) = ys.at(i - 1)
  let y-s(i) = ys.at(i - 1) + H.at(i - 1)
  let y-b(i) = ys.at(i - 1) + A.at(i - 1)
  let el = ()
  let ancres = (:)
  for (i0, rg) in noeuds.enumerate() {
    for (j0, x) in rg.enumerate() {
      let n = x.n
      let k = x.st.cles
      let px = xs.at(j0) + (W.at(j0) - n.w) / 2 + rd-abs(k.at("xshift", default: 0pt))
      let py = ys.at(i0) + A.at(i0) - n.asc - rd-abs(k.at("yshift", default: 0pt))
      el.push(place(top + left, dx: px, dy: py, n.corps))
      let anc = _ancres(px, py, n.w, n.h, n.asc)
      ancres.insert("cell " + str(i0 + 1) + "-" + str(j0 + 1), anc)
      if r.matrix-name != none { ancres.insert(r.matrix-name + "-" + str(i0 + 1) + "-" + str(j0 + 1), anc) }
      // retenues de la soustraction : petit chiffre dans un coin de la cellule, rogné par la cellule
      if x.cel.marque != none and not cache {
        let haut = x.cel.marque == "haut"
        let st = rd-style-fusion(
          (inset: 1pt), r.carry-style, if haut { r.top-carry-style } else { r.bot-carry-style }, st-calc, (inset: 1pt),
          commande: cmd,
        )
        let m = rd-noeud(rd-appliquer-police("1", r.carry-font, commande: cmd), st, commande: cmd)
        let mk = st.cles
        let mx = if haut { 0pt } else { n.w - m.w }
        let my = if haut { 0pt } else { n.h - m.h }
        el.push(place(top + left, dx: px, dy: py, box(width: n.w, height: n.h, clip: true, {
          place(top + left, dx: mx + rd-abs(mk.at("xshift", default: 0pt)), dy: my - rd-abs(mk.at("yshift", default: 0pt)), m.corps)
        })))
      }
    }
  }
  // décorations
  for d in g.decos {
    let genre = d.genre
    if genre == "virgule" {
      if d.calc and cache { continue }
      let st = rd-style-fusion((inset: 0pt), if d.calc { st-calc } else { none }, commande: cmd)
      let n = rd-noeud(r.decimal-sep, st, commande: cmd)
      el.push(place(top + left, dx: x-e(d.col) - n.w / 2, dy: y-b(d.row) - n.asc, n.corps))
    } else if genre == "trait" {
      if d.calc and cache { continue }
      let propre = if d.kind == "bar" { r.bar-style } else { r.subbar-style }
      let st = rd-style-fusion((line-width: lw), propre, if d.calc { tr-calc } else { none }, commande: cmd)
      el.push(_trait(x-w(d.c1), y-s(d.row), x-e(d.c2), y-s(d.row), st, lw, cmd))
    } else if genre == "potence" {
      let st = rd-style-fusion((line-width: lw), r.bar-style, commande: cmd)
      let xv = x-e(d.sr - 1) + lsep
      el.push(_trait(xv, y-s(1), x-e(d.sr + d.hbar - 1), y-s(1), st, lw, cmd))
      el.push(_trait(xv, y-n(1), xv, y-s(d.vbar), st, lw, cmd))
    } else if genre == "pont" {
      if cache { continue }
      let st = rd-style-fusion((line-width: lw), r.bridge-style, if corr { tr-calc } else { none }, commande: cmd)
      let t = rd-trait(st, epaisseur: lw, commande: cmd)
      if t == none { continue }
      let p0 = (x-w(d.c1), y-n(1))
      let p3 = (x-e(d.c2), y-n(1))
      let dist = (p3.at(0) - p0.at(0))
      let ang = st.cles.at("bend", default: 30) * 1deg
      let l = 0.3915 * dist
      let c1 = (p0.at(0) + l * calc.cos(ang), p0.at(1) - l * calc.sin(ang))
      let c2 = (p3.at(0) - l * calc.cos(ang), p3.at(1) - l * calc.sin(ang))
      el.push(place(top + left, curve(stroke: t, curve.move(p0), curve.cubic(c1, c2, p3))))
    }
  }
  if r.overlay != none { el.push((r.overlay)(ancres + (node: rd-node-at))) }
  let corps = box(width: largeur, height: hauteur, el.join())
  // cadre de la matrice (clé `matrix`) : marge intérieure, fond, contour
  let m = rd-marges(mst.cles.at("inset", default: r.matrix-inset))
  let m-fond = rd-fond(mst, commande: cmd)
  let m-trait = if "draw" in mst.cles { rd-trait(mst, epaisseur: 0.4pt, commande: cmd) } else { none }
  let m-rayon = mst.cles.at("radius", default: 0pt)
  let tot-w = largeur + m.left + m.right
  let tot-h = hauteur + m.top + m.bottom
  // ligne de base
  let bl = if r.baseline == "t" { tot-h } else if r.baseline == "c" { tot-h / 2 } else if r.baseline == "b" { 0pt } else {
    let n = calc.min(r.baseline, nl)
    tot-h - (m.top + y-b(n))
  }
  // arrière-plan de l'image (clé `tikz`)
  let tst = rd-style(r.tikz, commande: cmd, cle: "tikz")
  let tfond = rd-fond(tst, commande: cmd)
  let ttrait = if "draw" in tst.cles { rd-trait(tst, epaisseur: 0.4pt, commande: cmd) } else { none }
  // Une seule boîte porte `baseline` et `inset` : une boîte à marges imbriquée décalerait la ligne de base.
  // Typst compte la ligne de base d'une boîte à `inset` depuis le bas de son contenu : on retire la marge basse.
  let res = if tfond == none and ttrait == none {
    box(baseline: bl - m.bottom, inset: m, fill: m-fond, stroke: m-trait, radius: m-rayon, corps)
  } else {
    let mt = rd-marges(tst.cles.at("inset", default: 0.3333em))
    box(baseline: bl, width: tot-w, height: tot-h, {
      place(top + left, dx: -mt.left, dy: -mt.top, rect(
        width: tot-w + mt.left + mt.right, height: tot-h + mt.top + mt.bottom, fill: tfond, stroke: ttrait,
        radius: tst.cles.at("radius", default: 0pt),
      ))
      place(top + left, box(inset: m, fill: m-fond, stroke: m-trait, radius: m-rayon, corps))
    })
  }
  if r.matrix-name != none { [#res#label(r.matrix-name)] } else { res }
}

/// Opération effective d'après les clés `operation`, `add`, `sub`, `mul`, `div`, `divint` ; renvoie
/// (op, r) où `r` a `precision: 0` pour `divint`.
#let rdopp-operation(r) = {
  let op = r.operation
  let alias = (addition: "add", soustraction: "sub", multiplication: "mul")
  op = alias.at(op, default: op)
  let r2 = r
  if r.divint { op = "div"; r2.precision = 0 }
  else if r.div { op = "div" }
  else if r.mul { op = "mul" }
  else if r.sub { op = "sub" }
  else if r.add { op = "add" }
  (op, r2)
}

/// Rendu complet : `r` réglages résolus, `loc` clés locales (sans `auto`), `nombres` liste de nombres.
#let rdopp-rendu(r, loc, nombres, commande: "rdopp") = {
  let (op, r) = rdopp-operation(r)
  let g = if op == "div" {
    if nombres.len() != 2 {
      panic(commande + " : une division posée attend deux nombres (dividende, diviseur) ; reçu : " + str(nombres.len()) + ".")
    }
    _op-div(r, nombres, commande)
  } else {
    let parts = nombres.map(x => rdopp-lire-nombre(x, commande: commande))
    if op != "add" and parts.len() != 2 {
      panic(commande + " : une opération « " + op + " » attend deux nombres ; reçu : " + str(parts.len()) + ".")
    }
    if op == "add" { _op-add(r, parts, commande) } else if op == "sub" { _op-sub(r, parts, commande) } else { _op-mul(r, parts, commande) }
  }
  rdopp-dessiner(r, g, loc, commande: commande)
}
