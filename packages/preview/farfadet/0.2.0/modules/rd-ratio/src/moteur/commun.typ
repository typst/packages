// commun.typ (rdratio) — styles « à la TikZ » et tracés, communs aux paquets rdtime,
// rdratio, rdgrid et rdarithm : chacun en garde la copie élaguée de ce dont il se sert.
//
// Ces paquets passent des « styles TikZ » à leurs clés (`result={text=red}`,
// `cell style={fill=green!25}`…). En Typst, un STYLE est :
//   - `none` (rien) ;
//   - un dictionnaire de clés à la manière de TikZ (vocabulaire ci-dessous, `rd-style-cles`) ;
//   - une fonction `contenu => contenu` (transformation libre du contenu d'une cellule) ;
//   - un tableau de ces valeurs, appliquées dans l'ordre (la dernière l'emporte).
// Les styles se FUSIONNENT comme en TikZ : style par défaut du moteur, puis style de la ligne, puis style
// de la cellule… (`rd-style-fusion`).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: bf-xcolor, taille-latex, reglages-regler, reglages-reinitialiser, reglages-definir-style

// =====================================================================
// Setter commun (convention des réglages : pour, reinitialiser, definir, clés)
// =====================================================================

/// Corps des setters `setrd…` : réglage global ou d'un type (`pour`), style nommé (`definir`),
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
  draw: "couleur du contour, none ou true (draw=…)",
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
  stroke-out: "trait qui barre la cellule : (line-width, color, shadowed) ou none (stroke out=…)",
  shadowed: "couleur de l'ombre d'un trait, ou none (shadowed=…)",
  amplitude: "amplitude d'une accolade (decoration={amplitude=…})",
  shorten: "allonge (négatif) ou raccourcit (positif) un trait à ses deux bouts (shorten <, shorten >)",
  out: "angle de départ d'un lien courbe (out=…)",
  "in": "angle d'arrivée d'un lien courbe (in=…)",
  nodes: "style des nœuds d'une matrice, dictionnaire (nodes={…})",
  content: "contenu posé au centre d'une forme (path picture={\\node at (…center) {…}})",
  "pattern": "motif de remplissage : un `tiling` Typst (pattern=…, pattern color=…)",
  fn: "fonction appliquée en dernier au contenu (ajout Typst)",
)

/// Contrôle de réglage pour une clé de style.
#let rd-controle-style = (
  v => v == none or type(v) in (dictionary, function, array),
  "none, un dictionnaire de style (text, fill, draw, font, line-width…), une fonction ou un tableau de styles",
)

/// Contrôle : dictionnaire de styles indexés par numéro de cellule (règle R7 : `("3-2": (fill: red))`).
#let rd-controle-styles-numerotes = (
  v => v == none or (type(v) == dictionary and v.values().all(x => x == none or type(x) in (dictionary, function, array))),
  "none ou un dictionnaire de styles indexés par numéro en chaîne, par exemple (\"3\": (fill: red))",
)

/// Normalise un style en (cles: dictionnaire fusionné, fns: tableau de fonctions), après contrôle des clés.
#let rd-style(v, commande: "rdratio", cle: "style") = {
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
#let rd-style-fusion(..styles, commande: "rdratio") = {
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

/// Couleur Typst ou expression xcolor (« red!50 », « arithmcol1 »…) ; `courante` remplace le nom spécial
/// « arithmcol » (couleur dynamique de \RowPGCD et \DecompFrac).
#let rd-couleur(v, commande: "rdratio", courante: none) = {
  if v == none or v == auto { return v }
  if type(v) != str { return bf-xcolor(v, commande: commande) }
  if courante != none and "arithmcol" in v {
    let morceaux = v.split("!").map(m => if m.trim() == "arithmcol" { courante.to-hex() } else { m })
    return bf-xcolor(morceaux.join("!"), commande: commande)
  }
  bf-xcolor(v, commande: commande)
}

#let _opacite(c, op) = if c == none or op == none or op >= 1 { c } else { c.transparentize((1 - op) * 100%) }

/// Arguments de `text` tirés de la clé `font` (dictionnaire), sans la couleur.
#let rd-police(f, commande: "rdratio") = {
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

/// Contrôle d'une clé de police (`label above font=\footnotesize`…) : taille LaTeX en chaîne, longueur,
/// dictionnaire (size, weight, style, family) ou fonction.
#let rd-controle-police = (
  v => v == none or type(v) in (str, length, dictionary, function),
  "none, une taille LaTeX (\"footnotesize\"), une longueur, un dictionnaire (size, weight, style, family) ou une fonction",
)

/// Applique une police (valeur d'une clé `… font`) au contenu ; dans un `context`.
#let rd-appliquer-police(c, f, commande: "rdratio") = {
  if f == none { return c }
  if type(f) == function { return f(c) }
  if type(f) == str { return text(size: taille-latex(f), c) }
  if type(f) == length { return text(size: f, c) }
  text(..rd-police(f, commande: commande), c)
}

/// Applique au contenu les clés « texte » d'un style normalisé : couleur, police, opacité, fonctions.
#let rd-texte(c, st, commande: "rdratio", courante: none) = {
  let k = st.cles
  let args = rd-police(k.at("font", default: none), commande: commande)
  let couleur = rd-couleur(k.at("text", default: none), commande: commande, courante: courante)
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
#let rd-trait(st, defaut: black, epaisseur: 0.4pt, commande: "rdratio", courante: none) = {
  let k = st.cles
  let d = k.at("draw", default: auto)
  if d == none or d == false { return none }
  let c = if d == auto or d == true { defaut } else { rd-couleur(d, commande: commande, courante: courante) }
  if c == none { return none }
  let op = k.at("draw-opacity", default: k.at("opacity", default: none))
  let s = (paint: _opacite(c, op), thickness: k.at("line-width", default: epaisseur))
  if "dash" in k and k.dash != none { s.dash = k.dash }
  s
}

/// Fond d'un style (`fill`, avec `fill-opacity` ou `opacity`).
#let rd-fond(st, commande: "rdratio", courante: none) = {
  let k = st.cles
  let f = rd-couleur(k.at("fill", default: none), commande: commande, courante: courante)
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

/// Longueur absolue (les `em` résolus dans la police courante) : à appeler dans un `context`.
#let rd-abs(l) = if type(l) == length { l.to-absolute() } else if type(l) == relative { l.length.to-absolute() } else { l }

// =====================================================================
// Tracés : accolades, traits ombrés
// =====================================================================

/// Accolade de longueur `l` et d'amplitude `a` (décoration TikZ `brace`), tracée depuis l'origine vers la
/// droite ; `haut: true` : pointe vers le haut (y négatif en Typst), sinon vers le bas (`mirror`).
#let rd-accolade(l, a, trait, haut: true) = {
  let s = if haut { -1 } else { 1 }
  let p(x, y) = (x, s * y)
  curve(
    stroke: trait,
    curve.move(p(0pt, 0pt)),
    curve.cubic(p(0.15 * a, 0.3 * a), p(0.5 * a, 0.5 * a), p(a, 0.5 * a)),
    curve.line(p(l / 2 - a, 0.5 * a)),
    curve.cubic(p(l / 2 - 0.5 * a, 0.5 * a), p(l / 2 - 0.15 * a, 0.7 * a), p(l / 2, a)),
    curve.cubic(p(l / 2 + 0.15 * a, 0.7 * a), p(l / 2 + 0.5 * a, 0.5 * a), p(l / 2 + a, 0.5 * a)),
    curve.line(p(l - a, 0.5 * a)),
    curve.cubic(p(l - 0.5 * a, 0.5 * a), p(l - 0.15 * a, 0.3 * a), p(l, 0pt)),
  )
}

/// Couleur numéro `i` (à partir de 1) d'une liste, en boucle (comme `mod` dans rdarithm et rdratio).
#let rd-cycle(liste, i) = liste.at(calc.rem(i - 1, liste.len()))

/// Liste de couleurs : tableau, ou chaîne LaTeX « a, b, c » (les accolades extérieures sont ignorées).
#let rd-liste(v) = {
  if v == none { return () }
  if type(v) == array { return v }
  if type(v) == str {
    let s = v.trim()
    if s.starts-with("{") and s.ends-with("}") { s = s.slice(1, -1) }
    return s.split(",").map(x => x.trim()).filter(x => x != "")
  }
  (v,)
}

/// Clés locales d'un appel, sans les valeurs `auto` (« selon les réglages »).
#let rd-local(d) = {
  let res = (:)
  for (k, v) in d { if v != auto { res.insert(k, v) } }
  res
}

/// Pose `c` centré sur le point `p` (aide passée à `code-after` sous le nom `node`).
#let rd-node-at(p, c, anchor: center) = place(top + left, dx: p.at(0), dy: p.at(1), {
  context {
    let m = measure(c)
    let dx = if anchor == left or anchor == left + horizon { 0pt } else if anchor == right or anchor == right + horizon { -m.width } else { -m.width / 2 }
    place(top + left, dx: dx, dy: -m.height / 2, c)
  }
})
