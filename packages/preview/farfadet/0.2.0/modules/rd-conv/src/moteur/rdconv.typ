// rdconv.typ (moteur) — tableaux de conversion d'unités : longueur, masse, capacité, aire, volume.
//
// Le tableau est une grille Typst : colonnes d'information à gauche (numéros, texte libre), puis une colonne
// par rang de chaque unité (une, deux ou trois selon la dimension). Les chiffres sont des « nœuds » posés dans
// les cellules ; la virgule et les ratures sont dessinées dans la cellule du chiffre qu'elles accompagnent.
// Les lignes du tableau sont décrites par `rdplace`, `rdconvert` et `rdconvemptyline` (données), puis rendues
// ensemble par `rdconv`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, reglages-resoudre, reglages-courants,
  bf-reglages-socle, est-correction, bf-xcolor, xmix,
)
#import "../../../zones-reponse/lib.typ": interne as _crep
#import _crep: lignes-seyes
#import "commun.typ": *

// =====================================================================
// Unités : rang absolu de chaque unité (table commune à tous les types de tableau)
// =====================================================================

#let rdconv-unites = (
  // longueurs
  "km": 0, "hm": 1, "dam": 2, "m": 3, "dm": 4, "cm": 5, "mm": 6,
  // aires
  "km^2": 1, "hm^2": 3, "dam^2": 5, "m^2": 7, "dm^2": 9, "cm^2": 11, "mm^2": 13,
  // aires agraires
  "ha": 3, "a": 5, "ca": 7,
  // volumes
  "km^3": 2, "hm^3": 5, "dam^3": 8, "m^3": 11, "dm^3": 14, "cm^3": 17, "mm^3": 20,
  // capacités
  "kL": 11, "hL": 12, "daL": 13, "L": 14, "dL": 15, "cL": 16, "mL": 17,
  // masses
  "t": 0, "q": 1, "kg": 3, "hg": 4, "dag": 5, "g": 6, "dg": 7, "cg": 8, "mg": 9,
)

/// Nom normalisé d'une unité : exposants « ² » et « ³ » ramenés à « ^2 » et « ^3 », espaces supprimés.
#let rdconv-nom-unite(u) = {
  let s = if type(u) == str { u } else if type(u) == content and u.has("text") { u.text } else { none }
  if s == none { return none }
  s.replace("²", "^2").replace("³", "^3").replace(regex("\s+"), "")
}

/// Rang absolu d'une unité ; arrête la compilation si elle n'existe pour aucun type de tableau.
#let rdconv-rang-unite(u, commande: "rdconv") = {
  let nom = rdconv-nom-unite(u)
  if nom == none or nom not in rdconv-unites {
    panic(
      commande + " : unité invalide " + repr(u) + ". Unités possibles : "
        + rdconv-unites.keys().map(k => "« " + k + " »").join(", ") + ".",
    )
  }
  rdconv-unites.at(nom)
}

/// Unité mise en forme pour l'affichage : `m^2` devient m².
#let rdconv-unite-affichee(u) = {
  let nom = rdconv-nom-unite(u)
  if nom == none { return u }
  if nom.ends-with("^2") { [#nom.slice(0, -2)#super[2]] } else if nom.ends-with("^3") {
    [#nom.slice(0, -2)#super[3]]
  } else { [#nom] }
}

// =====================================================================
// Nombres
// =====================================================================

/// Lit un nombre positif (entier ou décimal, point ou virgule) : (ent, dec), chaînes de chiffres brutes.
#let rdconv-lire-nombre(v, commande: "rdconv") = {
  let s = if type(v) == str { v } else if type(v) in (int, float, decimal) { str(v) } else if (
    type(v) == content and v.has("text")
  ) { v.text } else { none }
  if s == none {
    panic(commande + " : valeur illisible " + repr(v) + ". Forme attendue : un nombre écrit comme une chaîne (\"3,45\") ou un nombre Typst.")
  }
  let t = s.replace(regex("[\s~\u{00A0}\u{202F}\u{2009}]"), "")
  if t.match(regex("^[0-9]*[.,]?[0-9]*$")) == none or t.match(regex("[0-9]")) == none {
    panic(commande + " : valeur illisible " + repr(v) + ". Forme attendue : un nombre entier ou décimal (« 12 », « 3,45 », « 45.6 »).")
  }
  let morceaux = t.split(regex("[.,]"))
  (ent: morceaux.at(0), dec: if morceaux.len() > 1 { morceaux.at(1) } else { "" })
}

#let _sans-zeros-tete(s) = {
  let r = s.replace(regex("^0+"), "")
  if r == "" { "0" } else { r }
}
#let _sans-zeros-queue(s) = s.replace(regex("0+$"), "")

/// Nombre décalé de `k` rangs vers la droite (k > 0 : la virgule recule, il y a plus de chiffres) ou vers la
/// gauche (k < 0), écrit avec une virgule décimale, sans zéros inutiles. Équivaut à la multiplication par 10^k.
#let rdconv-decaler(v, k, commande: "rdconvtext") = {
  let n = rdconv-lire-nombre(v, commande: commande)
  let (ent, dec) = n
  if k > 0 {
    for _ in range(k) {
      if dec == "" { ent += "0" } else {
        ent += dec.first()
        dec = dec.slice(1)
      }
    }
  } else if k < 0 {
    for _ in range(-k) {
      if ent == "" { dec = "0" + dec } else {
        dec = ent.last() + dec
        ent = ent.slice(0, -1)
      }
    }
  }
  ent = _sans-zeros-tete(ent)
  dec = _sans-zeros-queue(dec)
  if dec == "" { ent } else { ent + "," + dec }
}

/// Valeur affichée dans les colonnes d'information : telle que saisie, avec la virgule décimale.
#let rdconv-valeur-affichee(v, commande: "rdconv") = {
  let n = rdconv-lire-nombre(v, commande: commande)
  if n.dec == "" and not (type(v) == str and v.contains(regex("[.,]$"))) { n.ent } else { n.ent + "," + n.dec }
}

// =====================================================================
// Lignes du tableau (données) : chiffres, zéros ajoutés, ratures, virgule
// =====================================================================

/// Place la valeur dans `n` colonnes, l'unité étant à la colonne `a` (1 = première colonne) :
/// (cases: tableau de n entrées, none ou (c, t), croix: colonnes à barrer, virgule: colonne ou none).
#let rdconv-placer(valeur, a, n, virgule: false, commande: "rdplace") = {
  let (ent, dec) = rdconv-lire-nombre(valeur, commande: commande)
  ent = _sans-zeros-tete(ent)
  dec = _sans-zeros-queue(dec)
  let m = (:)
  let c = a
  for d in ent.clusters().rev() {
    m.insert(str(c), (c: d, t: "digit"))
    c -= 1
  }
  c = a + 1
  for d in dec.clusters() {
    m.insert(str(c), (c: d, t: "digit"))
    c += 1
  }
  let cases = range(1, n + 1).map(k => m.at(str(k), default: none))
  let v = if virgule and dec != "" and a >= 1 and a + 1 <= n { a } else { none }
  (cases: cases, croix: (), virgule: v)
}

/// Conversion de `valeur` de la colonne `a` (unité de départ) vers la colonne `b` (unité d'arrivée) :
/// chiffres, zéros ajoutés (« added »), colonnes à barrer, virgule à placer après la colonne `b`.
#let rdconv-convertir(valeur, a, b, n, commande: "rdconvert") = {
  let (ent, dec) = rdconv-lire-nombre(valeur, commande: commande)
  ent = _sans-zeros-tete(ent)
  dec = _sans-zeros-queue(dec)
  let m = (:)
  let mn = 999
  let mx = -999
  let c = a
  for d in ent.clusters().rev() {
    m.insert(str(c), (c: d, t: "digit"))
    mn = calc.min(mn, c)
    mx = calc.max(mx, c)
    c -= 1
  }
  c = a + 1
  for d in dec.clusters() {
    m.insert(str(c), (c: d, t: "digit"))
    mn = calc.min(mn, c)
    mx = calc.max(mx, c)
    c += 1
  }
  if b < mn {
    for k in range(b, mn) { m.insert(str(k), (c: "0", t: "added")) }
    mn = b
  }
  if b > mx {
    for k in range(mx + 1, b + 1) { m.insert(str(k), (c: "0", t: "added")) }
    mx = b
  }
  let premier = 999
  let dernier = -999
  for k in range(mn, mx + 1) {
    if m.at(str(k)).c != "0" {
      premier = calc.min(premier, k)
      dernier = calc.max(dernier, k)
    }
  }
  let gauche = calc.min(premier, b)
  let droite = calc.max(dernier, b)
  let croix = range(mn, mx + 1).filter(k => (k < gauche or k > droite) and k >= 1 and k <= n)
  let cases = range(1, n + 1).map(k => m.at(str(k), default: none))
  let v = if b < dernier and b >= 1 and b + 1 <= n { b } else { none }
  (cases: cases, croix: croix, virgule: v)
}

// =====================================================================
// Réglages (\setrdconv) : clés /rdconv/
// =====================================================================

#let _fmt = (
  v => v == none or type(v) == dictionary,
  "none ou un dictionnaire de format (bg, fg, font, align, border, text, fill…)",
)
#let _trait = (
  v => v == auto or v == none or type(v) in (length, color, stroke, dictionary),
  "auto, none (ligne invisible), une longueur, une couleur, un trait Typst (1.5pt + black) ou un dictionnaire (paint, thickness, dash)",
)
#let _colonne = (
  v => v in ("l", "c", "r") or type(v) == dictionary,
  "\"l\", \"c\", \"r\" ou un dictionnaire (align: left | center | right, width: longueur, pourcentage ou fraction)",
)
#let _macro = (
  v => v == none or type(v) == function or v == "rdconvbadge",
  "none, une fonction `numéro => contenu` ou \"rdconvbadge\"",
)
#let _style-auto = (
  v => v == auto or v == none or type(v) in (dictionary, function, array),
  "auto, none, un dictionnaire de style (text, fill, draw, font, line-width…), une fonction ou un tableau de styles",
)

#let rdconv-defauts = (
  type: "length",
  title: none,
  title-pos: "top",
  title-format: none,
  title-border: true,
  show-mult: false,
  mult-format: none,
  mult-border: true,
  mult-text: [Multiples],
  submult-text: [Sous-multiples],
  decimal-sep: false,
  correction: false,
  mass-tons: false,
  show-ca: false,
  sec-units: true,
  width: 100%,
  liter: $ell$,
  number-info: false,
  number-table: false,
  nb-info-col-type: "c",
  nb-table-col-type: "c",
  nb-info-macro: none,
  nb-table-macro: none,
  info-col-type: "l",
  info-col: none,
  tblr-options: none,
  grid-style: auto,
  grid-v-style: auto,
  grid-vminor-style: auto,
  grid-outer-style: auto,
  grid-h-style: auto,
  grid-hminor-style: auto,
  unit-format: none,
  sec-unit-format: none,
  data-format: none,
  cell-base-style: auto,
  digit-style: auto,
  added-style: auto,
  comma-style: auto,
  cross-style: auto,
  cross-path: none,
  rdtheme-main-color: rgb("#5F8090"),
)

// Valeurs d'origine des styles laissés à `auto`
#let rdconv-base-defaut = (inset: 2pt, min-width: 1em)
#let rdconv-ajoute-defaut = (text: red, font: (weight: "bold"))
#let rdconv-virgule-defaut = (text: red, font: (weight: "bold", size: 1.6em), inset: 0pt)
#let rdconv-rature-defaut = (draw: red, line-width: 0.8pt)

#let rdconv-controles = (
  type: reglages-choix("length", "mass", "capacity", "area", "volume"),
  title: (v => v == none or type(v) in (str, content), "none, une chaîne ou un contenu"),
  title-pos: reglages-choix("top", "bottom", "below-mult"),
  title-format: _fmt,
  title-border: reglages-controles.booleen,
  show-mult: reglages-controles.booleen,
  mult-format: _fmt,
  mult-border: reglages-controles.booleen,
  mult-text: reglages-controles.contenu,
  submult-text: reglages-controles.contenu,
  decimal-sep: reglages-controles.booleen,
  correction: reglages-controles.booleen,
  mass-tons: reglages-controles.booleen,
  show-ca: reglages-controles.booleen,
  sec-units: reglages-controles.booleen,
  width: (v => type(v) in (length, ratio, relative), "une longueur ou un pourcentage"),
  liter: reglages-controles.contenu,
  number-info: reglages-controles.booleen,
  number-table: reglages-controles.booleen,
  nb-info-col-type: _colonne,
  nb-table-col-type: _colonne,
  nb-info-macro: _macro,
  nb-table-macro: _macro,
  info-col-type: _colonne,
  info-col: (v => v == none or type(v) in (str, content, function), "none, un contenu ou une fonction `dictionnaire => contenu`"),
  tblr-options: (
    v => v == none or (type(v) == dictionary and v.keys().all(k => k in ("colsep", "rowsep", "cells"))),
    "none ou un dictionnaire (colsep: longueur, rowsep: longueur, cells: format)",
  ),
  grid-style: _trait,
  grid-v-style: _trait,
  grid-vminor-style: _trait,
  grid-outer-style: _trait,
  grid-h-style: _trait,
  grid-hminor-style: _trait,
  unit-format: _fmt,
  sec-unit-format: _fmt,
  data-format: _fmt,
  cell-base-style: _style-auto,
  digit-style: _style-auto,
  added-style: _style-auto,
  comma-style: _style-auto,
  cross-style: _style-auto,
  cross-path: (v => v == none or type(v) == function, "none ou une fonction `noeud => contenu` (noeud : w, h, asc, stroke)"),
  rdtheme-main-color: reglages-controles.couleur-ou-nom,
)

// ---- Styles prédéfinis : rdfiche, rdtheme et ses déclinaisons

#let rdconv-sans = ("Latin Modern Sans", "TeX Gyre Heros")
#let rdconv-magenta = rgb("#e52779")
#let rdconv-bleu-fonce = rgb("#5F8090")
#let rdconv-bleu-moyen = rgb("#AABAC2")
#let rdconv-bleu-clair = rgb("#EEF3F5")
#let rdconv-bleu = rgb("#1565c0")
#let rdconv-sarcelle = rgb("#009688")
#let rdconv-rouge = rgb("#d32f2f")

/// ➊ ➋ ➌… : numéro encerclé (dingbat), en entier de 1 à 10.
#let rdconvdingnum(n) = {
  if type(n) != int or n < 1 or n > 10 {
    panic("rdconvdingnum : un entier de 1 à 10 est attendu ; reçu : " + repr(n) + ".")
  }
  text(font: "DejaVu Sans", str.from-unicode(0x2789 + n))
}

/// Pastille ronde numérotée (couleur `couleur`).
#let rdconvbadge(n, couleur: rdconv-bleu-fonce) = {
  let c = bf-xcolor(couleur, commande: "rdconvbadge")
  box(
    baseline: 0.34em,
    circle(
      width: 1.3em, height: 1.3em, inset: 0pt, fill: c,
      align(center + horizon, text(fill: white, size: 0.7em, weight: "bold", font: rdconv-sans, [#n])),
    ),
  )
}

/// Jeu de clés du style `rdtheme` pour trois couleurs (principale, multiples, fond des données).
#let rdconv-theme(c1, c2, c3) = (
  show-mult: true,
  number-table: true,
  nb-table-macro: "rdconvbadge",
  rdtheme-main-color: c1,
  grid-outer-style: none,
  grid-v-style: none,
  grid-vminor-style: none,
  grid-h-style: none,
  grid-hminor-style: (thickness: 0.6pt, paint: c1, dash: "dashed"),
  mult-border: false,
  mult-format: (bg: c2, fg: white, font: (family: rdconv-sans)),
  unit-format: (bg: c1, fg: white, font: (family: rdconv-sans, weight: "bold")),
  sec-unit-format: (bg: c1, fg: white, font: (family: rdconv-sans)),
  data-format: (bg: c3, fg: c1, font: (family: rdconv-sans)),
  added-style: (text: c1, font: (weight: "bold"), inset: 0pt),
  comma-style: (text: c1, font: (weight: "bold", size: 1.6em)),
)

#let rdconv-styles = (
  rdfiche: (
    correction: true,
    number-info: true,
    number-table: true,
    nb-info-macro: rdconvdingnum,
    nb-table-macro: rdconvdingnum,
    unit-format: (bg: "black!50", fg: white, font: (family: rdconv-sans, weight: "bold")),
    grid-style: none,
    data-format: (bg: "black!5", font: (family: rdconv-sans, weight: "bold")),
    cell-base-style: (seyes: (fill: white, opacity: 0.6), text-depth: 1.5mm, min-width: 100%, text-height: 5.5mm),
    added-style: (text: rdconv-magenta),
    cross-path: n => place(
      top + left,
      line(
        start: (n.w / 2 - 0.5em, n.asc + 2pt),
        end: (n.w / 2 + 0.5em, n.asc - 1em),
        stroke: n.stroke + (thickness: 0.8pt),
      ),
    ),
    tblr-options: (colsep: 3pt, rowsep: 3pt),
  ),
  rdtheme: rdconv-theme(rdconv-bleu-fonce, rdconv-bleu-moyen, rdconv-bleu-clair),
  rdtheme-blue: rdconv-theme(rdconv-bleu-fonce, rdconv-bleu-moyen, rdconv-bleu-clair),
  rdtheme-dark: rdconv-theme(black, xmix(black, 50), xmix(black, 10)),
  rdtheme-lightblue: rdconv-theme(rdconv-bleu, xmix(rdconv-bleu, 50), xmix(rdconv-bleu, 10)),
  rdtheme-teal: rdconv-theme(rdconv-sarcelle, xmix(rdconv-sarcelle, 50), xmix(rdconv-sarcelle, 10)),
  rdtheme-red: rdconv-theme(rdconv-rouge, xmix(rdconv-rouge, 50), xmix(rdconv-rouge, 10)),
)

#let rdconv-reglages = reglages-paquet(
  "rdconv",
  rdconv-defauts,
  controles: rdconv-controles,
  styles: rdconv-styles,
  commande: "setrdconv",
)

// =====================================================================
// Rendu (dans un `context`)
// =====================================================================

/// Format de cellule (bg, fg, font, alignement, bordure) : style normalisé, alignement, bordure.
#let _format(f, commande, cle) = {
  if f == none { return (st: rd-style(none), border: none, align: auto) }
  let d = f
  let bordure = d.remove("border", default: none)
  let al = d.remove("align", default: auto)
  if "bg" in d { d.fill = d.remove("bg") }
  if "fg" in d { d.text = d.remove("fg") }
  let al = if al == "l" { left } else if al == "c" { center } else if al == "r" { right } else { al }
  (st: rd-style(d, commande: commande, cle: cle), border: bordure, align: al)
}

/// Trait de grille : `auto` donne `defaut`, `none` une ligne invisible.
#let _norm-trait(v, defaut, commande) = {
  if v == auto { return defaut }
  if v == none { return none }
  if type(v) == dictionary {
    let d = v
    if "paint" in d and type(d.paint) == str { d.paint = bf-xcolor(d.paint, commande: commande) }
    return stroke(..d)
  }
  if type(v) == str { return bf-xcolor(v, commande: commande) }
  v
}

#let _col-spec(v) = {
  let al = (l: left, c: center, r: right)
  if type(v) == str { return (align: al.at(v), width: auto) }
  (align: v.at("align", default: left), width: v.at("width", default: auto))
}

/// Géométrie de la grille selon le type : (n colonnes de données, mult, base, dim, décalage).
#let _geometrie(r) = {
  let t = r.type
  if t == "length" { (n: 7, mult: 3, base: 1, dim: 1, off: 0) } else if t == "capacity" {
    (n: 7, mult: 3, base: 1, dim: 1, off: -11)
  } else if t == "area" { (n: 14, mult: 6, base: 2, dim: 2, off: 0) } else if t == "volume" {
    (n: 21, mult: 9, base: 3, dim: 3, off: 0)
  } else if r.mass-tons { (n: 10, mult: 6, base: 1, dim: 1, off: 0) } else { (n: 7, mult: 3, base: 1, dim: 1, off: -3) }
}

/// En-têtes des unités : tableau de (contenu, colonnes occupées, alignement).
#let _entetes-unites(r, geo) = {
  let t = r.type
  let l = r.liter
  let simple(xs) = xs.map(x => (x, 1, center))
  if t == "length" { simple(("km", "hm", "dam", "m", "dm", "cm", "mm").map(x => [#x])) } else if t == "capacity" {
    simple(("k", "h", "da", "", "d", "c", "m").map(x => box[#x#sym.wj#l]))
  } else if t == "mass" and r.mass-tons {
    simple(("t", "q", "", "kg", "hg", "dag", "g", "dg", "cg", "mg").map(x => [#x]))
  } else if t == "mass" { simple(("kg", "hg", "dag", "g", "dg", "cg", "mg").map(x => [#x])) } else {
    let e = if t == "area" { 2 } else { 3 }
    ("km", "hm", "dam", "m", "dm", "cm", "mm").map(x => (box[#x#super[#e]], geo.dim, right))
  }
}

/// Ligne des unités secondaires (aires : ha, a, ca ; volumes : capacités) : tableau de n contenus, ou none.
#let _secondaires(r, geo) = {
  if not r.sec-units or r.type not in ("area", "volume") { return none }
  let c = (none,) * geo.n
  if r.type == "area" {
    c.at(3) = [ha]
    c.at(5) = [a]
    if r.show-ca { c.at(7) = [ca] }
  } else {
    for (i, p) in ("k", "h", "da", "", "d", "c", "m").enumerate() { c.at(11 + i) = box[#p#sym.wj#r.liter] }
  }
  c
}

/// Valeur d'une clé de style : le défaut du moteur quand elle vaut `auto`.
#let _ou-defaut(v, defaut) = if v == auto { defaut } else { v }

/// Fond Seyès d'un nœud : fonction (w, h, asc) → contenu, ou none.
#let _fond-seyes(spec) = {
  if spec == none or spec == false { return none }
  let fond = none
  let op = 1
  if type(spec) == dictionary {
    fond = spec.at("fill", default: none)
    op = spec.at("opacity", default: 1)
  }
  (w, h, asc) => box(width: w, height: h, clip: true, {
    if fond != none {
      let c = bf-xcolor(fond, commande: "rdconv")
      place(top + left, rect(width: w, height: h, fill: if op < 1 { c.transparentize((1 - op) * 100%) } else { c }, stroke: none))
    }
    lignes-seyes(w, h, asc)
  })
}

/// Cellule de grille.
#let _cell(x, y, corps, colspan: 1, fill: none, align: auto, strut: true) = (
  x: x, y: y, colspan: colspan, fill: fill, align: align,
  corps: if strut { box(height: 1.2em, std.align(horizon, corps)) } else { corps },
)

/// Numéro de ligne mis en forme par la macro choisie (`rdconvbadge`, fonction ou rien).
#let _numero(m, v, couleur) = {
  if m == none { [#v] } else if m == "rdconvbadge" { rdconvbadge(v, couleur: couleur) } else { m(v) }
}

/// Rendu de `rdconv` : `r` = réglages résolus ; `lignes` = lignes décrites par `rdplace`, `rdconvert` et
/// `rdconvemptyline`.
#let rdconv-rendu(r, lignes, commande: "rdconv") = {
  let cmd = commande
  let geo = _geometrie(r)
  let n = geo.n
  let dim = geo.dim
  let opts = if r.tblr-options == none { (:) } else { r.tblr-options }
  let colsep = opts.at("colsep", default: 6pt)
  let rowsep = opts.at("rowsep", default: 2pt)
  // ---- version prof / élève et style des corrections
  let rs = reglages-courants(bf-reglages-socle)
  let corr-couleur = bf-xcolor(rs.correction-color, commande: cmd)
  let corr-police = rs.correction-font
  let corr-prof = r.correction and est-correction()
  let afficher = (not r.correction) or est-correction()
  let st-corr = (text: corr-couleur, font: corr-police)
  // ---- styles des nœuds
  let st-base = rd-style(_ou-defaut(r.cell-base-style, rdconv-base-defaut), commande: cmd, cle: "cell-base-style")
  let digit-perso = r.digit-style != auto
  let st-digit = rd-style(if digit-perso { r.digit-style } else { none }, commande: cmd, cle: "digit-style")
  let ajoute-perso = r.added-style != auto
  let st-ajoute = rd-style(_ou-defaut(r.added-style, rdconv-ajoute-defaut), commande: cmd, cle: "added-style")
  let virgule-perso = r.comma-style != auto
  let st-virgule = rd-style(_ou-defaut(r.comma-style, rdconv-virgule-defaut), commande: cmd, cle: "comma-style")
  let rature-perso = r.cross-style != auto
  let st-rature = rd-style(_ou-defaut(r.cross-style, rdconv-rature-defaut), commande: cmd, cle: "cross-style")
  let st-saisi = rd-style-fusion(st-base, st-digit, commande: cmd)
  let st-chiffre = rd-style-fusion(st-saisi, if corr-prof and not digit-perso { st-corr } else { none }, commande: cmd)
  let st-zero = rd-style-fusion(
    st-saisi, st-ajoute, if corr-prof and not ajoute-perso { st-corr } else { none }, commande: cmd,
  )
  let st-rature-final = rd-style-fusion(
    st-rature, if corr-prof and not rature-perso { (draw: corr-couleur) } else { none }, commande: cmd,
  )
  let trait-rature = rd-trait(st-rature-final, defaut: red, epaisseur: 0.8pt, commande: cmd)
  let ht0 = rd-hauteur[0]
  let fond-seyes = _fond-seyes(st-base.cles.at("seyes", default: none))
  // ---- colonnes de gauche
  let gauche = ()
  if r.number-info { gauche.push((cle: "num-info", spec: _col-spec(r.nb-info-col-type))) }
  if r.info-col != none { gauche.push((cle: "info", spec: _col-spec(r.info-col-type))) }
  if r.number-table { gauche.push((cle: "num-table", spec: _col-spec(r.nb-table-col-type))) }
  let g = gauche.len()
  // ---- lignes de données
  let numero = 0
  let donnees = ()
  for l in lignes {
    if type(l) != dictionary or "rdconv-ligne" not in l {
      panic(
        cmd + " : le contenu d'un tableau se compose de lignes `rdplace(…)`, `rdconvert(…)` et `rdconvemptyline(…)` ; reçu : "
          + repr(l) + ".",
      )
    }
    if l.rdconv-ligne == "vide" {
      for _ in range(l.nombre) {
        numero += 1
        donnees.push((num: numero, type: "vide"))
      }
    } else if l.rdconv-ligne == "place" {
      numero += 1
      let a = rdconv-rang-unite(l.unite, commande: "rdplace") + geo.off + 1
      let p = rdconv-placer(l.valeur, a, n, virgule: r.decimal-sep, commande: "rdplace")
      donnees.push((
        num: numero, type: "place", ..p, local: none,
        info: (
          rdValInit: rdconv-valeur-affichee(l.valeur), rdUnitInit: rdconv-unite-affichee(l.unite),
          rdValTarget: [], rdUnitTarget: [],
        ),
      ))
    } else {
      numero += 1
      let ra = rdconv-rang-unite(l.de, commande: "rdconvert")
      let rb = rdconv-rang-unite(l.vers, commande: "rdconvert")
      let p = rdconv-convertir(l.valeur, ra + geo.off + 1, rb + geo.off + 1, n, commande: "rdconvert")
      donnees.push((
        num: numero, type: "convertir", ..p, local: l.comma-style,
        info: (
          rdValInit: rdconv-valeur-affichee(l.valeur), rdUnitInit: rdconv-unite-affichee(l.de),
          rdValTarget: rdconv-decaler(l.valeur, rb - ra, commande: "rdconvert"), rdUnitTarget: rdconv-unite-affichee(l.vers),
        ),
      ))
    }
  }
  // ---- lignes du tableau
  let titre = r.title != none and r.title != "" and r.title != []
  let rangs = ()
  if titre and r.title-pos == "top" { rangs.push("titre") }
  if r.show-mult { rangs.push("mult") }
  if titre and r.title-pos == "below-mult" { rangs.push("titre") }
  rangs.push("unites")
  let secondaire = _secondaires(r, geo)
  if secondaire != none { rangs.push("sec") }
  let iu = rangs.position(x => x == "unites")
  let premiere-donnee = rangs.len()
  for _ in donnees { rangs.push("data") }
  if titre and r.title-pos == "bottom" { rangs.push("titre") }
  let nr = rangs.len()
  // ---- formats
  let f-titre = _format(r.title-format, cmd, "title-format")
  let f-mult = _format(r.mult-format, cmd, "mult-format")
  let f-unites = _format(r.unit-format, cmd, "unit-format")
  let f-sec = _format(r.sec-unit-format, cmd, "sec-unit-format")
  let f-data = _format(r.data-format, cmd, "data-format")
  let f-toutes = _format(opts.at("cells", default: none), cmd, "tblr-options")
  let bord-titre = if f-titre.border != none { f-titre.border } else { r.title-border }
  let bord-mult = if f-mult.border != none { f-mult.border } else { r.mult-border }
  if r.title-pos == "below-mult" and r.show-mult and bord-mult and not bord-titre { bord-titre = true }
  // ---- traits de la grille : H.at(y).at(j) = trait au-dessus de la ligne y, colonne de données j ;
  //      V.at(b).at(y) = trait entre les colonnes b et b+1 (0 et n : bords), ligne y
  let defaut-gras = stroke(thickness: 1.5pt, paint: black)
  let t-grille = r.grid-style
  let t-h = _norm-trait(if r.grid-h-style != auto { r.grid-h-style } else { t-grille }, defaut-gras, cmd)
  let t-v = _norm-trait(if r.grid-v-style != auto { r.grid-v-style } else { t-grille }, defaut-gras, cmd)
  let t-vmin = _norm-trait(
    if r.grid-vminor-style != auto { r.grid-vminor-style } else { t-grille },
    stroke(thickness: 0.6pt, paint: black, dash: "dashed"), cmd,
  )
  let t-ext = _norm-trait(if r.grid-outer-style != auto { r.grid-outer-style } else { t-grille }, defaut-gras, cmd)
  let t-hmin = _norm-trait(if r.grid-hminor-style != auto { r.grid-hminor-style } else { t-grille }, auto, cmd)
  let H = range(nr + 1).map(_ => (t-h,) * n)
  H.at(0) = (t-ext,) * n
  H.at(nr) = (t-ext,) * n
  if secondaire != none and t-hmin != auto { H.at(iu + 1) = (t-hmin,) * n }
  let V = range(n + 1).map(b => {
    let t = if b == 0 or b == n { t-ext } else if calc.rem(b, dim) == 0 { t-v } else { t-vmin }
    (t,) * nr
  })
  // limites de colonne masquées par une cellule fusionnée, par ligne
  let cache = range(nr).map(_ => ())
  // ---- cellules de la grille
  let cellules = ()
  for (y, k) in rangs.enumerate() {
    if k == "titre" {
      let c = rd-texte(r.title, f-titre.st, commande: cmd)
      cellules.push(_cell(
        g, y, c, colspan: n, fill: rd-fond(f-titre.st, commande: cmd),
        align: if f-titre.align == auto { center } else { f-titre.align },
      ))
      for b in range(1, n) { cache.at(y).push(b) }
      if not bord-titre {
        if r.title-pos == "bottom" { H.at(nr) = (none,) * n } else { H.at(y) = (none,) * n }
        V.at(0).at(y) = none
        V.at(n).at(y) = none
      }
    } else if k == "mult" {
      let c1 = rd-texte(r.mult-text, f-mult.st, commande: cmd)
      let c2 = rd-texte(r.submult-text, f-mult.st, commande: cmd)
      let fo = rd-fond(f-mult.st, commande: cmd)
      let al = if f-mult.align == auto { center } else { f-mult.align }
      cellules.push(_cell(g, y, c1, colspan: geo.mult, fill: fo, align: al))
      cellules.push(_cell(g + geo.mult + geo.base, y, c2, colspan: n - geo.mult - geo.base, fill: fo, align: al))
      for b in range(1, geo.mult) { cache.at(y).push(b) }
      for b in range(geo.mult + 1, geo.mult + geo.base) { cache.at(y).push(b) }
      for b in range(geo.mult + geo.base + 1, n) { cache.at(y).push(b) }
      // le dessus de la case vide du milieu n'est tracé que sous un titre encadré
      let sous-titre = titre and r.title-pos == "top" and bord-titre
      if not sous-titre {
        for j in range(geo.mult, geo.mult + geo.base) { H.at(y).at(j) = none }
      }
      if not bord-mult {
        for j in range(0, geo.mult) { H.at(y).at(j) = none }
        for j in range(geo.mult + geo.base, n) { H.at(y).at(j) = none }
        for b in (0, geo.mult, geo.mult + geo.base, n) { V.at(b).at(y) = none }
      }
    } else if k == "unites" {
      let x = 0
      for (c, span, al) in _entetes-unites(r, geo) {
        cellules.push(_cell(
          g + x, y, rd-texte(c, f-unites.st, commande: cmd), colspan: span,
          fill: rd-fond(f-unites.st, commande: cmd), align: if f-unites.align == auto { al } else { f-unites.align },
        ))
        for b in range(x + 1, x + span) { cache.at(y).push(b) }
        x += span
      }
    } else if k == "sec" {
      for (j, c) in secondaire.enumerate() {
        cellules.push(_cell(
          g + j, y, rd-texte(if c == none { [] } else { c }, f-sec.st, commande: cmd), fill: rd-fond(f-sec.st, commande: cmd),
          align: if f-sec.align == auto { center } else { f-sec.align },
        ))
      }
    }
  }
  // ---- lignes de données
  for (i, d) in donnees.enumerate() {
    let y = premiere-donnee + i
    for (ic, col) in gauche.enumerate() {
      let corps = if col.cle == "num-info" {
        _numero(r.nb-info-macro, d.num, r.rdtheme-main-color)
      } else if col.cle == "num-table" {
        _numero(r.nb-table-macro, d.num, r.rdtheme-main-color)
      } else if d.type == "vide" {
        []
      } else if type(r.info-col) == function {
        (r.info-col)(d.info)
      } else { r.info-col }
      cellules.push(_cell(ic, y, corps, align: col.spec.align + horizon))
    }
    for j in range(n) {
      let case = if d.type == "vide" { none } else { d.cases.at(j) }
      let visible = case != none and (d.type == "place" or afficher)
      let st = if not visible { st-base } else if case.t == "digit" {
        if d.type == "place" { st-saisi } else { st-chiffre }
      } else { st-zero }
      let contenu = if visible { [#case.c] } else { [] }
      let croix = visible and d.type == "convertir" and (j + 1) in d.croix and trait-rature != none
      let vir = d.at("virgule", default: none)
      let virgule = vir != none and (j + 1) == vir and (d.type == "place" or afficher)
      let cellule = layout(sz => {
        let w = sz.width
        let nd = rd-noeud(
          contenu, st, commande: cmd, largeur-max: w,
          ht-defaut: if visible { ht0 } else { none }, dp-defaut: if visible { 0pt } else { none },
          fond-extra: fond-seyes,
        )
        let x0 = (w - nd.w) / 2
        let hh = calc.max(nd.h, 1.2em.to-absolute())
        let y0 = (hh - nd.h) / 2
        box(width: w, height: hh, {
          let ombre = st.cles.at("drop-shadow", default: none)
          if ombre != none and ombre != false {
            let c = if ombre == true { black.transparentize(50%) } else { bf-xcolor(ombre, commande: cmd) }
            place(top + left, dx: x0 + 0.25em, dy: y0 + 0.25em, rect(width: nd.w, height: nd.h, fill: c, stroke: none))
          }
          place(top + left, dx: x0, dy: y0, nd.corps)
          if croix {
            let fn = if r.cross-path != none { r.cross-path } else {
              z => place(top + left, line(start: (0pt, z.h), end: (z.w, 0pt), stroke: z.stroke))
            }
            place(top + left, dx: x0, dy: y0, fn((w: nd.w, h: nd.h, asc: nd.asc, stroke: trait-rature)))
          }
          if virgule {
            // virgule : centrée sur la limite de colonne, à la hauteur de la ligne de base
            let st-v = if d.type == "place" {
              st-virgule
            } else {
              rd-style-fusion(
                st-virgule, if corr-prof and not virgule-perso { st-corr } else { none }, d.local, commande: cmd,
              )
            }
            let vn = rd-noeud([,], st-v, commande: cmd)
            place(
              top + left,
              dx: w + colsep - vn.w / 2 + rd-abs(st-v.cles.at("xshift", default: 0pt)),
              dy: y0 + nd.asc - vn.h / 2 - rd-abs(st-v.cles.at("yshift", default: 0pt)),
              vn.corps,
            )
          }
        })
      })
      cellules.push(_cell(g + j, y, cellule, fill: rd-fond(f-data.st, commande: cmd), align: center + horizon, strut: false))
    }
  }
  // ---- traits : plages contiguës de même style
  let traits = ()
  for (y, l) in H.enumerate() {
    let j = 0
    while j < n {
      let t = l.at(j)
      if t == none {
        j += 1
        continue
      }
      let k = j
      while k + 1 < n and l.at(k + 1) == t { k += 1 }
      traits.push(grid.hline(y: y, start: g + j, end: g + k + 1, stroke: t))
      j = k + 1
    }
  }
  for (b, col) in V.enumerate() {
    let y = 0
    while y < nr {
      let t = col.at(y)
      if t == none or (b in cache.at(y)) {
        y += 1
        continue
      }
      let k = y
      while k + 1 < nr and col.at(k + 1) == t and not (b in cache.at(k + 1)) { k += 1 }
      traits.push(grid.vline(x: g + b, start: y, end: k + 1, stroke: t))
      y = k + 1
    }
  }
  // ---- grille
  let colonnes = gauche.map(c => c.spec.width) + (1fr,) * n
  let alignements = gauche.map(c => c.spec.align + horizon) + (center + horizon,) * n
  // deux couches superposées de même géométrie : dessous, les fonds et les traits (contenu invisible) ;
  // dessus, le contenu seul, pour que la virgule et les ratures passent par-dessus les traits
  let dessous = cellules.map(c => grid.cell(
    x: c.x, y: c.y, colspan: c.colspan, fill: if c.fill == none { auto } else { c.fill }, align: c.align, hide(c.corps),
  ))
  let dessus = cellules.map(c => grid.cell(x: c.x, y: c.y, colspan: c.colspan, align: c.align, c.corps))
  let couche-bas = grid(
    columns: colonnes, align: alignements, inset: (x: colsep, y: rowsep), stroke: none,
    fill: rd-fond(f-toutes.st, commande: cmd), ..dessous, ..traits,
  )
  let couche-haut = grid(
    columns: colonnes, align: alignements, inset: (x: colsep, y: rowsep), stroke: none, ..dessus,
  )
  block(width: r.width, breakable: false, rd-texte({ couche-bas; place(top + left, couche-haut) }, f-toutes.st, commande: cmd))
}
