// boite.typ (farfadet-qcm, moteur) — boîte « à la tcolorbox » des QCM rdmcq.
//
// rdmcq compose ses zones (question, réponses) avec des boîtes tcolorbox réglées
// par des « styles tcb ». En Typst, un style tcb est un DICTIONNAIRE dont les clés reprennent les noms
// des options tcolorbox (espaces → tirets) : `(colback: red, boxrule: 1pt, arc: 2mm, rounded-corners: "north")`.
// Les styles s'empilent par fusion (`mcq-fusionner`) : la dernière couche l'emporte, comme `.append style`.
//
// Une valeur peut être une FONCTION `m => valeur` : elle est évaluée au moment du dessin avec les
// informations `m` de la boîte (numéro de question, de réponse, bonne réponse, mode correction…).
// C'est l'équivalent Typst de `\ifmcqbr`, `\ifmcqcor`, `\rdmcqQuestioncount` dans les formats LaTeX.
// Champs de `m` : question, answer, br, correction, boxrule, rowsep, orientation,
// counter-format ; pour `overlay`, `underlay` : en plus largeur et hauteur de la boîte.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: bf-resoudre-couleur, bf-est-nommee, bf-xcolor, xcouleur, reglages-verifier, reglages-controles, reglages-choix, reglages-ou

/// Police sans empattement de bfcours (`\sffamily`).
#let mcq-sans = ("Latin Modern Sans", "TeX Gyre Heros")

/// Tailles LaTeX relatives (classe 11 pt) : `\tiny`… `\large`, en `em`.
#let mcq-tailles = (
  tiny: 0.545em,
  scriptsize: 0.727em,
  footnotesize: 0.818em,
  small: 0.909em,
  normalsize: 1em,
  large: 1.091em,
  Large: 1.309em,
)

// ---------------------------------------------------------------------
// Vocabulaire : clés d'un style tcb et leurs contrôles
// ---------------------------------------------------------------------

#let _c = reglages-controles
#let _fonction = (v => type(v) == function, "une fonction m => valeur")
#let _avec-fonction(ctrl) = reglages-ou(ctrl, _fonction)
#let _coul = _avec-fonction(reglages-ou(_c.couleur, _c.texte, (v => v == none or v == auto, "none ou auto")))
#let _long = _avec-fonction(reglages-ou(_c.longueur, (v => v == auto, "auto")))
#let _opac = _avec-fonction((v => type(v) in (int, float) and v >= 0 and v <= 1, "un nombre entre 0 et 1"))
#let _cotes = ("all", "north", "south", "east", "west", "northwest", "northeast", "southwest", "southeast")
#let _halign = ("left", "center", "right", "justify", "flush left", "flush center", "flush right")
#let _contenu-ou-fonction = (v => v == none or type(v) in (content, str, function), "none, un contenu ou une fonction m => contenu")
#let _police = (
  v => v == none or type(v) in (dictionary, function),
  "none, un dictionnaire de réglages de texte (font, size, weight, style, fill…) ou une fonction corps => contenu",
)
#let _ombre = _avec-fonction((
  v => v == none or (type(v) == dictionary and v.keys().all(k => k in ("dx", "dy", "color", "arc"))),
  "none ou un dictionnaire (dx: 0pt, dy: 1mm, color: black)",
))

/// Contrôles des clés d'un style tcb (clé : (test, valeurs possibles)).
#let mcq-tcb-controles = (
  // couleurs et opacités
  colback: _coul,
  colframe: _coul,
  coltext: _coul,
  colupper: _coul,
  collower: _coul,
  colbacklower: _coul,
  coltitle: _coul,
  colbacktitle: _coul,
  opacityback: _opac,
  opacityframe: _opac,
  // cadre
  boxrule: _long,
  leftrule: _long,
  rightrule: _long,
  toprule: _long,
  bottomrule: _long,
  frame-hidden: _avec-fonction(_c.booleen),
  arc: _long,
  sharp-corners: _avec-fonction(reglages-ou(_c.booleen, reglages-choix(.._cotes))),
  rounded-corners: _avec-fonction(reglages-ou(reglages-choix(.._cotes), (v => v == none or v == auto, "none ou auto"))),
  // marges
  boxsep: _long,
  left: _long,
  right: _long,
  top: _long,
  bottom: _long,
  // alignements et polices
  halign: _avec-fonction(reglages-choix(.._halign)),
  halign-lower: _avec-fonction(reglages-ou(reglages-choix(.._halign), (v => v == auto, "auto"))),
  halign-title: _avec-fonction(reglages-choix(.._halign)),
  valign: _avec-fonction(reglages-choix("top", "center", "bottom")),
  fontupper: _police,
  fontlower: _police,
  fonttitle: _police,
  before-upper: _contenu-ou-fonction,
  after-upper: _contenu-ou-fonction,
  // titre
  title: _contenu-ou-fonction,
  toptitle: _long,
  bottomtitle: _long,
  lefttitle: _long,
  righttitle: _long,
  // côte à côte (sidebyside) : partie gauche `lefthand`, contenu à droite
  lefthand: _contenu-ou-fonction,
  lefthand-width: _long,
  sidebyside-gap: _long,
  // dessins
  shadow: _ombre,
  overlay: _contenu-ou-fonction,
  underlay: _contenu-ou-fonction,
  // dimensions et espacement (boîte englobante)
  width: _long,
  height: _long,
  before-skip: _long,
  after-skip: _long,
  breakable: _avec-fonction(_c.booleen),
)

/// Style de départ de toute boîte (`blankest` de tcolorbox) : ni cadre, ni fond, ni marge.
#let mcq-tcb-defauts = (
  colback: none,
  colframe: black,
  coltext: auto,
  colupper: auto,
  collower: auto,
  colbacklower: none,
  coltitle: white,
  colbacktitle: auto,
  opacityback: 1,
  opacityframe: 1,
  boxrule: 0pt,
  leftrule: auto,
  rightrule: auto,
  toprule: auto,
  bottomrule: auto,
  frame-hidden: false,
  arc: 0pt,
  sharp-corners: false,
  rounded-corners: auto,
  boxsep: 0pt,
  left: 0pt,
  right: 0pt,
  top: 0pt,
  bottom: 0pt,
  halign: "left",
  halign-lower: auto,
  halign-title: "left",
  valign: "top",
  fontupper: none,
  fontlower: none,
  fonttitle: none,
  before-upper: none,
  after-upper: none,
  title: none,
  toptitle: 0pt,
  bottomtitle: 0pt,
  lefttitle: 0pt,
  righttitle: 0pt,
  lefthand: none,
  lefthand-width: 2em,
  sidebyside-gap: 0pt,
  shadow: none,
  overlay: none,
  underlay: none,
  width: auto,
  height: auto,
  before-skip: 0pt,
  after-skip: 0pt,
  breakable: true,
)

/// Vérifie un style tcb (dictionnaire) : clé inconnue ou valeur invalide = erreur explicite. Ne renvoie rien
/// (s'emploie comme instruction dans un bloc de contenu).
#let mcq-verifier-style(commande, style) = {
  if type(style) != dictionary {
    panic(commande + " : un style tcb est un dictionnaire de clés tcolorbox, par exemple (colback: yellow, boxrule: 1pt) ; reçu : " + repr(style) + ".")
  }
  let _ = reglages-verifier(commande, style, mcq-tcb-controles)
}

// ---------------------------------------------------------------------
// Fusion des couches
// ---------------------------------------------------------------------

/// Couleur → expression utilisable par `xcolor` (pour remplacer `tcbcolback` dans « tcbcolback!60 »).
#let _vers-expr(c) = if type(c) == color { rgb(c).to-hex() } else if type(c) == str { c } else if bf-est-nommee(c) { c.bf-nommee } else { "white" }

/// Empile des styles tcb (la dernière couche l'emporte). `none` est ignoré.
/// Une couleur écrite « tcbcolback!60 » se calcule sur la couleur de fond de la couche précédente ; si
/// celle-ci n'a pas de fond (boîte « blank » de tcolorbox, dont l'intérieur n'est pas dessiné), il n'y en a
/// toujours pas.
#let mcq-fusionner(..couches) = {
  let res = (:)
  for c in couches.pos() {
    if c == none { continue }
    for (cle, valeur) in c {
      if type(valeur) == str and valeur.contains("tcbcolback") {
        let avant = res.at("colback", default: none)
        valeur = if avant == none { none } else { valeur.replace("tcbcolback", _vers-expr(avant)) }
      }
      res.insert(cle, valeur)
    }
  }
  res
}

// ---------------------------------------------------------------------
// Dessin
// ---------------------------------------------------------------------

/// Évalue une valeur de style (fonction `m => valeur` ou valeur).
#let _val(v, m) = if type(v) == function { v(m) } else { v }

/// Clés dont la valeur est naturellement une fonction (évaluée au dessin, pas à la résolution).
#let _cles-fonctions = ("fontupper", "fontlower", "fonttitle", "overlay", "underlay")

/// Style complet, chaque valeur évaluée pour `m`.
#let mcq-evaluer(s, m) = {
  let r = mcq-tcb-defauts + s
  for (cle, v) in r {
    if type(v) == function and cle not in _cles-fonctions { r.insert(cle, v(m)) }
  }
  r
}

/// Couleur d'un style : couleur Typst, expression xcolor ou marqueur de couleur nommée (`bf-nommee`).
#let _resoudre(c) = if c == none or c == auto { c } else if bf-est-nommee(c) { bf-xcolor(c, commande: "Mcq") } else { bf-resoudre-couleur(c) }

#let _opacifier(c, o) = {
  if c == none or o == 0 { return none }
  if o >= 1 or type(c) != color { return c }
  c.transparentize((1 - o) * 100%)
}

#let _police(p, corps) = if p == none { corps } else if type(p) == function { p(corps) } else { text(..p, corps) }

#let _align-h(h) = (
  left: left,
  center: center,
  right: right,
  justify: left,
  "flush left": left,
  "flush center": center,
  "flush right": right,
).at(h)

#let _align-v(v) = (top: top, center: horizon, bottom: bottom).at(v)

#let _aligner(h, corps) = {
  if h == "justify" { set par(justify: true); align(left, corps) } else {
    set par(justify: false)
    align(_align-h(h), corps)
  }
}

/// Rayons des coins d'après arc, sharp-corners et rounded-corners.
#let _rayons(s) = {
  let a = s.arc
  if a == 0pt { return 0pt }
  let coins = ("top-left", "top-right", "bottom-left", "bottom-right")
  let par-cote = (
    all: coins,
    north: ("top-left", "top-right"),
    south: ("bottom-left", "bottom-right"),
    east: ("top-right", "bottom-right"),
    west: ("top-left", "bottom-left"),
    northwest: ("top-left",),
    northeast: ("top-right",),
    southwest: ("bottom-left",),
    southeast: ("bottom-right",),
  )
  let ronds = if s.rounded-corners != auto {
    if s.rounded-corners == none { () } else { par-cote.at(s.rounded-corners) }
  } else if s.sharp-corners == true { () } else if s.sharp-corners == false { coins } else {
    coins.filter(c => c not in par-cote.at(s.sharp-corners))
  }
  let d = (:)
  for c in coins { d.insert(c, if c in ronds { a } else { 0pt }) }
  d
}

/// Épaisseurs des quatre côtés du cadre.
#let mcq-regles(s) = {
  let r(x) = if x == auto { s.boxrule } else { x }
  (left: r(s.leftrule), right: r(s.rightrule), top: r(s.toprule), bottom: r(s.bottomrule))
}

/// Marges intérieures totales (cadre + boxsep + left/right/top/bottom) d'un style évalué.
#let mcq-marges(s) = {
  let s = mcq-tcb-defauts + s
  let reg = mcq-regles(s)
  (
    left: reg.left + s.boxsep + s.left,
    right: reg.right + s.boxsep + s.right,
    top: reg.top + s.boxsep + s.top,
    bottom: reg.bottom + s.boxsep + s.bottom,
  )
}

/// Dessine une boîte. `s` : style tcb (fusionné) ; `largeur`, `hauteur` : dimensions imposées (longueurs
/// absolues ou auto) ; `m` : informations transmises aux valeurs-fonctions. À appeler dans un `context`.
#let mcq-boite(s, corps, largeur: auto, hauteur: auto, m: (:)) = {
  let s = mcq-evaluer(s, m)
  let largeur = if largeur == auto { s.width } else { largeur }
  let hauteur = if hauteur == auto { s.height } else { hauteur }
  let fond = _opacifier(_resoudre(s.colback), s.opacityback)
  let cadre = _opacifier(_resoudre(s.colframe), s.opacityframe)
  let reg = mcq-regles(s)
  let trait(e) = if s.frame-hidden or cadre == none or e <= 0pt { none } else { (paint: cadre, thickness: e) }
  let contour = (left: trait(reg.left), right: trait(reg.right), top: trait(reg.top), bottom: trait(reg.bottom))
  // le cadre tcolorbox est intérieur à la boîte : on recule le trait d'une demi-épaisseur
  let retrait = (left: -reg.left / 2, right: -reg.right / 2, top: -reg.top / 2, bottom: -reg.bottom / 2)
  let rayons = _rayons(s)
  let couleur-texte = _resoudre(if s.colupper != auto { s.colupper } else { s.coltext })
  let couleur-bas = _resoudre(s.collower)
  // contenu : avant / corps / après, éventuellement côte à côte
  let haut = [#_val(s.before-upper, m)#corps#_val(s.after-upper, m)]
  let interieur = if s.lefthand != none {
    let gauche = _val(s.lefthand, m)
    let droite = {
      let d = _police(s.fontlower, haut)
      if couleur-bas != auto and couleur-bas != none { d = text(fill: couleur-bas, d) }
      _aligner(if s.halign-lower == auto { s.halign } else { s.halign-lower }, d)
    }
    grid(
      columns: (s.lefthand-width, 1fr),
      column-gutter: s.sidebyside-gap,
      align: top,
      _aligner(s.halign, _police(s.fontupper, gauche)), droite,
    )
  } else { _aligner(s.halign, _police(s.fontupper, haut)) }
  if couleur-texte != auto and couleur-texte != none { interieur = text(fill: couleur-texte, interieur) }
  let marges = (
    left: reg.left + s.boxsep + s.left,
    right: reg.right + s.boxsep + s.right,
    top: reg.top + s.boxsep + s.top,
    bottom: reg.bottom + s.boxsep + s.bottom,
  )
  // titre éventuel (bande en haut de la boîte, couleur du cadre par défaut)
  let titre = _val(s.title, m)
  let fond-titre = _resoudre(if s.colbacktitle == auto { s.colframe } else { s.colbacktitle })
  let bande-titre = if titre != none {
    block(
      width: 100%,
      fill: fond-titre,
      inset: (
        left: marges.left - s.left + s.lefttitle,
        right: marges.right - s.right + s.righttitle,
        top: reg.top + s.boxsep + s.toptitle,
        bottom: s.boxsep + s.bottomtitle,
      ),
      above: 0pt,
      below: 0pt,
      text(fill: _resoudre(s.coltitle), _aligner(s.halign-title, _police(s.fonttitle, titre))),
    )
  }
  let dessins = s.overlay != none or s.underlay != none or s.shadow != none or s.colbacklower != none
  let construire(h, m2, dessiner: true) = {
    let sous = if s.underlay != none or s.colbacklower != none {
      // fond de la partie droite (bicolor) puis dessous utilisateur, dans le repère du cadre
      let x0 = marges.left + s.lefthand-width + s.sidebyside-gap / 2
      place(top + left, dx: 0pt, dy: 0pt, {
        if dessiner and s.colbacklower != none {
          place(top + left, dx: x0, rect(width: m2.largeur - x0, height: m2.hauteur, fill: _resoudre(s.colbacklower), stroke: none))
        }
        if dessiner and s.underlay != none { place(top + left, (s.underlay)(m2)) }
      })
    }
    let valign = _align-v(s.valign)
    if titre == none {
      block(
        width: largeur,
        height: h,
        fill: fond,
        stroke: contour,
        outset: retrait,
        radius: rayons,
        clip: dessins,
        inset: if dessins { 0pt } else { marges },
        above: 0pt,
        below: 0pt,
        breakable: false,
        if dessins {
          sous
          block(width: 100%, height: if h == auto { auto } else { 100% }, inset: marges, above: 0pt, below: 0pt, align(valign, interieur))
        } else { align(valign, interieur) },
      )
    } else {
      block(
        width: largeur,
        height: h,
        fill: fond,
        stroke: contour,
        outset: retrait,
        radius: rayons,
        clip: true,
        above: 0pt,
        below: 0pt,
        breakable: false,
        {
          sous
          grid(
            rows: (auto, if h == auto { auto } else { 1fr }),
            bande-titre,
            block(
              width: 100%,
              height: if h == auto { auto } else { 100% },
              inset: marges + (top: s.top + s.boxsep),
              above: 0pt,
              below: 0pt,
              align(valign, interieur),
            ),
          )
        },
      )
    }
  }
  let b = construire(hauteur, m, dessiner: false)
  if not dessins { return b }
  // seconde passe : les dessins connaissent la taille finale de la boîte
  let taille = measure(b, width: if type(largeur) == length { largeur } else { auto })
  let h = if hauteur == auto { taille.height } else { hauteur }
  let l = if type(largeur) == length { largeur } else { taille.width }
  let m2 = m + (largeur: l, hauteur: h)
  let final = construire(h, m2)
  if s.shadow == none and s.overlay == none { return final }
  let o = s.shadow
  // ombre sous la boîte, dessus (overlay) au-dessus et NON rogné (comme `overlay` de tcolorbox)
  block(width: l, height: h, above: 0pt, below: 0pt, breakable: false, {
    if o != none {
      place(top + left, dx: o.at("dx", default: 0pt), dy: o.at("dy", default: 1mm), block(
        width: l,
        height: h,
        radius: rayons,
        fill: _opacifier(_resoudre(o.at("color", default: black)), 0.5),
      ))
    }
    place(top + left, final)
    if s.overlay != none { place(top + left, (s.overlay)(m2)) }
  })
}
