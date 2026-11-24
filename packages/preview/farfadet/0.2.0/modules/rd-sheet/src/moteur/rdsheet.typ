// rdsheet.typ (rdsheet, moteur) — captures de feuilles de calcul : en-têtes alphabétiques et numériques
// protégés, translation transparente des coordonnées, sélection active (cadre et poignée de recopie),
// barre de formule (thèmes Calc et Excel), mode noir et blanc à contraste réglable.
//
// Les valeurs de couleurs et de dimensions sont celles d'origine (palettes des thèmes ci-dessous).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, reglages-resoudre,
  bf-xcolor, longueur-latex, taille-latex,
)
#import "commun.typ": *
#import "icones.typ": rd-icones

// =====================================================================
// Palettes des thèmes (couleur et noir et blanc)
// =====================================================================

// Couleurs communes aux deux thèmes, en mode couleur : boutons de la barre de formule.
#let _icones-couleur = (
  sigmab: "3F3F3F", sigmat: "737373", sigmac: "242424", eqdark: "1F1F1F", eqlight: "A2A2A2", eqmid: "555555",
  eqshd: "3F3F3F", eqmidshd: "737373", fxfg: "323232", fxdark: "262626", fxshd: "3F3F3F", fxmidshd: "737373",
)
// Les mêmes en niveaux de gris : (valeur à contraste 0, valeur à contraste 1).
#let _icones-gris = (
  sigmab: (0.45, 0.15), sigmat: (0.65, 0.40), sigmac: (0.30, 0.00), eqdark: (0.30, 0.00), eqlight: (0.80, 0.60),
  eqmid: (0.60, 0.35), eqshd: (0.45, 0.15), eqmidshd: (0.65, 0.40), fxfg: (0.30, 0.00), fxdark: (0.30, 0.00),
  fxshd: (0.45, 0.15), fxmidshd: (0.65, 0.40),
)

#let _theme-couleur = (
  default: (
    headerbg: "EBEBEB", headerfg: "000000", grid: "CCCCCC", headerborder: "A0A0A0", border: "A0A0A0",
    selectborder: "0078D7", selecthandle: "0078D7", selectheadbg: "0078D7", selectheadfg: "FFFFFF",
    toolbarbg: "EEEEEE", btnsep: "D0D0D0", btnfg: "333333", arrowbg: "E2E2E2",
    cornertriangle: "C8C6C4", barborder: "D1D5DB", btnneutral: "BDBDBD", dotsfg: "505050", fxcolor: "242424",
  ),
  excel: (
    headerbg: "F3F2F1", headerfg: "242424", grid: "D4D4D4", headerborder: "D4D4D4", border: "D1D5DB",
    barborder: "D1D5DB", selectborder: "107C41", selecthandle: "107C41", selectheadbg: "E1DFDD",
    selectheadfg: "107C41", toolbarbg: "F3F2F1", btnneutral: "BDBDBD", dotsfg: "505050", btnsep: "E1DFDD",
    btnfg: "323130", arrowbg: "EDEBE9", fxcolor: "242424", cornertriangle: "C8C6C4",
  ),
)

#let _theme-gris = (
  default: (
    headerbg: (0.90, 0.96), headerfg: (0.30, 0.00), grid: (0.85, 0.55), headerborder: (0.75, 0.25),
    border: (0.65, 0.00), selectborder: (0.40, 0.00), selecthandle: (0.40, 0.00), selectheadbg: (0.50, 0.12),
    selectheadfg: (1.00, 1.00), toolbarbg: (0.92, 0.97), btnsep: (0.80, 0.40), btnfg: (0.35, 0.00),
    arrowbg: (0.88, 0.80), cornertriangle: (0.80, 0.40), barborder: (0.85, 0.55), btnneutral: (0.78, 0.68),
    dotsfg: (0.45, 0.00), fxcolor: (0.30, 0.00),
  ),
  excel: (
    headerbg: (0.93, 0.97), headerfg: (0.30, 0.00), grid: (0.88, 0.68), headerborder: (0.88, 0.60),
    border: (0.80, 0.00), barborder: (0.85, 0.55), selectborder: (0.35, 0.00), selecthandle: (0.35, 0.00),
    selectheadbg: (0.88, 0.72), selectheadfg: (0.25, 0.00), toolbarbg: (0.93, 0.97), btnneutral: (0.78, 0.68),
    dotsfg: (0.45, 0.00), btnsep: (0.88, 0.60), btnfg: (0.35, 0.00), arrowbg: (0.90, 0.75),
    fxcolor: (0.30, 0.00), cornertriangle: (0.80, 0.40),
  ),
)

/// Palette d'un thème : dictionnaire nom → couleur. `contraste` (0 à 1) règle l'interpolation des gris.
#let rd-palette(excel, bw, contraste) = {
  let th = if excel { "excel" } else { "default" }
  let c = calc.min(1, calc.max(0, contraste))
  let gris(v) = luma((v.at(0) + c * (v.at(1) - v.at(0))) * 100%)
  if bw {
    let p = _theme-gris.at(th).pairs().map(((k, v)) => (k, gris(v))).to-dict()
    for (k, v) in _icones-gris { p.insert(k, gris(v)) }
    p
  } else {
    let p = _theme-couleur.at(th).pairs().map(((k, v)) => (k, rgb("#" + v))).to-dict()
    for (k, v) in _icones-couleur { p.insert(k, rgb("#" + v)) }
    p
  }
}

// =====================================================================
// Réglages (\setrdsheet et options de l'environnement rdsheet)
// =====================================================================

// Clés de style d'une cellule, d'une ligne ou d'une colonne (clés tabularray).
#let rd-cles-style = (
  "bg", "fg", "font", "halign", "valign", "ht", "wd", "mode", "r", "c", "cmd", "preto", "appto",
)

#let _est-style(v) = v == none or type(v) == dictionary
#let _est-specs(v) = v == none or type(v) in (dictionary, array)
#let _est-trait(v) = v == none or type(v) in (length, color, stroke, str, dictionary)
#let _est-traits(v) = v == none or type(v) in (dictionary, array) or _est-trait(v)
#let _est-longueur(v) = type(v) in (length, relative, ratio, str) and (type(v) != str or longueur-latex(v) != none)

#let rdsheet-reglages = reglages-paquet(
  "rdsheet",
  (
    theme: "default",
    bw: false,
    contrast: 0.5,
    row-start: 1,
    col-start: 1,
    range: none,
    head-width: auto,
    width: 100%,
    colspec: auto,
    select: none,
    bar: auto,
    name: none,
    name-width: 60pt,
    formula: none,
    cell: none,
    row: none,
    column: none,
    cells: none,
    rows: none,
    columns: none,
    hline: none,
    vline: none,
    hlines: none,
    vlines: none,
    long: false,
    baseline: none,
    // valeurs codées en dur dans rdsheet.sty / tabularray, rendues réglables (ajouts)
    colsep: 6pt,
    rowsep: 2pt,
    row-height: 1.4em,
    grid-width: 0.5pt,
    border-width: 0.8pt,
    select-width: 1.5pt,
    handle-size: 4.5pt,
    sans-font: ("Latin Modern Sans", "TeX Gyre Heros", "Liberation Sans", "Arial"),
    colors: none,
  ),
  controles: (
    theme: reglages-choix("default", "classic", "blue", "calc", "libreoffice", "excel", "green", "office", "print", "bw"),
    bw: reglages-controles.booleen,
    contrast: reglages-controles.nombre,
    row-start: reglages-controles.entier,
    col-start: (v => type(v) == int or (type(v) == str and v.trim().match(regex("^([0-9]+|[A-Za-z]+)$")) != none), "un entier ou une lettre de colonne (3 ou \"C\")"),
    range: (v => v == none or (type(v) == str and v.replace(" ", "").match(regex("^[A-Za-z]+[0-9]+(:[A-Za-z]+[0-9]+)?$")) != none), "none ou une plage de tableur (\"C12:E15\" ou \"C12\")"),
    head-width: (v => v == auto or _est-longueur(v), "auto ou une longueur"),
    width: (v => _est-longueur(v), "une longueur, un pourcentage ou une chaîne LaTeX (\"8cm\")"),
    colspec: (v => v == auto or type(v) in (str, array), "auto, une chaîne tabularray (\"Q[l,m,wd=2cm] X[c]\") ou un tableau de largeurs"),
    select: (v => v == none or (type(v) == str and v.replace(" ", "").match(regex("^[A-Za-z]+[0-9]+(:[A-Za-z]+[0-9]+)?$")) != none), "none ou une cellule ou plage de tableur (\"B2\" ou \"B2:C3\")"),
    bar: (v => v == auto or type(v) == bool, "auto (barre seulement si `name` ou `formula` est donné), true ou false"),
    name: reglages-controles.contenu-ou-none,
    name-width: reglages-controles.longueur,
    formula: reglages-controles.contenu-ou-none,
    cell: (_est-specs, "none, un dictionnaire { \"B2\": style } ou un tableau de ((\"B2\", style), (lignes, colonnes, style))"),
    row: (_est-specs, "none, un dictionnaire { \"1\": style } ou un tableau de (sélecteur, style)"),
    column: (_est-specs, "none, un dictionnaire { \"A\": style } ou un tableau de (sélecteur, style)"),
    cells: (_est-style, "none ou un dictionnaire de style (bg, fg, font, halign, valign, ht, mode…)"),
    rows: (_est-style, "none ou un dictionnaire de style (bg, fg, font, halign, valign, ht, mode…)"),
    columns: (_est-style, "none ou un dictionnaire de style (bg, fg, font, halign, valign, wd, mode…)"),
    hline: (_est-specs, "none, un dictionnaire { \"2\": filet } ou un tableau de (sélecteur, filet) ou (sélecteur, colonnes, filet)"),
    vline: (_est-specs, "none, un dictionnaire { \"2\": filet } ou un tableau de (sélecteur, filet) ou (sélecteur, lignes, filet)"),
    hlines: (_est-trait, "none ou un filet (\"0.5pt, gray!40\", 1pt + red, (thickness: 1pt, paint: red))"),
    vlines: (_est-trait, "none ou un filet (\"0.5pt, gray!40\", 1pt + red, (thickness: 1pt, paint: red))"),
    long: reglages-controles.booleen,
    baseline: (v => v == none or type(v) in (str, length, ratio), "none, \"t\", \"c\", \"b\" ou une longueur"),
    colsep: reglages-controles.longueur,
    rowsep: reglages-controles.longueur,
    row-height: reglages-controles.longueur,
    grid-width: reglages-controles.longueur,
    border-width: reglages-controles.longueur,
    select-width: reglages-controles.longueur,
    handle-size: reglages-controles.longueur,
    sans-font: (v => type(v) in (str, array), "un nom de police ou un tableau de noms"),
    colors: (v => v == none or type(v) == dictionary, "none ou un dictionnaire { headerbg: …, selectborder: … }"),
  ),
  commande: "setrdsheet",
)

// Alias LaTeX des clés (rdsheet.sty) : alias → clé de la matrice.
#let _alias = (
  print: "bw", monochrome: "bw", blackandwhite: "bw", gray: "bw", grey: "bw",
  rowstart: "row-start", start-row: "row-start", startrow: "row-start", row_start: "row-start",
  colstart: "col-start", start-col: "col-start", startcol: "col-start", col_start: "col-start",
  head_width: "head-width", headwidth: "head-width",
  name_width: "name-width", namewidth: "name-width",
)

/// Remplace les alias LaTeX par la clé de la matrice ; sans les valeurs `auto`.
#let rdsheet-cles(d) = {
  let res = (:)
  for (k, v) in d {
    if v == auto { continue }
    res.insert(_alias.at(k, default: k), v)
  }
  res
}

// =====================================================================
// Coordonnées : lettres de colonnes, décalage, sélecteurs
// =====================================================================

/// 1 → « A », 27 → « AA ».
#let rd-lettres(n) = {
  let s = ""
  let k = n
  while k > 0 {
    s = str.from-unicode(65 + calc.rem(k - 1, 26)) + s
    k = calc.quo(k - 1, 26)
  }
  s
}

/// « A » → 1, « AB » → 28 (0 si ce n'est pas une suite de lettres).
#let rd-colonne-entier(s) = {
  let t = upper(s.trim())
  if t.match(regex("^[A-Z]+$")) == none { return 0 }
  let n = 0
  for c in t.clusters() { n = n * 26 + (str.to-unicode(c) - 64) }
  n
}

// Indice physique (1 = en-tête) d'une coordonnée utilisateur, selon l'origine `debut`.
#let _decale(n, debut) = if n >= debut { n - debut + 2 } else { n + 1 }

#let _ancres = (Z: 0, Y: 1, X: 2, W: 3, V: 4, U: 5)

#let _extremite(s, debut, dernier, col, commande) = {
  let t = upper(s.trim())
  if t in _ancres { return dernier - _ancres.at(t) }
  if col and t.match(regex("^[A-Z]+$")) != none { return _decale(rd-colonne-entier(t), debut) }
  if t.match(regex("^-?[0-9]+$")) != none {
    let n = int(t)
    return if n < 0 { dernier + 1 + n } else { _decale(n, debut) }
  }
  panic(
    commande + " : repère invalide « " + s + " ». Formes possibles : un numéro, une plage « 2-4 », une liste « 1, 3 », "
      + "une lettre de colonne, « odd », « even » ou une ancre (« Z » = dernier, « Y » = avant-dernier…).",
  )
}

/// Indices physiques (1 à `dernier`) désignés par un sélecteur : « 2 », « 2-4 », « 1, 3 », « odd », « B-C »…
#let rd-indices(spec, debut, dernier, col, commande) = {
  let spec = if type(spec) == int { str(spec) } else { spec }
  if type(spec) != str {
    panic(commande + " : sélecteur invalide " + repr(spec) + ". Attendu : une chaîne (« 2-4 », « A, C ») ou un entier.")
  }
  let res = ()
  for item in spec.split(",") {
    let t = item.trim()
    if t == "" { continue }
    let bas = lower(t)
    if bas in ("odd", "even") {
      for k in range(1, dernier + 1) {
        if (bas == "odd" and calc.odd(k)) or (bas == "even" and calc.even(k)) { res.push(k) }
      }
      continue
    }
    let m = t.match(regex("^(.+?) *- *(.+)$"))
    if m != none and not t.starts-with("-") {
      let a = _extremite(m.captures.at(0), debut, dernier, col, commande)
      let b = _extremite(m.captures.at(1), debut, dernier, col, commande)
      for k in range(calc.min(a, b), calc.max(a, b) + 1) { res.push(k) }
    } else {
      res.push(_extremite(t, debut, dernier, col, commande))
    }
  }
  res.dedup().filter(k => k >= 1 and k <= dernier)
}

// Cellules ou plages de tableur « B2 », « A1:C3 », « A1, C2 » → liste de (rows, cols) en indices physiques.
#let _tableur(s, deb-l, deb-c, commande) = {
  let res = ()
  for item in s.replace("{", "").replace("}", "").split(",") {
    let t = item.replace(" ", "")
    if t == "" { continue }
    let m = t.match(regex("^([A-Za-z]+)([0-9]+)(:([A-Za-z]+)([0-9]+))?$"))
    if m == none {
      panic(commande + " : coordonnées invalides « " + t + " ». Formes possibles : « B2 », « A1:C3 » ou une liste « A1, C2 ».")
    }
    let k = m.captures
    let c1 = rd-colonne-entier(k.at(0))
    let r1 = int(k.at(1))
    let (c2, r2) = if k.at(2) != none { (rd-colonne-entier(k.at(3)), int(k.at(4))) } else { (c1, r1) }
    let ca = _decale(calc.min(c1, c2), deb-c)
    let cb = _decale(calc.max(c1, c2), deb-c)
    let ra = _decale(calc.min(r1, r2), deb-l)
    let rb = _decale(calc.max(r1, r2), deb-l)
    res.push((rows: range(ra, rb + 1), cols: range(ca, cb + 1)))
  }
  res
}

// =====================================================================
// Styles de cellules, filets
// =====================================================================

// Arguments de `text` d'une clé `font` : dictionnaire, ou déclarations LaTeX « bfseries itshape ».
#let _police(f, commande) = {
  if f == none { return (:) }
  if type(f) == dictionary {
    let a = (:)
    for (k, v) in f {
      if k == "size" { a.size = if type(v) == str { taille-latex(v) } else { v } }
      else if k == "weight" { a.weight = v }
      else if k == "style" { a.style = v }
      else if k in ("family", "font") { a.font = v }
      else {
        panic(commande + " : clé de police inconnue « " + k + " ». Clés possibles : « size », « weight », « style », « family ».")
      }
    }
    return a
  }
  if type(f) == str {
    let a = (:)
    for t in f.replace(",", " ").replace("\\", " ").split(" ") {
      if t == "" { continue }
      if t == "bfseries" { a.weight = "bold" }
      else if t == "mdseries" { a.weight = "regular" }
      else if t in ("itshape", "slshape") { a.style = "italic" }
      else if t == "upshape" { a.style = "normal" }
      else if t == "ttfamily" { a.font = "Latin Modern Mono" }
      else if t in ("sffamily", "rmfamily", "normalfont") { }
      else if t in ("tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge") {
        a.size = taille-latex(t)
      } else {
        panic(commande + " : déclaration de police inconnue « " + t + " ». Possibles : bfseries, itshape, ttfamily, sffamily, small, large…")
      }
    }
    return a
  }
  panic(commande + " : valeur invalide pour `font` : " + repr(f) + ". Attendu : un dictionnaire (size, weight, style, family) ou une chaîne (\"bfseries\").")
}

#let _halign = (l: left, c: center, r: right, j: left, left: left, center: center, right: right)
#let _valign = (t: top, m: horizon, b: bottom, h: top, top: top, horizon: horizon, bottom: bottom)

// Vérifie les clés d'un style de cellule ; renvoie le style.
#let _verifier-style(s, commande, cle) = {
  if type(s) != dictionary {
    panic(commande + " : le style de « " + cle + " » doit être un dictionnaire (bg, fg, font…) ; reçu : " + repr(s) + ".")
  }
  for k in s.keys() {
    if k not in rd-cles-style {
      panic(
        commande + " : clé de style inconnue « " + k + " » dans « " + cle + " ». Clés possibles : "
          + rd-cles-style.map(x => "« " + x + " »").join(", ") + ".",
      )
    }
  }
  s
}

// Filet : « 1pt, dashed, blue », 1pt, rouge, 1pt + red, (thickness:, paint:, dash:) → dictionnaire de trait ou none.
#let _trait(v, commande) = {
  if v == none { return none }
  let t = (paint: black, thickness: 0.4pt)
  if type(v) == str {
    for morceau in v.split(",") {
      let m = morceau.trim()
      if m == "" { continue }
      let l = longueur-latex(m)
      if l != none { t.thickness = l }
      else if m in ("solid", "dashed", "dotted", "densely dashed", "loosely dashed", "densely dotted", "loosely dotted") {
        t.dash = m.replace("densely ", "densely-").replace("loosely ", "loosely-")
        if t.dash == "solid" { let _ = t.remove("dash") }
      } else { t.paint = bf-xcolor(m, commande: commande) }
    }
    return t
  }
  if type(v) == length { t.thickness = v; return t }
  if type(v) == color { t.paint = v; return t }
  if type(v) == stroke {
    if v.paint != auto { t.paint = v.paint }
    if v.thickness != auto { t.thickness = v.thickness }
    if v.dash != auto { t.dash = v.dash }
    return t
  }
  if type(v) == dictionary {
    for (k, x) in v {
      if k in ("paint", "color") { t.paint = bf-xcolor(x, commande: commande) }
      else if k == "thickness" { t.thickness = longueur-latex(x, defaut: x) }
      else if k == "dash" { t.dash = x }
      else { panic(commande + " : clé de filet inconnue « " + k + " ». Clés possibles : « paint », « thickness », « dash ».") }
    }
    return t
  }
  panic(commande + " : filet invalide " + repr(v) + ". Attendu : \"0.5pt, gray!40\", 1pt + red ou (thickness: 1pt, paint: red).")
}

// Colspec : chaîne tabularray ou tableau → liste de (largeur, style) pour les colonnes de données.
#let _colspec(v, commande) = {
  if v == auto { return none }
  if type(v) == array {
    return v.map(x => {
      if type(x) == dictionary {
        let s = x
        let co = s.at("co", default: 1)
        let w = if "wd" in s { longueur-latex(s.wd) } else { co * 1fr }
        let st = s
        if "co" in st { let _ = st.remove("co") }
        (w, st)
      } else if x == auto or type(x) in (length, relative, fraction) { (x, (:)) }
      else if type(x) == str { (longueur-latex(x, defaut: auto), (:)) }
      else { panic(commande + " : élément de `colspec` invalide : " + repr(x) + ".") }
    })
  }
  let res = ()
  let jetons = v.matches(regex("([XQlcrjpmb])(\[[^\]]*\]|\{[^}]*\})?"))
  for j in jetons {
    let lettre = j.captures.at(0)
    let opts = j.captures.at(1)
    let st = (:)
    let co = 1
    let wd = none
    if lettre in ("l", "c", "r", "j") { st.halign = lettre }
    if lettre in ("p", "m", "b") { st.valign = if lettre == "p" { "t" } else { lettre } }
    if opts != none and opts.starts-with("{") { wd = longueur-latex(opts.slice(1, -1)) }
    else if opts != none {
      for o in opts.slice(1, -1).split(",") {
        let t = o.trim()
        if t in ("l", "c", "r", "j") { st.halign = t }
        else if t in ("t", "m", "b", "h") { st.valign = t }
        else if t.starts-with("wd=") { wd = longueur-latex(t.slice(3)) }
        else if t.starts-with("co=") { co = float(t.slice(3)) }
        else if t.starts-with("bg=") { st.bg = t.slice(3) }
        else if t.starts-with("fg=") { st.fg = t.slice(3) }
        else if t != "" and t.match(regex("^[0-9.]+$")) != none { co = float(t) }
      }
    }
    let w = if wd != none { wd } else if lettre == "X" { co * 1fr } else { auto }
    res.push((w, st))
  }
  if res.len() == 0 {
    panic(commande + " : `colspec` illisible : " + repr(v) + ". Forme attendue : \"X[l,m] Q[c,wd=2cm] r\".")
  }
  res
}

// Sélection « B2 » ou « B2:C3 » → (ra, rb, ca, cb, nom) en coordonnées utilisateur, ou none.
#let _selection(s) = {
  if s == none { return none }
  let t = s.replace(" ", "").replace("{", "").replace("}", "")
  let m = t.match(regex("^([A-Za-z]+)([0-9]+)(:([A-Za-z]+)([0-9]+))?$"))
  let k = m.captures
  let c1 = rd-colonne-entier(k.at(0))
  let r1 = int(k.at(1))
  let (c2, r2) = if k.at(2) != none { (rd-colonne-entier(k.at(3)), int(k.at(4))) } else { (c1, r1) }
  (ra: calc.min(r1, r2), rb: calc.max(r1, r2), ca: calc.min(c1, c2), cb: calc.max(c1, c2), nom: upper(t))
}

// Pose `style` sur les cellules (rows × cols, indices physiques 1-based) : renvoie la grille mise à jour.
#let _appliquer(st, rows, cols, style) = {
  for i in rows {
    for j in cols {
      st.at(i - 1).at(j - 1) = st.at(i - 1).at(j - 1) + style
    }
  }
  st
}

// Pose `trait` sur les segments des tableaux de filets : `ys` indices de filets (0-based), `xs` positions.
#let _poser(filets, lignes, positions, trait) = {
  for y in lignes {
    for x in positions {
      if y >= 0 and y < filets.len() and x >= 0 and x < filets.at(y).len() { filets.at(y).at(x) = trait }
    }
  }
  filets
}

// Segments consécutifs de même trait : liste de (début, fin, trait) ; `saute(k)` interrompt une série.
#let _series(ligne, saute) = {
  let res = ()
  let cur = none
  for (k, t) in ligne.enumerate() {
    let s = if saute(k) { none } else { t }
    if cur != none and s != none and cur.at(2) == s and cur.at(1) == k {
      cur = (cur.at(0), k + 1, s)
    } else {
      if cur != none { res.push(cur) }
      cur = if s == none { none } else { (k, k + 1, s) }
    }
  }
  if cur != none { res.push(cur) }
  res
}

// Contenu d'une cellule de données.
#let _contenu(c, mode) = {
  if c == none { return [] }
  let c = if type(c) in (int, float) { str(c) } else { c }
  if mode == "math" {
    if type(c) == str { return math.equation(block: false, eval(c, mode: "math")) }
    return math.equation(block: false, c)
  }
  c
}

// =====================================================================
// Barre de formule
// =====================================================================

// Polyligne ouverte ou fermée en points (y vers le HAUT, comme TikZ) dans une barre de hauteur `h`.
#let _poly(h, pts, ..args) = {
  let p = pts.map(((x, y)) => (x * 1pt, (h - y) * 1pt))
  if args.named().at("ferme", default: false) {
    place(top + left, polygon(fill: args.named().at("fill", default: none), stroke: none, ..p))
  } else {
    place(top + left, curve(stroke: args.named().at("stroke", default: none), curve.move(p.first()), ..p.slice(1).map(q => curve.line(q))))
  }
}

// Icône vectorielle centrée en (x, y) (y vers le haut) dans une barre de hauteur `h`.
#let _icone(nom, pal, x, y, h) = {
  let ic = rd-icones.at(nom)
  let (x0, y0, ..) = ic.bbox
  let coul(n, op) = {
    let c = if n == "black" { black } else { pal.at(n) }
    if op < 1 { c.transparentize((1 - op) * 100%) } else { c }
  }
  for f in ic.formes {
    let fond = if f.degrade != none {
      let (g, m, d, ang) = f.degrade
      let stops = if m == none { (coul(g, f.opacite), coul(d, f.opacite)) } else { (coul(g, f.opacite), coul(m, f.opacite), coul(d, f.opacite)) }
      gradient.linear(..stops, angle: -ang * 1deg)
    } else if f.fill != none { coul(f.fill, f.opacite) } else { black }
    let elems = ()
    for c in f.chemin {
      let pt(i) = ((c.at(i) - x0) * 1pt, (c.at(i + 1) - y0) * 1pt)
      if c.at(0) == "m" { elems.push(curve.move(pt(1))) }
      else if c.at(0) == "l" { elems.push(curve.line(pt(1))) }
      else if c.at(0) == "c" { elems.push(curve.cubic(pt(1), pt(3), pt(5))) }
      else { elems.push(curve.close()) }
    }
    place(top + left, dx: x * 1pt + x0 * 1pt, dy: (h - y) * 1pt + y0 * 1pt, curve(fill: fond, stroke: none, ..elems))
  }
}

// Texte de la barre (zone de nom, champ de formule) découpé dans son cadre : (x0, x1) en points, hauteur h.
#let _texte-barre(c, x-texte, x0, x1, h, y0, y1) = {
  let corps = text(size: taille-latex("small"), c)
  place(top + left, dx: x0 * 1pt, dy: (h - y1) * 1pt,
    box(width: (x1 - x0) * 1pt, height: (y1 - y0) * 1pt, clip: true,
      place(top + left, dx: (x-texte - x0) * 1pt, box(height: (y1 - y0) * 1pt, align(horizon, corps)))))
}

// Barre de formule du thème par défaut (Calc). `l` : largeur en points.
#let _barre-calc(pal, l, nom, formule, r) = {
  let h = 22
  let nom-fin = 3 + r.name-width / 1pt
  let sep-nom = nom-fin - 11
  let fleche-nom = nom-fin - 5.5
  let clip-nom = nom-fin - 11.5
  let sep1 = nom-fin + 4
  let fx = sep1 + 11
  let sigma = sep1 + 26
  let sigma-fleche = sep1 + 33.5
  let egal = sep1 + 44
  let sep2 = sep1 + 55
  let debut-formule = sep1 + 59
  let texte-formule = debut-formule + 4
  box(width: l * 1pt, height: h * 1pt, {
    place(top + left, dx: 0.3pt, dy: 0.3pt, rect(width: (l - 0.6) * 1pt, height: (h - 0.6) * 1pt, fill: pal.toolbarbg, stroke: 0.6pt + pal.border))
    // zone de nom
    place(top + left, dx: 3pt, dy: 3pt, rect(width: (nom-fin - 3) * 1pt, height: 16pt, fill: white, stroke: 0.5pt + pal.border))
    place(top + left, dx: sep-nom * 1pt, dy: 3.5pt, rect(width: (nom-fin - 0.5 - sep-nom) * 1pt, height: 15pt, fill: pal.arrowbg, stroke: none))
    _poly(h, ((sep-nom, 3), (sep-nom, 19)), stroke: 0.5pt + pal.border)
    _poly(h, ((fleche-nom - 2.2, 12.2), (fleche-nom, 9.8), (fleche-nom + 2.2, 12.2)), stroke: stroke(paint: pal.btnfg, thickness: 1pt, cap: "round", join: "round"))
    if nom != none { _texte-barre(nom, 6, 3.5, clip-nom, h, 3.5, 18.5) }
    // boutons d'action
    _poly(h, ((sep1, 5), (sep1, 17)), stroke: 0.6pt + pal.btnsep)
    _icone("fx", pal, fx, 11, h)
    _icone("sigma", pal, sigma, 11, h)
    _poly(h, ((sigma-fleche - 1.5, 10.8), (sigma-fleche + 1.5, 10.8), (sigma-fleche, 8.5)), ferme: true, fill: pal.btnfg)
    _icone("egal", pal, egal, 11, h)
    _poly(h, ((sep2, 5), (sep2, 17)), stroke: 0.6pt + pal.btnsep)
    // champ de formule
    place(top + left, dx: debut-formule * 1pt, dy: 3pt, rect(width: (l - 3 - debut-formule) * 1pt, height: 16pt, fill: white, stroke: 0.5pt + pal.border))
    place(top + left, dx: (l - 14) * 1pt, dy: 3.5pt, rect(width: 10.5pt, height: 15pt, fill: pal.arrowbg, stroke: none))
    _poly(h, ((l - 14, 3), (l - 14, 19)), stroke: 0.5pt + pal.border)
    _poly(h, ((l - 11.2, 12.5), (l - 6.2, 12.5), (l - 8.7, 9.5)), ferme: true, fill: pal.btnfg)
    if formule != none { _texte-barre(formule, texte-formule, debut-formule + 0.5, l - 14.5, h, 3.5, 18.5) }
  })
}

// Barre de formule du thème Excel.
#let _barre-excel(pal, l, nom, formule, r) = {
  let h = 24
  let nom-fin = 3 + r.name-width / 1pt
  let chevron-nom = nom-fin - 10
  let clip-nom = nom-fin - 13
  let points-x = nom-fin + 8
  let boutons-debut = points-x + 8
  let boutons-fin = boutons-debut + 54
  let debut-formule = boutons-fin + 5
  let texte-formule = debut-formule + 6
  let pilule(x0, x1) = place(top + left, dx: x0 * 1pt, dy: 3pt, rect(width: (x1 - x0) * 1pt, height: 18pt, fill: white, stroke: 0.5pt + pal.barborder, radius: 2pt))
  box(width: l * 1pt, height: h * 1pt, {
    place(top + left, dx: 0.3pt, dy: 0.3pt, rect(width: (l - 0.6) * 1pt, height: (h - 0.6) * 1pt, fill: pal.toolbarbg, stroke: 0.6pt + pal.border))
    // zone de nom
    pilule(3, nom-fin)
    if nom != none { _texte-barre(nom, 8, 4, clip-nom, h, 3.5, 20.5) }
    _poly(h, ((chevron-nom, 13), (chevron-nom + 2.2, 10.6), (chevron-nom + 4.4, 13)), stroke: stroke(paint: pal.btnfg, thickness: 0.8pt, cap: "round", join: "round"))
    // trois points
    for y in (9.2, 12.0, 14.8) {
      place(top + left, dx: (points-x - 0.75) * 1pt, dy: (h - y - 0.75) * 1pt, circle(radius: 0.75pt, fill: pal.dotsfg, stroke: none))
    }
    // boutons : croix, coche, fx
    pilule(boutons-debut, boutons-fin)
    let bx = boutons-debut + 10
    _poly(h, ((bx - 3.6, 8.4), (bx + 3.6, 15.6)), stroke: stroke(paint: pal.btnneutral, thickness: 0.85pt, cap: "round"))
    _poly(h, ((bx - 3.6, 15.6), (bx + 3.6, 8.4)), stroke: stroke(paint: pal.btnneutral, thickness: 0.85pt, cap: "round"))
    let cx = boutons-debut + 27
    _poly(h, ((cx - 3.4, 12.2), (cx - 0.8, 9.2), (cx + 3.4, 15.2)), stroke: stroke(paint: pal.btnneutral, thickness: 0.95pt, cap: "round", join: "round"))
    _icone("fx-excel", pal, boutons-debut + 44, 12, h)
    // champ de formule
    pilule(debut-formule, l - 3)
    _poly(h, ((l - 11, 13), (l - 8.8, 10.6), (l - 6.6, 13)), stroke: stroke(paint: pal.btnfg, thickness: 0.8pt, cap: "round", join: "round"))
    if formule != none { _texte-barre(formule, texte-formule, debut-formule + 1, l - 15, h, 3.5, 20.5) }
  })
}

// =====================================================================
// Rendu
// =====================================================================

// Ligne de données : tableau de cellules, ou chaîne « a & b & c ».
#let _ligne(l, commande) = {
  if type(l) == array { return l }
  if type(l) == str { return l.split("&").map(c => c.trim()) }
  panic(commande + " : une ligne est un tableau de cellules ou une chaîne « a & b & c » ; reçu : " + repr(l) + ".")
}

#let _specs-liste(v, cle, commande) = {
  if v == none { return () }
  if type(v) == dictionary { return v.pairs() }
  if type(v) == array {
    return v.map(x => if type(x) == array and x.len() in (2, 3) { x } else {
      panic(commande + " : un élément de « " + cle + " » est un tableau (sélecteur, style) ou (lignes, colonnes, style) ; reçu : " + repr(x) + ".")
    })
  }
  panic(commande + " : la clé « " + cle + " » attend un dictionnaire ou un tableau ; reçu : " + repr(v) + ".")
}

/// Rendu d'une feuille : `r` réglages résolus, `lignes` les lignes de données.
#let rdsheet-rendu(r, lignes) = {
  let cmd = "rdsheet"
  // --- thème
  let th = r.theme
  let bw = r.bw
  if th in ("print", "bw") { bw = true; th = "default" }
  let excel = th in ("excel", "green", "office")
  let pal = rd-palette(excel, bw, r.contrast)
  if r.colors != none {
    for (k, v) in r.colors {
      if k not in pal {
        panic(cmd + " : couleur inconnue « " + k + " » dans `colors`. Noms possibles : " + pal.keys().map(x => "« " + x + " »").join(", ") + ".")
      }
      pal.insert(k, bf-xcolor(v, commande: cmd))
    }
  }
  let colsep = r.colsep
  let rowsep = r.rowsep

  // --- données et origine
  let donnees = lignes.map(l => _ligne(l, cmd))
  let ligne-debut = r.row-start
  let col-debut = if type(r.col-start) == int { r.col-start } else if r.col-start.trim().match(regex("^[0-9]+$")) != none { int(r.col-start.trim()) } else { rd-colonne-entier(r.col-start) }
  let plage-l = 0
  let plage-c = 0
  if r.range != none {
    let m = r.range.replace(" ", "").match(regex("^([A-Za-z]+)([0-9]+)(:([A-Za-z]+)([0-9]+))?$"))
    let k = m.captures
    let c1 = rd-colonne-entier(k.at(0))
    let r1 = int(k.at(1))
    if k.at(2) != none {
      let c2 = rd-colonne-entier(k.at(3))
      let r2 = int(k.at(4))
      col-debut = calc.min(c1, c2)
      ligne-debut = calc.min(r1, r2)
      plage-c = calc.abs(c2 - c1) + 1
      plage-l = calc.abs(r2 - r1) + 1
    } else {
      col-debut = c1
      ligne-debut = r1
    }
  }
  col-debut = calc.max(1, col-debut)
  ligne-debut = calc.max(1, ligne-debut)
  let nl = calc.max(1, donnees.len(), plage-l)
  let nc = calc.max(1, ..donnees.map(l => l.len()), plage-c)
  let P = nl + 1 // lignes physiques (la première est l'en-tête)
  let Q = nc + 1
  let grille = range(nl).map(i => range(nc).map(j => if i < donnees.len() and j < donnees.at(i).len() { donnees.at(i).at(j) } else { none }))

  // --- largeur de l'en-tête de ligne
  let derniere = ligne-debut + nl - 1
  let largeur-tete = if r.head-width != auto { longueur-latex(r.head-width) } else if derniere >= 1000 { 3.2em } else if derniere >= 100 { 2.5em } else { 2em }

  // --- sélection
  let sel = _selection(r.select)
  let sel-p = if sel == none { none } else {
    (
      ra: _decale(sel.ra, ligne-debut), rb: _decale(sel.rb, ligne-debut),
      ca: _decale(sel.ca, col-debut), cb: _decale(sel.cb, col-debut),
    )
  }

  // --- barre
  let barre = if r.bar == auto { r.name != none or r.formula != none } else { r.bar }
  let nom-barre = if r.name != none { r.name } else if sel != none { sel.nom } else { none }
  let formule = r.formula
  if barre and formule == none and sel != none and sel.ra == sel.rb and sel.ca == sel.cb {
    let a = if sel.ra >= ligne-debut { sel.ra - ligne-debut + 1 } else { sel.ra }
    let b = if sel.ca >= col-debut { sel.ca - col-debut + 1 } else { sel.ca }
    if a >= 1 and a <= nl and b >= 1 and b <= nc {
      let v = grille.at(a - 1).at(b - 1)
      if v != none { formule = if type(v) in (int, float) { str(v) } else { v } }
    }
  }

  // --- styles des cellules
  let base = (halign: "l", valign: "m", ht: r.row-height)
  let st = range(P).map(_ => range(Q).map(_ => base))
  let cs = _colspec(r.colspec, cmd)
  let largeurs = range(nc).map(_ => 1fr)
  if cs != none {
    largeurs = range(nc).map(j => if j < cs.len() { cs.at(j).at(0) } else { cs.last().at(0) })
    for j in range(nc) {
      let s = if j < cs.len() { cs.at(j).at(1) } else { cs.last().at(1) }
      st = _appliquer(st, range(1, P + 1), (j + 2,), s)
    }
  }
  let tous-r = range(1, P + 1)
  let tous-c = range(1, Q + 1)
  let don-r = range(2, P + 1)
  let don-c = range(2, Q + 1)
  if r.cells != none { st = _appliquer(st, don-r, don-c, _verifier-style(r.cells, cmd, "cells")) }
  if r.columns != none { st = _appliquer(st, tous-r, don-c, _verifier-style(r.columns, cmd, "columns")) }
  if r.rows != none { st = _appliquer(st, don-r, tous-c, _verifier-style(r.rows, cmd, "rows")) }
  for (sel-c, s) in _specs-liste(r.column, "column", cmd) {
    st = _appliquer(st, tous-r, rd-indices(sel-c, col-debut, Q, true, cmd), _verifier-style(s, cmd, "column"))
  }
  for (sel-r, s) in _specs-liste(r.row, "row", cmd) {
    st = _appliquer(st, rd-indices(sel-r, ligne-debut, P, false, cmd), tous-c, _verifier-style(s, cmd, "row"))
  }
  for it in _specs-liste(r.cell, "cell", cmd) {
    if it.len() == 3 {
      st = _appliquer(st, rd-indices(it.at(0), ligne-debut, P, false, cmd), rd-indices(it.at(1), col-debut, Q, true, cmd), _verifier-style(it.at(2), cmd, "cell"))
    } else {
      for z in _tableur(it.at(0), ligne-debut, col-debut, cmd) {
        st = _appliquer(st, z.rows, z.cols, _verifier-style(it.at(1), cmd, "cell"))
      }
    }
  }
  // en-têtes protégés : toujours réappliqués après les réglages de l'utilisateur
  let entete = (bg: pal.headerbg, fg: pal.headerfg, halign: "c", valign: "m", font: none)
  st = _appliquer(st, (1,), tous-c, entete)
  st = _appliquer(st, tous-r, (1,), entete)
  // en-têtes de la sélection
  if sel-p != none {
    let sty = (bg: pal.selectheadbg, fg: pal.selectheadfg, halign: "c", valign: "m", font: if excel { none } else { (weight: "bold") })
    st = _appliquer(st, (1,), range(sel-p.ca, sel-p.cb + 1), sty)
    st = _appliquer(st, range(sel-p.ra, sel-p.rb + 1), (1,), sty)
  }

  // --- fusions de cellules
  let proprio = range(P).map(i => range(Q).map(j => (i, j)))
  for i in range(P) {
    for j in range(Q) {
      if proprio.at(i).at(j) != (i, j) { continue }
      let s = st.at(i).at(j)
      let sc = calc.max(1, s.at("c", default: 1))
      let sr = calc.max(1, s.at("r", default: 1))
      if sc > 1 or sr > 1 {
        for ii in range(i, calc.min(P, i + sr)) {
          for jj in range(j, calc.min(Q, j + sc)) { proprio.at(ii).at(jj) = (i, j) }
        }
      }
    }
  }

  // --- largeurs de colonnes
  let colonnes = (largeur-tete + 2 * colsep,)
  for j in range(nc) {
    let wd = st.at(1).at(j + 1).at("wd", default: none)
    let w = if wd != none { longueur-latex(wd, defaut: auto) } else { largeurs.at(j) }
    colonnes.push(if type(w) == length { w + 2 * colsep } else { w })
  }

  // --- filets
  let hs = range(P + 1).map(_ => range(Q).map(_ => none))
  let vs = range(Q + 1).map(_ => range(P).map(_ => none))
  let grid = (paint: pal.grid, thickness: r.grid-width)
  let bord = (paint: pal.border, thickness: r.border-width)
  let bord-tete = (paint: pal.headerborder, thickness: r.grid-width)
  hs = _poser(hs, range(P + 1), range(Q), grid)
  vs = _poser(vs, range(Q + 1), range(P), grid)
  hs = _poser(hs, (0, 1, P), range(Q), bord)
  vs = _poser(vs, (0, 1, Q), range(P), bord)
  // filets de l'utilisateur
  let t-hlines = _trait(r.hlines, cmd)
  if r.hlines != none { hs = _poser(hs, range(1, P + 1), range(1, Q), t-hlines) }
  let t-vlines = _trait(r.vlines, cmd)
  if r.vlines != none { vs = _poser(vs, range(1, Q + 1), range(1, P), t-vlines) }
  for it in _specs-liste(r.hline, "hline", cmd) {
    let (sel-f, seg, f) = if it.len() == 3 { it } else if type(it.at(1)) == array and it.at(1).len() == 2 and type(it.at(1).at(0)) in (str, int) { (it.at(0), it.at(1).at(0), it.at(1).at(1)) } else { (it.at(0), none, it.at(1)) }
    let ys = rd-indices(sel-f, ligne-debut, P + 1, false, cmd).map(k => k - 1)
    let xs = if seg == none { range(1, Q) } else { rd-indices(seg, col-debut, Q, true, cmd).map(k => k - 1) }
    hs = _poser(hs, ys, xs, _trait(f, cmd))
  }
  for it in _specs-liste(r.vline, "vline", cmd) {
    let (sel-f, seg, f) = if it.len() == 3 { it } else if type(it.at(1)) == array and it.at(1).len() == 2 and type(it.at(1).at(0)) in (str, int) { (it.at(0), it.at(1).at(0), it.at(1).at(1)) } else { (it.at(0), none, it.at(1)) }
    let xs = rd-indices(sel-f, col-debut, Q + 1, true, cmd).map(k => k - 1)
    let ys = if seg == none { range(1, P) } else { rd-indices(seg, ligne-debut, P, false, cmd).map(k => k - 1) }
    vs = _poser(vs, xs, ys, _trait(f, cmd))
  }
  // immunité des en-têtes
  hs = _poser(hs, range(2, P + 1), (0,), bord-tete)
  vs = _poser(vs, range(2, Q + 1), (0,), bord-tete)
  hs = _poser(hs, (0,), range(Q), bord)
  hs = _poser(hs, (1, P), (0,), bord)
  vs = _poser(vs, (0,), range(P), bord)
  vs = _poser(vs, (1, Q), (0,), bord)
  // cadre de sélection et liserés Excel
  if sel-p != none {
    let cadre = (paint: pal.selectborder, thickness: r.select-width)
    let xs = range(sel-p.ca - 1, sel-p.cb)
    let ys = range(sel-p.ra - 1, sel-p.rb)
    hs = _poser(hs, (sel-p.ra - 1, sel-p.rb), xs, cadre)
    vs = _poser(vs, (sel-p.ca - 1, sel-p.cb), ys, cadre)
    if excel {
      let liseres = (paint: pal.selectborder, thickness: 2pt)
      hs = _poser(hs, (1,), xs, liseres)
      vs = _poser(vs, (1,), ys, liseres)
    }
  }

  // --- cellules de la table
  let cellules = ()
  for i in range(P) {
    let hauteur = calc.max(..st.at(i).map(s => s.ht))
    for j in range(Q) {
      if proprio.at(i).at(j) != (i, j) { continue }
      let s = st.at(i).at(j)
      let mode = s.at("mode", default: none)
      let brut = if i == 0 and j == 0 { [] } else if i == 0 { rd-lettres(col-debut + j - 1) } else if j == 0 { str(ligne-debut + i - 1) } else { _contenu(grille.at(i - 1).at(j - 1), mode) }
      let args = _police(s.at("font", default: none), cmd)
      let fg = rd-couleur(s.at("fg", default: none), commande: cmd)
      if fg != none { args.fill = fg }
      let corps = if args.len() > 0 { text(..args, brut) } else { brut }
      if type(s.at("font", default: none)) == function { corps = (s.font)(corps) }
      if "cmd" in s and s.cmd != none { corps = (s.cmd)(corps) }
      if "preto" in s { corps = [#s.preto#corps] }
      if "appto" in s { corps = [#corps#s.appto] }
      // décors : triangle Excel (coin) et poignée de recopie
      let decor = []
      if i == 0 and j == 0 and excel {
        decor = place(bottom + right, dx: colsep - 1.5pt, dy: rowsep - 1.5pt, polygon(fill: pal.cornertriangle, stroke: none, (0pt, 12.5pt), (12.5pt, 12.5pt), (12.5pt, 0pt)))
      }
      if sel-p != none and i + 1 == sel-p.rb and j + 1 == sel-p.cb {
        let k = r.handle-size
        decor = place(bottom + right, dx: colsep + k / 2, dy: rowsep + k / 2, rect(width: k, height: k, fill: pal.selecthandle, stroke: none))
      }
      let ha = _halign.at(s.halign, default: left)
      let va = _valign.at(s.valign, default: horizon)
      let contenu = if j == 0 { block(width: 100%, height: hauteur, align(ha + va, corps)) } else { corps }
      cellules.push(table.cell(
        x: j, y: i, colspan: calc.max(1, s.at("c", default: 1)), rowspan: calc.max(1, s.at("r", default: 1)),
        fill: rd-couleur(s.at("bg", default: none), commande: cmd), align: ha + va,
        [#contenu#decor],
      ))
    }
  }
  let lignes-h = ()
  for (y, ligne) in hs.enumerate() {
    let saute(x) = y > 0 and y < P and proprio.at(y - 1).at(x) == proprio.at(y).at(x)
    for (a, b, t) in _series(ligne, saute) { lignes-h.push(table.hline(y: y, start: a, end: b, stroke: t)) }
  }
  let lignes-v = ()
  for (x, colonne) in vs.enumerate() {
    let saute(y) = x > 0 and x < Q and proprio.at(y).at(x - 1) == proprio.at(y).at(x)
    for (a, b, t) in _series(colonne, saute) { lignes-v.push(table.vline(x: x, start: a, end: b, stroke: t)) }
  }
  let tableau = table(
    columns: colonnes, stroke: none, inset: (x: colsep, y: rowsep), align: left + horizon,
    ..cellules, ..lignes-h, ..lignes-v,
  )

  // --- assemblage
  let largeur = longueur-latex(r.width, defaut: 100%)
  let police = r.sans-font
  let bloc = block(width: largeur, breakable: r.long, {
    set block(spacing: 0pt)
    set text(font: police)
    set par(justify: false)
    if barre {
      layout(size => {
        let l = size.width / 1pt
        if excel { _barre-excel(pal, l, nom-barre, formule, r) } else { _barre-calc(pal, l, nom-barre, formule, r) }
      })
    }
    tableau
  })
  if r.baseline == none { bloc } else {
    let b = r.baseline
    let base = if b in ("c", "m") { 50% } else if b == "t" { 100% } else if b == "b" { 0pt } else { b }
    box(baseline: base, bloc)
  }
}
