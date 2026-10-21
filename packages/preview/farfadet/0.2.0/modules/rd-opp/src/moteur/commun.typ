// commun.typ (rdopp) — styles de cellules, tracés et mesures communs au moteur.
//
// Un STYLE est :
//   - `none` (rien) ;
//   - un dictionnaire de clés (vocabulaire ci-dessous, `rd-style-cles`) ;
//   - une fonction `contenu => contenu` (transformation libre du contenu d'une cellule) ;
//   - un tableau de ces valeurs, appliquées dans l'ordre (la dernière l'emporte).
// Les styles se FUSIONNENT : style par défaut du moteur, puis style de la ligne, puis style de la cellule…
// (`rd-style-fusion`).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: bf-xcolor, taille-latex, reglages-regler, reglages-reinitialiser, reglages-definir-style

// =====================================================================
// Setter commun (convention des réglages : pour, reinitialiser, definir, clés)
// =====================================================================

/// Corps du setter `setrdopp` : réglage global ou d'un type (`pour`), style nommé (`definir`),
/// réinitialisation (`true` : réglages seuls ; `"tout"` : réglages et styles).
#let rd-regler(r, commande, pour, reinitialiser, definir, cles) = {
  if cles.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".")
  }
  if reinitialiser not in (true, false, "tout") {
    panic(commande + " : `reinitialiser` vaut `true`, `false` ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none {
    if type(definir) != str or definir.trim() == "" {
      panic(commande + " : `definir` attend le nom du style (chaîne non vide) ; reçu : " + repr(definir) + ".")
    }
    if reinitialiser != false {
      panic(commande + " : `definir` et `reinitialiser` ne se combinent pas.")
    }
    reglages-definir-style(r, definir, pour: pour, commande: commande, ..cles)
  } else if reinitialiser == "tout" {
    reglages-reinitialiser(r, styles: true)
    if cles.named().len() > 0 { reglages-regler(r, pour: pour, commande: commande, ..cles) }
  } else {
    reglages-regler(r, pour: pour, reinitialiser: reinitialiser, commande: commande, ..cles)
  }
}

// =====================================================================
// Vocabulaire des styles
// =====================================================================

/// Clés permises dans un dictionnaire de style (équivalents TikZ entre parenthèses).
#let rd-style-cles = (
  text: "couleur du texte (text=…)",
  font: "police : dictionnaire (size, weight, style, family) ou fonction (font=…, node font=…)",
  fill: "couleur de fond ou none (fill=…)",
  draw: "couleur du contour ou du trait, none ou true (draw=…)",
  line-width: "épaisseur du contour ou du trait (line width=…)",
  dash: "pointillés : \"dashed\", \"dotted\"… (dashed, dotted)",
  opacity: "opacité générale, de 0 à 1 (opacity=…)",
  fill-opacity: "opacité du fond (fill opacity=…)",
  text-opacity: "opacité du texte (text opacity=…)",
  draw-opacity: "opacité du contour (draw opacity=…)",
  inset: "marge intérieure : longueur ou dictionnaire (inner sep=…)",
  radius: "arrondi des coins (rounded corners=…)",
  min-width: "largeur minimale (minimum width=…)",
  min-height: "hauteur minimale (minimum height=…)",
  text-width: "largeur imposée du texte (text width=…)",
  align: "alignement du texte : left, center, right (align=…)",
  shape: "\"rectangle\", \"circle\" ou \"ellipse\" (circle, ellipse)",
  text-height: "hauteur du texte au-dessus de la ligne de base (text height=…)",
  text-depth: "profondeur du texte sous la ligne de base (text depth=…)",
  xshift: "décalage horizontal vers la droite (xshift=…)",
  yshift: "décalage vertical vers le haut (yshift=…)",
  bend: "courbure d'un arc, en degrés : positive à gauche, négative à droite (bend left=…, bend right=…)",
  arrow: "pointe d'un trait : \"end\" (->), \"start\" (<-) ou \"both\" (<->)",
  nodes: "style des cellules d'une matrice, dictionnaire (nodes={…})",
  row-sep: "espace entre deux lignes (row sep=…)",
  column-sep: "espace entre deux colonnes (column sep=…)",
  fn: "fonction appliquée en dernier au contenu (ajout Typst)",
)

/// Contrôle de réglage pour une clé de style.
#let rd-controle-style = (
  v => v == none or type(v) in (dictionary, function, array),
  "none, un dictionnaire de style (text, fill, draw, font, line-width…), une fonction ou un tableau de styles",
)

/// Normalise un style en (cles: dictionnaire fusionné, fns: tableau de fonctions), après contrôle des clés.
#let rd-style(v, commande: "rdopp", cle: "style") = {
  if v == none { return (cles: (:), fns: ()) }
  if type(v) == function { return (cles: (:), fns: (v,)) }
  if type(v) == array {
    let res = (cles: (:), fns: ())
    for x in v {
      let s = rd-style(x, commande: commande, cle: cle)
      res.cles += s.cles
      res.fns += s.fns
    }
    return res
  }
  if type(v) != dictionary {
    panic(commande + " : valeur invalide pour la clé « " + cle + " » : " + repr(v) + ". Valeurs possibles : " + rd-controle-style.at(1) + ".")
  }
  for k in v.keys() {
    if k not in rd-style-cles {
      panic(
        commande + " : clé de style inconnue « " + k + " » dans « " + cle + " ». Clés possibles : "
          + rd-style-cles.keys().map(x => "« " + x + " »").join(", ") + ".",
      )
    }
  }
  let fns = if "fn" in v { (v.fn,) } else { () }
  let cles = v
  if "fn" in cles { let _ = cles.remove("fn") }
  (cles: cles, fns: fns)
}

/// Fusionne plusieurs styles (déjà normalisés ou bruts) ; le dernier l'emporte, clé par clé.
#let rd-style-fusion(..styles, commande: "rdopp") = {
  let res = (cles: (:), fns: ())
  for s in styles.pos() {
    let n = if type(s) == dictionary and "cles" in s and "fns" in s and s.len() == 2 { s } else { rd-style(s, commande: commande) }
    res.cles += n.cles
    res.fns += n.fns
  }
  res
}

// =====================================================================
// Couleurs (dans un `context`)
// =====================================================================

/// Couleur Typst ou expression xcolor (« red!50 »…).
#let rd-couleur(v, commande: "rdopp") = {
  if v == none or v == auto { return v }
  bf-xcolor(v, commande: commande)
}

#let _opacite(c, op) = if c == none or op == none or op >= 1 { c } else { c.transparentize((1 - op) * 100%) }

/// Arguments de `text` tirés de la clé `font` (dictionnaire), sans la couleur.
#let rd-police(f, commande: "rdopp") = {
  if f == none or type(f) in (function, str, length) { return (:) }
  let a = (:)
  for (k, v) in f {
    if k == "size" { a.size = if type(v) == str { taille-latex(v) } else { v } }
    else if k == "weight" { a.weight = v }
    else if k == "style" { a.style = v }
    else if k == "family" or k == "font" { a.font = v }
    else {
      panic(commande + " : clé de police inconnue « " + k + " ». Clés possibles : « size », « weight », « style », « family ».")
    }
  }
  a
}

/// Applique une police (valeur d'une clé `… font`) au contenu ; dans un `context`.
#let rd-appliquer-police(c, f, commande: "rdopp") = {
  if f == none { return c }
  if type(f) == function { return f(c) }
  if type(f) == str { return text(size: taille-latex(f), c) }
  if type(f) == length { return text(size: f, c) }
  text(..rd-police(f, commande: commande), c)
}

/// Applique au contenu les clés « texte » d'un style normalisé : couleur, police, opacité, fonctions.
#let rd-texte(c, st, commande: "rdopp") = {
  let k = st.cles
  let args = rd-police(k.at("font", default: none), commande: commande)
  let couleur = rd-couleur(k.at("text", default: none), commande: commande)
  let op = k.at("text-opacity", default: k.at("opacity", default: none))
  if op != none and op < 1 {
    couleur = _opacite(if couleur == none { black } else { couleur }, op)
  }
  if couleur != none { args.fill = couleur }
  let res = if args.len() > 0 { text(..args, c) } else { c }
  let f = k.at("font", default: none)
  if type(f) in (function, str, length) { res = rd-appliquer-police(res, f, commande: commande) }
  for fn in st.fns { res = fn(res) }
  res
}

/// Trait (`stroke` Typst) d'un style : couleur `draw` (ou `defaut`), épaisseur, pointillés, opacité.
#let rd-trait(st, defaut: black, epaisseur: 0.4pt, commande: "rdopp") = {
  let k = st.cles
  let d = k.at("draw", default: auto)
  if d == none or d == false { return none }
  let c = if d == auto or d == true { defaut } else { rd-couleur(d, commande: commande) }
  if c == none { return none }
  let op = k.at("draw-opacity", default: k.at("opacity", default: none))
  let s = (paint: _opacite(c, op), thickness: k.at("line-width", default: epaisseur))
  if "dash" in k and k.dash != none { s.dash = k.dash }
  s
}

/// Fond d'un style (`fill`, avec `fill-opacity` ou `opacity`).
#let rd-fond(st, commande: "rdopp") = {
  let k = st.cles
  let f = rd-couleur(k.at("fill", default: none), commande: commande)
  _opacite(f, k.at("fill-opacity", default: k.at("opacity", default: none)))
}

// =====================================================================
// Mesures de l'encre (à appeler dans un `context`)
// =====================================================================

#let _grand = 100pt

/// Hauteur de l'encre au-dessus de la ligne de base (boîte TeX : \ht).
#let rd-hauteur(c) = calc.max(
  0pt,
  measure(box({
    set par(leading: 0pt)
    set text(top-edge: "bounds", bottom-edge: -_grand)
    sym.zws
    c
  })).height
    - _grand,
)

/// Profondeur de l'encre sous la ligne de base (boîte TeX : \dp).
#let rd-profondeur(c) = calc.max(
  0pt,
  measure(box({
    set par(leading: 0pt)
    set text(top-edge: _grand, bottom-edge: "bounds")
    sym.zws
    c
  })).height
    - _grand,
)

/// Boîte TeX d'un contenu : (w: largeur, ht: hauteur, dp: profondeur).
#let rd-boite(c) = (w: measure(box(c)).width, ht: rd-hauteur(c), dp: rd-profondeur(c))

/// Distance du haut de `box(c)` (bords de texte par défaut) à sa ligne de base : sert à poser `c` avec
/// `place` à une ligne de base voulue.
#let rd-haut-cadre(c) = {
  let hb = measure(box(c)).height
  let d0 = calc.max(0pt, measure(box({
    set par(leading: 0pt)
    set text(top-edge: _grand)
    sym.zws
    c
  })).height - _grand)
  hb - d0
}

#let _marges(i) = {
  if type(i) == dictionary {
    let x = i.at("x", default: i.at("rest", default: 0pt))
    let y = i.at("y", default: i.at("rest", default: 0pt))
    (
      left: i.at("left", default: x),
      right: i.at("right", default: x),
      top: i.at("top", default: y),
      bottom: i.at("bottom", default: y),
    )
  } else { (left: i, right: i, top: i, bottom: i) }
}

/// Longueur absolue (les `em` résolus dans la police courante) : à appeler dans un `context`.
#let rd-abs(l) = if type(l) == length { l.to-absolute() } else if type(l) == relative { l.length.to-absolute() } else { l }

/// Marges d'un `inset` Typst (longueur ou dictionnaire) : (left, right, top, bottom).
#let rd-marges(i) = _marges(i).pairs().map(((k, v)) => (k, rd-abs(v))).to-dict()

// =====================================================================
// Nœuds (cellules), dans un `context`
// =====================================================================

/// Construit un nœud : renvoie (corps: contenu de taille fixe, w, h, asc) où `asc` est la distance du haut
/// du nœud à la ligne de base du texte (ancre `base`). `st` : style normalisé ; `defaut-inset` : inner sep.
/// Le nœud ne dépend pas de la ligne de base du texte qui l'entoure : on le pose avec `place`.
#let rd-noeud(c, st, defaut-inset: 0pt, commande: "rdopp", epaisseur: 0.4pt, trait-defaut: auto) = {
  let k = st.cles
  let contenu = rd-texte(c, st, commande: commande)
  if "text-width" in k and k.text-width != none {
    let al = k.at("align", default: "left")
    let a = if al == "center" { center } else if al == "right" { right } else { left }
    contenu = box(width: k.text-width, align(a, contenu))
  }
  let b = rd-boite(contenu)
  let hc = rd-haut-cadre(contenu)
  let ht = rd-abs(k.at("text-height", default: b.ht))
  let dp = rd-abs(k.at("text-depth", default: b.dp))
  let m = rd-marges(k.at("inset", default: defaut-inset))
  let w = b.w + m.left + m.right
  let h = ht + dp + m.top + m.bottom
  let forme = k.at("shape", default: "rectangle")
  let trait = if "draw" in k { rd-trait(st, defaut: if trait-defaut == auto { black } else { trait-defaut }, epaisseur: epaisseur, commande: commande) } else { none }
  let fond = rd-fond(st, commande: commande)
  if forme == "circle" {
    let d = calc.sqrt(calc.pow(w / 1pt, 2) + calc.pow(h / 1pt, 2)) * 1pt
    d = calc.max(d, rd-abs(k.at("min-width", default: 0pt)), rd-abs(k.at("min-height", default: 0pt)))
    let dx = (d - b.w) / 2
    let asc = (d - (ht + dp)) / 2 + ht
    let corps = box(width: d, height: d, {
      place(top + left, circle(radius: d / 2, fill: fond, stroke: trait))
      place(top + left, dx: dx, dy: asc - hc, contenu)
    })
    return (corps: corps, w: d, h: d, asc: asc)
  }
  w = calc.max(w, rd-abs(k.at("min-width", default: 0pt)))
  h = calc.max(h, rd-abs(k.at("min-height", default: 0pt)))
  // texte centré dans le nœud quand la largeur ou la hauteur minimale agrandit le nœud
  let dx = (w - b.w) / 2
  let asc = (h - (ht + dp)) / 2 + ht
  let corps = box(width: w, height: h, {
    if forme == "ellipse" {
      place(top + left, dx: -w * 0.2071, dy: -h * 0.2071, ellipse(width: w * 1.4142, height: h * 1.4142, fill: fond, stroke: trait))
    } else if fond != none or trait != none {
      place(top + left, rect(width: w, height: h, fill: fond, stroke: trait, radius: k.at("radius", default: 0pt)))
    }
    place(top + left, dx: dx, dy: asc - hc, contenu)
  })
  (corps: corps, w: w, h: h, asc: asc)
}

/// Pose `c` centré sur le point `p` (aide passée à la clé `overlay` sous le nom `node`).
#let rd-node-at(p, c, anchor: center) = place(top + left, dx: p.at(0), dy: p.at(1), {
  context {
    let m = measure(c)
    let dx = if anchor == left or anchor == left + horizon { 0pt } else if anchor == right or anchor == right + horizon { -m.width } else { -m.width / 2 }
    place(top + left, dx: dx, dy: -m.height / 2, c)
  }
})

/// Clés locales d'un appel, sans les valeurs `auto` (« selon les réglages »).
#let rd-local(d) = {
  let res = (:)
  for (k, v) in d { if v != auto { res.insert(k, v) } }
  res
}
