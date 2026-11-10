// rdtabnum.typ (moteur) — tableaux de numération : réglages, lecture des nombres, calcul des cases,
// mise en page et tracé (grille, en-têtes, chiffres, virgules, zéros barrés, flèches latérales).
//
// Un tableau est construit en trois temps :
//   1. les éléments (`rdtnplace`, `rdtnconvert`, `rdtnemptyline`) sont transformés en lignes de cases
//      (chiffre ou vide, genre du chiffre), virgules et barres ;
//   2. la mise en page calcule les hauteurs de rangées (traits de base comme tabularray) ;
//   3. le tracé pose fonds, textes, traits de grille, virgules, barres et flèches dans une boîte de
//      taille fixe.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-interligne-p,
  bf-lire,
  reglages-paquet, reglages-controles, reglages-choix, reglages-resoudre, reglages-courants,
  bf-reglages-socle, est-correction, bf-xcolor, bf-interligne,
)
#import "../../../zones-reponse/lib.typ": interne as _crep
#import _crep: lignes-seyes, seyes-unite, registre-crep
#import "commun.typ": *

// =====================================================================
// Couleurs d'origine des flèches
// =====================================================================

/// Couleur par défaut des flèches latérales (rdtabnumarrowcol).
#let rdtabnumarrowcol = rgb("#9C3063")
/// Synonyme de `rdtabnumarrowcol`.
#let rdtnpurple = rdtabnumarrowcol

// =====================================================================
// Réglages (`setrdtabnum`) : clés du tableau et clés des flèches
// =====================================================================

#let _style = rd-controle-style
#let _trait-controle = (
  v => v == none or type(v) in (str, length, color, stroke, dictionary),
  "none, \"invisible\", une épaisseur, une couleur, un trait (1pt + black) ou un dictionnaire (thickness, paint, dash)",
)
#let _borne-controle = (
  v => type(v) in (int, str),
  "un entier relatif ou un nom (\"milliers\", \"unites\", \"dixiemes\"…)",
)

#let rdtabnum-reglages = reglages-paquet(
  "rdtabnum",
  (
    start: "milliers",
    stop: "milliemes",
    width: 100%,
    show-parts: false,
    show-initial-comma: false,
    correction: true,
    tblr-options: none,
    classes-style: none,
    cdu-style: none,
    decimals-style: none,
    data-style: none,
    int-part-style: none,
    dec-part-style: none,
    header-tikz: none,
    int-part-tikz: none,
    dec-part-tikz: none,
    classes-tikz: none,
    cdu-tikz: none,
    decimals-tikz: none,
    grid-outer-style: 1pt + black,
    grid-h-style: 1pt + black,
    grid-v-style: 1pt + black,
    digit-style: none,
    added-style: none,
    cross-style: none,
    cross-path: none,
    comma-style: none,
    initial-comma-style: none,
    cell-base-style: none,
    row-cell-style: none,
  ),
  controles: (
    start: _borne-controle,
    stop: _borne-controle,
    width: (v => type(v) in (length, ratio, relative), "une longueur ou un pourcentage (100%)"),
    show-parts: reglages-controles.booleen,
    show-initial-comma: reglages-controles.booleen,
    correction: reglages-controles.booleen,
    tblr-options: (v => v == none or type(v) == dictionary, "none ou un dictionnaire (rowsep, colsep, cells)"),
    classes-style: _style,
    cdu-style: _style,
    decimals-style: _style,
    data-style: _style,
    int-part-style: _style,
    dec-part-style: _style,
    header-tikz: _style,
    int-part-tikz: _style,
    dec-part-tikz: _style,
    classes-tikz: _style,
    cdu-tikz: _style,
    decimals-tikz: _style,
    grid-outer-style: _trait-controle,
    grid-h-style: _trait-controle,
    grid-v-style: _trait-controle,
    digit-style: _style,
    added-style: _style,
    cross-style: _style,
    cross-path: (v => v == none or type(v) == function, "none (diagonale) ou une fonction cellule => contenu"),
    comma-style: _style,
    initial-comma-style: _style,
    cell-base-style: _style,
    row-cell-style: (
      v => v == none or type(v) in (dictionary, array),
      "none, un dictionnaire (\"1\": style, \"2-\": style, \"odd\": style…) ou un tableau de paires (sélecteur, style)",
    ),
  ),
  commande: "setrdtabnum",
)

#let rdtnarrow-reglages = reglages-paquet(
  "rdtnarrow",
  (
    pos: "right",
    shift-start: 0pt,
    shift-end: 0pt,
    arm: 0.3cm,
    arrow-style: none,
    color: none,
    tip: "Stealth[length=2mm, inset=1pt]",
    node-sep: 2mm,
    node-pos: 0.5,
    node-style: none,
    correction: "auto",
  ),
  controles: (
    pos: reglages-choix("left", "right"),
    shift-start: reglages-controles.longueur,
    shift-end: reglages-controles.longueur,
    arm: reglages-controles.longueur,
    arrow-style: _style,
    color: (v => v == none or type(v) in (color, str), "none, une couleur ou un nom xcolor"),
    tip: (
      v => v == none or type(v) in (str, dictionary),
      "none (sans pointe), un nom (\"Stealth\", \"Latex\", \"Triangle\", \"Stealth[length=2mm, inset=1pt]\") ou un dictionnaire (type, length, inset, width)",
    ),
    node-sep: reglages-controles.longueur,
    node-pos: reglages-controles.nombre,
    node-style: _style,
    correction: reglages-choix("auto", true, false),
  ),
  commande: "setrdtabnum",
)

/// Développe les clés « raccourcis » (`grid-style`, `part-style`, `part-tikz`) en leurs clés détaillées,
/// dans l'ordre d'écriture (la dernière l'emporte).
#let rdtabnum-developper(cles) = {
  let res = (:)
  for (k, v) in cles {
    if k == "grid-style" {
      for x in ("grid-outer-style", "grid-h-style", "grid-v-style") { res.insert(x, v) }
    } else if k == "part-style" {
      for x in ("int-part-style", "dec-part-style") { res.insert(x, v) }
    } else if k == "part-tikz" {
      for x in ("int-part-tikz", "dec-part-tikz") { res.insert(x, v) }
    } else {
      res.insert(k, v)
    }
  }
  res
}

/// Développe les clés « raccourcis » des flèches : `left`, `right` (côté) et `shift` (décalage symétrique).
#let rdtabnum-developper-fleche(cles) = {
  let res = (:)
  for (k, v) in cles {
    if k == "left" {
      if v == true { res.insert("pos", "left") } else if v != false { panic("rdtn-arrow : la clé « left » attend true ou false ; reçu : " + repr(v) + ".") }
    } else if k == "right" {
      if v == true { res.insert("pos", "right") } else if v != false { panic("rdtn-arrow : la clé « right » attend true ou false ; reçu : " + repr(v) + ".") }
    } else if k == "shift" {
      if type(v) != length { panic("rdtn-arrow : la clé « shift » attend une longueur ; reçu : " + repr(v) + ".") }
      res.insert("shift-start", v)
      res.insert("shift-end", -v)
    } else {
      res.insert(k, v)
    }
  }
  res
}

// =====================================================================
// Bornes (start, stop) et nombres
// =====================================================================

#let _plat(s) = lower(s).replace("é", "e").replace("è", "e").replace("ê", "e").replace("ë", "e").trim()
#let _singulier(s) = if s.ends-with("s") { s.slice(0, -1) } else { s }

#let _noms-depart = (milliard: 11, million: 8, millier: 5, unite: 2)
#let _noms-fin = (
  unite: 0,
  dixieme: -1,
  centieme: -2,
  millieme: -3,
  "dix-millieme": -4,
  "cent-millieme": -5,
  millionieme: -6,
  "dix-millionieme": -7,
  "cent-millionieme": -8,
  milliardieme: -9,
  "dix-milliardieme": -10,
  "cent-milliardieme": -11,
)

/// Borne de départ (`start`) : un entier ou un nom (« milliards », « million », « unités »…) → puissance de dix.
#let rdtabnum-borne-depart(v, commande: "rdtabnum") = {
  let n = if type(v) == int { v } else {
    let cle = _singulier(_plat(v))
    if cle in _noms-depart { _noms-depart.at(cle) } else {
      panic(commande + " : valeur invalide pour la clé « start » : " + repr(v) + ". Valeurs possibles : un entier (2, 5, 8 ou 11) ou « milliards », « millions », « milliers », « unites ».")
    }
  }
  if n < 2 or calc.rem(n - 2, 3) != 0 {
    panic(commande + " : valeur invalide pour la clé « start » : " + repr(v) + ". Valeurs possibles : 2, 5, 8, 11 (puissance de dix de la colonne des centaines d'une classe) ou « milliards », « millions », « milliers », « unites ».")
  }
  n
}

/// Borne d'arrivée (`stop`) : un entier ou un nom (« dixièmes », « millièmes »…) → puissance de dix.
#let rdtabnum-borne-fin(v, commande: "rdtabnum") = {
  let n = if type(v) == int { v } else {
    let cle = _singulier(_plat(v))
    if cle in _noms-fin { _noms-fin.at(cle) } else {
      panic(commande + " : valeur invalide pour la clé « stop » : " + repr(v) + ". Valeurs possibles : un entier de 0 à -11 ou « unites », « dixiemes », « centiemes », « milliemes », « dix-milliemes », « cent-milliemes », « millioniemes »…")
    }
  }
  if n > 0 or n < -11 {
    panic(commande + " : valeur invalide pour la clé « stop » : " + repr(v) + ". Valeurs possibles : un entier de 0 à -11 ou un nom (« unites », « dixiemes », « centiemes »…).")
  }
  n
}

#let _libelles-decimaux = (
  "-1": "dixièmes",
  "-2": "centièmes",
  "-3": "millièmes",
  "-4": "dix-millièmes",
  "-5": "cent-millièmes",
  "-6": "millionièmes",
  "-7": "dix-millionièmes",
  "-8": "cent-millionièmes",
  "-9": "milliardièmes",
  "-10": "dix-milliardièmes",
  "-11": "cent-milliardièmes",
)
#let _libelles-classes = ("11": "milliards", "8": "millions", "5": "milliers", "2": "unités")

/// Lit un nombre (entier ou décimal, point ou virgule) : (entier: "chiffres", decimale: "chiffres" ou none).
#let rdtabnum-lire-nombre(v, commande: "rdtnplace") = {
  let s = if type(v) == str { v } else if type(v) in (int, float) { str(v) } else {
    panic(commande + " : un nombre s'écrit comme une chaîne (\"3,14\"), un entier ou un décimal ; reçu : " + repr(v) + ".")
  }
  let s = s.replace(regex("[\\s\u{a0}\u{202f}\u{2009}]"), "").replace(".", ",")
  if s.match(regex("^[0-9]*(,[0-9]*)?$")) == none or s == "" or s == "," {
    panic(commande + " : nombre invalide " + repr(v) + " : chiffres avec une virgule (ou un point) éventuelle, par exemple \"3,14\".")
  }
  let morceaux = s.split(",")
  (entier: morceaux.at(0), decimale: if morceaux.len() > 1 { morceaux.at(1) } else { none })
}

// =====================================================================
// Éléments d'un tableau (cases à remplir)
// =====================================================================

#let _case(c, genre) = (c: c, genre: genre)

/// Ligne produite par `rdtnplace` : (cases, virgules, barres).
#let _ligne-place(it, n, start, act, masque) = {
  let cases = range(n).map(_ => none)
  if it.etoile and masque { return (cases: cases, virgules: (), barres: ()) }
  let cu = start - it.unite + 1
  let genre = if it.etoile and act { "convert" } else { "chiffre" }
  let entier = it.nombre.entier.clusters()
  for i in range(entier.len()) {
    let c = cu - (entier.len() - 1 - i)
    if c >= 1 and c <= n { cases.at(c - 1) = _case(entier.at(i), genre) }
  }
  let virgules = ()
  if it.nombre.decimale != none {
    let dec = it.nombre.decimale.clusters()
    for i in range(dec.len()) {
      let c = cu + 1 + i
      if c >= 1 and c <= n { cases.at(c - 1) = _case(dec.at(i), genre) }
    }
    if cu > 0 and cu < n { virgules.push((col: cu, genre: if it.etoile and act { "convert" } else { "simple" })) }
  }
  (cases: cases, virgules: virgules, barres: ())
}

/// Ligne produite par `rdtnconvert` : conversion d'un nombre de l'unité `depart` à l'unité `cible`.
#let _ligne-convert(it, n, start, act, masque, montrer-initiale) = {
  let cases = range(n).map(_ => none)
  if masque { return (cases: cases, virgules: (), barres: ()) }
  let cd = start - it.depart + 1
  let ct = start - it.cible + 1
  let a-dec = it.nombre.decimale != none
  let mini = 999
  let maxi = -999
  let entier = it.nombre.entier.clusters()
  for i in range(entier.len()) {
    let c = cd - (entier.len() - 1 - i)
    if c >= 1 and c <= n {
      cases.at(c - 1) = _case(entier.at(i), "convert")
      mini = calc.min(mini, c)
      maxi = calc.max(maxi, c)
    }
  }
  if a-dec {
    let dec = it.nombre.decimale.clusters()
    for i in range(dec.len()) {
      let c = cd + 1 + i
      if c >= 1 and c <= n {
        cases.at(c - 1) = _case(dec.at(i), "convert")
        mini = calc.min(mini, c)
        maxi = calc.max(maxi, c)
      }
    }
  }
  // zéros ajoutés pour atteindre l'unité cible
  if ct < mini {
    for c in range(ct, mini) { if c >= 1 and c <= n { cases.at(c - 1) = _case("0", "ajoute") } }
    mini = ct
  }
  if ct > maxi {
    for c in range(maxi + 1, ct + 1) { if c >= 1 and c <= n { cases.at(c - 1) = _case("0", "ajoute") } }
    maxi = ct
  }
  // zéros inutiles
  let premier = 999
  let dernier = -999
  for c in range(mini, maxi + 1) {
    if c >= 1 and c <= n and cases.at(c - 1) != none and cases.at(c - 1).c != "0" {
      premier = calc.min(premier, c)
      dernier = calc.max(dernier, c)
    }
  }
  if premier == 999 {
    premier = ct
    dernier = ct
  }
  let bas = calc.min(premier, ct)
  let haut = calc.max(dernier, ct)
  let barres = ()
  for c in range(mini, maxi + 1) {
    if (c < bas or c > haut) and c >= 1 and c <= n { barres.push(c) }
  }
  // virgules
  let virgules = ()
  if montrer-initiale and a-dec and cd != ct and cd > 0 and cd < n { virgules.push((col: cd, genre: "initiale")) }
  let nouvelle = (ct < haut) or (cd == ct and a-dec)
  if nouvelle and ct > 0 and ct < n { virgules.push((col: ct, genre: "convert")) }
  (cases: cases, virgules: virgules, barres: barres)
}

/// Le sélecteur de ligne `sel` (« 2 », « 1-3 », « 2- », « -2 », « 1, 3 », « odd », « even ») retient-il la ligne `k` ?
#let _selecteur-ok(k, sel) = {
  let s = if type(sel) == int { str(sel) } else { sel }
  for it in s.split(",") {
    let it = it.trim()
    if it == "odd" {
      if calc.odd(k) { return true }
    } else if it == "even" {
      if calc.even(k) { return true }
    } else if "-" in it {
      let p = it.split("-")
      let a = p.at(0).trim()
      let b = p.at(1).trim()
      if (a == "" or k >= int(a)) and (b == "" or k <= int(b)) { return true }
    } else if it != "" and k == int(it) {
      return true
    }
  }
  false
}

// =====================================================================
// Traits
// =====================================================================

/// Normalise une spécification de trait de grille : none ou (paint, thickness, [dash], cap).
#let _trait(v, commande: "rdtabnum") = {
  if v == none or v == "invisible" or v == false { return none }
  let d = if type(v) == length { (thickness: v, paint: black) } else if type(v) == color { (thickness: 1pt, paint: v) } else if type(v) == str {
    (thickness: 1pt, paint: bf-xcolor(v, commande: commande))
  } else if type(v) == stroke {
    let r = (
      thickness: if v.thickness == auto { 1pt } else { v.thickness },
      paint: if v.paint == auto { black } else { v.paint },
    )
    if v.dash != none and v.dash != auto { r.dash = v.dash }
    r
  } else {
    let r = (thickness: v.at("thickness", default: 1pt), paint: v.at("paint", default: black))
    if type(r.paint) == str { r.paint = bf-xcolor(r.paint, commande: commande) }
    if "dash" in v and v.dash != none { r.dash = v.dash }
    r
  }
  if "dash" not in d { d.cap = "square" }
  d
}

#let _epaisseur(t) = if t == none { 0pt } else { t.thickness }

/// Pointe de flèche : (genre, longueur, retrait, demi-largeur) lue dans un nom ou un dictionnaire.
#let _pointe(v, commande: "rdtnArrow") = {
  if v == none { return none }
  let d = if type(v) == dictionary { v } else {
    let m = v.match(regex("^\\s*([A-Za-z]+)\\s*(?:\\[(.*)\\])?\\s*$"))
    if m == none {
      panic(commande + " : valeur invalide pour la clé « tip » : " + repr(v) + ". Valeurs possibles : « Stealth », « Latex », « Triangle », « Stealth[length=2mm, inset=1pt] » ou none.")
    }
    let r = (type: m.captures.at(0))
    if m.captures.at(1) != none {
      for morceau in m.captures.at(1).split(",") {
        let kv = morceau.split("=")
        if kv.len() == 2 {
          let cle = kv.at(0).trim()
          let val = kv.at(1).trim()
          if cle in ("length", "inset", "width") {
            let nombre = float(val.replace(regex("[a-z]+$"), ""))
            let unite = val.match(regex("[a-z]+$"))
            let l = if unite == none { nombre * 1pt } else if unite.text == "mm" { nombre * 1mm } else if unite.text == "cm" { nombre * 1cm } else if unite.text == "pt" { nombre * 1pt } else if unite.text == "em" { nombre * 1em } else {
              panic(commande + " : unité inconnue « " + unite.text + " » dans la pointe " + repr(v) + ". Unités possibles : mm, cm, pt, em.")
            }
            r.insert(cle, l)
          }
        }
      }
    }
    r
  }
  let genre = _plat(d.at("type", default: "stealth"))
  if genre not in ("stealth", "latex", "triangle") {
    panic(commande + " : pointe inconnue « " + str(d.at("type", default: "")) + " ». Pointes possibles : « Stealth », « Latex », « Triangle ».")
  }
  let longueur = rd-abs(d.at("length", default: 2mm))
  (
    genre: genre,
    longueur: longueur,
    retrait: rd-abs(d.at("inset", default: if genre == "stealth" { 1pt } else { 0pt })),
    demi: rd-abs(d.at("width", default: longueur * 0.9)) / 2,
  )
}

// =====================================================================
// Rendu
// =====================================================================

/// Deux lignes centrées (`a` puis `b`) séparées de `interligne` : (corps, w, ht, dp) où `ht` est la hauteur
/// au-dessus de la ligne de base de la seconde ligne et `dp` sa profondeur (boîte de cellule tabularray).
#let _deux-lignes(a, b, interligne) = {
  let ba = rd-boite(a)
  let bb = rd-boite(b)
  let w = calc.max(ba.w, bb.w)
  let ht = interligne + ba.ht
  let dp = bb.dp
  let corps = box(width: w, height: ht + dp, {
    place(top + left, dx: (w - ba.w) / 2, dy: ba.ht - rd-haut-cadre(a), box(a))
    place(top + left, dx: (w - bb.w) / 2, dy: ba.ht + interligne - rd-haut-cadre(b), box(b))
  })
  (corps: corps, w: w, ht: ht, dp: dp)
}

/// Rectangle de fond (couleur, dégradé, contour) d'un style normalisé.
#let _rect(x, y, w, h, st, commande: "rdtabnum") = {
  let f = rd-fond(st, commande: commande)
  let t = if "draw" in st.cles { rd-trait(st, commande: commande) } else { none }
  if f != none or t != none { place(top + left, dx: x, dy: y, rect(width: w, height: h, fill: f, stroke: t, radius: st.cles.at("radius", default: 0pt))) }
}

/// Texte posé dans la bande horizontale [x, x + w], sa ligne de base à l'ordonnée `yb`.
#let _poser(c, x, w, yb) = {
  let b = measure(box(c)).width
  place(top + left, dx: x + (w - b) / 2, dy: yb - rd-haut-cadre(c), box(c))
}

/// Construit le tableau : `r` = réglages résolus, `elements` = éléments du corps, `dispo` = largeur disponible.
#let rdtabnum-rendu(r, elements, dispo, commande: "rdtabnum") = {
  let start = rdtabnum-borne-depart(r.start, commande: commande)
  let stop = rdtabnum-borne-fin(r.stop, commande: commande)
  let n = start - stop + 1
  let nint = start + 1
  let ndec = if stop < 0 { -stop } else { 0 }
  if type(r.width) != length and dispo.pt() > 100000.0 {
    panic(commande + " : la largeur disponible n'est pas limitée (page ou colonne de largeur automatique) ; donner une largeur absolue, par exemple width: 8cm.")
  }
  let largeur-nominale = if type(r.width) == length { rd-abs(r.width) } else if type(r.width) == ratio { dispo * r.width } else {
    r.width.length.to-absolute() + dispo * r.width.ratio
  }
  let cw0 = largeur-nominale / n
  let parts = r.show-parts
  let doc-corr = est-correction()
  let act = r.correction and doc-corr
  let masque = r.correction and not doc-corr

  // ---- styles
  let st(v, cle) = rd-style(v, commande: commande, cle: cle)
  let fus(..a) = rd-style-fusion(..a, commande: commande)
  let cor = reglages-courants(bf-reglages-socle)
  let s-corr = st((text: cor.correction-color, font: cor.correction-font), "correction")
  let s-digit = st(r.digit-style, "digit-style")
  let s-convert = if act { fus(s-corr, s-digit) } else { s-digit }
  let s-ajoute = fus(if act { s-corr } else { st((text: "red"), "added-style") }, st(r.added-style, "added-style"))
  let s-virgule = st(r.comma-style, "comma-style")
  let s-virgule-conv = if act { fus(s-corr, s-virgule) } else { s-virgule }
  let s-initiale = fus(s-virgule, st((shape: "strike-out", draw: "red"), "initial-comma-style"), st(r.initial-comma-style, "initial-comma-style"))
  let s-croix = fus(st((draw: "red", line-width: 1pt), "cross-style"), st(r.cross-style, "cross-style"))
  let s-base = fus(st((inset: 0pt, min-width: 1em), "cell-base-style"), st(r.cell-base-style, "cell-base-style"))
  let tb = if r.tblr-options == none { (:) } else { r.tblr-options }
  for k in tb.keys() {
    if k not in ("rowsep", "colsep", "cells") {
      panic(commande + " : clé inconnue « " + k + " » dans « tblr-options ». Clés possibles : « rowsep », « colsep », « cells ».")
    }
  }
  let rs = rd-abs(tb.at("rowsep", default: 2pt))
  let s-cells = st(tb.at("cells", default: none), "tblr-options")
  let s-data = st(r.data-style, "data-style")
  let s-classes = st(r.classes-style, "classes-style")
  let s-cdu = st(r.cdu-style, "cdu-style")
  let s-dec = st(r.decimals-style, "decimals-style")
  let s-int = st(r.int-part-style, "int-part-style")
  let s-dpart = st(r.dec-part-style, "dec-part-style")
  let bord-int = s-int.cles.at("border", default: true)
  let bord-dec = s-dpart.cles.at("border", default: true)
  let regles = if r.row-cell-style == none { () } else if type(r.row-cell-style) == dictionary {
    r.row-cell-style.pairs().map(((sel, s)) => (sel, st(s, "row-cell-style")))
  } else {
    r.row-cell-style.map(p => (p.at(0), st(p.at(1), "row-cell-style")))
  }
  let rs-data = rd-abs(s-data.cles.at("row-sep", default: rs))

  // ---- mesures de base (interligne et trait de base tabularray : 0,7 et 0,3 de l'interligne)
  let bs = bf-lire(bf-interligne-p).baselineskip
  let sht = 0.7 * bs
  let sdp = 0.3 * bs

  // ---- éléments : lignes de cases, flèches, surcouches
  let lignes = ()
  let fleches = ()
  let dessous = ()
  let dessus = ()
  for it in elements {
    if type(it) != dictionary or "rdtn" not in it {
      panic(commande + " : le contenu d'un tableau se compose de rdtnplace, rdtnconvert, rdtnemptyline, rdtn-arrow et rdtnsurcouche ; reçu : " + repr(it) + ".")
    }
    if it.rdtn == "place" {
      lignes.push(_ligne-place(it, n, start, act, masque))
    } else if it.rdtn == "convert" {
      lignes.push(_ligne-convert(it, n, start, act, masque, r.show-initial-comma))
    } else if it.rdtn == "vide" {
      for _ in range(it.n) { lignes.push((cases: range(n).map(_ => none), virgules: (), barres: ())) }
    } else if it.rdtn == "fleche" {
      fleches.push(it)
    } else if it.rdtn == "surcouche" {
      if it.dessous { dessous.push(it.f) } else { dessus.push(it.f) }
    }
  }
  let nl = lignes.len()

  // ---- rangées d'en-tête
  let ink(c) = rd-boite(c)
  let h-parts = none
  let t-int = none
  let t-dpart = none
  if parts {
    t-int = rd-texte([Partie entière], fus(s-cells, s-int), commande: commande)
    t-dpart = rd-texte([Partie décimale], fus(s-cells, s-dpart), commande: commande)
    let bi = ink(t-int)
    let bd = if ndec > 0 { ink(t-dpart) } else { (ht: 0pt, dp: 0pt) }
    let asc = rs + calc.max(sht, bi.ht, bd.ht)
    let desc = rs + calc.max(sdp, bi.dp, bd.dp)
    h-parts = (asc: asc, h: asc + desc)
  }
  // classes
  let classes = ()
  let p = start
  while p >= 2 {
    let nom = _libelles-classes.at(str(p), default: none)
    let sc = fus(s-cells, s-classes)
    classes.push(_deux-lignes(
      rd-texte([Classe des], sc, commande: commande),
      rd-texte(if nom == none { [] } else { nom }, sc, commande: commande),
      bs,
    ))
    p -= 3
  }
  let nat-ht = 0pt
  let nat-dp = 0pt
  for c in classes {
    nat-ht = calc.max(nat-ht, c.ht)
    nat-dp = calc.max(nat-dp, c.dp)
  }
  let decs = ()
  let maxdec = 0pt
  for q in range(1, ndec + 1) {
    let c = rd-texte(_libelles-decimaux.at("-" + str(q)), fus(s-cells, s-dec), commande: commande)
    let rot = rotate(-90deg, reflow: true, box(c))
    maxdec = calc.max(maxdec, measure(box(c)).width)
    decs.push((c: c, rot: rot))
  }
  let ink-c = ink(rd-texte([c], fus(s-cells, s-cdu), commande: commande))
  let cdu-asc = rs + calc.max(sht, ink-c.ht)
  let cdu-desc = rs + calc.max(sdp, ink-c.dp)
  let h-cdu = cdu-asc + cdu-desc
  let hclasses = if ndec > 0 { calc.max(0pt, maxdec - (sht + sdp) + 6pt) } else { 0pt }
  let cl-asc = rs + calc.max(nat-ht, hclasses)
  let cl-desc = rs + calc.max(sdp, nat-dp)
  let h-classes = cl-asc + cl-desc

  // ---- largeurs des colonnes : largeur / n, élargie quand une cellule fusionnée (libellé de classe,
  // « Partie … », en-tête décimal) a besoin de plus de place, répartie à parts égales sur ses colonnes
  let colsep = rd-abs(tb.at("colsep", default: 6pt))
  let besoin = range(n).map(_ => 0pt)
  for (q, c) in classes.enumerate() {
    for j in range(3 * q, 3 * q + 3) { besoin.at(j) = calc.max(besoin.at(j), (c.w + 2 * colsep) / 3) }
  }
  if parts {
    for j in range(nint) { besoin.at(j) = calc.max(besoin.at(j), (ink(t-int).w + 2 * colsep) / nint) }
    for j in range(nint, n) { besoin.at(j) = calc.max(besoin.at(j), (ink(t-dpart).w + 2 * colsep) / ndec) }
  }
  for (q, d) in decs.enumerate() {
    besoin.at(nint + q) = calc.max(besoin.at(nint + q), measure(d.rot).width + 2 * colsep)
  }
  let cws = besoin.map(b => calc.max(cw0, b))
  let xl = (0pt,)
  for w in cws { xl.push(xl.last() + w) }
  let W = xl.last()
  let xs(j) = xl.at(j)
  let lw(a, b) = xl.at(b) - xl.at(a)

  // ---- cases (nœuds) des lignes de données
  let rc = if parts { 1 } else { 0 } // indice de la rangée des classes (0 = première)
  let ru = rc + 1
  let r0 = ru + 1 // indice de la première rangée de données
  let geo = reglages-courants(registre-crep)
  let cols-seyes = geo.at("seyes-colors", default: auto)
  if type(cols-seyes) != array { cols-seyes = (cols-seyes, cols-seyes) }
  let cols-seyes = cols-seyes.map(c => if c == auto { auto } else { bf-xcolor(c, commande: commande) })
  let lignes-dessin = ()
  for (i, l) in lignes.enumerate() {
    let k = i + 1
    let s-ligne = regles.filter(x => _selecteur-ok(k, x.at(0))).map(x => x.at(1))
    let cache = (:)
    let noeuds = ()
    for (jc, cs) in l.cases.enumerate() {
      let cwj = cws.at(jc)
      let cle = (if cs == none { "" } else { cs.genre + cs.c }) + "|" + repr(cwj)
      if cle not in cache {
        let genre-style = if cs == none { none } else if cs.genre == "chiffre" { s-digit } else if cs.genre == "convert" { s-convert } else { s-ajoute }
        let s = fus(s-base, ..s-ligne, genre-style)
        if "min-width" in s.cles {
          let mw = s.cles.min-width
          s.cles.min-width = calc.min(if type(mw) == ratio { cwj * mw } else { rd-abs(mw) }, cwj)
        }
        let contenu = if cs == none { [] } else { rd-texte(cs.c, fus(s-cells, s-data), commande: commande) }
        let nd = rd-noeud(contenu, s, commande: commande)
        let sy = s.cles.at("seyes", default: none)
        let corps = nd.corps
        if sy != none and sy != false {
          let fond = if type(sy) == dictionary and "fill" in sy { bf-xcolor(sy.fill, commande: commande) } else { none }
          corps = box(width: nd.w, height: nd.h, {
            box(width: nd.w, height: nd.h, clip: true, {
              if fond != none { place(top + left, rect(width: nd.w, height: nd.h, fill: fond, stroke: none)) }
              lignes-seyes(
                nd.w, nd.h, nd.asc,
                col-a: cols-seyes.at(0), col-b: cols-seyes.at(1),
                unite: geo.at("seyes-unit", default: seyes-unite),
              )
            })
            place(top + left, nd.corps)
          })
        }
        cache.insert(cle, (nd: (corps: corps, w: nd.w, h: nd.h, asc: nd.asc), s: s))
      }
      noeuds.push(cache.at(cle))
    }
    let asc = rs-data + calc.max(sht, ..noeuds.map(x => x.nd.asc))
    let desc = rs-data + calc.max(sdp, ..noeuds.map(x => x.nd.h - x.nd.asc))
    lignes-dessin.push((noeuds: noeuds, asc: asc, h: asc + desc, ligne: l))
  }

  // ---- rangées et ordonnées
  let rangs = ()
  if parts { rangs.push(h-parts) }
  rangs.push((asc: cl-asc, h: h-classes))
  rangs.push((asc: cdu-asc, h: h-cdu))
  for d in lignes-dessin { rangs.push((asc: d.asc, h: d.h)) }
  let R = rangs.len()
  let ys = (0pt,)
  for g in rangs { ys.push(ys.last() + g.h) }
  let H = ys.last()

  // ---- grille : segments horizontaux (0..R) et verticaux (0..n)
  let t-out = _trait(r.grid-outer-style, commande: commande)
  let t-h = _trait(r.grid-h-style, commande: commande)
  let t-v = _trait(r.grid-v-style, commande: commande)
  let hseg = range(R + 1).map(_ => range(n).map(_ => none))
  let vseg = range(n + 1).map(_ => range(R).map(_ => none))
  // hline{Z}, hline{2-Y}
  for c in range(n) { hseg.at(R).at(c) = t-out }
  for i in range(1, R) { for c in range(n) { hseg.at(i).at(c) = t-h } }
  if parts {
    for j in range(1, n) { for i in range(1, R) { vseg.at(j).at(i) = t-v } }
    let i-int = if bord-int { 0 } else { 1 }
    for c in range(nint) { hseg.at(i-int).at(c) = t-out }
    if ndec > 0 {
      let i-dec = if bord-dec { 0 } else { 1 }
      for c in range(nint, n) { hseg.at(i-dec).at(c) = t-out }
    }
    for i in range(if bord-int { 0 } else { 1 }, R) { vseg.at(0).at(i) = t-out }
    if ndec > 0 {
      for i in range(if bord-dec { 0 } else { 1 }, R) { vseg.at(n).at(i) = t-out }
      if bord-int or bord-dec { vseg.at(nint).at(0) = t-v }
    } else {
      for i in range(if bord-int { 0 } else { 1 }, R) { vseg.at(n).at(i) = t-out }
    }
  } else {
    for c in range(n) { hseg.at(0).at(c) = t-out }
    for i in range(R) {
      vseg.at(0).at(i) = t-out
      vseg.at(n).at(i) = t-out
    }
    for j in range(1, n) { for i in range(R) { vseg.at(j).at(i) = t-v } }
  }
  // traits cachés par les cellules fusionnées
  if parts {
    for j in range(1, nint) { vseg.at(j).at(0) = none }
    for j in range(nint + 1, n) { vseg.at(j).at(0) = none }
  }
  let ncl = classes.len()
  for q in range(ncl) {
    vseg.at(3 * q + 1).at(rc) = none
    vseg.at(3 * q + 2).at(rc) = none
  }
  for c in range(nint, n) { hseg.at(ru).at(c) = none }

  // ---- ordonnée de la ligne de base d'une rangée et centre de rangée
  let base-y(i) = ys.at(i) + rangs.at(i).asc
  let centre-y(i) = ys.at(i) + rangs.at(i).h / 2

  // ---- éléments pour surcouches et flèches
  let g = (
    largeur: W,
    hauteur: H,
    lignes: nl,
    colonnes: n,
    gauche: k => (x: 0pt, y: centre-y(r0 + k - 1)),
    droite: k => (x: W, y: centre-y(r0 + k - 1)),
    cellule: (k, c) => (
      x: xs(c - 1),
      y: ys.at(r0 + k - 1),
      w: lw(c - 1, c),
      h: rangs.at(r0 + k - 1).h,
      base: base-y(r0 + k - 1),
    ),
    colonne: c => (x: xs(c - 1), w: lw(c - 1, c)),
    separation: xs(nint),
    entete: (
      parties: if parts { (y: 0pt, h: h-parts.h) } else { none },
      classes: (y: ys.at(rc), h: h-classes),
      cdu: (y: ys.at(ru), h: h-cdu),
    ),
  )

  // ---- débord des flèches latérales (bras, pointe et libellé) : il entre dans la taille de la boîte,
  // comme la boîte englobante TikZ, pour qu'un libellé à gauche ne sorte pas du cadre qui contient le tableau
  // Empilement des bras : deux flèches du même côté dont les plages verticales se chevauchent ne
  // doivent pas se croiser. La plus courte reste au plus près du tableau ; le bras d'une flèche qui
  // passe devant une autre est repoussé au-delà de cette autre (bras, écart et libellé, plus 1,5 mm).
  // Un `arm` plus grand que nécessaire est gardé. (rdtabnum ne le fait pas : son libellé « × 10 »
  // chevauchait le bras de « × 100 » sur des lignes voisines.)
  let bras = fleches.map(_ => none)
  let infos = ()
  for (i, f) in fleches.enumerate() {
    let a = reglages-resoudre(rdtnarrow-reglages, local: rd-local(f.cles), commande: "rdtnArrow")
    let explicite = a.correction in (true, false)
    let corr = if explicite { a.correction } else { r.correction }
    if (f.etoile or explicite) and corr and not doc-corr { continue }
    if f.depart < 1 or f.depart > nl or f.arrivee < 1 or f.arrivee > nl { continue }
    let y1 = centre-y(r0 + f.depart - 1) - rd-abs(a.shift-start)
    let y2 = centre-y(r0 + f.arrivee - 1) - rd-abs(a.shift-end)
    let lib = if f.libelle != none and f.libelle != [] {
      let nn = rd-noeud(f.libelle, st(a.node-style, "node-style"), commande: "rdtnArrow")
      rd-abs(a.node-sep) + nn.w
    } else { 0pt }
    infos.push((i: i, pos: a.pos, haut: calc.min(y1, y2), bas: calc.max(y1, y2), arm: rd-abs(a.arm), lib: lib))
  }
  let places = ()
  for x in infos.sorted(key: x => x.bas - x.haut) {
    let arm = x.arm
    for p in places {
      if p.pos == x.pos and x.haut < p.bas and p.haut < x.bas { arm = calc.max(arm, p.arm + p.lib + 1.5mm) }
    }
    places.push(x + (arm: arm))
    bras.at(x.i) = arm
  }
  let (deb-g, deb-d) = (0pt, 0pt)
  for p in places {
    let ext = p.arm + 1pt + p.lib
    if p.pos == "right" { deb-d = calc.max(deb-d, ext) } else { deb-g = calc.max(deb-g, ext) }
  }

  box(inset: (left: deb-g, right: deb-d), box(width: W, height: H, {
    for f in dessous { place(top + left, f(g)) }

    // fonds des cellules (styles tabularray : bg)
    for d in range(nl) {
      let i = r0 + d
      _rect(0pt, ys.at(i), W, rangs.at(i).h, (cles: (fill: s-data.cles.at("fill", default: none)), fns: ()), commande: commande)
    }
    let fond-cl = s-classes.cles.at("fill", default: s-cells.cles.at("fill", default: none))
    for q in range(ncl) { _rect(xs(3 * q), ys.at(rc), lw(3 * q, 3 * q + 3), h-classes, (cles: (fill: fond-cl), fns: ()), commande: commande) }
    let fond-cdu = s-cdu.cles.at("fill", default: s-cells.cles.at("fill", default: none))
    for c in range(nint) { _rect(xs(c), ys.at(ru), lw(c, c + 1), h-cdu, (cles: (fill: fond-cdu), fns: ()), commande: commande) }
    let fond-dec = s-dec.cles.at("fill", default: s-cells.cles.at("fill", default: none))
    for c in range(ndec) { _rect(xs(nint + c), ys.at(rc), lw(nint + c, nint + c + 1), h-classes + h-cdu, (cles: (fill: fond-dec), fns: ()), commande: commande) }
    if parts {
      _rect(0pt, 0pt, xs(nint), h-parts.h, (cles: (fill: s-int.cles.at("fill", default: none)), fns: ()), commande: commande)
      if ndec > 0 { _rect(xs(nint), 0pt, (W - xs(nint)), h-parts.h, (cles: (fill: s-dpart.cles.at("fill", default: none)), fns: ()), commande: commande) }
    }

    // fonds TikZ des en-têtes
    let t-header = st(r.header-tikz, "header-tikz")
    _rect(0pt, 0pt, W, ys.at(ru + 1), t-header, commande: commande)
    if parts {
      _rect(0pt, 0pt, xs(nint), h-parts.h, st(r.int-part-tikz, "int-part-tikz"), commande: commande)
      if ndec > 0 { _rect(xs(nint), 0pt, (W - xs(nint)), h-parts.h, st(r.dec-part-tikz, "dec-part-tikz"), commande: commande) }
    }
    for q in range(ncl) { _rect(xs(3 * q), ys.at(rc), lw(3 * q, 3 * q + 3), h-classes, st(r.classes-tikz, "classes-tikz"), commande: commande) }
    for c in range(ndec) { _rect(xs(nint + c), ys.at(rc), lw(nint + c, nint + c + 1), h-classes + h-cdu, st(r.decimals-tikz, "decimals-tikz"), commande: commande) }
    for c in range(nint) { _rect(xs(c), ys.at(ru), lw(c, c + 1), h-cdu, st(r.cdu-tikz, "cdu-tikz"), commande: commande) }

    // textes d'en-tête
    if parts {
      _poser(t-int, 0pt, xs(nint), base-y(0))
      if ndec > 0 { _poser(t-dpart, xs(nint), (W - xs(nint)), base-y(0)) }
    }
    for (q, c) in classes.enumerate() {
      let haut = ys.at(rc) + (h-classes - (c.ht + c.dp)) / 2
      place(top + left, dx: xs(3 * q) + (lw(3 * q, 3 * q + 3) - c.w) / 2, dy: haut, c.corps)
    }
    for c in range(nint) {
      let p = start - c
      let lettre = ("u", "d", "c").at(calc.rem(p, 3))
      let tc = rd-texte(lettre, fus(s-cells, s-cdu), commande: commande)
      _poser(tc, xs(c), lw(c, c + 1), base-y(ru))
    }
    for (q, d) in decs.enumerate() {
      let hb = measure(d.rot).height
      let wb = measure(d.rot).width
      let bas = ys.at(rc) + h-classes + h-cdu - rs
      place(top + left, dx: xs(nint + q) + (lw(nint + q, nint + q + 1) - wb) / 2, dy: bas - hb, d.rot)
    }

    // chiffres
    for (d, ld) in lignes-dessin.enumerate() {
      let i = r0 + d
      let yb = base-y(i)
      for (c, x) in ld.noeuds.enumerate() {
        let cx = xs(c) + (lw(c, c + 1) - x.nd.w) / 2
        place(top + left, dx: cx, dy: yb - x.nd.asc, x.nd.corps)
      }
    }

    // traits de grille
    for i in range(R + 1) {
      let c = 0
      while c < n {
        let t = hseg.at(i).at(c)
        let c2 = c
        while c2 + 1 < n and hseg.at(i).at(c2 + 1) == t { c2 += 1 }
        if t != none {
          let e = _epaisseur(t) / 2
          place(top + left, line(start: (xs(c) - e, ys.at(i)), end: (xs(c2 + 1) + e, ys.at(i)), stroke: t))
        }
        c = c2 + 1
      }
    }
    for j in range(n + 1) {
      let i = 0
      while i < R {
        let t = vseg.at(j).at(i)
        let i2 = i
        while i2 + 1 < R and vseg.at(j).at(i2 + 1) == t { i2 += 1 }
        if t != none {
          let e = _epaisseur(t) / 2
          place(top + left, line(start: (xs(j), ys.at(i) - e), end: (xs(j), ys.at(i2 + 1) + e), stroke: t))
        }
        i = i2 + 1
      }
    }

    // virgules et barres
    for (d, ld) in lignes-dessin.enumerate() {
      let i = r0 + d
      let yb = base-y(i)
      for v in ld.ligne.virgules {
        let sv = if v.genre == "convert" { s-virgule-conv } else if v.genre == "initiale" { s-initiale } else { s-virgule }
        let nv = rd-noeud([,], sv, commande: commande)
        // milieu entre le bord droit du nœud de la colonne `col` et le bord gauche du nœud suivant
        let na = ld.noeuds.at(v.col - 1).nd
        let nb = ld.noeuds.at(v.col).nd
        let xe = xs(v.col - 1) + (lw(v.col - 1, v.col) + na.w) / 2
        let xw = xs(v.col) + (lw(v.col, v.col + 1) - nb.w) / 2
        place(top + left, dx: (xe + xw) / 2 - nv.w / 2, dy: yb - nv.asc, nv.corps)
      }
      for c in ld.ligne.barres {
        let x = ld.noeuds.at(c - 1)
        let ox = xs(c - 1) + (lw(c - 1, c) - x.nd.w) / 2
        let oy = yb - x.nd.asc
        let trait = rd-trait(s-croix, commande: commande)
        let info = (w: x.nd.w, h: x.nd.h, asc: x.nd.asc, trait: trait)
        if r.cross-path == none {
          if trait != none { place(top + left, dx: ox, dy: oy, line(start: (0pt, x.nd.h), end: (x.nd.w, 0pt), stroke: trait)) }
        } else {
          place(top + left, dx: ox, dy: oy, (r.cross-path)(info))
        }
      }
    }

    // flèches latérales
    for (i-f, f) in fleches.enumerate() {
      let a = reglages-resoudre(rdtnarrow-reglages, local: rd-local(f.cles), commande: "rdtnArrow")
      let explicite = a.correction in (true, false)
      let corr = if explicite { a.correction } else { r.correction }
      if (f.etoile or explicite) and corr and not doc-corr { continue }
      if f.depart < 1 or f.depart > nl or f.arrivee < 1 or f.arrivee > nl {
        panic("rdtn-arrow : les lignes de départ et d'arrivée vont de 1 à " + str(nl) + " (nombre de lignes de données) ; reçu : " + str(f.depart) + " et " + str(f.arrivee) + ".")
      }
      let droite = a.pos == "right"
      let coef = if droite { 1 } else { -1 }
      let xb = if droite { W } else { 0pt }
      let y1 = centre-y(r0 + f.depart - 1) - rd-abs(a.shift-start)
      let y2 = centre-y(r0 + f.arrivee - 1) - rd-abs(a.shift-end)
      let xc = xb + coef * (if bras.at(i-f) == none { rd-abs(a.arm) } else { bras.at(i-f) })
      let sf = fus(st((draw: rdtabnumarrowcol, line-width: 1pt), "arrow-style"), st(a.arrow-style, "arrow-style"), if a.color == none { none } else { st((draw: a.color), "color") })
      let trait = rd-trait(sf, defaut: rdtabnumarrowcol, epaisseur: 1pt, commande: "rdtnArrow")
      let pointe = _pointe(a.tip)
      let epa = if trait == none { 1pt } else { trait.thickness }
      let x-fin = if pointe == none { xb } else if pointe.genre == "stealth" { xb + coef * (pointe.longueur - pointe.retrait) } else { xb + coef * pointe.longueur * 0.8 }
      let xmin = calc.min(xb, xc, x-fin) - epa
      let ymin = calc.min(y1, y2) - epa
      if trait != none {
        place(
          top + left, dx: xmin, dy: ymin,
          curve(
            stroke: trait + (cap: "butt"),
            curve.move((xb - xmin, y1 - ymin)),
            curve.line((xc - xmin, y1 - ymin)),
            curve.line((xc - xmin, y2 - ymin)),
            curve.line((x-fin - xmin, y2 - ymin)),
          ),
        )
        if pointe != none {
          let col = trait.paint
          let pts = if pointe.genre == "stealth" {
            ((0pt, 0pt), (coef * pointe.longueur, pointe.demi), (coef * (pointe.longueur - pointe.retrait), 0pt), (coef * pointe.longueur, -pointe.demi))
          } else {
            ((0pt, 0pt), (coef * pointe.longueur, pointe.demi), (coef * pointe.longueur, -pointe.demi))
          }
          let px = xb
          let py = y2
          let mx = calc.min(..pts.map(q => q.at(0)))
          let my = calc.min(..pts.map(q => q.at(1)))
          place(
            top + left, dx: px + mx, dy: py + my,
            polygon(fill: col, stroke: none, ..pts.map(q => (q.at(0) - mx, q.at(1) - my))),
          )
        }
      }
      let libelle = f.libelle
      if libelle != none and libelle != [] {
        let nn = rd-noeud(libelle, st(a.node-style, "node-style"), commande: "rdtnArrow")
        let yl = y1 + (y2 - y1) * a.node-pos
        let sep = rd-abs(a.node-sep)
        let xl = if droite { xc + sep } else { xc - sep - nn.w }
        place(top + left, dx: xl, dy: yl - nn.h / 2, nn.corps)
      }
    }

    for f in dessus { place(top + left, f(g)) }
  }))
}

/// Résout les clés locales (`local`, valeurs `auto` ignorées) et construit le tableau dans un bloc
/// insécable de la largeur disponible.
#let rdtabnum-construire(local, elements, commande: "rdtabnum") = block(breakable: false, layout(size => context {
  let r = reglages-resoudre(rdtabnum-reglages, local: rdtabnum-developper(rd-local(local)), commande: commande)
  rdtabnum-rendu(r, elements, size.width, commande: commande)
}))

/// Aplatit les arguments positionnels d'un tableau (tableaux d'éléments permis, `none` ignoré).
#let rdtabnum-aplatir(pos) = pos.map(e => if type(e) == array { e } else { (e,) }).flatten().filter(e => e != none)
