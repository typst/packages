// crep.typ — zones de réponse (crep, tccrep, tcfillcrep, tcfraccrep, seyesrep, assosbox, dembox…).
// Banc de non-régression : tests/_ref et tests/regression.typ.
//
// Le principe : une boîte « réponse » occupe EXACTEMENT la même place
// en version élève et en version professeur.
//   - professeur : la réponse s'affiche dans la police de correction ;
//   - élève : la réponse est composée puis rendue invisible, et des lignes Seyès
//     (épaisses tous les 8 mm, fines tous les 2 mm) sont tracées dans la boîte,
//     calées sur les lignes de base du texte.
// Dans une boîte Seyès, le texte suit une grille de 8 mm quoi qu'il contienne
// (en LaTeX : \baselineskip = 8 mm et \lineskiplimit = −∞).
//
// Toutes les dimensions sont recalculées à partir du contenu :
//   - hauteur de la première ligne et profondeur de la dernière (mesurées sur
//     l'encre des glyphes, comme les boîtes TeX) ;
//   - hauteur de la grille (mesurée), lignes supplémentaires (extra lines) ;
//   - largeur restante de la ligne (tcfillcrep : boîte 1fr, sans les deux
//     compilations qu'exige tikzmark en LaTeX) ;
//   - largeur naturelle de la réponse (tcautocrep) ;
//   - espacements avant/après calqués sur « before/after skip balanced » de tcolorbox.
//
// Toutes les valeurs viennent du registre « crep » (reglages.typ, mécanisme du socle) : clés de
// `setrdcrep` et des boîtes, styles par défaut redéfinissables, styles nommés, crep-box / tccrep-box,
// unité Seyès et épaisseurs réglables. Les noms exportés par interne.typ sont stables.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "reglages.typ": *

// =====================================================================
// Constantes de rdcrep (défauts ; réglables par les clés seyes-unit, seyes-thick…)
// =====================================================================

#let seyes-unite = 8mm // \crep@seyesunit
#let _epais = ptl(1.128) // ligne épaisse (seyescolA)
#let _fin = ptl(0.564) // lignes fines (seyescolB)
#let _decal = ptl(0.564) // les lignes sont tracées 0,564 pt sous leur repère
#let _grand = 100pt // marge des mesures d'encre

// Compteurs (\crepcounter, \tccrepcounter et le compteur tcolorbox des crep).
#let crep-compteur = counter("bf-crep")
#let tccrep-compteur = counter("bf-tccrep")

// =====================================================================
// Mesures (à appeler dans un `context`)
// =====================================================================

/// Les boîtes contenues dans une mesure d'encre gardent les bords de texte et l'interligne du document
/// (sinon une \dembox mesurée hériterait des bords fictifs de la mesure et grandirait démesurément).
/// Attention : un `set par` posé AUTOUR d'une boîte en ligne coupe le paragraphe (la boîte mesurée
/// gagnait une ligne entière) ; l'interligne est donc posé DANS le corps de la boîte, reconstruite.
#let _bords-intacts(c) = {
  let (te, be, ld) = (text.top-edge, text.bottom-edge, par.leading)
  show box: it => {
    set text(top-edge: te, bottom-edge: be)
    let f = it.fields()
    let corps = f.remove("body", default: none)
    let etiquette = f.remove("label", default: none)
    // boîte déjà reconstruite (étiquette <bf-intact>) ou vide : telle quelle
    if corps == none or etiquette == <bf-intact> { it } else {
      [#box(..f, {
          set par(leading: ld)
          corps
        })<bf-intact>]
    }
  }
  c
}

#let _seq-recle = [*a* *b*].func()

/// Copie « de mesure » d'un contenu : formules (et gras, italique qui les contiennent) reconstruites, même
/// rendu, autre empreinte. Depuis Typst 0.12, `measure` donne à chaque élément localisable mesuré
/// l'emplacement de son « jumeau » réel (même empreinte) le plus proche : au tour 1 il n'existe pas encore,
/// au tour 2 si ; la réponse de l'introspection change et toute la fonction qui a mesuré est recomposée.
/// Sans jumeau, la réponse est la même à tous les tours : le tour 2 retrouve la mesure en cache.
/// Ne s'applique qu'aux copies MESURÉES (jamais au contenu posé) ; un `context` reste tel quel (opaque).
#let _recle(c) = {
  if type(c) != content { return c }
  let f = c.func()
  if f == math.equation or f == strong or f == emph {
    let ch = c.fields()
    let corps = ch.remove("body")
    let lbl = ch.remove("label", default: none)
    let e = f(..ch, if f == math.equation { corps } else { _recle(corps) })
    return if lbl == none { e } else { [#e#lbl] }
  }
  if f == _seq-recle { return c.children.map(_recle).join() }
  c
}

/// Hauteur de l'encre au-dessus de la ligne de base (boîte TeX : \ht).
#let _hauteur(c) = calc.max(
  0pt,
  measure(box({
    let c = _bords-intacts(_recle(c))
    set par(leading: 0pt)
    set text(top-edge: "bounds", bottom-edge: -_grand)
    sym.zws // sans texte sur la ligne, les bords ne s'appliqueraient pas (boîte seule)
    c
  })).height
    - _grand,
)

/// Profondeur de l'encre sous la ligne de base (boîte TeX : \dp).
#let _profondeur(c) = calc.max(
  0pt,
  measure(box({
    let c = _bords-intacts(_recle(c))
    set par(leading: 0pt)
    set text(top-edge: _grand, bottom-edge: "bounds")
    sym.zws
    c
  })).height
    - _grand,
)

/// Le contenu contient-il un bloc (colonnes, liste, tableau…) plutôt que du texte en ligne ? Entouré de deux
/// repères sans largeur, un contenu en ligne tient sur UNE ligne de mesure (moins de `_grand` + son encre) ;
/// un bloc coupe le paragraphe et ajoute deux lignes de mesure. Sans ce test, la « hauteur d'encre » d'un
/// bloc mesurait le bloc entier et repoussait la réponse d'une page.
#let _est-bloc(c) = measure(box({
  let c = _bords-intacts(_recle(c))
  set par(leading: 0pt)
  set text(top-edge: "bounds", bottom-edge: -_grand)
  sym.zws
  c
  sym.zws
})).height > 1.5 * _grand

/// `_est-bloc(c)` et `_hauteur(c)` en UNE mesure : `none` si `c` est un bloc, sinon l'encre au-dessus de la
/// ligne de base. Même mesure que `_est-bloc` (repère final compris : un repère sans encre ni largeur ne
/// change pas la hauteur d'une ligne), qui a les bords de `_hauteur`.
/// Pas d'équivalent pour `_profondeur` : ses bords (haut fixe, bas sur l'encre) font passer pour un bloc un
/// contenu en ligne très profond (opération posée de rdopp dans une zone Seyès), d'où une zone trop courte.
#let _encre-ligne(c) = {
  let m = measure(box({
    let c = _bords-intacts(_recle(c))
    set par(leading: 0pt)
    set text(top-edge: "bounds", bottom-edge: -_grand)
    sym.zws
    c
    sym.zws
  })).height
  if m > 1.5 * _grand { none } else { calc.max(0pt, m - _grand) }
}

/// Distances entre la ligne de base et les bords des lignes du texte courant
/// (réglages `text.top-edge` / `text.bottom-edge` du modèle).
#let _bords-texte() = (
  haut: measure(box({
    set par(leading: 0pt)
    set text(bottom-edge: "baseline")
    [x]
  })).height,
  bas: measure(box({
    set par(leading: 0pt)
    set text(top-edge: "baseline")
    [x]
  })).height,
)

// =====================================================================
// Première et dernière ligne d'un contenu
// =====================================================================

#let _sequence = [*a* *b*].func()
#let _espace = [*a* *b*].children.at(1).func()

/// Aplatit un contenu en éléments « en ligne » ; `none` marque une coupure
/// (paragraphe, retour à la ligne, début ou fin d'un bloc).
#let _feuilles(c) = {
  if c == none { return () }
  if type(c) == str { return (text(c),) }
  if type(c) != content { return () }
  let f = c.func()
  if f == _sequence {
    // \seyesskip (marqueur + espace vertical contextuel) : une coupure, pas un élément en ligne
    let res = ()
    let sauter = false
    for e in c.children {
      if sauter {
        sauter = false
        continue
      }
      if e.func() == metadata and e.value == "bf-seyesskip" {
        res.push(none)
        sauter = true
      } else { res += _feuilles(e) }
    }
    return res
  }
  if f == text { return (c,) }
  if f == _espace { return ([ ],) }
  if f in (parbreak, linebreak, pagebreak, colbreak) { return (none,) }
  if f == strong { return _feuilles(c.body).map(x => if x == none { none } else { strong(x) }) }
  if f == emph { return _feuilles(c.body).map(x => if x == none { none } else { emph(x) }) }
  if f == math.equation {
    if c.block { return (none, math.equation(block: false, math.display(c.body)), none) }
    return (c,)
  }
  if f in (list, enum, terms) { return (none,) + c.children.map(_feuilles).flatten() + (none,) }
  if f in (list.item, enum.item, terms.item) {
    return (none,) + _feuilles(c.at("body", default: c.at("description", default: none))) + (none,)
  }
  if f in (block, align, pad, par, stack, columns) {
    let corps = c.at("body", default: none)
    if corps == none and c.has("children") { return (none,) + c.children.map(_feuilles).flatten() + (none,) }
    return (none,) + _feuilles(corps) + (none,)
  }
  if c.has("child") { return _feuilles(c.child) } // contenu stylé
  if f in (metadata, state, counter, place, v, h) { return () }
  (c,) // autre élément en ligne (boîte, image, formule…)
}

/// Le contenu commence (ou finit, `fin: true`) par du texte en ligne, et non par un bloc
/// (liste, tableau, figure…) dont la hauteur ne dépend pas des bords de texte ?
#let _texte-en-tete(c, fin: false) = {
  if type(c) != content { return type(c) == str }
  let f = c.func()
  if f == _sequence {
    let enfants = c.children.filter(x => not (x.func() in (_espace, parbreak)))
    if enfants.len() == 0 { return false }
    return _texte-en-tete(if fin { enfants.last() } else { enfants.first() }, fin: fin)
  }
  if f in (strong, emph) { return _texte-en-tete(c.body, fin: fin) }
  if c.has("child") { return _texte-en-tete(c.child, fin: fin) }
  if f == math.equation { return not c.block }
  not (f in (list, enum, terms, block, table, grid, figure, image, align, pad, stack, columns, place))
}

/// Estimation du nombre de caractères que tient une ligne de largeur `l`.
#let _car-par-ligne(l) = calc.max(8, int(l / (0.47 * measure[M].width) * 0.85))

/// Morceau de texte (au plus `n` caractères) pris au début (`fin: false`) ou à la fin d'une liste de feuilles.
#let _morceau(feuilles, n, fin: false) = {
  let liste = if fin { feuilles.rev() } else { feuilles }
  let pris = ()
  let reste = n
  for f in liste {
    if f == none {
      if pris.len() > 0 { break } else { continue }
    }
    if reste <= 0 { break }
    if f.func() == _espace or (f.func() == text and f.text.trim() == "") {
      if pris.len() > 0 { pris.push([ ]) }
      continue
    }
    if f.func() == text {
      let t = f.text
      let k = t.clusters()
      if k.len() > reste {
        t = if fin { k.slice(k.len() - reste).join() } else { k.slice(0, reste).join() }
      }
      pris.push(text(t))
      reste -= k.len()
    } else {
      pris.push(f)
      reste -= 4
    }
  }
  if pris.len() == 0 { return none }
  if fin { pris = pris.rev() }
  pris.join()
}

// =====================================================================
// Lignes Seyès (pic « ligneseyes » de rdcrep)
// =====================================================================

/// Lignes Seyès dans une bande de largeur `l` et de hauteur `h`, calées sur une
/// ligne de base située à `y0` sous le haut de la bande (le tout est à rogner).
/// `unite`, `epais`, `fin`, `decal`, `subdivisions` : clés seyes-unit, seyes-thick, seyes-thin,
/// seyes-shift, seyes-subdivisions. `col-a`, `col-b` : `auto` = couleur nommée `seyescol` (courante :
/// à appeler alors dans un `context`).
#let lignes-seyes(
  l,
  h,
  y0,
  col-a: auto,
  col-b: auto,
  unite: seyes-unite,
  epais: _epais,
  fin: _fin,
  decal: _decal,
  subdivisions: 4,
) = {
  let col-a = if col-a == auto { bf-couleur-nommee("seyescol") } else { col-a }
  let col-b = if col-b == auto { bf-couleur-nommee("seyescol") } else { col-b }
  let kmin = -calc.ceil((h - y0) / unite) - 1
  let kmax = calc.ceil(y0 / unite) + 1
  let pas = unite / subdivisions
  for k in range(kmin, kmax + 1) {
    // ligne épaisse : son bord supérieur est exactement sur la ligne de base
    let y = y0 - k * unite + decal
    place(top + left, line(start: (0pt, y), end: (l, y), stroke: epais + col-a))
    for n in range(1, subdivisions) {
      let yn = y - n * pas
      place(top + left, line(start: (0pt, yn), end: (l, yn), stroke: fin + col-b))
    }
  }
}

/// Paramètres de tracé des lignes Seyès tirés des réglages résolus `r`.
#let _geometrie-seyes(r) = (
  unite: r.at("seyes-unit", default: seyes-unite),
  epais: r.at("seyes-thick", default: _epais),
  fin: r.at("seyes-thin", default: _fin),
  decal: r.at("seyes-shift", default: _decal),
  subdivisions: r.at("seyes-subdivisions", default: 4),
)

/// Bande rognée contenant des lignes Seyès (à `place`r dans une boîte).
#let _bande-seyes(l, h, y0, cols, rayon: 0pt, geo: (:)) = box(
  width: l,
  height: h,
  clip: true,
  radius: rayon,
  lignes-seyes(l, h, y0, col-a: cols.at(0), col-b: cols.at(1), ..geo),
)

// =====================================================================
// Styles de la réponse
// =====================================================================

/// Police LaTeX écrite en commandes (« \large\bfseries ») → dictionnaire (size:, weight:, style:, font:).
#let _police-latex(v) = {
  let f = (size: none, weight: "regular")
  for (motif, taille) in (
    ("\\tiny", "tiny"),
    ("\\scriptsize", "scriptsize"),
    ("\\footnotesize", "footnotesize"),
    ("\\small", "small"),
    ("\\normalsize", "normalsize"),
    ("\\large", "large"),
    ("\\Large", "Large"),
    ("\\LARGE", "LARGE"),
    ("\\huge", "huge"),
    ("\\Huge", "Huge"),
  ) {
    if v.contains(regex(motif.replace("\\", "\\\\") + "\\b")) { f.size = taille }
  }
  if v.contains("\\bfseries") or v.contains("\\textbf") or v.contains("\\boldmath") { f.weight = "bold" }
  if v.contains("\\itshape") or v.contains("\\textit") { f.style = "italic" }
  if v.contains("\\sffamily") { f.sans = true }
  f
}

/// Applique une police (dictionnaire, chaîne LaTeX ou fonction) à `c` ; `couleur` : couleur du texte ou none.
#let _appliquer-police(f, c, couleur: none, sans-font: crep-defauts-communs.sans-font) = {
  if f == auto or f == none { f = (:) }
  if type(f) == str { f = _police-latex(f) }
  if type(f) == function { return if couleur != none { text(fill: couleur, f(c)) } else { f(c) } }
  let args = (:)
  if couleur != none { args.fill = couleur }
  if f.at("size", default: none) != none {
    args.size = if type(f.size) == str { taille-latex(f.size) } else { f.size }
  }
  if f.at("weight", default: none) != none { args.weight = f.weight }
  if f.at("style", default: none) != none { args.style = f.style }
  if f.at("font", default: none) != none { args.font = f.font } else if f.at("sans", default: false) {
    args.font = sans-font
  }
  text(..args, c)
}

/// Police de correction (\crep@correction@font) et couleur (crepcorrectioncol).
#let _police-correction(r, c, couleur: true) = {
  let cc = crep-correction(r)
  let col = if couleur { bf-resoudre-couleur(cc.couleur) } else { none }
  _appliquer-police(cc.police, c, couleur: col, sans-font: r.at("sans-font", default: crep-defauts-communs.sans-font))
}

/// Couleur `c` à l'opacité `op` (0 à 1), comme opacityback.
#let _opacite(c, op) = if op >= 1 { c } else { c.transparentize((1 - op) * 100%) }

/// Couleurs des lignes Seyès : option de la boîte, sinon réglage global.
#let _couleurs-seyes(r, option) = {
  let c = if option == auto { r.seyes-colors } else { option }
  if type(c) != array { c = (c, c) }
  c.map(x => if type(x) == str { xcouleur(x) } else { x })
}

/// Couleur d'une clé (`auto` → `defaut`, chaîne xcolor → couleur).
#let _col(v, defaut) = if v == auto { defaut } else if type(v) == str { xcouleur(v) } else { v }
/// Valeur d'une clé (`auto` → `defaut`).
#let _val(v, defaut) = if v == auto { defaut } else { v }

/// Rendu d'une formule ou d'une boîte en ligne SANS encombrement vertical : la
/// ligne garde sa hauteur de grille, le contenu déborde (\lineskiplimit = −∞).
#let _sans-encombrement(it) = {
  let it = _bords-intacts(it)
  // une seule mesure (celle de `_hauteur`) donne la hauteur d'encre ET la largeur (le repère est sans chasse)
  let m = measure(box({
    set par(leading: 0pt)
    set text(top-edge: "bounds", bottom-edge: -_grand)
    sym.zws
    it
  }))
  let asc = calc.max(0pt, m.height - _grand)
  let larg = m.width
  box(width: larg, height: 0pt, place(top + left, dy: -asc, box({
    set par(leading: 0pt)
    set text(top-edge: "bounds", bottom-edge: "baseline")
    it
  })))
}

// =====================================================================
// Clés héritées (signatures d'avant l'épurage de la façade : `tcb:` chaîne LaTeX, `params:`, `titre:`)
// =====================================================================

// Chaîne d'options tcolorbox → clés du registre (clés reconnues seulement).
#let _options-tcb(o) = {
  let L(v) = longueur-latex(v, defaut: auto)
  let res = (:)
  for (k, v) in o {
    if k in ("colback", "colframe", "colbacklower", "colbacktitle", "coltitle") { res.insert(k, v) }
    if k in ("boxrule", "arc", "boxsep", "top", "bottom", "left", "right", "middle", "width", "height") {
      res.insert(k, L(v))
    }
    if k == "sharp-corners" { res.arc = 0pt }
    if k in ("halign", "halign-lower") { res.insert(k, v.replace("flush ", "")) }
    if k == "valign" { res.valign = v }
    if k == "lefthand-width" { res.lefthand-width = L(v) }
    if k == "righthand-width" { res.righthand-width = L(v) }
    if k == "sidebyside-gap" { res.sidebyside-gap = L(v) }
    if k == "frame-hidden" { res.frame-hidden = true }
    if k == "frame-style" { res.frame-hidden = false }
    if k == "opacityback" { res.opacityback = float(v) }
    if k == "title" { res.title = v } // titre LaTeX brut, affiché tel quel
    if k == "notitle" { res.title = none }
    if k == "bbox" {
      let m = v.split("}{").map(x => longueur-latex(x.trim("{").trim("}").trim(), defaut: 0pt))
      if m.len() == 2 { res.bbox = m }
    }
  }
  res
}

// Anciens noms des paramètres internes (`params:`) → clés.
#let _anciens-params = (
  fond: "colback",
  fond-op: "opacityback",
  cadre: "colframe",
  fond-bas: "colbacklower",
  titre: "title",
  fond-titre: "colbacktitle",
  col-titre: "coltitle",
  sbs-gap: "sidebyside-gap",
  lefthand: "lefthand-width",
  righthand: "righthand-width",
  avant: "before-skip",
  apres: "after-skip",
)

/// Clés locales d'un appel : clés du registre + clés héritées converties ; filtrées pour le type `pour`.
#let _cles-locales(pour, nommes) = {
  let o = nommes
  let herites = (:)
  if "tcb" in o { herites += _options-tcb(lire-options(o.remove("tcb"))) }
  if "params" in o {
    for (k, v) in o.remove("params") {
      if k == "cadre-vu" { herites.frame-hidden = not v } else if v != auto {
        herites.insert(_anciens-params.at(k, default: k), v)
      }
    }
  }
  if "titre" in o { herites.title = o.remove("titre") }
  if "largeur" in o { herites.width = o.remove("largeur") }
  // les clés héritées hors du type sont ignorées (comportement d'avant l'épurage de la façade)
  let permises = crep-defauts-communs.keys() + crep-types.at(pour, default: (:)).keys()
  for (k, v) in herites { if k in permises and k not in o { o.insert(k, v) } }
  o
}

// =====================================================================
// Boîtes en ligne : \tccrep, \tcfillcrep, \tcautocrep
// =====================================================================

// Pastille du numéro (crep num style) sur une boîte de largeur W et hauteur H.
#let _pastille(r, num, W, H, rayon) = {
  place(top + left, rect(width: W, height: H, fill: bf-resoudre-couleur(r.crep-num-veil), radius: rayon))
  place(top + left, box(fill: bf-resoudre-couleur(r.crep-num-fill), inset: 0.3333em * (5.5 / 11), text(
    size: if type(r.crep-num-size) == str { taille-latex(r.crep-num-size) } else { r.crep-num-size },
    weight: "bold",
    fill: bf-resoudre-couleur(r.crep-num-color),
    font: r.sans-font,
    str(num),
  )))
}

// Rendu d'une boîte en ligne à partir de ses paramètres `p` (voir _parametres-ligne).
// `largeur` : largeur imposée (none → p.largeur). `grille` : sans encombrement vertical.
// `entoure` : fonction (boîte, largeur, hauteur) → contenu, qui habille la boîte posée (crepbox).
#let _rendu-ligne(p, largeur: none, grille: false, entoure: none) = {
  let r = p.reglages
  let corr = c => _police-correction(r, c)
  let fonte = c => _police-correction(r, c, couleur: false) // police de correction, sans couleur
  let style = if p.style == "correction" { corr } else { c => c }
  let contenu = if p.maths and p.corps != none { math.equation(block: false, p.corps) } else { p.corps }
  // Hauteur et profondeur : fantôme \^Ep en police de correction, et le contenu.
  let police-texte = bf-lire(bf-police-p).at("texte", default: none)
  let fantome = if police-texte == none { fonte("Êp") } else { fonte(text(font: police-texte, "Êp")) }
  let h-ep = _hauteur(fantome)
  let d-ep = _profondeur(fantome)
  let (hc, dc) = if contenu == none { (0pt, 0pt) } else {
    let c-mesure = if p.montrer { style(contenu) } else { fonte(contenu) }
    (_hauteur(c-mesure), _profondeur(c-mesure))
  }
  let h = calc.max(h-ep, hc)
  let d = calc.max(d-ep, dc)
  let t = p.top + p.boxsep
  let b = p.bottom + p.boxsep
  let H = t + h + d + b
  let W = if largeur != none { largeur } else { p.largeur }
  let interieur = W - 2 * p.boxsep - p.left - p.right
  // Ce qui s'affiche dans la boîte
  let affiche = if p.montrer and contenu != none { style(contenu) } else if p.dotfill {
    if p.commande-pointilles != none { box(width: interieur, p.commande-pointilles) } else {
      box(width: interieur, repeat(box(width: 0.44em, align(center)[.])))
    }
  } else { none }
  let wc = if affiche == none { 0pt } else { measure(affiche).width }
  let dx = p.boxsep + p.left + if p.alignement == "center" { (interieur - wc) / 2 } else if p.alignement == "right" {
    interieur - wc
  } else { 0pt }
  let dessin = {
    if p.fond-op > 0 {
      place(top + left, rect(width: W, height: H, fill: _opacite(p.fond, p.fond-op), stroke: none, radius: p.arc))
    }
    if p.seyes { place(top + left, _bande-seyes(W, H, t + h, p.cols-seyes, rayon: p.arc, geo: p.geo)) }
    if p.cadre-vu and p.boxrule > 0pt {
      place(top + left, dx: p.boxrule / 2, dy: p.boxrule / 2, rect(
        width: W - p.boxrule,
        height: H - p.boxrule,
        stroke: p.boxrule + p.cadre,
        radius: calc.max(0pt, p.arc - p.boxrule / 2),
      ))
    }
    if affiche != none {
      let a = if p.visible { affiche } else { hide(affiche) }
      place(top + left, dx: dx, dy: t + h - _hauteur(affiche), box({
        set par(leading: 0pt)
        set text(top-edge: "bounds", bottom-edge: "baseline")
        a
      }))
    }
    if p.num != none { _pastille(r, p.num, W, H, p.arc) }
  }
  if grille {
    // la ligne de base de la boîte est à t + h sous son haut
    box(width: W, height: 0pt, place(top + left, dy: -(t + h), box(width: W, height: H, dessin)))
  } else {
    let boite = box(width: W, height: H, baseline: b + d, dessin)
    if entoure == none { boite } else { entoure(boite, W, H) }
  }
}

// Boîte en ligne « étiquetée » : les zones Seyès la redessinent sans encombrement.
#let _en-ligne(p) = {
  if p.mode == "reste" {
    [#box(width: 1fr, [#metadata(p)#layout(s => _rendu-ligne(p, largeur: s.width))])<bf-crep-ligne>]
  } else {
    [#box([#metadata(p)#_rendu-ligne(p)])<bf-crep-ligne>]
  }
}

// Version « grille » d'une boîte en ligne étiquetée (règle show des zones Seyès).
#let _en-ligne-grille(it) = {
  let p = it.body.children.first().value
  if p.mode == "reste" {
    box(width: 1fr, layout(s => _rendu-ligne(p, largeur: s.width, grille: true)))
  } else { _rendu-ligne(p, grille: true) }
}

/// Paramètres communs de \tccrep, \tcfillcrep, \tcautocrep (à appeler dans un `context`).
/// `commande` : nom de la commande publique (messages d'erreur).
#let _parametres-ligne(mode, largeur, corps, alignement-defaut: "center", commande: "tccrep", ..options) = {
  let local = _cles-locales("tccrep", options.named())
  // numéro lu seulement s il sert (compteur : introspection, recomposition au tour suivant)
  let num = () => tccrep-compteur.get().first()
  let r = crep-resoudre(
    "tccrep",
    local,
    commande: commande,
    style-defaut: "tccrep default style",
    numero: num,
    cle-numero: "tccrep-box",
  )
  let bbox = if r.bbox == none { (0pt, 0pt) } else { r.bbox }
  let p = (
    mode: mode,
    reglages: r,
    corps: corps,
    maths: r.maths,
    fond: _col(r.colback, xmix(xc.gray, 10)),
    fond-op: _val(r.opacityback, 1),
    arc: if r.sharp-corners == true { 0pt } else { _val(r.arc, 0pt) },
    boxsep: _val(r.boxsep, ptl(5)),
    top: _val(r.top, 0pt) + bbox.at(1),
    bottom: _val(r.bottom, 0pt) + bbox.at(0),
    left: _val(r.left, 0pt),
    right: _val(r.right, 0pt),
    boxrule: _val(r.boxrule, 0pt),
    cadre: _col(r.colframe, black),
    cadre-vu: not _val(r.frame-hidden, true), // tccrep default style : frame engine=empty
    dotfill: r.dotfill,
    commande-pointilles: r.dotfill-command,
    cols-seyes: _couleurs-seyes(r, r.seyes-colors),
    geo: _geometrie-seyes(r),
    num: if r.show-crep-num { num() } else { none },
  )
  // \setrdcrep{show crep=false} : boîte vide et invisible, sans lignes
  if not r.show-crep and not r.normal-crep { p += (fond-op: 0, cadre-vu: false, seyes: false) } else { p.seyes = r.seyes }
  // Style et visibilité (crep@setcrep + \tccrep@content)
  p.montrer = r.normal-crep or (r.show-crep and est-correction())
  p.style = if r.normal-crep { "normal" } else if r.show-crep and (est-correction() or not r.dotfill) { "correction" } else {
    "normal"
  }
  p.visible = true
  p.dotfill = r.dotfill and not p.montrer
  // Largeur et alignement
  p.alignement = if r.crep-align == "default" { alignement-defaut } else { r.crep-align }
  if mode == "auto" {
    let facteur = r.auto-factor
    let contenu = if r.maths { math.equation(block: false, corps) } else { corps }
    let w = measure(_police-correction(r, contenu, couleur: false)).width
    p.largeur = facteur * w + 2 * p.boxsep + p.left + p.right
  } else {
    p.largeur = if r.width != auto { r.width } else { largeur }
  }
  p
}

/// \tccrep[options]{largeur}{réponse} : boîte réponse en ligne de largeur fixe ; `largeur` = `auto` :
/// largeur automatique (\tcautocrep : auto factor × largeur naturelle de la réponse).
#let tccrep(..options, largeur, corps) = {
  tccrep-compteur.step()
  metadata("bf-crep-cell") // repère lu par farfadet-tableaux : pas de marge verticale autour de la boîte
  context _en-ligne(_parametres-ligne(
    if largeur == auto { "auto" } else { "fixe" },
    largeur,
    corps,
    ..options,
  ))
}

/// \tcfillcrep[options]{réponse} : boîte réponse qui occupe le reste de la ligne.
#let tcfillcrep(..options, corps) = {
  tccrep-compteur.step()
  metadata("bf-crep-cell") // repère lu par farfadet-tableaux : pas de marge verticale autour de la boîte
  context _en-ligne(_parametres-ligne("reste", none, corps, alignement-defaut: "left", commande: "tcfillcrep", ..options))
}

/// \tcautocrep[options]{réponse} : largeur = auto factor × largeur naturelle de la réponse.
/// Écart assumé : en LaTeX, la version élève mesure le fantôme de la
/// réponse (largeur nulle) et la boîte s'effondre ; ici les deux versions ont la même largeur.
/// (Non public : la façade écrit `tccrep(auto)[…]`.)
#let tcautocrep(..options, corps) = tccrep(..options, auto, corps)

/// \repsim[largeur]{réponse} (bfcours) = \tccrep{largeur}{réponse}.
#let repsim(largeur: 1.5cm, ..options, corps) = tccrep(..options, largeur, corps)

/// \tcfraccrep[options]{numérateur}{dénominateur} : fraction à trous (boîtes grises).
/// Options : width (0.7cm), crep-for ("both", "num", "den"), crep-num-style, crep-den-style, crep-style.
#let tcfraccrep(..options, num, den) = context {
  let r = reglages-resoudre(registre-crep, pour: "frac", local: options.named(), commande: "tcfraccrep")
  // corps mathématique d'un argument : $…$ ou contenu quelconque
  let corps-math(x) = if type(x) == content and x.func() == math.equation { x.body } else { x }
  let boite(x, style) = tccrep(
    ..((normal-crep: false, seyes: false) + r.crep-style + style),
    r.width,
    maths: true,
    [#corps-math(x)#hide[9]], // \vphantom{9}
  )
  let n = if r.crep-for in ("both", "num") { boite(num, r.crep-num-style) } else { corps-math(num) }
  let d = if r.crep-for in ("both", "den") { boite(den, r.crep-den-style) } else { corps-math(den) }
  math.equation(block: false, math.display(math.frac(n, d)))
}

// =====================================================================
// Texte de correction : \CorrectionBox, \crepcorrectionfont
// =====================================================================

/// \CorrectionBox{x} : `x` dans la couleur et la police de correction en version professeur ; en version
/// élève, la même place, invisible (\phantom). Clés de correction : celles de `setrdcrep`.
#let correction-box(corps) = context {
  let r = reglages-courants(registre-crep)
  let c = _police-correction(r, corps)
  if est-correction() { c } else { hide(c) }
}

/// \crepcorrectionfont : `x` dans la police de correction (sans sa couleur), dans les deux versions.
#let crep-correction-font(corps) = context {
  _police-correction(reglages-courants(registre-crep), corps, couleur: false)
}

// =====================================================================
// Réglages globaux : \setrdcrep{…}
// =====================================================================

// En LaTeX, \setrdcrep{correction color=…, correction font=…} règle aussi \SiCorrection* (même couleur
// crepcorrectioncol) : on recopie ces deux clés dans les réglages du socle (bf-reglages-socle).
#let _vers-socle(d, reinitialiser: false) = {
  let s = (:)
  if "correction-color" in d and d.correction-color not in (auto, none) { s.correction-color = d.correction-color }
  let f = d.at("correction-font", default: auto)
  if type(f) == str { f = _police-latex(f) }
  if type(f) == dictionary {
    s.correction-font = f.pairs().filter(((k, v)) => k in ("size", "weight", "style", "font")).to-dict()
  } else if type(f) == function { s.correction-font = f }
  if reinitialiser or s.len() > 0 {
    reglages-regler(bf-reglages-socle, reinitialiser: reinitialiser, commande: "setrdcrep", ..s)
  }
}

/// \setrdcrep{…} : le réglage du paquet (convention commune des setters). À partir de cet endroit :
///   - `setrdcrep(cle: v, …)` : réglage global ; `setrdcrep(pour: "type", cle: v)` : réglage d'un type
///     (crep, tccrep, frac, dembox, seyesfig, seyestab, tccheckbox, tccheckboxlist, crepbox, checkbox,
///     tcbcheckbox) ou d'un tableau de types ;
///   - `setrdcrep(definir: "nom", cle: v, …)` : définit le style nommé « nom » (appelé par `style: "nom"`) ;
///     `pour:` contrôle alors les clés contre un type ; les styles prédéfinis (« crep default style »…)
///     se redéfinissent de la même façon ;
///   - `reinitialiser: true` : oublie réglages global et par type (styles gardés) ; avec des clés, repart
///     des défauts puis les applique ; `reinitialiser: "tout"` : ramène aussi les styles aux styles prédéfinis.
/// Clés globales (/crep/) : correction-color, correction-font, show-crep, seyes, seyes-colors,
/// dotfill-command, auto-factor (+ ajouts seyes-unit, seyes-thick…). Paramètres propres : `correction`
/// (version prof/élève), `default: true` (défauts d'origine de rdcrep), `every-crep`, `every-tccrep`,
/// `every-box`, `reset-crep-counter`, `reset-tccrep-counter`, `set-crep-counter`, `set-tccrep-counter`.
#let setrdcrep(
  pour: none,
  reinitialiser: false,
  definir: none,
  correction: auto,
  default: false,
  every-crep: none,
  every-tccrep: none,
  every-box: none,
  reset-crep-counter: false,
  reset-tccrep-counter: false,
  set-crep-counter: none,
  set-tccrep-counter: none,
  ..reglages,
) = {
  if reglages.pos().len() > 0 {
    panic("setrdcrep : seuls des arguments nommés sont acceptés ; reçu : " + repr(reglages.pos().first()) + ".")
  }
  if reinitialiser not in (true, false, "tout") {
    panic("setrdcrep : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none { return reglages-definir-style(registre-crep, definir, pour: pour, ..reglages.named()) }
  if reinitialiser == "tout" { reglages-reinitialiser(registre-crep, styles: true) }
  let reinitialiser = reinitialiser != false
  let d = reglages.named()
  if type(correction) == str { correction = correction == "prof" or correction == "true" }
  // \setrdcrep{default} : défauts d'origine de rdcrep (correction=false, rouge, \bfseries\boldmath, seyes=false)
  if default {
    reglages-regler(registre-crep, ..crep-preset-rd)
    _vers-socle(crep-preset-rd)
    set-correction(false)
  }
  // Une seule source, deux PDF : `--input correction=true|false` l'emporte sur le réglage écrit
  // dans le document (en LaTeX, c'est le fichier maître ELEVE_… qui fixe la version).
  // La version vit dans farfadet-socle ; `set-correction` ne fait rien si `--input correction=…` l'impose.
  if correction != auto { set-correction(correction) }
  if reinitialiser or d.len() > 0 {
    reglages-regler(registre-crep, pour: pour, reinitialiser: reinitialiser, ..d)
    if pour == none { _vers-socle(d, reinitialiser: reinitialiser) }
  }
  // every crep / every tccrep / every box : réglages des types
  if every-box != none {
    reglages-regler(registre-crep, pour: "crep", ..every-box)
    reglages-regler(registre-crep, pour: "tccrep", ..every-box)
  }
  if every-crep != none { reglages-regler(registre-crep, pour: "crep", ..every-crep) }
  if every-tccrep != none { reglages-regler(registre-crep, pour: "tccrep", ..every-tccrep) }
  // compteurs
  if reset-crep-counter { crep-compteur.update(0) }
  if reset-tccrep-counter { tccrep-compteur.update(0) }
  if set-crep-counter != none { crep-compteur.update(set-crep-counter) }
  if set-tccrep-counter != none { tccrep-compteur.update(set-tccrep-counter) }
}

// =====================================================================
// Boîtes crep
// =====================================================================

// Version « grille » d'une dembox (zone Seyès) : sans encombrement vertical, à sa largeur demandée.
#let _dembox-grille(it) = box(width: it.width, height: 0pt, layout(t => {
  let corps = _bords-intacts(box(width: t.width, it.body))
  let asc = _hauteur(corps)
  place(top + left, dy: -asc, box({
    set par(leading: 0pt)
    set text(top-edge: "bounds", bottom-edge: "baseline")
    corps
  }))
}))

// Réglages typographiques d'une zone Seyès : grille de `unite` (8 mm) imposée.
#let _regles-grille(fleqn, corps, unite: seyes-unite) = {
  // bords de texte du document : une dembox garde les siens (sinon, mesurée avec les bords « baseline »
  // de la grille, elle s'aplatit et son étiquette chevauche le contenu)
  let (te0, be0) = (text.top-edge, text.bottom-edge)
  set text(top-edge: "baseline", bottom-edge: "baseline")
  set par(leading: unite, spacing: unite)
  set list(spacing: unite)
  set enum(spacing: unite)
  set terms(spacing: unite)
  // seulement sur le texte de la grille (bords « baseline ») : pas dans une dembox, qui reprend te0/be0
  show math.equation.where(block: false): it => context {
    if text.top-edge == "baseline" and text.bottom-edge == "baseline" { _sans-encombrement(it) } else { it }
  }
  show math.equation.where(block: true): it => block(width: 100%, above: unite, below: unite, {
    set align(if fleqn.actif { left } else { center })
    set par(justify: false)
    if fleqn.actif { h(fleqn.retrait) }
    math.equation(block: false, math.display(it.body))
  })
  show <bf-crep-ligne>: _en-ligne-grille
  show <bf-dembox>: it => {
    set text(top-edge: te0, bottom-edge: be0)
    _dembox-grille(it)
  }
  // tableaux Seyès (seyestab…) : version « grille » rangée dans leur métadonnée
  show <bf-seyes-tab>: it => it.body.children.first().value
  corps
}

/// Le contenu est-il « inerte » : texte, espaces, formules sans étiquette, gras, italique, contenus stylés,
/// rien d'autre ? Un tel contenu, caché (version élève), ne laisse aucune trace : ni dessin (`hide`), ni
/// compteur, état, métadonnée ou étiquette. On peut alors ne pas le composer du tout, la place étant déjà
/// mesurée. Tout le reste (boîte, `context`, liste, tableau, figure…) est composé caché, comme avant.
#let _inerte(c) = {
  if c == none or type(c) == str { return true }
  if type(c) != content { return false }
  let f = c.func()
  if f == _sequence { return c.children.all(_inerte) }
  if f in (text, _espace, parbreak, linebreak, h, smartquote) { return true }
  if f == math.equation { return not c.has("label") }
  if f in (strong, emph) { return not c.has("label") and _inerte(c.body) }
  if c.has("child") { return _inerte(c.child) } // contenu stylé (règles `set`)
  false
}

// Mise en page d'une partie de boîte. Renvoie :
//   hauteur : hauteur de la partie (sans les marges de la boîte)
//   base1, base2 : ordonnées de la première et de la dernière ligne de base (grille)
//   rendu : le contenu, à placer en haut à gauche de la partie
#let _partie(
  corps,
  l,
  style: c => c,
  visible: true,
  seyes: false,
  extra: 0,
  fleqn: (actif: true, retrait: 0pt),
  halign: "justify",
  unite: seyes-unite,
) = {
  let aligne(c) = {
    set par(justify: halign == "justify")
    set text(hyphenate: true) // LaTeX coupe les mots même hors justification
    set align(if halign == "center" { center } else if halign == "right" { right } else { left })
    c
  }
  if corps == none { return (hauteur: 0pt, base1: 0pt, base2: 0pt, rendu: none) }
  if seyes {
    let compose = style(aligne(_regles-grille(fleqn, corps, unite: unite)))
    let H = measure(block(width: l, style(aligne(_regles-grille(fleqn, _recle(corps), unite: unite))))).height
    let feuilles = _feuilles(corps)
    let n = _car-par-ligne(l)
    let debut = _morceau(feuilles, n)
    let fin = _morceau(feuilles, n, fin: true)
    // un bloc (colonnes, liste…) en tête ou en queue n'a pas d'encre de ligne : pas de correction
    // tête : test « bloc » et encre en une seule mesure (_encre-ligne : none pour un bloc) ; queue : deux mesures
    let h1 = if debut == none { 0pt } else { _encre-ligne(style(debut)) }
    let h1 = if h1 == none { 0pt } else { h1 }
    let d = if extra > 0 { extra * unite } else if fin == none or _est-bloc(style(fin)) { 0pt } else { _profondeur(style(fin)) }
    let rendu = if not visible and _inerte(corps) { none } else { move(dy: h1, block(width: l, if visible { compose } else { hide(compose) })) }
    (hauteur: h1 + H + d, base1: h1, base2: h1 + H, rendu: rendu)
  } else {
    let compose = style(aligne(corps))
    let H = measure(block(width: l, style(aligne(_recle(corps))))).height
    // Typst borne chaque ligne par les bords du modèle (top-edge, bottom-edge) ;
    // TeX, par l'encre de la première et de la dernière ligne : on corrige.
    let bords = _bords-texte()
    let feuilles = _feuilles(corps)
    let n = _car-par-ligne(l)
    let debut = _morceau(feuilles, n)
    let fin = _morceau(feuilles, n, fin: true)
    let dy = 0pt
    if _texte-en-tete(corps) and debut != none {
      dy = _hauteur(style(debut)) - bords.haut
      H += dy
    }
    if extra > 0 {
      // \vrule de profondeur extra × 8 mm sur la dernière ligne
      H += extra * unite - bords.bas
    } else if _texte-en-tete(corps, fin: true) and fin != none {
      H += _profondeur(style(fin)) - bords.bas
    }
    let rendu = if not visible and _inerte(corps) { none } else { move(dy: dy, block(width: l, if visible { compose } else { hide(compose) })) }
    (hauteur: H, base1: none, base2: none, rendu: rendu)
  }
}

// Saut « balanced » : nombre = fois l'interligne, ou longueur.
#let _saut(v, bs) = if type(v) in (int, float) { v * bs } else { v }

/// Boîte crep générique. `parties` : (haut) ou (haut, bas). `commande` : nom public (messages).
#let _crep(commande: "crep", local: (:), parties) = context {
  // numéro lu seulement s il sert (compteur : introspection, recomposition au tour suivant)
  let num = () => crep-compteur.get().first()
  let r = crep-resoudre("crep", local, commande: commande, style-defaut: "crep default style", numero: num, cle-numero: "crep-box")
  let il = bf-lire(bf-interligne-p)
  let seyes = r.seyes
  let unite = r.seyes-unit
  let bbox = if r.bbox == none { (0pt, 0pt) } else { r.bbox }
  let p = (
    fond: _col(r.colback, xmix(xc.gray, 10)),
    fond-op: _val(r.opacityback, 1),
    cadre: _col(r.colframe, black),
    cadre-vu: not _val(r.frame-hidden, false),
    boxrule: _val(r.boxrule, ptl(0.6)),
    arc: if r.sharp-corners == true { 0pt } else { _val(r.arc, 1mm) },
    boxsep: _val(r.boxsep, ptl(7)),
    top: _val(r.top, 0pt) + bbox.at(1),
    bottom: _val(r.bottom, 0pt) + bbox.at(0),
    left: _val(r.left, 0pt),
    right: _val(r.right, 0pt),
    middle: _val(r.middle, 0pt),
    halign: _val(r.halign, "justify").replace("flush ", ""),
    halign-lower: _val(r.halign-lower, "justify").replace("flush ", ""),
    width: _val(r.width, 100%),
    height: r.height,
    sbs-gap: _val(r.sidebyside-gap, 0pt),
    lefthand: r.lefthand-width,
    righthand: r.righthand-width,
    fond-bas: _col(r.colbacklower, none),
    fond-bas-op: _val(r.opacitybacklower, 1),
    bicolor: _val(r.bicolor, false),
    titre: r.title,
    fond-titre: _col(r.colbacktitle, xmix(xc.gray, 30)),
    col-titre: _col(r.coltitle, black),
    police-titre: _val(r.fonttitle, (size: "large", weight: "bold")),
    avant: _val(r.before-skip, 0.25),
    apres: _val(r.after-skip, 0.5),
  )
  // \setrdcrep{show crep=false} : clé « nirvana » de tcolorbox, la boîte n'est pas composée du tout
  if not r.show-crep and not r.normal-crep { return }

  // Style et visibilité de la partie réponse (crep@setcrep)
  let corr = c => _police-correction(r, c)
  let (style-rep, visible-rep) = if r.normal-crep { (c => c, true) } else if r.show-crep {
    if est-correction() { (corr, true) } else if r.dotfill { (c => c, true) } else { (corr, false) }
  } else { (c => c, true) }

  let haut = parties.at(0, default: none)
  let bas = parties.at(1, default: none)
  let mode = if r.crep-mode == "regular" and bas != none { "upper" } else { r.crep-mode }
  let cote = mode in ("left", "right")
  let rep-haut = mode in ("regular", "upper", "left")
  let fleqn = bf-lire(bf-fleqn-p)
  let cols = _couleurs-seyes(r, r.seyes-colors)
  let geo = _geometrie-seyes(r)
  let num = if r.show-crep-num { num() } else { none }

  // Espacements « balanced » de tcolorbox, rapportés aux bords des lignes du modèle
  let bords = _bords-texte()
  let bs = il.baselineskip
  block(
    width: 100%,
    breakable: false,
    above: calc.max(0pt, _saut(p.avant, bs) + 0.3 * bs - bords.bas),
    below: calc.max(0pt, _saut(p.apres, bs) + 0.7 * bs - bords.haut),
    layout(taille => {
      let W = p.width
      if type(W) == ratio { W = W * taille.width } else if type(W) == relative {
        W = W.length + W.ratio * taille.width
      }
      // titre : bandeau de hauteur boxsep + texte + boxsep
      let titre = if p.titre == none { none } else {
        set align(center)
        _appliquer-police(p.police-titre, p.titre, couleur: p.col-titre, sans-font: r.sans-font)
      }
      let ht = if titre == none { 0pt } else {
        2 * p.boxsep + measure(block(width: W - 2 * p.boxrule - 2 * p.boxsep, titre)).height
      }
      let x0 = p.boxrule + p.boxsep + p.left
      let y0 = p.boxrule + ht + p.boxsep + p.top
      let interieur = W - 2 * p.boxrule - 2 * p.boxsep - p.left - p.right
      let gap = p.sbs-gap + 2 * p.boxsep // crep@sbs@adjustgap
      let (L, R) = if not cote { (interieur, interieur) } else if p.lefthand != auto {
        (p.lefthand, interieur - gap - p.lefthand)
      } else if p.righthand != auto { (interieur - gap - p.righthand, p.righthand) } else {
        ((interieur - gap) / 2, (interieur - gap) / 2)
      }
      let reponse(c, l, halign) = _partie(
        c,
        l,
        style: style-rep,
        visible: visible-rep,
        seyes: seyes,
        extra: if r.lines != auto { r.lines } else { r.extra-lines }, // lines = \repline[n]
        fleqn: fleqn,
        halign: halign,
        unite: unite,
      )
      let visible(c, l, halign) = _partie(c, l, halign: halign, unite: unite)
      let A = if rep-haut { reponse(haut, L, p.halign) } else { visible(haut, L, p.halign) }
      let B = if bas == none { none } else if rep-haut { visible(bas, R, p.halign-lower) } else {
        reponse(bas, R, p.halign-lower)
      }

      // Géométrie : origine des parties, hauteur totale, zone et ancrage de la grille
      let (ax, ay, bx, by, H) = (x0, y0, 0pt, 0pt, 0pt)
      let zone = none // (x, y, largeur, hauteur) de la bande Seyès
      let ancre = 0pt
      if B == none {
        H = y0 + A.hauteur + p.boxsep + p.bottom + p.boxrule
        if p.height != auto { H = p.height }
        if seyes {
          zone = (p.boxrule, p.boxrule + ht, W - 2 * p.boxrule, H - 2 * p.boxrule - ht)
          // hauteur imposée : ancrage sur la 1re ligne (tikzmark), sinon sur la dernière (prevdepth)
          ancre = ay + if r.forced-height or p.height != auto { A.base1 } else { A.base2 }
        }
      } else if not cote {
        let milieu = y0 + A.hauteur + p.boxsep + p.middle // ligne de segmentation
        by = milieu + p.middle + p.boxsep
        bx = x0
        H = by + B.hauteur + p.boxsep + p.bottom + p.boxrule
        if p.height != auto { H = calc.max(H, p.height) }
        if seyes {
          if rep-haut {
            zone = (p.boxrule, p.boxrule + ht, W - 2 * p.boxrule, milieu - p.boxrule - ht)
            ancre = ay + A.base2
          } else {
            zone = (p.boxrule, milieu, W - 2 * p.boxrule, H - p.boxrule - milieu)
            ancre = by + B.base2
          }
        }
      } else {
        // côte à côte, parties centrées verticalement (sidebyside align=center)
        let hmax = calc.max(A.hauteur, B.hauteur)
        ay = y0 + (hmax - A.hauteur) / 2
        by = y0 + (hmax - B.hauteur) / 2
        bx = x0 + L + gap
        H = y0 + hmax + p.boxsep + p.bottom + p.boxrule
        let couture = x0 + L + gap / 2
        if seyes {
          if rep-haut {
            zone = (p.boxrule, p.boxrule + ht, couture - p.boxrule, H - 2 * p.boxrule - ht)
            ancre = ay + A.base1
          } else {
            zone = (couture, p.boxrule + ht, W - p.boxrule - couture, H - 2 * p.boxrule - ht)
            ancre = by + B.base1
          }
        }
      }

      // Région de la partie basse (bicolor) : (x, y, largeur, hauteur)
      let region-bas = if B == none { none } else if cote { (x0 + L + gap / 2, 0pt, W - x0 - L - gap / 2, H) } else {
        (0pt, by - p.boxsep - p.middle, W, H - by + p.boxsep + p.middle)
      }
      // Fond arrondi rogné à une région
      let fond-region(couleur, region) = {
        let (fx, fy, fw, fh) = region
        place(top + left, dx: fx, dy: fy, box(width: fw, height: fh, clip: true, place(
          top + left,
          dx: -fx,
          dy: -fy,
          rect(width: W, height: H, fill: couleur, stroke: none, radius: p.arc),
        )))
      }
      let dessin = {
        // fond (bicolor : partie haute seulement) et fond de la partie basse
        if p.fond-op > 0 {
          let fond = _opacite(p.fond, p.fond-op)
          if p.bicolor and region-bas != none {
            let (bx0, by0, _, _) = region-bas
            fond-region(fond, if cote { (0pt, 0pt, bx0, H) } else { (0pt, 0pt, W, by0) })
          } else {
            place(top + left, rect(width: W, height: H, fill: fond, stroke: none, radius: p.arc))
          }
        }
        if titre != none {
          fond-region(p.fond-titre, (0pt, 0pt, W, p.boxrule + ht))
          place(top + left, dx: p.boxrule + p.boxsep, dy: p.boxrule + p.boxsep, block(width: W - 2 * p.boxrule - 2 * p.boxsep, titre))
        }
        if p.fond-bas != none and region-bas != none and p.fond-bas-op > 0 {
          fond-region(_opacite(p.fond-bas, p.fond-bas-op), region-bas)
        }
        // lignes Seyès
        if zone != none {
          let (zx, zy, zw, zh) = zone
          place(top + left, dx: zx, dy: zy, _bande-seyes(zw, zh, ancre - zy, cols, geo: geo))
        }
        // contenus
        if A.rendu != none { place(top + left, dx: x0, dy: ay, A.rendu) }
        if B != none and B.rendu != none { place(top + left, dx: bx, dy: by, B.rendu) }
        // cadre
        if p.cadre-vu and p.boxrule > 0pt {
          place(top + left, dx: p.boxrule / 2, dy: p.boxrule / 2, rect(
            width: W - p.boxrule,
            height: H - p.boxrule,
            stroke: p.boxrule + p.cadre,
            radius: calc.max(0pt, p.arc - p.boxrule / 2),
          ))
        }
        // show crep num : voile blanc et numéro
        if num != none { _pastille(r, num, W, H, p.arc) }
      }
      block(width: W, height: H, breakable: false, dessin)
    }),
  )
}

/// \begin{crep}[options] réponse \end{crep} — et, avec \tcblower, deux parties :
/// `#crep(crep-mode: "lower")[énoncé][réponse]` ou `#crep(tcblower: [réponse])[énoncé]`.
#let crep(commande: "crep", ..args) = {
  crep-compteur.step()
  let local = _cles-locales("crep", args.named())
  let parties = args.pos()
  let bas = local.at("tcblower", default: none)
  if bas != none {
    let _ = local.remove("tcblower")
    parties = (parties.at(0, default: none), bas)
  }
  _crep(commande: commande, local: local, parties)
}

/// \begin{seyesrep}[options]{réponse} énoncé \end{seyesrep} : énoncé en haut, réponse Seyès en bas.
#let seyesrep(..options, reponse, enonce) = {
  let o = options.named()
  let styles = ("seyesrep style",) + {
    let s = o.at("style", default: ())
    if type(s) == str { (s,) } else { s }
  }
  let _ = o.remove("style", default: none)
  crep(commande: "seyesrep", ..o, style: styles, enonce, reponse)
}

/// \begin{assosbox}[options]{réponse} énoncé \end{assosbox} : case réponse à droite
/// (défaut, `box-right: 1.5cm`) ou à gauche (`box-left: 1.5cm`, ou `true`).
#let assosbox(box-right: auto, box-left: none, ..options, reponse, enonce) = {
  let o = options.named()
  for (cle, v) in (box-right: box-right, box-left: box-left) {
    if not (v in (auto, none, true, false) or type(v) == length) {
      panic("assosbox : valeur invalide pour la clé « " + cle + " » : " + repr(v) + ". Valeurs possibles : une longueur, true ou auto.")
    }
  }
  let styles = ("assosbox common style",) + {
    let s = o.at("style", default: ())
    if type(s) == str { (s,) } else { s }
  }
  let _ = o.remove("style", default: none)
  context {
    let teinte = xmix(_couleurs-seyes(reglages-courants(registre-crep), auto).at(0), 15)
    if box-left != none and box-left != false {
      let l = if box-left == auto or box-left == true { 1.5cm } else { box-left }
      let imposees = (
        crep-mode: "left",
        lefthand-width: l,
        halign: "center",
        halign-lower: "justify",
        colback: teinte,
        opacityback: 1,
        opacitybacklower: 0,
      )
      crep(commande: "assosbox", ..(imposees + o), style: styles, reponse, enonce)
    } else {
      let l = if box-right == auto or box-right == true { 1.5cm } else { box-right }
      let imposees = (
        crep-mode: "right",
        righthand-width: l,
        halign-lower: "center",
        opacityback: 0,
        colbacklower: teinte,
      )
      crep(commande: "assosbox", ..(imposees + o), style: styles, enonce, reponse)
    }
  }
}

// =====================================================================
// \dembox : étiquette de démonstration (Hypothèse, Conclusion…)
// =====================================================================

/// \dembox[options]{titre}{contenu} ; `demskin` : "regular", "compact" ou "fiche".
/// Clés : demskin, normal-dembox, normal-crep, width, halign, colback, opacityback, colframe, coltext,
/// coltitle, fonttitle, boxrule, top, bottom, left, right, title-boxsep, tick-length, corner-length.
#let _dembox(..options, titre, corps) = context {
  let o = options.named()
  if "largeur" in o { o.insert("width", o.remove("largeur")) } // ancien nom
  let r = reglages-resoudre(registre-crep, pour: "dembox", local: o, commande: "dembox")
  let rc = reglages-courants(registre-crep)
  let c-corr = bf-resoudre-couleur(crep-correction(rc).couleur)
  // normal dembox : noir quelle que soit la version, indépendamment de normal crep
  let noir = r.normal-crep or r.normal-dembox
  let c = _col(r.colframe, if noir { black } else { c-corr })
  let c-texte = _col(r.coltext, if noir { black } else { c-corr })
  let compact = r.demskin == "compact"
  let fiche = r.demskin == "fiche"
  // titre : \sffamily\bfseries\scriptsize (\tiny et coins arrondis de 1 mm pour « fiche »), boîte de la
  // couleur du cadre, boxsep 2pt
  let police-titre = if r.fonttitle == auto {
    (size: if fiche { "tiny" } else { "scriptsize" }, weight: "bold", sans: true)
  } else { r.fonttitle }
  let etiquette = box(fill: c, inset: r.title-boxsep, radius: if fiche { 1mm } else { 0pt }, _appliquer-police(
    police-titre,
    titre,
    couleur: _col(r.coltitle, white),
    sans-font: rc.sans-font,
  ))
  let e = measure(etiquette)
  let (g, d, t, b) = (if compact { e.width + r.left } else { r.left }, r.right, r.top, r.bottom)
  let trait = r.boxrule
  // regular : titre posé AU-DESSUS du cadre ; compact : dans le cadre ; fiche : à cheval sur le bord haut
  let haut-titre = if compact { 0pt } else if fiche { e.height / 2 } else { e.height }
  let haut-trait = _val(r.tick-length, if compact { 6mm } else { 4mm })
  let bords = _bords-texte()
  // Contenu : minipage alignée (centrée par défaut), première ligne à sa hauteur naturelle
  let ecrit = text(fill: c-texte, corps)
  let h1 = _hauteur(ecrit)
  let alignement = r.halign.replace("flush ", "")
  box(width: r.width, layout(taille => {
    let W = taille.width
    let bloc = block(width: W - g - d, {
      set align(if alignement == "left" { left } else if alignement == "right" { right } else if alignement == "justify" { left } else { center })
      set par(justify: true) if alignement == "justify"
      ecrit
    })
    let hc = measure(bloc).height - bords.haut + h1
    let H = haut-titre + t + hc + b
    let base = haut-titre + t + h1 // ligne de base de la première ligne, depuis le haut
    box(width: W, height: H, baseline: H - base, {
      place(top + left, dy: haut-titre, rect(width: W, height: H - haut-titre, fill: _opacite(_col(r.colback, black), r.opacityback)))
      place(top + left, dx: g, dy: haut-titre + t + h1 - bords.haut, bloc)
      // trait vertical en haut à gauche (équerre pour « fiche »), équerre en bas à droite
      place(top + left, line(
        start: (trait / 2, haut-titre),
        end: (trait / 2, haut-titre + haut-trait),
        stroke: trait + c,
      ))
      if fiche {
        place(top + left, line(
          start: (0pt, haut-titre + trait / 2),
          end: (haut-trait, haut-titre + trait / 2),
          stroke: trait + c,
        ))
      }
      place(top + left, line(start: (W - r.corner-length, H - trait / 2), end: (W - trait / 2, H - trait / 2), stroke: trait + c))
      place(top + left, line(start: (W - trait / 2, H), end: (W - trait / 2, H - r.corner-length), stroke: trait + c))
      place(top + left, dx: if fiche { haut-trait } else { 0pt }, etiquette)
    })
  }))
}

// Étiquetée : dans une zone Seyès, elle ne compte pas dans l'interligne (sauf sur la première et la
// dernière ligne, comme en LaTeX) ; sauter les lignes qu'elle occupe avec la clé `skip`.
#let dembox(..options, titre, corps) = context {
  let o = options.named()
  if "largeur" in o { o.insert("width", o.remove("largeur")) } // ancien nom
  let w = reglages-resoudre(registre-crep, pour: "dembox", local: o, commande: "dembox").width
  [#box(width: w, _dembox(..o, width: 100%, titre, corps))<bf-dembox>]
}

// =====================================================================
// \crepbox : boîte réponse Seyès précédée d'une étiquette à gauche
// =====================================================================

/// \crepbox[options]{largeur}{étiquette}{réponse} : une tccrep Seyès de la largeur donnée, dans un cadre
/// dont la partie gauche porte l'étiquette (tcbox en ligne, posée sur la ligne de base de la réponse).
/// Clés : lw, inner-left-sep, left-align, crep-style, colback (fond de l'étiquette), colframe (cadre),
/// coltext et fontupper (étiquette), boxrule, boxsep, arc, opacityback, opacityframe.
#let crepbox(..options, largeur, etiquette, corps) = {
  tccrep-compteur.step()
  metadata("bf-crep-cell") // repère lu par farfadet-tableaux : pas de marge verticale autour de la boîte
  context {
    let r = reglages-resoudre(registre-crep, pour: "crepbox", local: options.named(), commande: "crepbox")
    let rc = reglages-courants(registre-crep)
    let (br, bs, arc) = (r.boxrule, r.boxsep, r.arc)
    let isep = r.inner-left-sep.to-absolute()
    let etiq = _appliquer-police(r.fontupper, etiquette, couleur: _col(r.coltext, black), sans-font: rc.sans-font)
    let we = measure(etiq).width
    // largeur de la zone d'étiquette : lw, ou l'étiquette entre deux inner-left-sep (et le trait)
    let wl = if r.lw > 0pt { r.lw } else { isep + br + we + isep }
    let tw = calc.max(0pt, wl - br - 2 * isep)
    let al = if r.left-align == "left" { left } else if r.left-align == "right" { right } else { center }
    let p = _parametres-ligne("fixe", largeur, corps, commande: "crepbox", ..((seyes: true) + r.crep-style))
    let entoure(boite, w, h) = {
      let ho = h + 2 * (br + bs)
      let wo = wl + bs + w + br + bs
      let fond = _opacite(_col(r.colback, white), r.opacityback)
      let cadre = _opacite(_col(r.colframe, black), r.opacityframe)
      box(inset: (left: wl + bs, right: br + bs, top: br + bs, bottom: br + bs), {
        // fond de l'étiquette, puis cadre
        place(top + left, dx: -(wl + bs), dy: -(br + bs), rect(
          width: wl,
          height: ho,
          fill: fond,
          stroke: none,
          radius: (left: arc),
        ))
        place(top + left, dx: -(wl + bs) + br / 2, dy: -(br + bs) + br / 2, rect(
          width: wo - br,
          height: ho - br,
          stroke: br + cadre,
          radius: calc.max(0pt, arc - br / 2),
        ))
        // étiquette : ligne de base 1,25 mm sous le milieu de la boîte, centrée dans la zone
        place(top + left, dx: -(wl + bs) + br + isep, dy: -(br + bs) + ho / 2 + 1.25mm, box(width: tw, align(al, {
          set text(top-edge: "baseline", bottom-edge: "baseline")
          etiq
        })))
        set text(top-edge: "baseline", bottom-edge: "baseline")
        boite
      })
    }
    _rendu-ligne(p, entoure: entoure)
  }
}

// =====================================================================
// Petits outils
// =====================================================================

/// \seyesskip[n] : n × \baselineskip d'espace vertical.
/// Le marqueur `bf-seyesskip` signale à `_feuilles` une coupure (sinon l'espace vertical, mesuré comme un
/// élément en ligne, gonflait la première ligne de la zone Seyès).
#let seyesskip(n: 1) = [#metadata("bf-seyesskip")#context v(n * bf-lire(bf-interligne-p).baselineskip)]

/// Figure encadrée « Seyès » (style seyesfig de rdcrep).
/// Clés : title, boxrule, colframe, colback, arc, halign, valign, boxsep, top, bottom, left, right,
/// lefttitle, fonttitle, width, height.
#let seyesfig(..options, corps) = context {
  let o = options.named()
  if "titre" in o { o.insert("title", o.remove("titre")) } // ancien nom
  let r = reglages-resoudre(registre-crep, pour: "seyesfig", local: o, commande: "seyesfig")
  let rc = reglages-courants(registre-crep)
  let (col-a, col-b) = _couleurs-seyes(rc, auto)
  let al(a) = if a == "left" { left } else if a == "right" { right } else { center }
  let va(a) = if a == "top" { top } else if a == "bottom" { bottom } else { horizon }
  block(
    width: r.width,
    height: r.height,
    stroke: r.boxrule + _col(r.colframe, xmix(col-a, 90, autre: black)),
    fill: _col(r.colback, xmix(col-b, 10)),
    radius: r.arc,
    inset: (left: r.boxsep + r.left, right: r.boxsep + r.right, top: r.boxsep + r.top, bottom: r.boxsep + r.bottom),
    {
      if r.title != none {
        block(below: 0.5em, pad(left: r.lefttitle, _appliquer-police(r.fonttitle, r.title, sans-font: rc.sans-font)))
      }
      align(al(r.halign) + va(r.valign), corps)
    },
  )
}
