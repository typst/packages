// reglages.typ (farfadet-crep) — registre de réglages du paquet, bâti sur le mécanisme du socle.
//
// UN registre « crep » (setrdcrep, seul setter du paquet) : clés /crep/ (globales) et /tcb/crep/ (locales),
// et les types crep, tccrep, frac, dembox, seyesfig, seyestab, tccheckbox, tccheckboxlist, crepbox,
// plus checkbox (clés /tikz/chkbox/ et /chkbox/) et tcbcheckbox (clés /tcbchkbox/ et clés
// tcolorbox de l'environnement), réglés eux aussi par `setrdcrep(pour: …)`.
// Les clés reprennent les options LaTeX (espaces → tirets). Les valeurs autrefois codées en dur du moteur
// (unité Seyès, épaisseurs, pastille du numéro…) sont des clés ajoutées, avec leur ancienne valeur en défaut.
// Couleurs par défaut = couleurs NOMMÉES de bfcours (`bf-nommee`), lues au rendu : `setbfcolors` les change.
//
// Les clés « tcolorbox » des boîtes (colback, boxrule, top…) valent `auto` dans les registres : `auto` veut
// dire « selon le style par défaut » (crep default style, tccrep default style, crep default seyes…).
// Ces styles par défaut sont des STYLES NOMMÉS du registre, redéfinissables (setrdcrep(definir: …)) :
//   valeurs du code < style par défaut < crep default seyes (si seyes) < crep opaq (si crep-opaq)
//   < réglage global < réglage du type (every-crep…) < styles locaux < clés locales < crep-box / tccrep-box.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *

#let _c = reglages-controles
#let _auto = (v => v == auto, "auto")
#let _rien = (v => v == none, "none")
#let _coul = reglages-ou(_c.couleur-ou-nom, _auto, _rien)
#let _long = reglages-ou(_c.longueur, _auto)
#let _long-none = reglages-ou(_c.longueur, _auto, _rien)
#let _nombre = reglages-ou(_c.nombre, _auto)
#let _bool = reglages-ou(_c.booleen, _auto)
#let _dico = (v => type(v) == dictionary, "un dictionnaire de clés, par exemple (colback: yellow)")
#let _dico-num = (
  v => type(v) == dictionary and v.values().all(x => type(x) == dictionary),
  "un dictionnaire indexé par le numéro de la boîte, par exemple (\"3\": (colback: yellow))",
)
#let _police = (
  v => v == auto or v == none or type(v) in (dictionary, str, function),
  "un dictionnaire (size:, weight:, style:, font:), une chaîne de commandes LaTeX (\"\\large\\bfseries\") ou une fonction",
)
#let _paire-couleurs = (
  v => type(v) in (color, str) or bf-est-nommee(v) or (
    type(v) == array and v.len() == 2 and v.all(x => type(x) in (color, str) or bf-est-nommee(x))
  ),
  "une couleur, ou un tableau de deux couleurs (lignes épaisses, lignes fines)",
)
#let _peinture = (
  v => v == none or v == auto or type(v) in (color, gradient, tiling, str, dictionary),
  "none, une couleur, un dégradé, un motif ou un dictionnaire (fill:, stroke:)",
)
#let _saut = (
  v => v == auto or type(v) in (int, float, length, relative),
  "un nombre (fois l'interligne) ou une longueur",
)
#let _halign = reglages-ou(reglages-choix("justify", "left", "center", "right", "flush left", "flush center", "flush right"), _auto)
#let _valign = reglages-ou(reglages-choix("top", "center", "bottom"), _auto)
#let _liste-num = (
  v => type(v) == int or (type(v) == array and v.all(x => type(x) == int)),
  "un numéro ou un tableau de numéros, par exemple (2, 3)",
)

// =====================================================================
// Registre « crep » : setrdcrep
// =====================================================================

/// Défauts communs (clés /crep/ de \setrdcrep) = ceux qu'impose bfcours (bfcours-use_rdexo_rdcrep.sty) :
/// \setrdcrep{seyes, correction=true, correction color=monrose, correction font=\large\bfseries}.
/// `correction-color` et `correction-font` valent `auto` : la zone suit alors les réglages du socle
/// (`setbfsocle(correction-color: …)`, par défaut la couleur nommée `monrose` et `\large\bfseries`),
/// comme les objets rd ; `setrdcrep(correction-color: …)` les remplace pour les zones de réponse et
/// recopie la valeur dans le socle (`_vers-socle`), comme le \setrdcrep de LaTeX.
#let crep-defauts-communs = (
  correction-color: auto,
  correction-font: auto,
  show-crep: true,
  seyes: true,
  seyes-colors: (bf-nommee("seyescol"), bf-nommee("seyescol")),
  dotfill-command: none,
  auto-factor: 2,
  // ajouts : valeurs codées en dur dans rdcrep, désormais réglables
  seyes-unit: 8mm, // \crep@seyesunit
  seyes-thick: ptl(1.128), // ligne épaisse (seyescolA)
  seyes-thin: ptl(0.564), // lignes fines (seyescolB)
  seyes-shift: ptl(0.564), // décalage des lignes sous leur repère
  seyes-subdivisions: 4, // une ligne épaisse puis 3 fines
  sans-font: ("Latin Modern Sans", "TeX Gyre Heros"), // \sffamily de bfcours
)

/// Clés de boîte (tcolorbox) communes à crep et tccrep : `auto` = selon le style par défaut.
#let _cles-boite = (
  colback: auto,
  colframe: auto,
  opacityback: auto,
  boxrule: auto,
  arc: auto,
  sharp-corners: auto,
  boxsep: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  frame-hidden: auto,
)

/// Défauts de la boîte « tcolorbox » de crepbox (tcolorbox : colframe=black!75!white, colback=white,
/// coltext=black, boxrule 0.7pt de crepboxstyle, arc=1mm).
#let crepbox-defauts = (
  lw: 0pt, // largeur de la zone d'étiquette ; 0pt : celle de l'étiquette + 2 × inner-left-sep
  inner-left-sep: 1em,
  left-align: "center",
  crep-style: (:),
  colback: white, // fond de l'étiquette
  colframe: xmix(xc.black, 75), // trait du cadre
  coltext: black, // couleur de l'étiquette
  fontupper: none, // police de l'étiquette
  boxrule: ptl(0.7),
  boxsep: ptl(2),
  arc: 1mm,
  opacityback: 1,
  opacityframe: 1,
)

/// Défauts de \checkbox (rdcheckbox).
#let checkbox-defauts = (
  width: 0.9em,
  color: black,
  opacity: 1,
  background-color: none,
  background-opacity: 1,
  background-style: none,
  checked: false,
  checked-corr: false,
  skin: "squareshadow",
  fill-style: none,
  check-mark: "mark1",
  mark-color: red,
  mark-overlay: true,
  mark-scale: 1,
  mark-opacity: 1,
  mark-style: none,
  mark-preaction: none,
  raise: 0pt,
)

#let checkbox-skins-noms = ("square", "squareshadow", "squarerounded", "squareshadowrounded", "circle", "circleshadowA", "circleshadowB")
#let checkbox-marks-noms = (
  ..range(1, 15).map(i => "mark" + str(i)),
  "square",
  "hollowsquare",
  "squarerounded",
  "hollowsquarerounded",
  "disc",
  "smalldisc",
  "hollowdisc",
)

/// Défauts de l'environnement tcbcheckbox (rdcheckbox).
#let tcbcheckbox-defauts = (
  xsep: ptl(3),
  ysep: ptl(3),
  sep: auto,
  checked-corr: false,
  checkbox-auto-color: false,
  checkbox: (:),
  colframe: black,
  colback: white,
  opacityback: 0,
  opacityframe: 1,
  valign: "center",
  halign: "center",
  boxsep: ptl(3),
  boxrule: ptl(0.7),
  arc: 0pt,
  top: 0pt,
  bottom: 0pt,
  left: 0pt,
  right: 0pt,
  width: 100%,
  height: auto,
)

#let crep-types = (
  crep: _cles-boite + (
    lines: auto, // lignes ajoutées (= \repline[n]) ; auto : extra-lines
    extra-lines: 0,
    dotfill: false,
    normal-crep: false,
    show-crep-num: false,
    crep-mode: "regular",
    forced-height: false,
    crep-opaq: false,
    bbox: none,
    crep-box: (:),
    title: none,
    tcblower: none,
    colbacklower: auto,
    opacitybacklower: auto,
    colbacktitle: auto,
    coltitle: auto,
    fonttitle: auto,
    middle: auto,
    width: auto,
    height: auto,
    halign: auto,
    halign-lower: auto,
    valign: auto,
    lefthand-width: auto,
    righthand-width: auto,
    sidebyside-gap: auto,
    bicolor: auto,
    before-skip: auto,
    after-skip: auto,
    // pastille du numéro (crep num style) : ajouts
    crep-num-veil: white.transparentize(20%),
    crep-num-fill: xmix(xc.black, 70),
    crep-num-color: white,
    crep-num-size: "tiny",
  ),
  tccrep: _cles-boite + (
    dotfill: false,
    normal-crep: false,
    show-crep-num: false,
    crep-align: "default",
    crep-opaq: false,
    bbox: none,
    tccrep-box: (:),
    maths: false,
    width: auto,
    crep-num-veil: white.transparentize(20%),
    crep-num-fill: xmix(xc.black, 70),
    crep-num-color: white,
    crep-num-size: "tiny",
  ),
  frac: (
    width: 0.7cm,
    crep-for: "both",
    crep-style: (:),
    crep-num-style: (:),
    crep-den-style: (:),
  ),
  dembox: (
    demskin: "regular",
    normal-dembox: false, // étiquette et traits en noir, quelle que soit la version 
    normal-crep: false,
    width: 100%,
    halign: "center",
    colback: black,
    opacityback: 0.05,
    colframe: auto, // auto : couleur de correction (noire avec normal-crep)
    coltext: auto, // idem
    coltitle: white,
    fonttitle: auto, // auto : sans, gras, scriptsize (tiny avec demskin: "fiche")
    boxrule: ptl(1),
    top: ptl(8),
    bottom: ptl(4),
    left: ptl(6),
    right: ptl(6),
    title-boxsep: ptl(2),
    tick-length: auto, // trait vertical en haut à gauche : 4 mm (regular), 6 mm (compact)
    corner-length: 4mm, // équerre en bas à droite
  ),
  seyesfig: (
    title: none,
    boxrule: ptl(1.128),
    colframe: auto, // seyescolA!90!black
    colback: auto, // seyescolB!10
    arc: 1mm,
    halign: "center",
    valign: "center",
    boxsep: ptl(2),
    top: ptl(4),
    bottom: ptl(4),
    left: 0pt,
    right: 0pt,
    lefttitle: 0pt,
    fonttitle: (weight: "bold"),
    width: 100%,
    height: auto,
  ),
  seyestab: (
    vlines: false,
    hlines: false,
    rules-width: ptl(0.4),
    rules-color: black,
    tabcolsep: ptl(6),
    arraycolsep: ptl(5),
    strut-height: 5mm,
    strut-depth: 3mm,
    largeur: none, // largeur du tableau (colonnes `X` : elles se partagent cette largeur) ; none : naturelle
    delims: none, // seyesarray : délimiteurs (gauche, droite) ; "." : aucun
  ),
  tccheckbox: (
    left-width: 1.5em,
    background: auto, // seyescolA!20
    check-color: auto, // couleur de correction
    check-mark: "mark2",
    mark-scale: 1,
    checked: false,
    checked-corr: false,
    on-line: false,
    colback: white,
    opacityback: 0,
    colframe: black,
    boxrule: ptl(0.5),
    arc: 1mm,
    boxsep: ptl(3),
    top: 0pt,
    bottom: 0pt,
    left: 0pt,
    right: 0pt,
    width: 100%,
    height: auto,
    halign: "left",
    valign: "center",
  ),
  tccheckboxlist: (
    columns: 0,
    col-skip: 2mm,
    row-skip: 2mm,
    checked: (),
    checked-corr: (),
    raster: (:),
    checkbox-style: (:),
    checked-style: (:),
    checkbox: (:),
  ),
  // \checkbox
  checkbox: checkbox-defauts,
  // environnement tcbcheckbox
  tcbcheckbox: tcbcheckbox-defauts,
  // \crepbox
  crepbox: crepbox-defauts,
)

#let crep-controles = (
  correction-color: reglages-ou(_c.couleur-ou-nom, _auto),
  correction-font: _police,
  show-crep: _c.booleen,
  seyes: _bool,
  seyes-colors: reglages-ou(_paire-couleurs, _auto),
  dotfill-command: _c.contenu-ou-none,
  auto-factor: _nombre,
  seyes-unit: _c.longueur,
  seyes-thick: _c.longueur,
  seyes-thin: _c.longueur,
  seyes-shift: _c.longueur,
  seyes-subdivisions: _c.entier,
  sans-font: (v => type(v) in (str, array), "un nom de police ou un tableau de noms"),
  colback: _coul,
  colframe: _coul,
  colbacklower: _coul,
  colbacktitle: _coul,
  coltitle: _coul,
  coltext: _coul,
  opacityback: _nombre,
  opacitybacklower: _nombre,
  boxrule: _long,
  arc: _long,
  sharp-corners: _bool,
  boxsep: _long,
  top: _long,
  bottom: _long,
  left: _long,
  right: _long,
  middle: _long,
  frame-hidden: _bool,
  lines: _nombre,
  extra-lines: _c.nombre,
  dotfill: _c.booleen,
  normal-crep: _c.booleen,
  show-crep-num: _c.booleen,
  crep-mode: reglages-choix("regular", "upper", "lower", "left", "right"),
  crep-align: reglages-choix("default", "center", "left", "right"),
  forced-height: _c.booleen,
  crep-opaq: _c.booleen,
  bbox: reglages-ou(_rien, (v => type(v) == array and v.len() == 2 and v.all(x => type(x) == length), "un tableau de deux longueurs (bas, haut)")),
  crep-box: _dico-num,
  tccrep-box: _dico-num,
  title: _c.contenu-ou-none,
  tcblower: _c.contenu-ou-none,
  fonttitle: _police,
  width: reglages-ou(_c.longueur, _auto),
  height: reglages-ou(_c.longueur, _auto),
  halign: _halign,
  halign-lower: _halign,
  valign: _valign,
  lefthand-width: _long,
  righthand-width: _long,
  sidebyside-gap: _long,
  bicolor: _bool,
  before-skip: _saut,
  after-skip: _saut,
  maths: _c.booleen,
  crep-num-veil: _c.couleur-ou-nom,
  crep-num-fill: _c.couleur-ou-nom,
  crep-num-color: _c.couleur-ou-nom,
  crep-num-size: reglages-ou(_c.texte, _c.longueur),
  crep-for: reglages-choix("both", "num", "den"),
  crep-style: _dico,
  crep-num-style: _dico,
  crep-den-style: _dico,
  demskin: reglages-choix("regular", "compact", "fiche"),
  normal-dembox: _c.booleen,
  title-boxsep: _c.longueur,
  tick-length: _long,
  corner-length: _c.longueur,
  lefttitle: _c.longueur,
  vlines: reglages-ou(_c.booleen, (v => type(v) == array, "un tableau de numéros de filets")),
  hlines: reglages-ou(_c.booleen, (v => type(v) == array, "un tableau de numéros de filets")),
  rules-width: _c.longueur,
  rules-color: _c.couleur-ou-nom,
  tabcolsep: _c.longueur,
  arraycolsep: _c.longueur,
  strut-height: _c.longueur,
  strut-depth: _c.longueur,
  largeur: reglages-ou(_rien, _c.longueur),
  delims: reglages-ou(_rien, (v => type(v) == array and v.len() == 2 and v.all(x => type(x) == str), "un tableau de deux chaînes (gauche, droite), par exemple (\"(\", \")\") ; \".\" : pas de délimiteur")),
  left-width: _c.longueur,
  background: _coul,
  check-color: _coul,
  check-mark: reglages-ou(reglages-choix(..checkbox-marks-noms), (v => type(v) == content, "un contenu")),
  mark-scale: _c.nombre,
  checked: reglages-ou(_c.booleen, _liste-num),
  checked-corr: reglages-ou(_c.booleen, _liste-num),
  on-line: _c.booleen,
  columns: _c.entier,
  col-skip: _c.longueur,
  row-skip: _c.longueur,
  raster: _dico,
  checkbox-style: _dico,
  checked-style: _dico,
  checkbox: reglages-ou(_dico-num, _dico),
  // rdcheckbox : \checkbox
  color: reglages-ou(_c.couleur-ou-nom, _rien),
  opacity: _c.nombre,
  background-color: reglages-ou(_c.couleur-ou-nom, _rien),
  background-opacity: _c.nombre,
  background-style: _peinture,
  skin: reglages-choix(..checkbox-skins-noms),
  fill-style: _peinture,
  mark-color: reglages-ou(_c.couleur-ou-nom, _rien),
  mark-overlay: _c.booleen,
  mark-opacity: _c.nombre,
  mark-style: _peinture,
  mark-preaction: reglages-ou(_rien, (v => type(v) in (stroke, length, color, dictionary), "un trait Typst (3pt + white)")),
  raise: _c.longueur,
  // rdcheckbox : tcbcheckbox
  xsep: _c.longueur,
  ysep: _c.longueur,
  sep: _long,
  checkbox-auto-color: _c.booleen,
  opacityframe: _nombre,
  // crepbox
  lw: _c.longueur,
  inner-left-sep: _c.longueur,
  left-align: reglages-choix("center", "left", "right"),
  fontupper: _police,
)

/// Styles nommés prédéfinis (styles tcolorbox de rdcrep.sty, redéfinissables par setrdcrep(definir: …)).
#let crep-styles-defaut = (
  "crep default style": (
    colback: xmix(xc.gray, 10),
    colframe: black,
    opacityback: 1,
    boxsep: ptl(7),
    top: 0pt,
    bottom: 0pt,
    left: 0pt,
    right: 0pt,
    middle: 0pt,
    sidebyside-gap: 0pt,
    boxrule: ptl(0.6),
    arc: 1mm,
    frame-hidden: false,
    halign: "justify",
    halign-lower: "justify",
    valign: "top",
    before-skip: 0.25,
    after-skip: 0.5,
    colbacktitle: xmix(xc.gray, 30),
    coltitle: black,
    fonttitle: (size: "large", weight: "bold"),
  ),
  "tccrep default style": (
    colback: xmix(xc.gray, 10),
    colframe: black,
    opacityback: 1,
    boxsep: ptl(5),
    top: 0pt,
    bottom: 0pt,
    left: 0pt,
    right: 0pt,
    arc: 0pt,
    frame-hidden: true,
    boxrule: 0pt,
  ),
  "crep default seyes": (
    frame-hidden: true,
    boxrule: 0pt,
    opacityback: 0,
    arc: 0pt,
    colback: white,
    top: 1mm,
  ),
  "crep opaq": (seyes: false, colback: black, opacityback: 0.15, normal-crep: false),
  "seyes upper": (seyes: true, crep-mode: "upper"),
  "seyes lower": (seyes: true, crep-mode: "lower"),
  "seyes left": (seyes: true, crep-mode: "left"),
  "seyes right": (seyes: true, crep-mode: "right"),
  "seyesrep style": (
    seyes: true,
    crep-mode: "lower",
    top: 0pt,
    middle: 0.5mm,
    boxrule: ptl(0.7),
    frame-hidden: false,
    arc: 1.5mm,
    halign: "center",
    valign: "center",
    halign-lower: "center",
    bottom: 1mm,
  ),
  "assosbox common style": (bicolor: true, frame-hidden: false, boxrule: ptl(0.7), arc: 1mm, colframe: black),
)

/// Registre « crep » (état « bfr-crep ») ; ses styles nommés partent des styles prédéfinis
/// (`setrdcrep(reinitialiser: "tout")` y revient).
#let registre-crep = reglages-paquet(
  "crep",
  crep-defauts-communs,
  controles: crep-controles,
  types: crep-types,
  commande: "setrdcrep",
  styles: crep-styles-defaut,
)

/// Préréglage « rd » : les défauts d'origine de rdcrep (\setrdcrep{default}).
#let crep-preset-rd = (
  correction-color: red,
  correction-font: (weight: "bold"),
  show-crep: true,
  dotfill-command: none,
  seyes: false,
)

/// Couleur et police des corrections d'une zone : la valeur de `r` (réglages résolus de crep), ou celle
/// du socle quand elle vaut `auto` (défaut). Renvoie (couleur: …, police: …). À appeler dans un `context`.
#let crep-correction(r) = {
  let s = reglages-courants(bf-reglages-socle)
  let couleur = r.at("correction-color", default: auto)
  let police = r.at("correction-font", default: auto)
  (
    couleur: if couleur == auto { s.correction-color } else { couleur },
    police: if police == auto { s.correction-font } else { police },
  )
}

/// Style nommé `nom` tel qu'il est défini à cet endroit (à appeler dans un `context`).
#let crep-style(nom) = bf-lire(registre-crep).styles.at(nom, default: crep-styles-defaut.at(nom, default: (:)))

/// Valeurs effectives d'une boîte (à appeler dans un `context`).
/// `pour` : type ; `local` : clés locales (dictionnaire) ; `style-defaut` : nom du style par défaut ;
/// `numero` et `cle-numero` : style par numéro d'instance (crep-box, tccrep-box).
#let crep-resoudre(pour, local, commande: auto, style-defaut: none, numero: none, cle-numero: none) = {
  let res = reglages-resoudre(registre-crep, pour: pour, local: local, commande: commande)
  // style par numéro d'instance (appliqué après les options locales, comme en LaTeX)
  // `numero` : valeur, ou fonction qui la lit (compteur), appelée seulement si un style par numéro existe
  if cle-numero != none and numero != none and res.at(cle-numero, default: (:)).len() > 0 {
    let numero = if type(numero) == function { numero() } else { numero }
    let n = res.at(cle-numero, default: (:)).at(str(numero), default: none)
    if n != none {
      reglages-verifier(if commande == auto { pour } else { commande }, n, registre-crep.controles)
      for (k, v) in n { if v != auto { res.insert(k, v) } }
    }
  }
  // seyes, crep opaq : décidés avant l'empilement des styles par défaut
  let opaq = res.at("crep-opaq", default: false)
  let seyes = if opaq { false } else { res.at("seyes", default: false) }
  let base = if style-defaut == none { (:) } else { crep-style(style-defaut) }
  if seyes and style-defaut in ("crep default style", "tccrep default style") { base += crep-style("crep default seyes") }
  if opaq { base += crep-style("crep opaq") }
  for (k, v) in res { if v != auto or k not in base { base.insert(k, v) } }
  base.seyes = seyes
  if opaq { base.normal-crep = false }
  base
}
