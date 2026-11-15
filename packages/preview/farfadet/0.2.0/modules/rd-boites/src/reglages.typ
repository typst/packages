// reglages.typ (rdboites) — personnalisation des boîtes (module `rd`).
//
// Un seul registre (`_R`, état « bfr-rd ») décrit TOUTES les clés de toutes les boîtes, par le mécanisme
// générique de farfadet-socle (`reglages-paquet`). Un « type » est une boîte (`zone`, `cours`, `attention`…).
//
// Priorité (unique pour tous les paquets bfcours) :
//   clé locale > style nommé > réglage du type > réglage global > défaut du paquet
//
// Les noms de clés sont ceux de tcolorbox quand la boîte les prend en option
// (`colframe`, `colback`, `coltext`, `coltitle`, `colbacktitle`, `colbacklower`, `arc`, `boxrule`,
// `leftrule`, `width`, `height`, `halign`, `valign`, `left`, `right`, `top`, `bottom`, `toptitle`,
// `ltitle-width`, `raster-columns`, `raster-column-skip`, `raster-row-skip`, `before-skip`, `after-skip`,
// `title`…), avec des tirets à la place des espaces. Les autres clés (`ombre`, `graine`, `lateral`…) sont
// des ajouts propres à ce paquet.
//
// Les valeurs par défaut sont celles du rendu standard des boîtes.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-regler, reglages-definir-style, reglages-reinitialiser, reglages-resoudre,
  reglages-controles, reglages-choix, reglages-ou, reglages-liste, bf-resoudre-couleur, reglages-regler-types,
)
#import "rd-outils.typ" as o

// =====================================================================
// Contrôles de valeurs
// =====================================================================

#let _coul = reglages-ou(reglages-controles.couleur-ou-nom, reglages-choix(none))
#let _lg = reglages-controles.longueur
#let _lg-auto = reglages-ou(reglages-controles.longueur, reglages-choix(none))
#let _align = (v => type(v) == alignment, "un alignement (left, center, right, top, horizon, bottom)")

#let _controles = (
  // couleurs
  colframe: _coul,
  colback: _coul,
  coltext: _coul,
  coltitle: _coul,
  colbacktitle: _coul,
  colbacklower: _coul,
  color: _coul,
  colframe-fin: _coul,
  ruban: _coul,
  colliquid: _coul,
  couleur-grille: _coul,
  couleur-coche: _coul,
  couleur-bord: _coul,
  icone-fill: _coul,
  icone-contour: _coul,
  sub-color: _coul,
  // longueurs
  width: _lg,
  height: _lg-auto,
  height-min: _lg-auto,
  arc: _lg,
  boxrule: _lg,
  leftrule: _lg,
  left: _lg,
  right: _lg,
  top: _lg,
  bottom: _lg,
  toptitle: _lg,
  ltitle-width: _lg-auto,
  raster-column-skip: _lg,
  raster-row-skip: _lg,
  before-skip: _lg,
  after-skip: _lg,
  // alignements
  halign: _align,
  valign: _align,
  sub-align: _align,
  coin: _align,
  // choix
  type: reglages-choix("file", "classroom"),
  // textes et polices
  police-sans: reglages-controles.texte,
  police-titre: reglages-controles.texte,
  police-manuscrite: reglages-controles.texte,
)

// =====================================================================
// Défauts : communs (global) puis propres à chaque boîte
// =====================================================================

#let _P = o.palette
#let _pale = o.pale
#let _gris10 = o.pale(o.gris, 10)
#let _noir75 = o.pale(black, 75)

#let _defauts = (
  police-sans: o.sans,
  police-titre: o.police-titre,
  police-manuscrite: o.police-manuscrite,
  before-skip: o.espace,
  after-skip: o.espace,
  taille-notes: o.t-notes,
  taille-script: o.t-script,
  rayon-point: 1.75pt,
)

// Bandeau de titre plein largeur : scratchuse, mydoc, schemamainlevee, etiquette.
#let _titree(colframe, colback, extra: (:)) = (
  colframe: colframe,
  colback: colback,
  coltitle: white,
  colbacktitle: auto,
  coltext: auto,
  arc: 1mm,
  boxrule: 0.4pt,
  width: 100%,
  halign: left,
  fonttitle-size: 1em,
  // boxsep 7 pt et toptitle -5 pt : 2 pt autour du titre ; boxsep 7 pt autour du corps
  toptitle: 2pt,
  left: 7pt,
  right: 7pt,
  top: 7pt,
  bottom: 7pt,
  justify: false,
) + extra

// Boîtes à onglet vertical : formula, myformule, rappelbox.
#let _formule(etiquette) = (
  colframe: black,
  colback: auto,
  colbacktitle: auto,
  coltitle: white,
  coltext: black,
  etiquette: etiquette,
  width: 100%,
  tab-width: 4mm,
  boxrule: 0.4pt,
  arc: 1pt,
  // \tiny (6 pt pour un corps de 11 pt) ; réduite automatiquement si l'onglet est trop court
  fonttitle-size: 0.55em,
)

#let _types = (
  // --- simples -------------------------------------------------------
  attention: (
    colframe: _P.alerte,
    colback: auto,
    coltext: auto,
    leftrule: 12mm,
    boxrule: 0.5mm,
    width: 100%,
    height-min: 14mm,
    top: 3.5mm,
    right: 4mm,
    icone: true,
    icone-size: 8mm,
    icone-fill: rgb("#FF8000"),
    icone-contour: rgb("#5A2600"),
  ),
  regularcell: (
    colframe: black,
    colback: white,
    coltext: auto,
    // coins vifs (sharp corners) ; seule la grille regulartcbitemize arrondit ses cellules
    arc: 0pt,
    boxrule: 0.6pt,
    boxsep: 3pt,
    width: auto,
    height: auto,
    halign: center,
    valign: horizon,
  ),
  regulartcbitemize: (
    colframe: black,
    colback: white,
    coltext: auto,
    arc: 2mm,
    boxrule: 0.6pt,
    boxsep: 3pt,
    raster-column-skip: 2mm,
    raster-row-skip: 2mm,
    width: 100%,
    halign: center,
    valign: horizon,
  ),
  scratchuse: _titree(_P.scratch, auto),
  mydoc: _titree(_noir75, _gris10),
  schemamainlevee: _titree(_noir75, _gris10, extra: (fonttitle-size: 0.8em, toptitle: 3pt, left: 3pt, right: 3pt, top: 3pt, bottom: 3pt, height: auto)),
  // réglages par défaut de tcolorbox : boxsep 1 mm, left/right 4 mm, top/bottom 2 mm, cadre 0,5 mm ; titre à gauche
  etiquette: _titree(black, _gris10, extra: (width: 5.5cm, boxrule: 0.5mm, arc: 2mm, halign: left, toptitle: 1mm, left: 5mm, right: 5mm, top: 3mm, bottom: 3mm, justify: true)),
  encadreOB: (
    colback: _gris10,
    coltext: auto,
    width: 100%,
    boxsep: 3pt,
    ombre: true,
    // fuzzy shadow={4pt}{-4pt}{0mm}{1pt}{black}
    ombre-decalage: 4pt,
    ombre-flou: 1.4pt,
    ombre-opacite: 35%,
    ombre-couleur: black,
  ),
  encadre: (colback: _gris10, colframe: _noir75, coltext: auto, arc: 1mm, boxrule: 0.4pt, boxsep: 7pt, width: 100%),
  encadregrille: (
    colback: _pale(black, 5),
    colframe: _noir75,
    coltext: auto,
    arc: 1mm,
    boxrule: 0.4pt,
    boxsep: 5pt,
    width: 100%,
    height: auto,
    pas: 7.5mm,
    couleur-grille: o.gris,
    epaisseur-grille: 0.4pt,
    style-grille: "densely-dashed",
  ),
  entete: (
    colframe: black,
    colback: auto,
    coltext: auto,
    width: 100%,
    // boxsep 1 mm + left/right 4 mm, top/bottom 2 mm
    left: 5mm,
    right: 5mm,
    top: 3mm,
    bottom: 3mm + o.jambage,
    rule-width: 1.5pt,
  ),
  zone: (
    colframe: _P.zone,
    colback: none,
    coltitle: white,
    colbacktitle: auto,
    coltext: auto,
    arc: 5pt,
    boxrule: 1pt,
    width: 100%,
    halign: center,
    // boxsep 0, top et bottom 0 : le texte suit le bandeau
    toptitle: 0pt,
    left: 5pt,
    right: 5pt,
    top: 1pt,
    bottom: 1pt,
  ),
  ficheno: (
    colframe: _P.fiche,
    colback: none,
    coltext: _P.fiche-texte,
    coltitle: white,
    colbacktitle: auto,
    arc: 2mm,
    boxrule: 0.5mm,
    width: 7cm,
    halign: center,
    toptitle: 2.2pt,
    fonttitle-size: o.t-notes,
    numero: auto,
    etiquette: [Fiche n#super[o]~],
  ),
  exemplerealisation: (
    colframe: _P.ggb,
    colback: none,
    coltext: auto,
    coltitle: white,
    colbacktitle: auto,
    arc: 3mm,
    boxrule: 0.4pt,
    width: 100%,
    cible: none,
    lateral: none,
    largeur-lateral: 3cm,
    numero: auto,
  ),
  domino: (colframe: black, colback: white, coltext: auto, arc: 1mm, boxrule: 0.8pt, boxsep: 5pt, width: 100%, ombre: true),
  formula: _formule([Formule]),
  myformule: _formule([Formule]),
  rappelbox: _formule([Rappel]),
  miniexemple: (colframe: o.gris, colback: _pale(o.gris, 15), coltext: auto, boxrule: 1pt, width: 100%, left: 4mm, right: 4mm, top: 3mm, bottom: 3mm),
  exem: (colframe: _noir75, colback: _gris10, coltext: auto, boxrule: 0.6pt, width: 100%, left: 6pt, right: 6pt, top: 2mm, bottom: 2mm, title: [Exemple]),
  boiteprog: (colframe: black, colback: _pale(o.gris, 5), coltext: auto, leftrule: 2pt, width: 100%, fonttitle-size: 0.9em),
  casio: (
    // cadre « vertcasio », fond et étiquette dans le vert « casiocolor »
    colframe: rgb(68, 115, 109),
    colback: _pale(_P.casio, 25),
    coltext: auto,
    coltitle: _pale(_P.casio, 50),
    leftrule: 2em,
    boxrule: 0.5mm,
    width: 100%,
    etiquette: [Calculatrice],
  ),
  alignbox: (width: auto, height: auto, halign: center, valign: horizon, boxsep: 0pt),
  centragebox: (width: auto, height: auto, halign: center, valign: horizon),
  tcalignbox: (width: auto, height: auto, halign: center, valign: horizon),
  blankbox: (width: auto, height: auto, halign: center, valign: horizon),
  figbox: (width: auto, height: auto, title: none, halign: center, valign: horizon),
  tcwhite: (colback: white, opacityback: 70%, arc: 2mm, boxsep: 3pt),
  tcencadre: (colback: _gris10, colframe: _noir75, arc: 1mm, boxrule: 0.4pt, left: 7pt, right: 7pt, top: 7pt, bottom: 7pt),
  // --- moyennes ------------------------------------------------------
  cours: (
    colframe: black,
    colframe-fin: o.gris,
    colback: _gris10,
    coltitle: white,
    coltext: auto,
    arc: 2mm,
    width: 100%,
    left: 15pt + 1mm,
    right: 1mm,
    puce: $bullet$,
  ),
  exemple: (
    // leftrule 2 mm + boxsep 1 mm + left 7 pt ; top (sous la pastille) 1,5 mm + 1 mm ; bottom 2 mm + 1 mm
    colframe: o.gris,
    colback: none,
    opacityback: 100%,
    colbacktitle: auto,
    coltitle: white,
    coltext: auto,
    rule-width: 1pt,
    width: 100%,
    left: 2mm + 1mm + 7pt,
    right: 1mm + 7pt,
    top: 2.5mm,
    bottom: 3mm,
    title: [Exemple(s)],
    decale: false,
  ),
  exemplereduit: (
    colframe: o.gris,
    colback: none,
    opacityback: 100%,
    colbacktitle: auto,
    coltitle: white,
    coltext: auto,
    rule-width: 1pt,
    width: 8cm,
    left: 2mm + 1mm + 7pt,
    right: 1mm + 7pt,
    top: 1mm,
    bottom: 3mm,
    title: [Exemple(s)],
    decale: true,
  ),
  // left/right 2 mm, top/bottom 1 mm, plus le boxsep de 1 mm (et 0,5 mm de filet réservé en haut et en bas)
  coinpli: (colframe: black, colback: _gris10, coltext: auto, boxrule: 0.6pt, width: 100%, pli: 4mm, left: 3mm, right: 3mm, top: 2.5mm, bottom: 2.5mm),
  tccoinpli: (colframe: black, colback: _gris10, coltext: auto, boxrule: 0.6pt, pli: 4mm, left: 3mm, right: 3mm, top: 2.5mm, bottom: 2.5mm),
  tornpage: (
    colback: _P.papier,
    colframe: auto,
    coltext: auto,
    width: 100%,
    graine: 1,
    ombre: true,
    pas: 2.2pt,
    amplitude: 1pt,
    left: 5mm,
    right: 5mm,
    top: 3mm,
    bottom: 3mm,
  ),
  parchemin: (
    colback: auto,
    colframe: auto,
    coltext: auto,
    width: 100%,
    graine: 7,
    ombre: true,
    pas: 2.2pt,
    amplitude: 1pt,
    // boxsep 3 pt, left/right/top/bottom 0
    left: 3pt,
    right: 3pt,
    top: 3pt,
    bottom: 3pt,
  ),
  dottedbox: (colback: _pale(black, 5), coltext: auto, boxsep: 3pt, width: 100%),
  dottedleftbox: (colback: _gris10, coltext: auto, boxsep: 3pt, anchor-width: 1.5em, sidebyside-gap: 6pt, width: 100%),
  dottedrightbox: (colback: _gris10, coltext: auto, boxsep: 3pt, anchor-width: 1.5em, sidebyside-gap: 6pt, width: 100%),
  leftpoint: (boxsep: 3pt, anchor-width: 1.5em, width: 100%),
  rightpoint: (boxsep: 3pt, anchor-width: 1.5em, width: 100%),
  boxpointlignesrep: (colframe: red, boxrule: 1pt, visible: auto),
  acocher: (
    colframe: _noir75,
    colback: auto,
    coltext: auto,
    arc: 1mm,
    boxrule: 0.4pt,
    // colonne de gauche : boxsep 2 pt + 0,8 em + moitié de l'écart de 8 pt
    leftrule: 0.8em + 6pt,
    width: 100%,
    juste: false,
    couleur-coche: red,
    // nobeforeafter : les propositions successives se touchent presque
    before-skip: 2pt,
    after-skip: 2pt,
  ),
  casesvf: (couleur-coche: red, coche-size: 3.4mm, reponse: none),
  listecocher: (column-gap: 4mm, br: none, couleur-coche: red),
  helpblock: (
    colframe: _P.aide,
    colback: auto,
    coltitle: white,
    coltext: auto,
    arc: 1mm,
    boxrule: 0.5mm,
    leftrule: 6mm,
    width: 100%,
    largeur-gauche: 3cm,
    etiquette: [Aide],
  ),
  // nobeforeafter : les items isolés s'empilent presque sans espace
  mytcbitembox: (colback: _gris10, coltext: auto, lefthand-width: 1.8em, boxsep: 5pt, sidebyside-gap: 10pt, numero: auto, before-skip: 1mm, after-skip: 1mm),
  mytcbitemize: (
    colback: _gris10,
    coltext: auto,
    raster-columns: 1,
    raster-column-skip: 4mm,
    raster-row-skip: 2.5mm,
    lefthand-width: 1.8em,
    boxsep: 5pt,
    sidebyside-gap: 10pt,
    depart: 1,
    width: 100%,
  ),
  ltitlebox: (
    colframe: black,
    colback: _pale(black, 20),
    colbacktitle: _noir75,
    coltitle: white,
    coltext: black,
    arc: 1pt,
    boxrule: 0.6pt,
    width: 100%,
    ltitle-width: auto,
    top: 3pt,
    bottom: 3pt,
    right: 3pt,
  ),
  opbox: (opbox-fill-color: _gris10, coltext: auto, width: 100%, bottom: 1cm, solution: none),
  cinema: (colframe: black, colback: none, coltext: auto, width: 100%, band-height: 5mm, perforation: white, perforation-pitch: 5mm, perforation-width: 2mm, perforation-height: 3mm),
  vf: (
    colframe: black,
    colback: white,
    colbacklower: _pale(black, 20),
    colbacktitle: black,
    coltitle: white,
    coltext: auto,
    boxrule: 0.7pt,
    righthand-width: 2.2cm,
    width: 100%,
    height-min: 1.5cm,
    left: 0.5cm + 7pt,
    reponse: none,
    couleur-coche: red,
  ),
  jourleague: (colframe: black, colbacktitle: _pale(black, 25), coltitle: white, coltext: auto, boxrule: 0.6pt, width: 5cm),
  thermobox: (colframe: _P.thermo, colback: _P.thermo-clair, colliquid: _P.thermo-moyen, boxrule: 1pt, arc: 3pt, niveau: 60%, width: 1.5cm, height: 3cm),
  progbox: (colframe: _P.prog-cadre, colback: _P.prog-interieur, coltext: auto, arc: 3mm, boxrule: 1pt, width: 100%, ombre: true),
  // rouge pur de xcolor (le `red` de Typst est un rouge orangé) ; fond black!5, arc intérieur 0,5 mm
  corrdembox: (colframe: rgb(255, 0, 0), colback: _pale(black, 5), coltitle: white, coltext: auto, arc: 0.5mm, width: 100%, visible: auto),
  scratchblock: (colframe: auto, colback: white, colbacktitle: _pale(black, 10), coltitle: auto, arc: 1mm, boxrule: 2pt, label: [Programme]),
  scratchblockenv: (colframe: auto, colback: white, colbacktitle: _pale(black, 10), coltitle: auto, arc: 1mm, boxrule: 2pt, width: 100%, label: [Programme]),
  scratchfig: (colframe: auto, colback: _P.scratch-figure-fond, colbacktitle: _P.scratch-figure, coltitle: auto, arc: 1mm, boxrule: 0.4pt, width: auto, label: [Figure]),
  scratchfigbox: (colframe: auto, colback: _P.scratch-figure-fond, colbacktitle: _P.scratch-figure, coltitle: auto, arc: 1mm, boxrule: 0.4pt, width: auto, label: [Figure]),
  scratchcapture: (colframe: _P.scratch-capture, colback: white, colbacktitle: auto, arc: 0pt, boxrule: 0.4pt, width: 100%, height: auto, label: [Image]),
  mylink: (
    colframe: _P.lien-cadre,
    colback: _P.lien-fond,
    coltext: _P.lien-texte,
    arc: 3pt,
    boxrule: 0.5pt,
    etiquette: [Aide en ligne],
    label-width: 2.7cm,
  ),
  partieDNB: (colback: _pale(black, 15), boxsep: 0pt, ombre: true, label: [Partie ]),
  "sans-coin": (
    colframe: blue.darken(30%),
    colback: blue.lighten(92%),
    coltext: auto,
    arc: 2pt,
    boxrule: 1.2pt,
    width: 100%,
    coin: top + left,
    title: none,
    trou: 8pt,
  ),
  // --- fortes --------------------------------------------------------
  methode: (colframe: black, coltitle: white, coltext: auto, width: 100%, title: [Méthode], sep-title: 1em, tab-height: 0.8cm, ribbon-height: 0.1cm),
  tache: (
    colframe: _P.tache-cadre,
    colback: _P.tache-fond,
    ruban: _P.tache-etiquette,
    coltitle: white,
    coltext: auto,
    arc: 3mm,
    // le cadre n'est pas dessiné (frame engine=empty) : `colframe` ne sert qu'avec un `boxrule` positif
    boxrule: 0pt,
    width: 100%,
    ombre: true,
  ),
  designbox: (
    color: auto,
    colframe: black,
    colback: black,
    coltitle: white,
    coltext: auto,
    arc: 2mm,
    boxrule: 1pt,
    width: 100%,
    flat: true,
    shadow-title: true,
    sub-align: left,
    sub-color: black,
    sous-texte: none,
  ),
  ggbentrainer: (
    colframe: _P.ggb,
    coltext: auto,
    arc: 2mm,
    boxrule: 0.5mm,
    width: 100%,
    title: [S'entraîner],
    sous-titre: [en autonomie],
    largeur-droite: 10cm,
  ),
  ggbqr: (colframe: _P.ggb, height: 2cm, type: "file", capture: none, qr: none),
  ggbqrenv: (colframe: _P.ggb, height: 2cm, type: "file", capture: none, qr: none, width: 100%),
)

// Types dont les clés `boxsep`, `fonttitle-size`, `justify`… ne figurent pas dans tous les dictionnaires
// ci-dessus : les contrôles de ces clés sont déduits de leurs valeurs par défaut.

// Styles prédéfinis : crochets vides (encadreOB, mydoc, schemamainleveetyle,
// designboxstyle : appliqués automatiquement par la boîte du même nom), `exemplewithinterior` et `br`.
#let _styles-initiaux = (
  encadreOB: (:),
  mydoc: (:),
  schemamainleveetyle: (:),
  designboxstyle: (:),
  // sans `top` : la marge haute de 3,5 mm faisait passer la première ligne sous la pastille « exemple(s) »
  exemplewithinterior: (colback: white, opacityback: 60%),
  br: (juste: true),
)

/// Le registre de réglages du module `rd` (interne : utiliser `setrdboites`).
#let _R = reglages-paquet("rd", _defauts, controles: _controles, types: _types, commande: "setrdboites", styles: _styles-initiaux)

// Crochet automatique : nom de la boîte -> nom du style appliqué d'office.
#let _crochets = (
  encadreOB: "encadreOB",
  mydoc: "mydoc",
  schemamainlevee: "schemamainleveetyle",
  designbox: "designboxstyle",
)

// =====================================================================
// Résolution (à appeler dans un `context`)
// =====================================================================

/// Valeurs effectives des clés de la boîte `pour`, à partir des arguments nommés de l'appel (`args`).
/// Valide les clés (message explicite) et résout les couleurs données par un nom xcolor.
#let resoudre-rd(pour, args) = {
  if args.pos().len() > 0 {
    panic(pour + " : argument positionnel inattendu : " + repr(args.pos().first()) + ".")
  }
  let l = (:)
  for (k, v) in args.named() { if v != auto { l.insert(k, v) } }
  let hook = _crochets.at(pour, default: none)
  if hook != none and hook in _socle.bf-lire(_R).styles {
    let s = l.at("style", default: ())
    l.insert("style", (hook,) + (if type(s) == str { (s,) } else { s }))
  }
  let r = reglages-resoudre(_R, pour: pour, local: l, commande: pour)
  let defs = _R.defauts + _R.types.at(pour)
  for (k, v) in r {
    if type(v) == str and (k.starts-with("col") or type(defs.at(k, default: none)) == color) {
      r.insert(k, bf-resoudre-couleur(v))
    }
  }
  r
}

/// Même chose, à partir d'un dictionnaire de clés locales déjà construit.
#let resoudre-rd-dico(pour, dico) = resoudre-rd(pour, arguments(..dico))

/// Valeurs effectives des seules clés GLOBALES (polices, espaces, rayon des points…), à appeler dans un `context`.
#let resoudre-rd-global() = reglages-resoudre(_R, pour: none, commande: "setrdboites")

/// Dictionnaire des clés d'une boîte et de leurs valeurs par défaut (sans `context`) : sert à découvrir
/// ce qu'on peut régler. Sans `pour`, ce sont les clés communes à toutes les boîtes.
///
/// ```typ
/// #cles-rd(pour: "zone")
/// ```
///
/// - pour (none, str): nom de la boîte (`"zone"`, `"cours"`…).
/// -> dictionary
#let cles-rd(pour: none) = {
  if pour == none { _R.defauts } else {
    if pour not in _R.types {
      panic("cles-rd : boîte inconnue « " + str(pour) + " ». Boîtes possibles : " + reglages-liste(_R.types.keys()) + ".")
    }
    _R.defauts + _R.types.at(pour)
  }
}

// =====================================================================
// Écriture : l'unique setter `setrdboites`
// =====================================================================

/// Règle les boîtes pour la suite du document : réglage global, réglage d'une ou de plusieurs
/// boîtes, définition d'un style nommé, remise à zéro. Un seul setter, de signature commune à tous les
/// paquets bfcours.
///
/// | Appel | Effet |
/// |---|---|
/// | `setrdboites(colframe: red)` | réglage global : toutes les boîtes qui ont la clé |
/// | `setrdboites(pour: "zone", arc: 0pt)` | réglage d'une boîte (ou d'un tableau de boîtes) |
/// | `setrdboites(definir: "sobre", arc: 0pt)` | définit le style nommé « sobre », appelé par `style: "sobre"` |
/// | `setrdboites(reinitialiser: true)` | oublie les réglages global et par boîte (styles gardés) |
/// | `setrdboites(reinitialiser: "tout")` | idem, et ramène les styles aux cinq styles prédéfinis |
///
/// Avec des clés, `reinitialiser` repart d'abord des défauts puis applique les clés. La priorité est :
/// clé locale, puis style nommé, puis réglage de la boîte, puis réglage global, puis défaut.
///
/// ```typ
/// #setrdboites(police-sans: "Latin Modern Sans", before-skip: 1em)
/// #setrdboites(pour: "zone", colframe: rgb("#2a9d8f"))
/// #setrdboites(pour: ("zone", "cours"), arc: 0pt)
/// #setrdboites(definir: "discret", colframe: gray, colback: white)
/// ```
///
/// - pour (none, str, array): nom de la boîte à régler (`"zone"`, `"cours"`…) ou tableau de noms ; `none` : réglage global. Avec `definir`, réserve le style à une boîte (contrôle des clés).
/// - reinitialiser (bool, str): `true` repart des défauts (styles gardés) ; `"tout"` ramène aussi les styles aux styles prédéfinis.
/// - definir (none, str): nom du style à définir ; les clés deviennent le contenu du style.
/// - cles (arguments): les clés (`colframe: …`, `arc: …`, `style: "mon-style"`…). Voir `cles-rd()`.
/// -> content
#let setrdboites(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (false, true, "tout") {
    panic("setrdboites : `reinitialiser` attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none {
    if reinitialiser != false {
      panic("setrdboites : `definir` et `reinitialiser` ne se combinent pas (deux appels).")
    }
    reglages-definir-style(_R, definir, pour: pour, commande: "setrdboites", ..cles)
  } else if reinitialiser == "tout" {
    reglages-reinitialiser(_R, styles: true)
    if pour != none or cles.named().len() > 0 or cles.pos().len() > 0 {
      reglages-regler(_R, pour: pour, ..cles)
    }
  } else {
    reglages-regler(_R, pour: pour, reinitialiser: reinitialiser, ..cles)
  }
}
